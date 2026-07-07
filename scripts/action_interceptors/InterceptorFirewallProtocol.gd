# 监听玩家打出融合卡，然后触发防火墙协议的状态效果动作
extends BaseActionInterceptor

const FIREWALL_STATUS_EFFECT_ID: String = "status_effect_firewall_protocol"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	if preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var player_combatant: BaseCombatant = action_interceptor_processor.parent_action.parent_combatant
	if player_combatant == null:
		return ACTION_ACCEPTENCES.REJECTED
	if not player_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED
	
	var card_play_request: CardPlayRequest = action_interceptor_processor.parent_action.card_play_request
	if card_play_request == null or card_play_request.card_data == null:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var card_data: CardData = card_play_request.card_data
	
	# 如果打出的不是融合卡，直接跳过
	if card_data.object_id != "card_forge_fusion":
		return ACTION_ACCEPTENCES.CONTINUE
	
	# 避免多重触发：
	# HandManager 的 ACTION_CARD_PLAY 会对 [null] 以及所有存活敌人分别跑一遍拦截器链。
	# 因为防火墙挂在玩家（发起者）身上，如果不加这个判断，场上有多少个敌人就会额外触发多少次！
	if action_interceptor_processor.target != null:
		return ACTION_ACCEPTENCES.CONTINUE
		
	# 获取玩家身上的防火墙状态
	var statuses: Array[StatusEffect] = player_combatant.status_id_to_status_effects.get(FIREWALL_STATUS_EFFECT_ID, [])
	if len(statuses) == 0:
		return ACTION_ACCEPTENCES.CONTINUE
		
	var status_effect_script: BaseStatusEffect = statuses[0].status_effect_script
	
	# 核心！原架构师的神级钩子：调用状态自带的玩家动作
	# 这会自动将状态层数作为 custom_key_names 传入到动作中
	status_effect_script.perform_status_effect_actions()
				
	return ACTION_ACCEPTENCES.CONTINUE
