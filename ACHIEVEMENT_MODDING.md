# 数据驱动成就模组接口

模组成就与原生成就都使用 `AchievementData`。将 JSON 放入模组的 `achievements/` 目录，并在 `mod_info.json` 的 `mod_folder_to_load_data` 中将该目录映射到 `AchievementData` / `_id_to_achievement_data`。

## 约定

- ID 必须全局唯一，推荐使用 `mod_id.achievement_id`。
- 模组成就只写入本地档案，不会同步平台。
- 移除模组不会删除状态；重新安装同一 ID 后会恢复。
- 同一触发器的条件为 AND；多个触发器为 OR。
- 自定义信号会自动映射为 `custom_signal:<custom_signal_id>`。
- 脚本也可调用 `AchievementManager.submit_event(event_id, values)`。为需要幂等的事件提供稳定的 `values.event_key`。

完整可运行 JSON 示例位于 `external/mods/mod_data_example_mod/achievements/`。

## 事件与字段

内置事件为 `enemy_killed`、`combat_stat_changed`、`turn_completed`、`combat_completed`、`run_completed`、`location_entered`、`achievement_unlocked` 和 `custom_signal:<id>`。

每个事件都提供 `event_id`、`value`、`values`、`is_custom_run`、`timestamp`，以及角色、难度、地点、回合/战斗/单局统计快照和各级 `scope_key`。条件和进度字段使用点路径，例如 `values.run_victory` 或 `combat_stats.CARDS_PLAYED`。

`AchievementConditionData.OPERATORS` 支持相等、不等、数值比较、包含、属于集合及布尔判断。比较另一个事件字段时，条件值写作 `{"field": "values.run_player_health_max"}`。

## 聚合与范围

`AchievementProgressData.AGGREGATIONS` 包括 `COUNT`、`SUM`、`LATEST`、`MAXIMUM`、`MINIMUM`、`UNIQUE_COUNT`；`SCOPES` 包括 `LIFETIME`、`RUN`、`COMBAT`、`TURN`。没有 `achievement_progress` 时，第一次匹配即解锁。

特殊逻辑可配置 `achievement_custom_evaluator_script_path`。脚本必须继承 `BaseAchievementEvaluator`，实现 `evaluate()` 并只返回 `{accepted, candidate_value, unique_value}`，不得写数据库或发送解锁信号。
