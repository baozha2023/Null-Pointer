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
	card_commit.card_texture_path = "sprites/card/red/card_commit.png"
	card_commit.card_description = "造成 [damage] 点伤害。打出后，所有代码提交的伤害永久提升 [damage_growth] 点。"
	card_commit.card_type = CardData.CARD_TYPES.ATTACK
	card_commit.card_rarity = CardData.CARD_RARITIES.COMMON
	card_commit.card_requires_target = true
	card_commit.card_energy_cost = 1
	card_commit.card_keyword_object_ids = []
	card_commit.card_values = {
		"damage": 7,
		"number_of_attacks": 1,
		"damage_growth": 1,
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
							"modify_parent_card": true,
							"card_value_improvements": {"damage": card_commit.card_values["damage_growth"]},
						},
					},
				],
			},
		},
		{
			Scripts.ACTION_IMPROVE_CARD_VALUES: {
				"pick_played_card": true,
				"modify_parent_card": true,
				"card_value_improvements": {"damage": card_commit.card_values["damage_growth"]},
			},
		},
	]
	Global.register_rod(card_commit)

	# 栈溢出 — 手牌越多越强
	var card_stack_overflow: CardData = CardData.new("card_stack_overflow")
	card_stack_overflow.card_name = "栈溢出"
	card_stack_overflow.card_color_id = "color_{0}".format([color])
	card_stack_overflow.card_texture_path = "sprites/card/red/card_stack_overflow.png"
	card_stack_overflow.card_description = "造成 [damage] 点伤害。当前线程中每有一个脚本额外造成 [damage_per_card] 点伤害。自身获得 1 层输出降级。"
	card_stack_overflow.card_type = CardData.CARD_TYPES.ATTACK
	card_stack_overflow.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_stack_overflow.card_requires_target = true
	card_stack_overflow.card_energy_cost = 2
	card_stack_overflow.card_values = {"damage": 6, "damage_per_card": 2, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_stack_overflow.card_upgrade_value_improvements = {"damage": 3}
	card_stack_overflow.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_stack_overflow.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "cards_in_hand",
				"action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: {"damage": card_stack_overflow.card_values["damage_per_card"]}},
				],
				"multiplied_values": ["damage"],
				"multiplied_values_bases": {"damage": card_stack_overflow.card_values["damage"]},
			},
		},
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
	card_recursion.card_texture_path = "sprites/card/red/card_recursion.png"
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
	card_binary_search.card_texture_path = "sprites/card/red/card_binary_search.png"
	card_binary_search.card_description = "造成 [damage] 点伤害。如果目标敌人本时钟周期没有攻击意图，额外造成 [bonus_damage] 点伤害。"
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
	card_unit_test.card_texture_path = "sprites/card/red/card_unit_test.png"
	card_unit_test.card_description = "造成 [damage] 点伤害。如果目标完整度低于 [threshold_percent]%，造成 [execution_damage] 点伤害。"
	card_unit_test.card_type = CardData.CARD_TYPES.ATTACK
	card_unit_test.card_rarity = CardData.CARD_RARITIES.COMMON
	card_unit_test.card_requires_target = true
	card_unit_test.card_energy_cost = 1
	card_unit_test.card_values = {"damage": 7, "execution_damage": 12, "threshold_percent": 50, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_unit_test.card_upgrade_value_improvements = {"damage": 3, "execution_damage": 4}
	card_unit_test.card_first_upgrade_value_changes = {"threshold_percent": 60}
	card_unit_test.card_first_upgrade_property_changes = {"card_description": "造成 [damage] 点伤害。如果目标完整度低于 [threshold_percent]%，造成 [execution_damage] 点伤害。"}
	card_unit_test.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_TARGET_HEALTH: {
						"operator": "<=",
						"comparison_value": card_unit_test.card_values["threshold_percent"],
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

	# 异或操作 — 伤害+漏洞暴露
	var card_xor_cipher: CardData = CardData.new("card_xor_cipher")
	card_xor_cipher.card_name = "异或操作"
	card_xor_cipher.card_color_id = "color_{0}".format([color])
	card_xor_cipher.card_texture_path = "sprites/card/red/card_xor_cipher.png"
	card_xor_cipher.card_description = "造成 [damage] 点伤害并对目标施加 [status_charge_amount] 层漏洞暴露。"
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
	card_production_deploy.card_texture_path = "sprites/card/red/card_production_deploy.png"
	card_production_deploy.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害。"
	card_production_deploy.card_type = CardData.CARD_TYPES.ATTACK
	card_production_deploy.card_rarity = CardData.CARD_RARITIES.RARE
	card_production_deploy.card_requires_target = true
	card_production_deploy.card_energy_cost = 2
	card_production_deploy.card_play_destination = HandManager.EXHAUST_PILE
	card_production_deploy.card_values = {"damage": 10, "number_of_attacks": 2, "impact_vfx_animation_id": "animation_vfx_impact_default", "time_delay": 0.3,}
	card_production_deploy.card_upgrade_value_improvements = {"damage": 4}
	card_production_deploy.card_first_upgrade_property_changes = {
		"card_energy_cost": 1,
		"card_description": "造成 [number_of_attacks] 次 [damage] 点伤害。战斗开始时置入当前线程。",
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
	card_force_push.card_texture_path = "sprites/card/red/card_force_push.png"
	card_force_push.card_description = "丢弃所有当前线程脚本，然后读取同等数量的脚本。"
	card_force_push.card_type = CardData.CARD_TYPES.SKILL
	card_force_push.card_rarity = CardData.CARD_RARITIES.COMMON
	card_force_push.card_requires_target = false
	card_force_push.card_energy_cost = 1
	card_force_push.card_values = {"draw_count": 1}
	card_force_push.card_upgrade_value_improvements = {}
	card_force_push.card_first_upgrade_property_changes = {
		"card_description": "丢弃所有当前线程脚本，然后读取同等数量+1的脚本。",
		"card_play_actions": [
			{
				Scripts.ACTION_PICK_CARDS: {
					"card_pick_type": HandManager.HAND_PILE,
					"max_card_amount": 999,
					"min_card_amount": 999,
					"min_cards_are_required_for_action": false,
					"random_selection": true,
					"action_data": [
						{Scripts.ACTION_DRAW_GENERATOR: {}},
						{Scripts.ACTION_DISCARD_CARDS: {}},
						{
							Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
								"combat_stat_name": "cards_in_hand",
								"multiplied_values": ["draw_count"],
								"multiplied_values_bases": {"draw_count": 1},
							},
						},
					],
				},
			},
		],
	}
	card_force_push.card_discard_actions = [
		{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}},
	]
	card_force_push.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.HAND_PILE,
				"max_card_amount": 999,
				"min_card_amount": 999,
				"min_cards_are_required_for_action": false,
				"random_selection": true,
				"action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {}},
					{Scripts.ACTION_DISCARD_CARDS: {}},
					{
						Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
							"combat_stat_name": "cards_in_hand",
							"multiplied_values": ["draw_count"],
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_force_push)

	# 代码审查 — 抽牌+漏洞暴露
	var card_code_review: CardData = CardData.new("card_code_review")
	card_code_review.card_name = "代码审查"
	card_code_review.card_color_id = "color_{0}".format([color])
	card_code_review.card_texture_path = "sprites/card/red/card_code_review.png"
	card_code_review.card_description = "读取 [draw_count] 个脚本，对随机敌人施加 [status_charge_amount] 层漏洞暴露。"
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
	card_try_catch.card_texture_path = "sprites/card/red/card_try_catch.png"
	card_try_catch.card_description = "获得 [block] 点防火墙。如果目标本时钟周期有攻击意图，额外获得 [block_bonus] 点防火墙。"
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
	card_refactor.card_texture_path = "sprites/card/red/card_refactor.png"
	card_refactor.card_description = "永久升级当前线程中的 [card_amount] 个脚本。"
	card_refactor.card_type = CardData.CARD_TYPES.SKILL
	card_refactor.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_refactor.card_requires_target = false
	card_refactor.card_energy_cost = 0
	card_refactor.card_play_destination = HandManager.EXHAUST_PILE
	card_refactor.card_values = {"card_amount": 1, "upgrade_parent_card": true}
	card_refactor.card_upgrade_value_improvements = {}
	card_refactor.card_first_upgrade_value_changes = {"card_amount": 2}
	card_refactor.card_first_upgrade_property_changes = {"card_description": "永久升级当前线程中的 [card_amount] 个脚本。"}
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
	card_template.card_texture_path = "sprites/card/red/card_template.png"
	card_template.card_description = "选择当前线程中的 [card_amount] 个脚本进行复制。"
	card_template.card_type = CardData.CARD_TYPES.SKILL
	card_template.card_rarity = CardData.CARD_RARITIES.COMMON
	card_template.card_requires_target = false
	card_template.card_energy_cost = 1
	card_template.card_play_destination = HandManager.EXHAUST_PILE
	card_template.card_values = {"card_amount": 1}
	card_template.card_upgrade_value_improvements = {"card_amount": 1}
	card_template.card_first_upgrade_property_changes = {"card_play_destination": HandManager.DISCARD_PILE, "card_description": "选择当前线程中的 [card_amount] 个脚本进行复制。"}
	card_template.card_play_actions = [
		{
			Scripts.ACTION_PICK_DUPLICATE_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount", "min_card_amount": "card_amount"},
				"min_cards_are_required_for_action": true,
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择要复制模板的脚本",
				"random_selection": false,
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_HAND: {
							"custom_key_names": {"picked_cards": "generated_cards"},
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_template)

	# 贪心算法 — 预支算力
	var card_greedy_algo: CardData = CardData.new("card_greedy_algo")
	card_greedy_algo.card_name = "贪心算法"
	card_greedy_algo.card_color_id = "color_{0}".format([color])
	card_greedy_algo.card_texture_path = "sprites/card/red/card_greedy_algo.png"
	card_greedy_algo.card_description = "获得 [energy_amount] 点算力，对目标施加 [status_charge_amount] 层漏洞暴露。自身获得 [status_charge_amount] 层漏洞暴露。"
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
				"time_delay": 0.2,
			},
		},
	]
	Global.register_rod(card_greedy_algo)

	# 动态规划 — 预支防御
	var card_dp_cache: CardData = CardData.new("card_dp_cache")
	card_dp_cache.card_name = "动态规划"
	card_dp_cache.card_color_id = "color_{0}".format([color])
	card_dp_cache.card_texture_path = "sprites/card/red/card_dp_cache.png"
	card_dp_cache.card_description = "获得 [block] 点防火墙和 [status_charge_amount] 层缓存防御。"
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
	card_ci_pipeline.card_texture_path = "sprites/card/red/card_ci_pipeline.png"
	card_ci_pipeline.card_description = "获得 [status_charge_amount] 层算力增幅。获得 [draw_count] 层扩容内存队列。"
	card_ci_pipeline.card_type = CardData.CARD_TYPES.POWER
	card_ci_pipeline.card_rarity = CardData.CARD_RARITIES.RARE
	card_ci_pipeline.card_requires_target = false
	card_ci_pipeline.card_energy_cost = 2
	card_ci_pipeline.card_play_destination = HandManager.BANISH_PILE
	card_ci_pipeline.card_values = {"status_charge_amount": 3, "draw_count": 1}
	card_ci_pipeline.card_upgrade_value_improvements = {"status_charge_amount": 2}
	card_ci_pipeline.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_ci_pipeline.card_upgrade_amount_max = 1
	card_ci_pipeline.card_keyword_object_ids = []
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
	card_fork.card_texture_path = "sprites/card/red/card_fork.png"
	card_fork.card_description = "获得 [status_charge_amount] 层多线程攻击。"
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
	card_circuit_breaker.card_texture_path = "sprites/card/red/card_circuit_breaker.png"
	card_circuit_breaker.card_description = "战斗开始时获得 [block] 点防火墙和 [status_charge_amount] 层反伤模块。打牌时再次触发。"
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
	card_type_cast.card_texture_path = "sprites/card/red/card_type_cast.png"
	card_type_cast.card_description = "造成 [damage] 点伤害。不受输出降级影响。"
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
	card_connection_pool.card_texture_path = "sprites/card/red/card_connection_pool.png"
	card_connection_pool.card_description = "获得 [block] 点防火墙和 [status_charge_amount] 层算力增幅。"
	card_connection_pool.card_type = CardData.CARD_TYPES.POWER
	card_connection_pool.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_connection_pool.card_requires_target = false
	card_connection_pool.card_energy_cost = 1
	card_connection_pool.card_play_destination = HandManager.BANISH_PILE
	card_connection_pool.card_values = {"block": 6, "status_charge_amount": 2}
	card_connection_pool.card_upgrade_value_improvements = {"block": 3, "status_charge_amount": 1}
	card_connection_pool.card_keyword_object_ids = []
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
	card_hotfix.card_texture_path = "sprites/card/red/card_hotfix.png"
	card_hotfix.card_description = "恢复 [health_amount] 点完整度。时钟周期结束时若仍在当前线程自动触发。"
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

	#region 系统控制与资源回收

	# 死锁检测 — 高费控制，防御+双debuff
	var card_deadlock: CardData = CardData.new("card_deadlock")
	card_deadlock.card_name = "死锁检测"
	card_deadlock.card_color_id = "color_{0}".format([color])
	card_deadlock.card_texture_path = "sprites/card/red/card_deadlock.png"
	card_deadlock.card_description = "获得 [block] 点防火墙。对随机敌人施加 [vuln_amount] 层漏洞暴露。对随机敌人施加 [weak_amount] 层输出降级。"
	card_deadlock.card_type = CardData.CARD_TYPES.SKILL
	card_deadlock.card_rarity = CardData.CARD_RARITIES.RARE
	card_deadlock.card_requires_target = false
	card_deadlock.card_energy_cost = 3
	card_deadlock.card_values = {"block": 15, "vuln_amount": 3, "weak_amount": 2}
	card_deadlock.card_upgrade_value_improvements = {"block": 5, "vuln_amount": 1, "weak_amount": 1}
	card_deadlock.card_first_upgrade_property_changes = {"card_energy_cost": 2}
	card_deadlock.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.2,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"custom_key_names": {"status_charge_amount": "vuln_amount"},
				"target_override": BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY,
				"time_delay": 0.3,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_weaken",
				"custom_key_names": {"status_charge_amount": "weak_amount"},
				"target_override": BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY,
				"time_delay": 0.4,
			},
		},
	]
	Global.register_rod(card_deadlock)

	# 回滚操作 — 从弃牌堆回收资源
	var card_rollback: CardData = CardData.new("card_rollback")
	card_rollback.card_name = "回滚操作"
	card_rollback.card_color_id = "color_{0}".format([color])
	card_rollback.card_texture_path = "sprites/card/red/card_rollback.png"
	card_rollback.card_description = "将回收站顶部的 [card_amount] 个脚本置入当前线程。"
	card_rollback.card_type = CardData.CARD_TYPES.SKILL
	card_rollback.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_rollback.card_requires_target = false
	card_rollback.card_energy_cost = 1
	card_rollback.card_values = {"card_amount": 1}
	card_rollback.card_upgrade_value_improvements = {"card_amount": 1}
	card_rollback.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_rollback.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount", "min_card_amount": "card_amount"},
				"min_cards_are_required_for_action": false,
				"card_pick_type": HandManager.DISCARD_PILE,
				"random_selection": true,
				"action_data": [
					{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
				],
			},
		},
	]
	Global.register_rod(card_rollback)

	# 内存泄漏 — 回合结束自动触发，伤害逐回合增长
	var card_memory_leak: CardData = CardData.new("card_memory_leak")
	card_memory_leak.card_name = "内存泄漏"
	card_memory_leak.card_color_id = "color_{0}".format([color])
	card_memory_leak.card_texture_path = "sprites/card/red/card_memory_leak.png"
	card_memory_leak.card_description = "造成 [damage] 点伤害。时钟周期结束时若仍在当前线程，对随机敌人造成 [damage] 点伤害并永久提升所有内存泄漏 [damage_growth] 点伤害。"
	card_memory_leak.card_type = CardData.CARD_TYPES.ATTACK
	card_memory_leak.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_memory_leak.card_requires_target = true
	card_memory_leak.card_energy_cost = 2
	card_memory_leak.card_values = {"damage": 5, "damage_growth": 3, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_memory_leak.card_upgrade_value_improvements = {"damage": 3}
	card_memory_leak.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_memory_leak.card_end_of_turn_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"target_override": BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY,
				"bypass_block": false,
				"time_delay": 0.2,
			},
		},
		# 自我成长：回合结束后所有副本伤害永久提升
		{
			Scripts.ACTION_PICK_CARDS: {
				"max_card_amount": 999,
				"min_card_amount": 999,
				"min_cards_are_required_for_action": false,
				"random_selection": false,
				"card_pick_type": HandManager.COMBAT_DECK,
				"card_pick_text": "",
				"validator_data": [
					{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": [card_memory_leak.object_id]}},
				],
				"action_data": [
					{
						Scripts.ACTION_IMPROVE_CARD_VALUES: {
							"pick_played_card": false,
							"modify_parent_card": true,
							"card_value_improvements": {"damage": card_memory_leak.card_values["damage_growth"]},
						},
					},
				],
			},
		},
		{
			Scripts.ACTION_IMPROVE_CARD_VALUES: {
				"pick_played_card": true,
				"modify_parent_card": true,
				"card_value_improvements": {"damage": card_memory_leak.card_values["damage_growth"]},
			},
		},
	]
	card_memory_leak.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: {}},
	]
	Global.register_rod(card_memory_leak)

	# 并发攻击 — 多段+AOE溅射
	var card_concurrent_attack: CardData = CardData.new("card_concurrent_attack")
	card_concurrent_attack.card_name = "并发攻击"
	card_concurrent_attack.card_color_id = "color_{0}".format([color])
	card_concurrent_attack.card_texture_path = "sprites/card/red/card_concurrent_attack.png"
	card_concurrent_attack.card_description = "对目标造成 [number_of_attacks] 次 [damage] 点伤害，并对所有敌人造成 [aoe_damage] 点伤害。"
	card_concurrent_attack.card_type = CardData.CARD_TYPES.ATTACK
	card_concurrent_attack.card_rarity = CardData.CARD_RARITIES.RARE
	card_concurrent_attack.card_requires_target = true
	card_concurrent_attack.card_energy_cost = 3
	card_concurrent_attack.card_values = {"damage": 7, "number_of_attacks": 3, "aoe_damage": 5, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_concurrent_attack.card_upgrade_value_improvements = {"damage": 2, "aoe_damage": 2}
	card_concurrent_attack.card_first_upgrade_property_changes = {"card_energy_cost": 2}
	card_concurrent_attack.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: {
				"time_delay": 0.12,
				"actions_on_lethal": [],
			},
		},
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {"damage": "aoe_damage"},
				"bypass_block": false,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
				"time_delay": 0.4,
			},
		},
	]
	Global.register_rod(card_concurrent_attack)

	# 编译优化 — 永久降费
	var card_compile_opt: CardData = CardData.new("card_compile_opt")
	card_compile_opt.card_name = "编译优化"
	card_compile_opt.card_color_id = "color_{0}".format([color])
	card_compile_opt.card_texture_path = "sprites/card/red/card_compile_opt.png"
	card_compile_opt.card_description = "永久减少当前线程中 [card_amount] 个脚本的耗能 [cost_reduction] 点（最低为 0）。"
	card_compile_opt.card_type = CardData.CARD_TYPES.SKILL
	card_compile_opt.card_rarity = CardData.CARD_RARITIES.RARE
	card_compile_opt.card_requires_target = false
	card_compile_opt.card_energy_cost = 2
	card_compile_opt.card_play_destination = HandManager.BANISH_PILE
	card_compile_opt.card_values = {"card_amount": 1, "cost_reduction": 1}
	card_compile_opt.card_upgrade_value_improvements = {"card_amount": 1}
	card_compile_opt.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_compile_opt.card_upgrade_amount_max = 1
	card_compile_opt.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount", "min_card_amount": "card_amount"},
				"min_cards_are_required_for_action": false,
				"card_pick_text": "选择要优化的脚本",
				"card_pick_type": HandManager.HAND_PILE,
				"random_selection": false,
				"validator_data": [
					{
						Scripts.VALIDATOR_CARD_PROPERTIES: {
							"card_property_name": "card_energy_cost",
							"operator": ">",
							"comparison_value": 0,
						},
					},
				],
				"action_data": [
					{
						Scripts.ACTION_IMPROVE_CARD_PROPERTIES: {
							"modify_parent_card": true,
							"card_property_improvements": {"card_energy_cost": -1},
						},
					},
				],
			},
		},
		{
			Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {
				"pick_played_card": true
			}
		}
	]
	Global.register_rod(card_compile_opt)

	# 缓冲区溢出 — 随漏洞暴露增加伤害
	var card_buffer_overflow: CardData = CardData.new("card_buffer_overflow")
	card_buffer_overflow.card_name = "缓冲区溢出"
	card_buffer_overflow.card_color_id = "color_{0}".format([color])
	card_buffer_overflow.card_texture_path = "sprites/card/red/card_buffer_overflow.png"
	card_buffer_overflow.card_description = "造成 [damage] 点伤害。目标每有一层漏洞暴露，额外造成 [bonus_damage] 点伤害。"
	card_buffer_overflow.card_type = CardData.CARD_TYPES.ATTACK
	card_buffer_overflow.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_buffer_overflow.card_requires_target = true
	card_buffer_overflow.card_energy_cost = 1
	card_buffer_overflow.card_values = {"damage": 5, "bonus_damage": 3, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_buffer_overflow.card_upgrade_value_improvements = {"damage": 2, "bonus_damage": 1}
	card_buffer_overflow.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "target_status_effect_charges",
				"stat_variable_name": "status_effect_vulnerable",
				"action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: {"damage": card_buffer_overflow.card_values["bonus_damage"]}},
				],
				"multiplied_values": ["damage"],
				"multiplied_values_bases": {"damage": card_buffer_overflow.card_values["damage"]},
			},
		},
	]
	Global.register_rod(card_buffer_overflow)

	# 空指针异常 — 随机多次攻击
	var card_null_pointer: CardData = CardData.new("card_null_pointer")
	card_null_pointer.card_name = "空指针异常"
	card_null_pointer.card_color_id = "color_{0}".format([color])
	card_null_pointer.card_texture_path = "sprites/card/red/card_null_pointer.png"
	card_null_pointer.card_description = "随机对场上任意单位（含自己）造成 [damage] 点伤害，触发 [number_of_attacks] 次。"
	card_null_pointer.card_type = CardData.CARD_TYPES.ATTACK
	card_null_pointer.card_rarity = CardData.CARD_RARITIES.RARE
	card_null_pointer.card_requires_target = false
	card_null_pointer.card_energy_cost = 2
	card_null_pointer.card_values = {"damage": 4, "number_of_attacks": 8, "impact_vfx_animation_id": "animation_vfx_impact_default", "time_delay": 0.15}
	card_null_pointer.card_upgrade_value_improvements = {"number_of_attacks": 2}
	card_null_pointer.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: {
				"target_override": BaseAction.TARGET_OVERRIDES.RANDOM_COMBATANT,
				"time_delay": 0.15,
			},
		},
	]
	Global.register_rod(card_null_pointer)

	# 线程同步 — 条件激活防御过牌
	var card_thread_sync: CardData = CardData.new("card_thread_sync")
	card_thread_sync.card_name = "线程同步"
	card_thread_sync.card_color_id = "color_{0}".format([color])
	card_thread_sync.card_texture_path = "sprites/card/red/card_thread_sync.png"
	card_thread_sync.card_description = "仅在本时钟周期已打出至少 [card_count] 个脚本时才能打出。获得 [block] 点防火墙，读取 [draw_count] 个脚本。"
	card_thread_sync.card_type = CardData.CARD_TYPES.SKILL
	card_thread_sync.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_thread_sync.card_requires_target = false
	card_thread_sync.card_energy_cost = 2
	card_thread_sync.card_values = {"block": 8, "draw_count": 2, "card_count": 3}
	card_thread_sync.card_upgrade_value_improvements = {"block": 4}
	card_thread_sync.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_STATS: {
				"stat_enum": CombatStatsData.STATS.CARDS_PLAYED,
				"turn_stat_type": 0,
				"operator": ">=",
				"comparison_value": 3,
			},
		},
	]
	card_thread_sync.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
		{Scripts.ACTION_DRAW_GENERATOR: {}},
	]
	Global.register_rod(card_thread_sync)

	# 内核恐慌 — 条件激活斩杀反杀
	var card_kernel_panic: CardData = CardData.new("card_kernel_panic")
	card_kernel_panic.card_name = "内核恐慌"
	card_kernel_panic.card_color_id = "color_{0}".format([color])
	card_kernel_panic.card_texture_path = "sprites/card/red/card_kernel_panic.png"
	card_kernel_panic.card_description = "仅在[前置时钟周期]受到过至少 [damage_taken] 点伤害时才能打出。造成 [damage] 点伤害，恢复 [health_amount] 点完整度。物理删除。"
	card_kernel_panic.card_type = CardData.CARD_TYPES.ATTACK
	card_kernel_panic.card_rarity = CardData.CARD_RARITIES.RARE
	card_kernel_panic.card_requires_target = true
	card_kernel_panic.card_energy_cost = 3
	card_kernel_panic.card_is_retained = true
	card_kernel_panic.card_keyword_object_ids = ["keyword_retain"]
	card_kernel_panic.card_play_destination = HandManager.EXHAUST_PILE
	card_kernel_panic.card_values = {"damage": 20, "health_amount": 10, "damage_taken": 10, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_kernel_panic.card_upgrade_value_improvements = {"damage": 8, "health_amount": 4}
	card_kernel_panic.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_STATS: {
				"stat_enum": CombatStatsData.STATS.PLAYER_DAMAGED_AMOUNT,
				"turn_stat_type": 1,
				"operator": ">=",
				"comparison_value": 10,
			},
		},
	]
	card_kernel_panic.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: {}},
		{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	Global.register_rod(card_kernel_panic)

	# 敏捷开发 — 基础攻击+过牌
	var card_agile_development: CardData = CardData.new("card_agile_development")
	card_agile_development.card_name = "敏捷开发"
	card_agile_development.card_color_id = "color_{0}".format([color])
	card_agile_development.card_texture_path = "sprites/card/red/card_agile_development.png"
	card_agile_development.card_description = "造成 [damage] 点伤害。读取 [draw_count] 个脚本。将一张[运行时注入]添加至当前线程中。"
	card_agile_development.card_type = CardData.CARD_TYPES.ATTACK
	card_agile_development.card_rarity = CardData.CARD_RARITIES.COMMON
	card_agile_development.card_requires_target = true
	card_agile_development.card_energy_cost = 2
	card_agile_development.card_values = {"damage": 6, "draw_count": 1, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_agile_development.card_upgrade_value_improvements = {"damage": 3}
	card_agile_development.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: {}},
		{Scripts.ACTION_DRAW_GENERATOR: {}},
		{
			Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_runtime_injection",
				"created_card_count": 1,
				"action_data": [
					{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
				],
			},
		},
	]
	Global.register_rod(card_agile_development)

	# 依赖注入 — 换取隐藏衍生卡
	var card_dependency_injection: CardData = CardData.new("card_dependency_injection")
	card_dependency_injection.card_name = "依赖注入"
	card_dependency_injection.card_color_id = "color_{0}".format([color])
	card_dependency_injection.card_texture_path = "sprites/card/red/card_dependency_injection.png"
	card_dependency_injection.card_description = "物理删除当前线程中的一个脚本，将一张[运行时注入]添加至当前线程中。"
	card_dependency_injection.card_type = CardData.CARD_TYPES.SKILL
	card_dependency_injection.card_rarity = CardData.CARD_RARITIES.COMMON
	card_dependency_injection.card_requires_target = false
	card_dependency_injection.card_energy_cost = 1
	card_dependency_injection.card_values = {"card_amount": 1}
	card_dependency_injection.card_upgrade_value_improvements = {}
	card_dependency_injection.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_dependency_injection.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount", "min_card_amount": "card_amount"},
				"min_cards_are_required_for_action": false,
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择要删除的脚本",
				"random_selection": false,
				"action_data": [
					{Scripts.ACTION_EXHAUST_CARDS: {}},
					{
						Scripts.ACTION_CREATE_CARDS: {
							"custom_key_names": {},
							"created_card_object_id": "card_runtime_injection",
							"created_card_count": 1,
							"action_data": [
								{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
							],
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_dependency_injection)

	# 运行时注入 — 动态生成稀有度
	var card_runtime_injection: CardData = CardData.new("card_runtime_injection")
	card_runtime_injection.card_name = "运行时注入"
	card_runtime_injection.card_color_id = "color_{0}".format([color])
	card_runtime_injection.card_texture_path = "sprites/card/red/card_runtime_injection.png"
	card_runtime_injection.card_description = "获得 [block] 点防火墙，获得 [energy_amount] 点算力。物理删除。"
	card_runtime_injection.card_type = CardData.CARD_TYPES.SKILL
	card_runtime_injection.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_runtime_injection.card_requires_target = false
	card_runtime_injection.card_energy_cost = 0
	card_runtime_injection.card_play_destination = HandManager.EXHAUST_PILE
	card_runtime_injection.card_values = {"block": 5, "energy_amount": 1}
	card_runtime_injection.card_upgrade_value_improvements = {"block": 3}
	card_runtime_injection.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
		{Scripts.ACTION_ADD_ENERGY: {}},
	]
	Global.register_rod(card_runtime_injection)

	#endregion
