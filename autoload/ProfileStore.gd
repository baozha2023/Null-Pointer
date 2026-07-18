## Sole persistence and query interface for cross-run profile data.
extends Node

enum WriteResult {
	FAILED,
	UNCHANGED,
	INSERTED,
}

const DATABASE_VERSION: int = 1
const DATABASE_FILE_NAME: String = "profile.sqlite3"

var _db: SQLite = null
var _database_ready: bool = false
var _profile_summary: ProfileSummaryData = ProfileSummaryData.new()
var _character_id_to_stats: Dictionary[String, CharacterProfileStatsData] = {}
var _discovered_card_ids: Dictionary[String, bool] = {}
var _achievement_states: Dictionary[String, AchievementStateData] = {}


func _ready() -> void:
	if not _open_database() or not _initialize_database() or not _load_caches():
		_abort_startup()


func _exit_tree() -> void:
	if _db != null:
		_db.close_db()
		_db = null
	_database_ready = false


func _open_database() -> bool:
	var database_path: String = _get_database_path()
	var absolute_directory: String = ProjectSettings.globalize_path(database_path).get_base_dir()
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return _report_error("Cannot create profile database directory: %s" % absolute_directory)

	_db = SQLite.new()
	_db.path = database_path
	_db.foreign_keys = true
	_db.verbosity_level = SQLite.QUIET
	if not _db.open_db():
		return _report_error("Cannot open profile database %s: %s" % [database_path, _db.error_message])
	return true


func _get_database_path() -> String:
	if not OS.has_feature("exported"):
		return "res://external/%s" % DATABASE_FILE_NAME
	if OS.has_feature("mobile") or OS.has_feature("web") or OS.has_feature("macos"):
		return "user://%s" % DATABASE_FILE_NAME
	return OS.get_executable_path().get_base_dir().path_join("external").path_join(DATABASE_FILE_NAME)


func _initialize_database() -> bool:
	if not _execute("PRAGMA foreign_keys = ON;"):
		return false
	if not _execute("PRAGMA synchronous = NORMAL;"):
		return false
	if not OS.has_feature("web") and not _execute("PRAGMA journal_mode = WAL;"):
		return false
	if not _execute("PRAGMA user_version;") or _db.query_result.is_empty():
		return false

	var database_version: int = int(_db.query_result[0].get("user_version", 0))
	if database_version != 0 and database_version != DATABASE_VERSION:
		return _report_error(
			"Unsupported profile database version %d. Delete %s and restart."
			% [database_version, _get_database_path()],
		)
	if database_version == DATABASE_VERSION:
		_database_ready = true
		return true

	if not _execute("BEGIN IMMEDIATE;"):
		return false
	for statement: String in _get_schema_statements():
		if not _execute(statement):
			_execute("ROLLBACK;")
			return false
	if not _execute("INSERT INTO profile_summary (id) VALUES (1);"):
		_execute("ROLLBACK;")
		return false
	if not _execute("PRAGMA user_version = %d;" % DATABASE_VERSION):
		_execute("ROLLBACK;")
		return false
	if not _execute("COMMIT;"):
		_execute("ROLLBACK;")
		return false
	_database_ready = true
	return true


func _get_schema_statements() -> Array[String]:
	return [
		"""CREATE TABLE profile_summary (
			id INTEGER PRIMARY KEY CHECK (id = 1),
			profile_name TEXT NOT NULL DEFAULT '',
			total_wins INTEGER NOT NULL DEFAULT 0,
			total_losses INTEGER NOT NULL DEFAULT 0,
			total_run_time REAL NOT NULL DEFAULT 0,
			fastest_win_run_time REAL NOT NULL DEFAULT 0,
			current_win_streak INTEGER NOT NULL DEFAULT 0,
			current_loss_streak INTEGER NOT NULL DEFAULT 0,
			highest_win_streak INTEGER NOT NULL DEFAULT 0,
			highest_loss_streak INTEGER NOT NULL DEFAULT 0
		);""",
		"""CREATE TABLE character_profile_stats (
			character_id TEXT PRIMARY KEY,
			wins INTEGER NOT NULL DEFAULT 0,
			losses INTEGER NOT NULL DEFAULT 0,
			current_win_streak INTEGER NOT NULL DEFAULT 0,
			highest_win_streak INTEGER NOT NULL DEFAULT 0,
			current_loss_streak INTEGER NOT NULL DEFAULT 0,
			highest_loss_streak INTEGER NOT NULL DEFAULT 0,
			highest_difficulty INTEGER NOT NULL DEFAULT -1,
			fastest_win_run_time REAL NOT NULL DEFAULT 0,
			total_run_time REAL NOT NULL DEFAULT 0
		);""",
		"CREATE TABLE discovered_cards (card_id TEXT PRIMARY KEY);",
		"""CREATE TABLE achievement_states (
			achievement_id TEXT PRIMARY KEY,
			current_value REAL NOT NULL DEFAULT 0,
			latest_value REAL NOT NULL DEFAULT 0,
			best_value REAL NOT NULL DEFAULT 0,
			update_count INTEGER NOT NULL DEFAULT 0,
			scope_update_count INTEGER NOT NULL DEFAULT 0,
			scope_key TEXT NOT NULL DEFAULT '',
			updated_at INTEGER NOT NULL DEFAULT 0,
			unlocked_at INTEGER
		);""",
		"CREATE TABLE achievement_unique_values (achievement_id TEXT NOT NULL, scope_key TEXT NOT NULL, value_key TEXT NOT NULL, PRIMARY KEY (achievement_id, scope_key, value_key));",
		"""CREATE TABLE achievement_recent_values (
			sample_id INTEGER PRIMARY KEY AUTOINCREMENT,
			achievement_id TEXT NOT NULL,
			value REAL NOT NULL,
			recorded_at INTEGER NOT NULL,
			scope_key TEXT NOT NULL DEFAULT '',
			context_json TEXT NOT NULL DEFAULT '{}'
		);""",
		"CREATE INDEX achievement_recent_values_index ON achievement_recent_values (achievement_id, sample_id DESC);",
		"""CREATE TABLE runs (
			run_id INTEGER PRIMARY KEY AUTOINCREMENT,
			seed INTEGER NOT NULL,
			character_id TEXT NOT NULL,
			difficulty_level INTEGER NOT NULL,
			player_health INTEGER NOT NULL,
			player_health_max INTEGER NOT NULL,
			player_money INTEGER NOT NULL,
			consumable_slot_count INTEGER NOT NULL,
			victory INTEGER NOT NULL CHECK (victory IN (0, 1)),
			floor INTEGER NOT NULL,
			defeat_event_id TEXT NOT NULL DEFAULT '',
			is_detailed INTEGER NOT NULL CHECK (is_detailed IN (0, 1)),
			completion_time REAL NOT NULL,
			completion_timestamp INTEGER NOT NULL
		);""",
		"CREATE INDEX runs_completion_index ON runs (completion_timestamp DESC, run_id DESC);",
		"CREATE TABLE run_modifiers (run_id INTEGER NOT NULL REFERENCES runs(run_id) ON DELETE CASCADE, ordinal INTEGER NOT NULL, modifier_id TEXT NOT NULL, PRIMARY KEY (run_id, ordinal));",
		"CREATE TABLE run_deck (run_id INTEGER NOT NULL REFERENCES runs(run_id) ON DELETE CASCADE, ordinal INTEGER NOT NULL, card_id TEXT NOT NULL, upgrade_amount INTEGER NOT NULL, PRIMARY KEY (run_id, ordinal));",
		"CREATE TABLE run_artifacts (run_id INTEGER NOT NULL REFERENCES runs(run_id) ON DELETE CASCADE, ordinal INTEGER NOT NULL, artifact_id TEXT NOT NULL, PRIMARY KEY (run_id, ordinal));",
		"CREATE TABLE run_consumables (run_id INTEGER NOT NULL REFERENCES runs(run_id) ON DELETE CASCADE, ordinal INTEGER NOT NULL, consumable_id TEXT NOT NULL, PRIMARY KEY (run_id, ordinal));",
		"CREATE TABLE run_stats (run_id INTEGER NOT NULL REFERENCES runs(run_id) ON DELETE CASCADE, stat_name TEXT NOT NULL, stat_value INTEGER NOT NULL, PRIMARY KEY (run_id, stat_name));",
		"""CREATE TABLE combats (
			combat_id INTEGER PRIMARY KEY AUTOINCREMENT,
			run_id INTEGER NOT NULL REFERENCES runs(run_id) ON DELETE CASCADE,
			ordinal INTEGER NOT NULL,
			event_object_id TEXT NOT NULL,
			combat_floor INTEGER NOT NULL,
			turn_count INTEGER NOT NULL,
			UNIQUE (run_id, ordinal)
		);""",
		"CREATE TABLE combat_total_stats (combat_id INTEGER NOT NULL REFERENCES combats(combat_id) ON DELETE CASCADE, stat_name TEXT NOT NULL, stat_value INTEGER NOT NULL, PRIMARY KEY (combat_id, stat_name));",
		"CREATE TABLE combat_current_turn_stats (combat_id INTEGER NOT NULL REFERENCES combats(combat_id) ON DELETE CASCADE, stat_name TEXT NOT NULL, stat_value INTEGER NOT NULL, PRIMARY KEY (combat_id, stat_name));",
		"CREATE TABLE combat_turns (combat_id INTEGER NOT NULL REFERENCES combats(combat_id) ON DELETE CASCADE, turn_ordinal INTEGER NOT NULL, PRIMARY KEY (combat_id, turn_ordinal));",
		"CREATE TABLE combat_turn_history_stats (combat_id INTEGER NOT NULL REFERENCES combats(combat_id) ON DELETE CASCADE, turn_ordinal INTEGER NOT NULL, stat_name TEXT NOT NULL, stat_value INTEGER NOT NULL, PRIMARY KEY (combat_id, turn_ordinal, stat_name), FOREIGN KEY (combat_id, turn_ordinal) REFERENCES combat_turns(combat_id, turn_ordinal) ON DELETE CASCADE);",
	]


func _load_caches() -> bool:
	if not _database_ready:
		return false
	if not _execute("SELECT * FROM profile_summary WHERE id = 1;") or _db.query_result.is_empty():
		return false
	_profile_summary = _profile_summary_from_row(_db.query_result[0])

	_character_id_to_stats.clear()
	if not _execute("SELECT * FROM character_profile_stats;"):
		return false
	for row: Dictionary in _db.query_result:
		var character_stats: CharacterProfileStatsData = _character_stats_from_row(row)
		_character_id_to_stats[character_stats.character_id] = character_stats

	_discovered_card_ids.clear()
	if not _execute("SELECT card_id FROM discovered_cards;"):
		return false
	for row: Dictionary in _db.query_result:
		_discovered_card_ids[str(row.get("card_id", ""))] = true

	_achievement_states.clear()
	if not _execute("SELECT * FROM achievement_states;"):
		return false
	for row: Dictionary in _db.query_result:
		var achievement_state: AchievementStateData = _achievement_state_from_row(row)
		_achievement_states[achievement_state.achievement_id] = achievement_state
	return true


func get_profile_summary() -> ProfileSummaryData:
	return _profile_summary.duplicate_data()


func get_character_stats(character_id: String) -> CharacterProfileStatsData:
	if _character_id_to_stats.has(character_id):
		return _character_id_to_stats[character_id].duplicate_data()
	var result := CharacterProfileStatsData.new()
	result.character_id = character_id
	return result


func set_profile_name(profile_name: String) -> bool:
	if not _database_ready:
		return false
	if not _execute("UPDATE profile_summary SET profile_name = ? WHERE id = 1;", [profile_name]):
		return false
	_profile_summary.profile_name = profile_name
	return true


func discover_card(card_id: String) -> WriteResult:
	if card_id == "" or not _database_ready:
		return WriteResult.FAILED
	if _discovered_card_ids.has(card_id):
		return WriteResult.UNCHANGED
	if not _execute("INSERT OR IGNORE INTO discovered_cards (card_id) VALUES (?);", [card_id]):
		return WriteResult.FAILED
	if _get_changed_row_count() == 0:
		return WriteResult.UNCHANGED
	_discovered_card_ids[card_id] = true
	return WriteResult.INSERTED


func is_card_discovered(card_id: String) -> bool:
	return _discovered_card_ids.has(card_id)


func get_achievement_state(achievement_id: String) -> AchievementStateData:
	if _achievement_states.has(achievement_id):
		return _achievement_states[achievement_id].duplicate_data()
	var result := AchievementStateData.new()
	result.achievement_id = achievement_id
	return result


func is_achievement_unlocked(achievement_id: String) -> bool:
	return _achievement_states.has(achievement_id) and _achievement_states[achievement_id].unlocked_at > 0


func get_unlock_timestamp(achievement_id: String) -> int:
	if not _achievement_states.has(achievement_id):
		return 0
	return _achievement_states[achievement_id].unlocked_at


func get_unlocked_achievement_timestamps() -> Dictionary[String, int]:
	var result: Dictionary[String, int] = {}
	for achievement_id: String in _achievement_states:
		var state: AchievementStateData = _achievement_states[achievement_id]
		if state.unlocked_at > 0:
			result[achievement_id] = state.unlocked_at
	return result


func unlock_achievement(achievement_id: String, timestamp: int) -> WriteResult:
	if achievement_id == "" or not _database_ready:
		return WriteResult.FAILED
	if is_achievement_unlocked(achievement_id):
		return WriteResult.UNCHANGED
	if not _execute("BEGIN IMMEDIATE;"):
		return WriteResult.FAILED
	if not _execute(
		"""INSERT INTO achievement_states (achievement_id, updated_at, unlocked_at)
		VALUES (?, ?, ?) ON CONFLICT(achievement_id) DO UPDATE SET
		updated_at = excluded.updated_at, unlocked_at = excluded.unlocked_at;""",
		[achievement_id, timestamp, timestamp],
	):
		_execute("ROLLBACK;")
		return WriteResult.FAILED
	if not _execute("COMMIT;"):
		_execute("ROLLBACK;")
		return WriteResult.FAILED
	var state: AchievementStateData = get_achievement_state(achievement_id)
	state.updated_at = timestamp
	state.unlocked_at = timestamp
	_achievement_states[achievement_id] = state
	return WriteResult.INSERTED


func reset_achievement_scope(achievement_id: String, scope_key: String) -> bool:
	if achievement_id == "" or not _database_ready:
		return false
	if not _achievement_states.has(achievement_id):
		return true
	var state: AchievementStateData = get_achievement_state(achievement_id)
	if state.scope_key == scope_key:
		return true
	state.current_value = 0.0
	state.scope_update_count = 0
	state.scope_key = scope_key
	state.updated_at = int(Time.get_unix_time_from_system())
	if not _execute("BEGIN IMMEDIATE;"):
		return false
	if not _write_achievement_state(state, false):
		_execute("ROLLBACK;")
		return false
	# Scoped UNIQUE_COUNT values are irrelevant after their run/combat/turn ends.
	# Processed event keys remain global so replayed native events stay idempotent.
	if not _execute(
		"DELETE FROM achievement_unique_values WHERE achievement_id = ? AND scope_key != ? AND scope_key != '__processed_events__';",
		[achievement_id, scope_key],
	):
		_execute("ROLLBACK;")
		return false
	if not _execute("COMMIT;"):
		_execute("ROLLBACK;")
		return false
	_achievement_states[achievement_id] = state
	return true


## Atomically applies one event sample, recent-history retention, and optional unlock.
func apply_achievement_update(
	achievement_id: String,
	candidate_value: float,
	aggregation: int,
	scope_key: String,
	target_value: float,
	comparison: int,
	recent_history_limit: int,
	context: Dictionary[String, Variant],
	unique_value: String = "",
	event_key: String = "",
) -> AchievementStateData:
	if achievement_id == "" or not _database_ready:
		return null
	var old_state: AchievementStateData = get_achievement_state(achievement_id)
	var next_state: AchievementStateData = old_state.duplicate_data()
	var scope_changed: bool = next_state.scope_key != scope_key
	if scope_changed:
		next_state.current_value = 0.0
		next_state.scope_update_count = 0
		next_state.scope_key = scope_key
	var is_first_scope_value: bool = next_state.scope_update_count == 0
	var timestamp: int = int(Time.get_unix_time_from_system())

	if not _execute("BEGIN IMMEDIATE;"):
		return null
	if event_key != "":
		if not _execute(
			"INSERT OR IGNORE INTO achievement_unique_values (achievement_id, scope_key, value_key) VALUES (?, ?, ?);",
			[achievement_id, "__processed_events__", event_key],
		):
			_execute("ROLLBACK;")
			return null
		if _get_changed_row_count() == 0:
			_execute("ROLLBACK;")
			return old_state
	if aggregation == AchievementProgressData.AGGREGATIONS.UNIQUE_COUNT:
		if unique_value == "":
			_execute("ROLLBACK;")
			return null
		if not _execute(
			"INSERT OR IGNORE INTO achievement_unique_values (achievement_id, scope_key, value_key) VALUES (?, ?, ?);",
			[achievement_id, scope_key, unique_value],
		):
			_execute("ROLLBACK;")
			return null
		if _get_changed_row_count() == 0:
			_execute("ROLLBACK;")
			return old_state
		if not _execute("SELECT COUNT(*) AS value_count FROM achievement_unique_values WHERE achievement_id = ? AND scope_key = ?;", [achievement_id, scope_key]):
			_execute("ROLLBACK;")
			return null
		next_state.current_value = float(_db.query_result[0].get("value_count", 0))
	else:
		match aggregation:
			AchievementProgressData.AGGREGATIONS.COUNT:
				next_state.current_value += 1.0
			AchievementProgressData.AGGREGATIONS.SUM:
				next_state.current_value += candidate_value
			AchievementProgressData.AGGREGATIONS.LATEST:
				next_state.current_value = candidate_value
			AchievementProgressData.AGGREGATIONS.MAXIMUM:
				next_state.current_value = candidate_value if is_first_scope_value else max(next_state.current_value, candidate_value)
			AchievementProgressData.AGGREGATIONS.MINIMUM:
				next_state.current_value = candidate_value if is_first_scope_value else min(next_state.current_value, candidate_value)

	next_state.latest_value = candidate_value
	next_state.update_count += 1
	next_state.scope_update_count += 1
	next_state.updated_at = timestamp
	if old_state.update_count == 0:
		next_state.best_value = next_state.current_value
	elif comparison == AchievementProgressData.COMPARISONS.LESS_OR_EQUAL:
		next_state.best_value = min(old_state.best_value, next_state.current_value)
	elif comparison == AchievementProgressData.COMPARISONS.EQUAL:
		if abs(next_state.current_value - target_value) < abs(old_state.best_value - target_value):
			next_state.best_value = next_state.current_value
	else:
		next_state.best_value = max(old_state.best_value, next_state.current_value)
	if next_state.unlocked_at <= 0 and _achievement_target_reached(next_state.current_value, target_value, comparison):
		next_state.unlocked_at = timestamp

	if not _write_achievement_state(next_state, false):
		_execute("ROLLBACK;")
		return null
	if recent_history_limit > 0:
		if not _execute(
			"INSERT INTO achievement_recent_values (achievement_id, value, recorded_at, scope_key, context_json) VALUES (?, ?, ?, ?, ?);",
			[achievement_id, candidate_value, timestamp, scope_key, JSON.stringify(context)],
		):
			_execute("ROLLBACK;")
			return null
		if not _execute(
			"""DELETE FROM achievement_recent_values WHERE sample_id IN (
				SELECT sample_id FROM achievement_recent_values WHERE achievement_id = ?
				ORDER BY sample_id DESC LIMIT -1 OFFSET ?
			);""",
			[achievement_id, recent_history_limit],
		):
			_execute("ROLLBACK;")
			return null
	if not _execute("COMMIT;"):
		_execute("ROLLBACK;")
		return null
	_achievement_states[achievement_id] = next_state
	return next_state.duplicate_data()


func get_achievement_recent_values(achievement_id: String, limit: int = 5) -> Array[AchievementRecentValueData]:
	var result: Array[AchievementRecentValueData] = []
	if limit <= 0 or not _database_ready:
		return result
	if not _execute(
		"SELECT value, recorded_at, scope_key, context_json FROM achievement_recent_values WHERE achievement_id = ? ORDER BY sample_id DESC LIMIT ?;",
		[achievement_id, limit],
	):
		return result
	for row: Dictionary in _db.query_result:
		var sample := AchievementRecentValueData.new()
		sample.value = float(row.get("value", 0.0))
		sample.recorded_at = int(row.get("recorded_at", 0))
		sample.scope_key = str(row.get("scope_key", ""))
		var parsed_context: Variant = JSON.parse_string(str(row.get("context_json", "{}")))
		if parsed_context is Dictionary:
			sample.context.assign(parsed_context)
		result.append(sample)
	return result


func _achievement_target_reached(current_value: float, target_value: float, comparison: int) -> bool:
	match comparison:
		AchievementProgressData.COMPARISONS.LESS_OR_EQUAL:
			return current_value <= target_value
		AchievementProgressData.COMPARISONS.EQUAL:
			return is_equal_approx(current_value, target_value)
		_:
			return current_value >= target_value


func _write_achievement_state(state: AchievementStateData, own_transaction: bool = true) -> bool:
	if own_transaction and not _execute("BEGIN IMMEDIATE;"):
		return false
	var unlocked_binding: Variant = state.unlocked_at if state.unlocked_at > 0 else null
	var succeeded: bool = _execute(
		"""INSERT INTO achievement_states (
			achievement_id, current_value, latest_value, best_value, update_count,
			scope_update_count, scope_key, updated_at, unlocked_at
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT(achievement_id) DO UPDATE SET
			current_value = excluded.current_value, latest_value = excluded.latest_value,
			best_value = excluded.best_value, update_count = excluded.update_count,
			scope_update_count = excluded.scope_update_count, scope_key = excluded.scope_key,
			updated_at = excluded.updated_at,
			unlocked_at = COALESCE(achievement_states.unlocked_at, excluded.unlocked_at);""",
		[
			state.achievement_id, state.current_value, state.latest_value, state.best_value,
			state.update_count, state.scope_update_count, state.scope_key, state.updated_at,
			unlocked_binding,
		],
	)
	if own_transaction:
		if succeeded:
			succeeded = _execute("COMMIT;")
		else:
			_execute("ROLLBACK;")
	return succeeded


func record_completed_run(run_stats: RunStatsData) -> bool:
	if run_stats == null or run_stats.run_character_id == "" or not _database_ready:
		return false

	var next_summary: ProfileSummaryData = _profile_summary.duplicate_data()
	var next_character: CharacterProfileStatsData = get_character_stats(run_stats.run_character_id)
	_update_aggregate_snapshots(next_summary, next_character, run_stats)

	if not _execute("BEGIN IMMEDIATE;"):
		return false
	if not _insert_run_graph(run_stats):
		_execute("ROLLBACK;")
		return false
	if not _write_aggregate_snapshots(next_summary, next_character):
		_execute("ROLLBACK;")
		return false
	if not _execute("COMMIT;"):
		_execute("ROLLBACK;")
		return false

	_profile_summary = next_summary
	_character_id_to_stats[next_character.character_id] = next_character
	return true


func _update_aggregate_snapshots(
	profile: ProfileSummaryData,
	character: CharacterProfileStatsData,
	run_stats: RunStatsData,
) -> void:
	profile.total_run_time += run_stats.run_completion_time
	character.total_run_time += run_stats.run_completion_time
	if run_stats.run_victory:
		profile.total_wins += 1
		profile.current_win_streak += 1
		profile.current_loss_streak = 0
		profile.highest_win_streak = max(profile.highest_win_streak, profile.current_win_streak)
		if profile.fastest_win_run_time <= 0.0:
			profile.fastest_win_run_time = run_stats.run_completion_time
		else:
			profile.fastest_win_run_time = min(profile.fastest_win_run_time, run_stats.run_completion_time)

		character.wins += 1
		character.current_win_streak += 1
		character.current_loss_streak = 0
		character.highest_win_streak = max(character.highest_win_streak, character.current_win_streak)
		character.highest_difficulty = max(character.highest_difficulty, run_stats.run_difficulty_level)
		if character.fastest_win_run_time <= 0.0:
			character.fastest_win_run_time = run_stats.run_completion_time
		else:
			character.fastest_win_run_time = min(character.fastest_win_run_time, run_stats.run_completion_time)
	else:
		profile.total_losses += 1
		profile.current_loss_streak += 1
		profile.current_win_streak = 0
		profile.highest_loss_streak = max(profile.highest_loss_streak, profile.current_loss_streak)

		character.losses += 1
		character.current_loss_streak += 1
		character.current_win_streak = 0
		character.highest_loss_streak = max(character.highest_loss_streak, character.current_loss_streak)


func _write_aggregate_snapshots(
	profile: ProfileSummaryData,
	character: CharacterProfileStatsData,
) -> bool:
	if not _execute(
		"""UPDATE profile_summary SET
			total_wins = ?, total_losses = ?, total_run_time = ?, fastest_win_run_time = ?,
			current_win_streak = ?, current_loss_streak = ?,
			highest_win_streak = ?, highest_loss_streak = ? WHERE id = 1;""",
		[
			profile.total_wins, profile.total_losses, profile.total_run_time,
			profile.fastest_win_run_time, profile.current_win_streak,
			profile.current_loss_streak, profile.highest_win_streak,
			profile.highest_loss_streak,
		],
	):
		return false
	return _execute(
		"""INSERT INTO character_profile_stats (
			character_id, wins, losses, current_win_streak, highest_win_streak,
			current_loss_streak, highest_loss_streak, highest_difficulty,
			fastest_win_run_time, total_run_time
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(character_id) DO UPDATE SET
			wins = excluded.wins, losses = excluded.losses,
			current_win_streak = excluded.current_win_streak,
			highest_win_streak = excluded.highest_win_streak,
			current_loss_streak = excluded.current_loss_streak,
			highest_loss_streak = excluded.highest_loss_streak,
			highest_difficulty = excluded.highest_difficulty,
			fastest_win_run_time = excluded.fastest_win_run_time,
			total_run_time = excluded.total_run_time;""",
		[
			character.character_id, character.wins, character.losses,
			character.current_win_streak, character.highest_win_streak,
			character.current_loss_streak, character.highest_loss_streak,
			character.highest_difficulty, character.fastest_win_run_time,
			character.total_run_time,
		],
	)


func _insert_run_graph(run_stats: RunStatsData) -> bool:
	if not _execute(
		"""INSERT INTO runs (
			seed, character_id, difficulty_level, player_health, player_health_max,
			player_money, consumable_slot_count, victory, floor, defeat_event_id,
			is_detailed, completion_time, completion_timestamp
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);""",
		[
			run_stats.run_seed, run_stats.run_character_id, run_stats.run_difficulty_level,
			run_stats.run_player_health, run_stats.run_player_health_max,
			run_stats.run_player_money, run_stats.run_consumable_slot_count,
			int(run_stats.run_victory), run_stats.run_floor, run_stats.run_defeat_event_id,
			int(run_stats.run_is_detailed), run_stats.run_completion_time,
			run_stats.run_completion_timestamp,
		],
	):
		return false
	var run_id: int = int(_db.last_insert_rowid)
	run_stats.run_history_id = run_id

	for index: int in run_stats.run_modifier_ids.size():
		if not _execute(
			"INSERT INTO run_modifiers (run_id, ordinal, modifier_id) VALUES (?, ?, ?);",
			[run_id, index, run_stats.run_modifier_ids[index]],
		):
			return false
	for index: int in run_stats.run_deck.size():
		var deck_entry: Array = run_stats.run_deck[index]
		if deck_entry.size() < 2:
			continue
		if not _execute(
			"INSERT INTO run_deck (run_id, ordinal, card_id, upgrade_amount) VALUES (?, ?, ?, ?);",
			[run_id, index, str(deck_entry[0]), int(deck_entry[1])],
		):
			return false
	for index: int in run_stats.run_artifact_ids.size():
		if not _execute(
			"INSERT INTO run_artifacts (run_id, ordinal, artifact_id) VALUES (?, ?, ?);",
			[run_id, index, run_stats.run_artifact_ids[index]],
		):
			return false
	for index: int in run_stats.run_consumable_ids.size():
		if not _execute(
			"INSERT INTO run_consumables (run_id, ordinal, consumable_id) VALUES (?, ?, ?);",
			[run_id, index, run_stats.run_consumable_ids[index]],
		):
			return false
	if not _insert_sparse_stats("run_stats", "run_id", run_id, run_stats.run_total_stats):
		return false

	for combat_index: int in run_stats.run_combat_stats.size():
		if not _insert_combat(run_id, combat_index, run_stats.run_combat_stats[combat_index]):
			return false
	return true


func _insert_combat(run_id: int, ordinal: int, combat: CombatStatsData) -> bool:
	if not _execute(
		"INSERT INTO combats (run_id, ordinal, event_object_id, combat_floor, turn_count) VALUES (?, ?, ?, ?, ?);",
		[run_id, ordinal, combat.event_object_id, combat.combat_floor, combat.turn_count],
	):
		return false
	var combat_id: int = int(_db.last_insert_rowid)
	if not _insert_sparse_stats("combat_total_stats", "combat_id", combat_id, combat.total_stats):
		return false
	if not _insert_sparse_stats("combat_current_turn_stats", "combat_id", combat_id, combat.turn_stats):
		return false
	for turn_ordinal: int in combat.turn_stats_history.size():
		if not _execute(
			"INSERT INTO combat_turns (combat_id, turn_ordinal) VALUES (?, ?);",
			[combat_id, turn_ordinal],
		):
			return false
		var turn_stats: Dictionary = combat.turn_stats_history[turn_ordinal]
		for stat_name: Variant in turn_stats:
			var stat_value: int = int(turn_stats[stat_name])
			if stat_value == 0:
				continue
			if not _execute(
				"INSERT INTO combat_turn_history_stats (combat_id, turn_ordinal, stat_name, stat_value) VALUES (?, ?, ?, ?);",
				[combat_id, turn_ordinal, str(stat_name), stat_value],
			):
				return false
	return true


func _insert_sparse_stats(table_name: String, id_column: String, id: int, stats: Dictionary) -> bool:
	var sql: String = "INSERT INTO %s (%s, stat_name, stat_value) VALUES (?, ?, ?);" % [table_name, id_column]
	for stat_name: Variant in stats:
		var stat_value: int = int(stats[stat_name])
		if stat_value == 0:
			continue
		if not _execute(sql, [id, str(stat_name), stat_value]):
			return false
	return true


func get_latest_run_summary() -> RunStatsData:
	return _query_run_summary(
		"SELECT * FROM runs ORDER BY run_id DESC LIMIT 1;",
		[],
	)


func get_older_run_summary(run_id: int) -> RunStatsData:
	return _query_run_summary(
		"SELECT * FROM runs WHERE run_id < ? ORDER BY run_id DESC LIMIT 1;",
		[run_id],
	)


func get_newer_run_summary(run_id: int) -> RunStatsData:
	return _query_run_summary(
		"SELECT * FROM runs WHERE run_id > ? ORDER BY run_id ASC LIMIT 1;",
		[run_id],
	)


func load_run_details(run_id: int) -> RunStatsData:
	var run_stats: RunStatsData = _query_run_summary(
		"SELECT * FROM runs WHERE run_id = ? LIMIT 1;",
		[run_id],
	)
	if run_stats == null:
		return null
	if not _load_run_children(run_stats):
		return null
	return run_stats


func _query_run_summary(sql: String, bindings: Array) -> RunStatsData:
	if not _database_ready or not _execute(sql, bindings) or _db.query_result.is_empty():
		return null
	return _run_stats_from_row(_db.query_result[0])


func _load_run_children(run_stats: RunStatsData) -> bool:
	var run_id: int = run_stats.run_history_id
	if not _execute("SELECT modifier_id FROM run_modifiers WHERE run_id = ? ORDER BY ordinal;", [run_id]):
		return false
	for row: Dictionary in _db.query_result:
		run_stats.run_modifier_ids.append(str(row.get("modifier_id", "")))

	if not _execute("SELECT card_id, upgrade_amount FROM run_deck WHERE run_id = ? ORDER BY ordinal;", [run_id]):
		return false
	for row: Dictionary in _db.query_result:
		run_stats.run_deck.append([str(row.get("card_id", "")), int(row.get("upgrade_amount", 0))])

	if not _execute("SELECT artifact_id FROM run_artifacts WHERE run_id = ? ORDER BY ordinal;", [run_id]):
		return false
	for row: Dictionary in _db.query_result:
		run_stats.run_artifact_ids.append(str(row.get("artifact_id", "")))

	if not _execute("SELECT consumable_id FROM run_consumables WHERE run_id = ? ORDER BY ordinal;", [run_id]):
		return false
	for row: Dictionary in _db.query_result:
		run_stats.run_consumable_ids.append(str(row.get("consumable_id", "")))

	if not _execute("SELECT stat_name, stat_value FROM run_stats WHERE run_id = ?;", [run_id]):
		return false
	for row: Dictionary in _db.query_result:
		run_stats.run_total_stats[str(row.get("stat_name", ""))] = int(row.get("stat_value", 0))

	if not _execute("SELECT * FROM combats WHERE run_id = ? ORDER BY ordinal;", [run_id]):
		return false
	var combat_rows: Array = _db.query_result.duplicate(true)
	for row: Dictionary in combat_rows:
		var combat: CombatStatsData = _load_combat(row)
		if combat == null:
			return false
		run_stats.run_combat_stats.append(combat)
	return true


func _load_combat(row: Dictionary) -> CombatStatsData:
	var combat_id: int = int(row.get("combat_id", -1))
	var combat := CombatStatsData.new(str(row.get("event_object_id", "")), int(row.get("combat_floor", 0)))
	combat.turn_count = int(row.get("turn_count", 1))
	combat.initialize_stats()

	if not _execute("SELECT stat_name, stat_value FROM combat_total_stats WHERE combat_id = ?;", [combat_id]):
		return null
	for stat_row: Dictionary in _db.query_result:
		combat.total_stats[str(stat_row.get("stat_name", ""))] = int(stat_row.get("stat_value", 0))

	if not _execute("SELECT stat_name, stat_value FROM combat_current_turn_stats WHERE combat_id = ?;", [combat_id]):
		return null
	for stat_row: Dictionary in _db.query_result:
		combat.turn_stats[str(stat_row.get("stat_name", ""))] = int(stat_row.get("stat_value", 0))

	if not _execute("SELECT turn_ordinal FROM combat_turns WHERE combat_id = ? ORDER BY turn_ordinal;", [combat_id]):
		return null
	var turn_rows: Array = _db.query_result.duplicate(true)
	combat.turn_stats_history.clear()
	for _turn_row: Dictionary in turn_rows:
		combat.turn_stats_history.append(combat.turn_stats.duplicate())
		for stat_name: Variant in combat.turn_stats_history[-1]:
			combat.turn_stats_history[-1][stat_name] = 0

	if not _execute(
		"SELECT turn_ordinal, stat_name, stat_value FROM combat_turn_history_stats WHERE combat_id = ? ORDER BY turn_ordinal;",
		[combat_id],
	):
		return null
	for stat_row: Dictionary in _db.query_result:
		var turn_ordinal: int = int(stat_row.get("turn_ordinal", -1))
		if turn_ordinal >= 0 and turn_ordinal < combat.turn_stats_history.size():
			combat.turn_stats_history[turn_ordinal][str(stat_row.get("stat_name", ""))] = int(stat_row.get("stat_value", 0))
	return combat


func _profile_summary_from_row(row: Dictionary) -> ProfileSummaryData:
	var result := ProfileSummaryData.new()
	result.profile_name = str(row.get("profile_name", ""))
	result.total_wins = int(row.get("total_wins", 0))
	result.total_losses = int(row.get("total_losses", 0))
	result.total_run_time = float(row.get("total_run_time", 0.0))
	result.fastest_win_run_time = float(row.get("fastest_win_run_time", 0.0))
	result.current_win_streak = int(row.get("current_win_streak", 0))
	result.current_loss_streak = int(row.get("current_loss_streak", 0))
	result.highest_win_streak = int(row.get("highest_win_streak", 0))
	result.highest_loss_streak = int(row.get("highest_loss_streak", 0))
	return result


func _character_stats_from_row(row: Dictionary) -> CharacterProfileStatsData:
	var result := CharacterProfileStatsData.new()
	result.character_id = str(row.get("character_id", ""))
	result.wins = int(row.get("wins", 0))
	result.losses = int(row.get("losses", 0))
	result.current_win_streak = int(row.get("current_win_streak", 0))
	result.highest_win_streak = int(row.get("highest_win_streak", 0))
	result.current_loss_streak = int(row.get("current_loss_streak", 0))
	result.highest_loss_streak = int(row.get("highest_loss_streak", 0))
	result.highest_difficulty = int(row.get("highest_difficulty", -1))
	result.fastest_win_run_time = float(row.get("fastest_win_run_time", 0.0))
	result.total_run_time = float(row.get("total_run_time", 0.0))
	return result


func _achievement_state_from_row(row: Dictionary) -> AchievementStateData:
	var result := AchievementStateData.new()
	result.achievement_id = str(row.get("achievement_id", ""))
	result.current_value = float(row.get("current_value", 0.0))
	result.latest_value = float(row.get("latest_value", 0.0))
	result.best_value = float(row.get("best_value", 0.0))
	result.update_count = int(row.get("update_count", 0))
	result.scope_update_count = int(row.get("scope_update_count", 0))
	result.scope_key = str(row.get("scope_key", ""))
	result.updated_at = int(row.get("updated_at", 0))
	var unlocked_value: Variant = row.get("unlocked_at", null)
	result.unlocked_at = 0 if unlocked_value == null else int(unlocked_value)
	return result


func _run_stats_from_row(row: Dictionary) -> RunStatsData:
	var result := RunStatsData.new()
	result.run_history_id = int(row.get("run_id", -1))
	result.run_seed = int(row.get("seed", 0))
	result.run_character_id = str(row.get("character_id", ""))
	result.run_difficulty_level = int(row.get("difficulty_level", 0))
	result.run_player_health = int(row.get("player_health", 0))
	result.run_player_health_max = int(row.get("player_health_max", 0))
	result.run_player_money = int(row.get("player_money", 0))
	result.run_consumable_slot_count = int(row.get("consumable_slot_count", 0))
	result.run_victory = bool(int(row.get("victory", 0)))
	result.run_floor = int(row.get("floor", 0))
	result.run_defeat_event_id = str(row.get("defeat_event_id", ""))
	result.run_is_detailed = bool(int(row.get("is_detailed", 0)))
	result.run_completion_time = float(row.get("completion_time", 0.0))
	result.run_completion_timestamp = int(row.get("completion_timestamp", 0))
	return result


func _get_changed_row_count() -> int:
	if not _execute("SELECT changes() AS changed_rows;") or _db.query_result.is_empty():
		return 0
	return int(_db.query_result[0].get("changed_rows", 0))


func _execute(sql: String, bindings: Array = []) -> bool:
	var succeeded: bool
	if bindings.is_empty():
		succeeded = _db.query(sql)
	else:
		succeeded = _db.query_with_bindings(sql, bindings)
	if not succeeded:
		_report_error("Profile database query failed: %s | %s" % [_db.error_message, sql])
	return succeeded


func _report_error(message: String) -> bool:
	push_error("ProfileStore: %s" % message)
	return false


func _abort_startup() -> void:
	_database_ready = false
	push_error("ProfileStore: profile initialization failed; startup aborted")
	call_deferred("_quit_after_initialization_failure")


func _quit_after_initialization_failure() -> void:
	get_tree().quit(1)
