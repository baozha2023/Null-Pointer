## 红色卡牌 — 码农 / 程序员主题
## 主题：攻击导向、连击、代码/栈操作、逻辑判断
class_name GlobalProdDataGeneratorRedCards
extends RefCounted

static func add_cards_red() -> void:
	var color: String = "red"

	#region 核心攻击

	# 代码提交 — 每次打出伤害递增
	var card_commit: CardData = CardData.new("card_commit")
	card_commit.card_name = "代码提交"
	card_commit.card_color_id = "color_{0}".format([color])
	card_commit.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_commit.card_description = "造成 [damage] 点伤害。本场战斗中所有代码提交提升 [damage_growth] 点伤害。"
	card_commit.card_type = CardData.CARD_TYPES.ATTACK
	card_commit.card_rarity = CardData.CARD_RARITIES.COMMON
	card_commit.card_requires_target = true
	card_commit.card_energy_cost = 1
	card_commit.card_keyword_object_ids = []
	card_commit.card_values = {
		"damage": 7,
		"number_of_attacks": 1,
		"damage_growth": 2,
		"impact_vfx_animation_id": "animation_vfx_impact_default",
	}
	card_commit.card_upgrade_value_improvements = {"damage": 3, "damage_growth": 1}
	card_commit.card_draw_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_CARD_TYPE_IN_HAND: {
						"card_type_minimum": 2,
						"card_types": CardData.CARD_TYPES.values(),
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}},
				],
			},
		},
	]
	card_commit.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: {},
		},
		{
			Scripts.ACTION_PICK_CARDS: {
				"max_card_amount": 999,
				"min_card_amount": 999,
				"min_cards_are_required_for_action": false,
				"random_selection": false,
				"card_pick_type": HandManager.COMBAT_DECK,
				"card_pick_text": "",
				"validator_data": [
					{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": [card_commit.object_id]}},
				],
				"action_data": [
					{
						Scripts.ACTION_IMPROVE_CARD_VALUES: {
							"pick_played_card": false,
							"modify_parent_card": false,
							"card_value_improvements": {"damage": 2},
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_commit)

	# 栈溢出 — 手牌越多越强
	var card_stack_overflow: CardData = CardData.new("card_stack_overflow")
	card_stack_overflow.card_name = "栈溢出"
	card_stack_overflow.card_color_id = "color_{0}".format([color])
	card_stack_overflow.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_stack_overflow.card_description = "造成 [damage] 点伤害。当前线程中每有一个脚本额外造成 [damage_per_card] 点伤害。"
	card_stack_overflow.card_type = CardData.CARD_TYPES.ATTACK
	card_stack_overflow.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_stack_overflow.card_requires_target = true
	card_stack_overflow.card_energy_cost = 2
	card_stack_overflow.card_values = {"damage": 6, "damage_per_card": 2, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_stack_overflow.card_upgrade_value_improvements = {"damage": 3, "damage_per_card": 1}
	card_stack_overflow.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_stack_overflow.card_play_actions = [
		# 根据手牌数提升伤害
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "cards_in_hand",
				"card_value_name": "damage",
				"stat_to_value_multiplier": 2,
				"time_delay": 0.0,
			},
		},
		{Scripts.ACTION_ATTACK_GENERATOR: {}},
		# 副作用：自身受损——栈过载会短暂降低处理能力
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_weaken",
				"status_charge_amount": 1,
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"time_delay": 0.2,
			},
		},
	]
	Global.register_rod(card_stack_overflow)

	# 递归调用 — 连击叠加
	var card_recursion: CardData = CardData.new("card_recursion")
	card_recursion.card_name = "递归调用"
	card_recursion.card_color_id = "color_{0}".format([color])
	card_recursion.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_recursion.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害。"
	card_recursion.card_type = CardData.CARD_TYPES.ATTACK
	card_recursion.card_rarity = CardData.CARD_RARITIES.RARE
	card_recursion.card_requires_target = true
	card_recursion.card_energy_cost = 2
	card_recursion.card_values = {
		"damage": 4,
		"number_of_attacks": 4,
		"impact_vfx_animation_id": "animation_vfx_impact_default",
		"time_delay": 0.15,
	}
	card_recursion.card_upgrade_value_improvements = {"number_of_attacks": 2}
	card_recursion.card_first_upgrade_property_changes = {
		"card_description": "造成 [number_of_attacks] 次 [damage] 点伤害。战斗开始时置入当前线程。",
		"card_initial_combat_actions": [
			{
				Scripts.ACTION_ADD_CARDS_TO_HAND: {
					"card_pick_type": HandManager.COMBAT_DECK,
					"validator_data": [{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": [card_recursion.object_id]}}],
					"max_card_amount": 1,
					"min_card_amount": 1,
					"min_cards_are_required_for_action": false,
					"random_selection": false,
					"time_delay": 0.0,
				},
			},
		],
	}
	card_recursion.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: {
				"time_delay": 0.15,
				"actions_on_lethal": [],
			},
		},
	]
	Global.register_rod(card_recursion)

	# 二进制切割 — 对非攻击目标额外伤害
	var card_binary_search: CardData = CardData.new("card_binary_search")
	card_binary_search.card_name = "二进制切割"
	card_binary_search.card_color_id = "color_{0}".format([color])
	card_binary_search.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_binary_search.card_description = "造成 [damage] 点伤害。如果目标敌人未在攻击，额外造成 [bonus_damage] 点伤害。"
	card_binary_search.card_type = CardData.CARD_TYPES.ATTACK
	card_binary_search.card_rarity = CardData.CARD_RARITIES.COMMON
	card_binary_search.card_requires_target = true
	card_binary_search.card_energy_cost = 1
	card_binary_search.card_values = {"damage": 7, "bonus_damage": 5, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_binary_search.card_upgrade_value_improvements = {"damage": 3, "bonus_damage": 3}
	card_binary_search.card_glow_validators = [
		{Scripts.VALIDATOR_ENEMY_ATTACKING: {"invert_validation": true}},
	]
	card_binary_search.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: {}},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_ENEMY_ATTACKING: {"invert_validation": true}},
				],
				"passed_action_data": [
					{
						Scripts.ACTION_DIRECT_DAMAGE: {
							"custom_key_names": {"damage": "bonus_damage"},
							"bypass_block": false,
							"time_delay": 0.3,
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_binary_search)

	# 单元测试 — 斩杀
	var card_unit_test: CardData = CardData.new("card_unit_test")
	card_unit_test.card_name = "单元测试"
	card_unit_test.card_color_id = "color_{0}".format([color])
	card_unit_test.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_unit_test.card_description = "造成 [damage] 点伤害。如果目标完整度低于 50%，造成 [execution_damage] 点伤害。"
	card_unit_test.card_type = CardData.CARD_TYPES.ATTACK
	card_unit_test.card_rarity = CardData.CARD_RARITIES.COMMON
	card_unit_test.card_requires_target = true
	card_unit_test.card_energy_cost = 1
	card_unit_test.card_values = {"damage": 7, "execution_damage": 12, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_unit_test.card_upgrade_value_improvements = {"damage": 3, "execution_damage": 4}
	card_unit_test.card_glow_validators = [
		{Scripts.VALIDATOR_COMBAT_STATS: {
			"combat_stat_name": "target_health_percent",
			"operator": "<=",
			"comparison_value": 50,
		}},
	]
	card_unit_test.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_COMBAT_STATS: {
						"combat_stat_name": "target_health_percent",
						"operator": "<=",
						"comparison_value": 50,
					}},
				],
				"passed_action_data": [
					{
						Scripts.ACTION_DIRECT_DAMAGE: {
							"custom_key_names": {"damage": "execution_damage"},
							"bypass_block": false,
							"time_delay": 0.3,
						},
					},
				],
				"failed_action_data": [
					{
						Scripts.ACTION_DIRECT_DAMAGE: {
							"custom_key_names": {"damage": "damage"},
							"bypass_block": false,
							"time_delay": 0.3,
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_unit_test)

	# 异或操作 — 伤害+易伤
	var card_xor_cipher: CardData = CardData.new("card_xor_cipher")
	card_xor_cipher.card_name = "异或操作"
	card_xor_cipher.card_color_id = "color_{0}".format([color])
	card_xor_cipher.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_xor_cipher.card_description = "造成 [damage] 点伤害并对目标施加 [status_charge_amount] 层易伤。"
	card_xor_cipher.card_type = CardData.CARD_TYPES.ATTACK
	card_xor_cipher.card_rarity = CardData.CARD_RARITIES.COMMON
	card_xor_cipher.card_requires_target = true
	card_xor_cipher.card_energy_cost = 1
	card_xor_cipher.card_values = {"damage": 5, "status_charge_amount": 2, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_xor_cipher.card_upgrade_value_improvements = {"damage": 3, "status_charge_amount": 1}
	card_xor_cipher.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: {}},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"time_delay": 0.3,
			},
		},
	]
	Global.register_rod(card_xor_cipher)

	# 最终部署 — 双段攻击，物理删除
	var card_production_deploy: CardData = CardData.new("card_production_deploy")
	card_production_deploy.card_name = "最终部署"
	card_production_deploy.card_color_id = "color_{0}".format([color])
	card_production_deploy.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_production_deploy.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害。物理删除。"
	card_production_deploy.card_type = CardData.CARD_TYPES.ATTACK
	card_production_deploy.card_rarity = CardData.CARD_RARITIES.RARE
	card_production_deploy.card_requires_target = true
	card_production_deploy.card_energy_cost = 2
	card_production_deploy.card_play_destination = HandManager.EXHAUST_PILE
	card_production_deploy.card_values = {"damage": 10, "number_of_attacks": 2, "impact_vfx_animation_id": "animation_vfx_impact_default", "time_delay": 0.3,}
	card_production_deploy.card_upgrade_value_improvements = {"damage": 4}
	card_production_deploy.card_first_upgrade_property_changes = {
		"card_energy_cost": 1,
		"card_description": "造成 [number_of_attacks] 次 [damage] 点伤害。物理删除。战斗开始时置入当前线程。",
		"card_initial_combat_actions": [
			{
				Scripts.ACTION_ADD_CARDS_TO_HAND: {
					"card_pick_type": HandManager.COMBAT_DECK,
					"validator_data": [{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": [card_production_deploy.object_id]}}],
					"max_card_amount": 1,
					"min_card_amount": 1,
					"min_cards_are_required_for_action": false,
					"random_selection": false,
					"time_delay": 0.0,
				},
			},
		],
	}
	card_production_deploy.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: {
				"time_delay": 0.3,
				"actions_on_lethal": [],
			},
		},
	]
	Global.register_rod(card_production_deploy)

	#endregion

	#region 辅助技能

	# 强制推送 — 弃牌换手牌
	var card_force_push: CardData = CardData.new("card_force_push")
	card_force_push.card_name = "强制推送"
	card_force_push.card_color_id = "color_{0}".format([color])
	card_force_push.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_force_push.card_description = "丢弃所有当前线程脚本，然后读取同等数量的脚本。"
	card_force_push.card_type = CardData.CARD_TYPES.SKILL
	card_force_push.card_rarity = CardData.CARD_RARITIES.COMMON
	card_force_push.card_requires_target = false
	card_force_push.card_energy_cost = 1
	card_force_push.card_upgrade_value_improvements = {}
	card_force_push.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_force_push.card_discard_actions = [
		{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}},
	]
	card_force_push.card_play_actions = [
		{
			# 先记下当前手牌数量，弃掉全部
			Scripts.ACTION_DISCARD_CARDS: {
				"max_card_amount": 999,
				"min_card_amount": 999,
				"min_cards_are_required_for_action": false,
				"card_pick_type": HandManager.HAND_PILE,
				"random_selection": false,
				"time_delay": 0.2,
			},
		},
		{
			# 抽取同等数量
			Scripts.ACTION_DRAW_GENERATOR: {
				"draw_count": 999,
				"time_delay": 0.3,
			},
		},
	]
	Global.register_rod(card_force_push)

	# 代码审查 — 抽牌+易伤
	var card_code_review: CardData = CardData.new("card_code_review")
	card_code_review.card_name = "代码审查"
	card_code_review.card_color_id = "color_{0}".format([color])
	card_code_review.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_code_review.card_description = "读取 [draw_count] 个脚本，对随机敌人施加 [status_charge_amount] 层易伤。"
	card_code_review.card_type = CardData.CARD_TYPES.SKILL
	card_code_review.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_code_review.card_requires_target = false
	card_code_review.card_energy_cost = 1
	card_code_review.card_values = {"draw_count": 3, "status_charge_amount": 1}
	card_code_review.card_upgrade_value_improvements = {"draw_count": 1, "status_charge_amount": 1}
	card_code_review.card_play_actions = [
		{Scripts.ACTION_DRAW_GENERATOR: {}},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"target_override": BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY,
				"time_delay": 0.3,
			},
		},
	]
	Global.register_rod(card_code_review)

	# 异常捕获 — 条件防御
	var card_try_catch: CardData = CardData.new("card_try_catch")
	card_try_catch.card_name = "异常捕获"
	card_try_catch.card_color_id = "color_{0}".format([color])
	card_try_catch.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_try_catch.card_description = "获得 [block] 点防火墙。如果目标正在攻击，额外获得 [block_bonus] 点防火墙。"
	card_try_catch.card_type = CardData.CARD_TYPES.SKILL
	card_try_catch.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_try_catch.card_requires_target = true
	card_try_catch.card_energy_cost = 1
	card_try_catch.card_values = {"block": 8, "block_bonus": 6}
	card_try_catch.card_upgrade_value_improvements = {"block": 3, "block_bonus": 3}
	card_try_catch.card_glow_validators = [
		{Scripts.VALIDATOR_ENEMY_ATTACKING: {}},
	]
	card_try_catch.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.2,
			},
		},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_ENEMY_ATTACKING: {}},
				],
				"passed_action_data": [
					{
						Scripts.ACTION_BLOCK: {
							"custom_key_names": {"block": "block_bonus"},
							"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
							"time_delay": 0.2,
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_try_catch)

	# 重构 — 随机升级，物理删除
	var card_refactor: CardData = CardData.new("card_refactor")
	card_refactor.card_name = "重构"
	card_refactor.card_color_id = "color_{0}".format([color])
	card_refactor.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_refactor.card_description = "永久升级当前线程中的 [card_amount] 个脚本。升级后本脚本物理删除。"
	card_refactor.card_type = CardData.CARD_TYPES.SKILL
	card_refactor.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_refactor.card_requires_target = false
	card_refactor.card_energy_cost = 0
	card_refactor.card_play_destination = HandManager.EXHAUST_PILE
	card_refactor.card_values = {"card_amount": 1, "upgrade_parent_card": true}
	card_refactor.card_upgrade_value_improvements = {}
	card_refactor.card_first_upgrade_value_changes = {"card_amount": 2}
	card_refactor.card_first_upgrade_property_changes = {"card_description": "永久升级当前线程中的 [card_amount] 个脚本。物理删除。"}
	card_refactor.card_upgrade_amount_max = 1
	card_refactor.card_play_actions = [
		{
			Scripts.ACTION_PICK_UPGRADE_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount", "min_card_amount": "card_amount"},
				"min_cards_are_required_for_action": false,
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择要重构的脚本",
				"random_selection": false,
				"upgrade_parent_card": true,
				"bypass_upgrade_max": false,
			},
		},
	]
	Global.register_rod(card_refactor)

	# 代码生成 — 复制手牌
	var card_template: CardData = CardData.new("card_template")
	card_template.card_name = "代码生成"
	card_template.card_color_id = "color_{0}".format([color])
	card_template.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_template.card_description = "复制当前线程中的 [card_amount] 个脚本到当前线程。"
	card_template.card_type = CardData.CARD_TYPES.SKILL
	card_template.card_rarity = CardData.CARD_RARITIES.COMMON
	card_template.card_requires_target = false
	card_template.card_energy_cost = 1
	card_template.card_play_destination = HandManager.EXHAUST_PILE
	card_template.card_values = {"card_amount": 1}
	card_template.card_upgrade_value_improvements = {"card_amount": 1}
	card_template.card_first_upgrade_property_changes = {"card_play_destination": HandManager.DISCARD_PILE, "card_description": "复制当前线程中的 [card_amount] 个脚本到当前线程。"}
	card_template.card_play_actions = [
		{
			Scripts.ACTION_PICK_DUPLICATE_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount", "min_card_amount": "card_amount"},
				"min_cards_are_required_for_action": true,
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择要复制模板的脚本",
				"random_selection": false,
			},
		},
	]
	Global.register_rod(card_template)

	# 贪心算法 — 预支算力
	var card_greedy_algo: CardData = CardData.new("card_greedy_algo")
	card_greedy_algo.card_name = "贪心算法"
	card_greedy_algo.card_color_id = "color_{0}".format([color])
	card_greedy_algo.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_greedy_algo.card_description = "获得 [energy_amount] 点算力，对目标施加 [status_charge_amount] 层易伤。自身获得 1 层易伤。"
	card_greedy_algo.card_type = CardData.CARD_TYPES.SKILL
	card_greedy_algo.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_greedy_algo.card_requires_target = true
	card_greedy_algo.card_energy_cost = 0
	card_greedy_algo.card_values = {"energy_amount": 2, "status_charge_amount": 1}
	card_greedy_algo.card_upgrade_value_improvements = {"energy_amount": 1, "status_charge_amount": 1}
	card_greedy_algo.card_play_actions = [
		{Scripts.ACTION_ADD_ENERGY: {}},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"time_delay": 0.3,
			},
		},
		# 副作用：短视决策会暴露自身弱点
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_charge_amount": 1,
				"time_delay": 0.2,
			},
		},
	]
	Global.register_rod(card_greedy_algo)

	# 动态规划 — 预支防御
	var card_dp_cache: CardData = CardData.new("card_dp_cache")
	card_dp_cache.card_name = "动态规划"
	card_dp_cache.card_color_id = "color_{0}".format([color])
	card_dp_cache.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_dp_cache.card_description = "获得 [block] 点防火墙（下回合开始时保留）。获得 [status_charge_amount] 层临时保留防火墙。"
	card_dp_cache.card_type = CardData.CARD_TYPES.SKILL
	card_dp_cache.card_rarity = CardData.CARD_RARITIES.COMMON
	card_dp_cache.card_requires_target = false
	card_dp_cache.card_energy_cost = 1
	card_dp_cache.card_values = {"block": 6, "status_charge_amount": 3}
	card_dp_cache.card_upgrade_value_improvements = {"block": 3, "status_charge_amount": 2}
	card_dp_cache.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_dp_cache.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.2,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_temp_preserve_block",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.3,
			},
		},
	]
	Global.register_rod(card_dp_cache)

	#endregion

	#region 守护进程

	# 持续集成 — 全局攻击增益
	var card_ci_pipeline: CardData = CardData.new("card_ci_pipeline")
	card_ci_pipeline.card_name = "持续集成"
	card_ci_pipeline.card_color_id = "color_{0}".format([color])
	card_ci_pipeline.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_ci_pipeline.card_description = "获得 [status_charge_amount] 层伤害增强。每回合多读取 [draw_count] 个脚本。"
	card_ci_pipeline.card_type = CardData.CARD_TYPES.POWER
	card_ci_pipeline.card_rarity = CardData.CARD_RARITIES.RARE
	card_ci_pipeline.card_requires_target = false
	card_ci_pipeline.card_energy_cost = 2
	card_ci_pipeline.card_play_destination = HandManager.BANISH_PILE
	card_ci_pipeline.card_values = {"status_charge_amount": 3, "draw_count": 1}
	card_ci_pipeline.card_upgrade_value_improvements = {"status_charge_amount": 2}
	card_ci_pipeline.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_ci_pipeline.card_upgrade_amount_max = 1
	card_ci_pipeline.card_keyword_object_ids = ["keyword_damage_increase"]
	card_ci_pipeline.card_status_effect_object_ids = ["status_effect_increase_turn_draw"]
	card_ci_pipeline.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_damage_increase",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.5,
			},
		},
		# 每回合多抽 1 的buff
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_increase_turn_draw",
				"custom_key_names": {"status_charge_amount": "draw_count"},
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.3,
			},
		},
	]
	Global.register_rod(card_ci_pipeline)

	# 分叉仓库 — 攻击复制状态
	var card_fork: CardData = CardData.new("card_fork")
	card_fork.card_name = "分叉仓库"
	card_fork.card_color_id = "color_{0}".format([color])
	card_fork.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_fork.card_description = "接下来的 [status_charge_amount] 次攻击脚本触发两次。"
	card_fork.card_type = CardData.CARD_TYPES.POWER
	card_fork.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_fork.card_requires_target = false
	card_fork.card_energy_cost = 1
	card_fork.card_play_destination = HandManager.BANISH_PILE
	card_fork.card_values = {"status_charge_amount": 1}
	card_fork.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_fork.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_duplicate_attacks",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.5,
			},
		},
	]
	Global.register_rod(card_fork)

	# 熔断机制 — 血量触发防御
	var card_circuit_breaker: CardData = CardData.new("card_circuit_breaker")
	card_circuit_breaker.card_name = "熔断机制"
	card_circuit_breaker.card_color_id = "color_{0}".format([color])
	card_circuit_breaker.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_circuit_breaker.card_description = "获得 [block] 点防火墙和 [status_charge_amount] 层反伤模块。战斗开始时自动触发。"
	card_circuit_breaker.card_type = CardData.CARD_TYPES.POWER
	card_circuit_breaker.card_rarity = CardData.CARD_RARITIES.RARE
	card_circuit_breaker.card_requires_target = false
	card_circuit_breaker.card_energy_cost = 2
	card_circuit_breaker.card_play_destination = HandManager.BANISH_PILE
	card_circuit_breaker.card_values = {"block": 8, "status_charge_amount": 3}
	card_circuit_breaker.card_upgrade_value_improvements = {"block": 4, "status_charge_amount": 2}
	card_circuit_breaker.card_initial_combat_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.0,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_pointy",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.0,
			},
		},
	]
	card_circuit_breaker.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.2,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_pointy",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.3,
			},
		},
	]
	Global.register_rod(card_circuit_breaker)

	# 类型安全 — 定点清除无视虚弱
	var card_type_cast: CardData = CardData.new("card_type_cast")
	card_type_cast.card_name = "类型检查"
	card_type_cast.card_color_id = "color_{0}".format([color])
	card_type_cast.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_type_cast.card_description = "造成 [damage] 点伤害。不受虚弱影响。"
	card_type_cast.card_type = CardData.CARD_TYPES.ATTACK
	card_type_cast.card_rarity = CardData.CARD_RARITIES.COMMON
	card_type_cast.card_requires_target = true
	card_type_cast.card_energy_cost = 1
	card_type_cast.card_values = {"damage": 8, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default", "ignored_interceptor_ids": ["interceptor_weaken"]}
	card_type_cast.card_upgrade_value_improvements = {"damage": 4}
	card_type_cast.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: {
				"time_delay": 0.0,
				"actions_on_lethal": [],
			},
		},
	]
	Global.register_rod(card_type_cast)

	# 连接池 — 攻防一体守护进程
	var card_connection_pool: CardData = CardData.new("card_connection_pool")
	card_connection_pool.card_name = "连接池"
	card_connection_pool.card_color_id = "color_{0}".format([color])
	card_connection_pool.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_connection_pool.card_description = "获得 [block] 点防火墙和 [status_charge_amount] 层伤害增强。"
	card_connection_pool.card_type = CardData.CARD_TYPES.POWER
	card_connection_pool.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_connection_pool.card_requires_target = false
	card_connection_pool.card_energy_cost = 1
	card_connection_pool.card_play_destination = HandManager.BANISH_PILE
	card_connection_pool.card_values = {"block": 6, "status_charge_amount": 2}
	card_connection_pool.card_upgrade_value_improvements = {"block": 3, "status_charge_amount": 1}
	card_connection_pool.card_keyword_object_ids = ["keyword_damage_increase"]
	card_connection_pool.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.2,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_damage_increase",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.3,
			},
		},
	]
	Global.register_rod(card_connection_pool)

	# 热修复 — 紧急恢复+后续增益
	var card_hotfix: CardData = CardData.new("card_hotfix")
	card_hotfix.card_name = "热修复"
	card_hotfix.card_color_id = "color_{0}".format([color])
	card_hotfix.card_texture_path = "external/sprites/cards/{0}/card_{0}.png".format([color])
	card_hotfix.card_description = "恢复 [health_amount] 点完整度。物理删除。回合结束时若仍在手牌自动触发并物理删除。"
	card_hotfix.card_type = CardData.CARD_TYPES.SKILL
	card_hotfix.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_hotfix.card_requires_target = false
	card_hotfix.card_energy_cost = 1
	card_hotfix.card_play_destination = HandManager.EXHAUST_PILE
	card_hotfix.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_hotfix.card_values = {"health_amount": 5}
	card_hotfix.card_upgrade_value_improvements = {"health_amount": 3}
	card_hotfix.card_end_of_turn_actions = [
		{
			Scripts.ACTION_ADD_HEALTH: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	card_hotfix.card_play_actions = [
		{
			Scripts.ACTION_ADD_HEALTH: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	Global.register_rod(card_hotfix)

	#endregion
