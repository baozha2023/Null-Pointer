extends Node
class_name PlatformManager

var api_port: String = ""
var token: String = ""
var player_id: String = ""
var player_name: String = ""
var is_host: bool = false

var ws: WebSocketPeer = WebSocketPeer.new()
var is_connected_to_platform: bool = false
var is_authenticated: bool = false
var _pending_requests: Dictionary = {}

signal platform_connected
signal platform_authenticated
signal platform_disconnected
signal platform_event_received(event_data)

func _ready() -> void:
	api_port = OS.get_environment("BZ_API_PORT")
	token = OS.get_environment("BZ_API_TOKEN")
	player_id = OS.get_environment("BZ_PLAYER_ID")
	player_name = OS.get_environment("BZ_PLAYER_NAME")
	is_host = OS.get_environment("BZ_IS_HOST") == "1"
	
	if api_port == "" or token == "":
		DebugLogger.log_line("Platform: 未检测到 BZ-Games 平台环境，运行在离线模式 (Offline Mode)。")
		set_process(false)
		if GameConfig.REQUIRE_BZ_GAMES_LAUNCH:
			call_deferred("_show_require_bz_games_screen")
		return
		
	var url: String = "ws://127.0.0.1:" + api_port
	var err: Error = ws.connect_to_url(url)
	if err != OK:
		DebugLogger.log_error("Platform: 连接本地 BZ-Games WebSocket 失败。")
		set_process(false)
		return
	
	DebugLogger.log_line("Platform: 正在连接 BZ-Games (URL: %s)" % url)
	set_process(true)

func _process(_delta: float) -> void:
	if api_port == "":
		return
		
	ws.poll()
	var state: WebSocketPeer.State = ws.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		if not is_connected_to_platform:
			is_connected_to_platform = true
			_on_connected()
			
		while ws.get_available_packet_count() > 0:
			var packet: PackedByteArray = ws.get_packet()
			var text: String = packet.get_string_from_utf8()
			if text != "":
				var json: JSON = JSON.new()
				if json.parse(text) == OK:
					if typeof(json.data) == TYPE_DICTIONARY:
						_handle_message(json.data)
					
	elif state == WebSocketPeer.STATE_CLOSED:
		if is_connected_to_platform:
			is_connected_to_platform = false
			is_authenticated = false
			platform_disconnected.emit()
			DebugLogger.log_line("Platform: WebSocket 连接已关闭。")
			set_process(false)

func _on_connected() -> void:
	platform_connected.emit()
	DebugLogger.log_line("Platform: WebSocket 连接成功，正在鉴权...")
	# Auth immediately using v2 protocol
	send_request("auth", {"token": token, "protocolVersion": 2}, Callable(self, "_on_auth_response"))

func _on_auth_response(payload: Dictionary, error: Dictionary) -> void:
	if error.size() > 0:
		is_authenticated = false
		DebugLogger.log_error("Platform: 鉴权失败: %s" % JSON.stringify(error))
		if GameConfig.REQUIRE_BZ_GAMES_LAUNCH:
			_show_require_bz_games_screen()
		return
		
	var p_data: Dictionary = payload.get("player", {})
	is_authenticated = true
	DebugLogger.log_line("Platform: 鉴权成功！当前玩家: %s" % p_data.get("name", "Unknown"))
	
	# Notify platform that the game client is fully loaded and ready
	send_request("game.ready", {})
	platform_authenticated.emit()

func send_request(action: String, payload: Dictionary, callback: Callable = Callable()) -> void:
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
		
	var request_id: String = _generate_uuid()
	
	if callback.is_valid():
		_pending_requests[request_id] = callback
		
	var msg: Dictionary = {
		"id": request_id,
		"type": "request",
		"action": action,
		"payload": payload
	}
	
	ws.send_text(JSON.stringify(msg))

func _handle_message(msg: Dictionary) -> void:
	var type: String = msg.get("type", "")
	
	if type == "response":
		var id: String = msg.get("id", "")
		if _pending_requests.has(id):
			var callback: Callable = _pending_requests[id]
			_pending_requests.erase(id)
			
			var error = msg.get("error", null)
			var error_dict: Dictionary = {}
			if error != null:
				if typeof(error) == TYPE_STRING:
					error_dict = {"message": error}
				elif typeof(error) == TYPE_DICTIONARY:
					error_dict = error
					
			var payload = msg.get("payload", {})
			if typeof(payload) != TYPE_DICTIONARY:
				payload = {}
				
			callback.call(payload, error_dict)
			
	elif type == "event":
		platform_event_received.emit(msg)

func _generate_uuid() -> String:
	# Simple random ID generator suitable for request tracking
	return str(Time.get_ticks_msec()) + "-" + str(randi())

# -----------------
# 平台高级 API 封装
# -----------------

## 解锁成就
func unlock_achievement(achievement_id: String, callback: Callable = Callable()) -> void:
	if not is_authenticated:
		return
	send_request("achievement.unlock", {"achievementId": achievement_id}, callback)

## 提报统计数据（例如: {"gamesPlayed": 1, "gamesWon": 1}）
func report_stats(stats: Dictionary) -> void:
	if not is_connected_to_platform: return
	send_request("stats.report", stats)

func _show_require_bz_games_screen() -> void:
	get_tree().change_scene_to_file("res://scenes/RequireBZGames.tscn")
