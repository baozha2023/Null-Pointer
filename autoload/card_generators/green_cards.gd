
class_name GlobalProdDataGeneratorGreenCards
extends RefCounted

static func add_cards_green() -> void:
	var color: String = "green"

	#region Health and Self Damage

	# Blossom
	var card_blossom: CardData = CardData.new("card_blossom")
	card_blossom.card_name = "数字绽放"
	card_blossom.card_color_id = "color_{0}".format([color])
	card_blossom.card_texture_path = "sprites/card/green/card_blossom.png"
	card_blossom.card_description = "恢复 [health_amount] 点完整度。[color=green]培育 [cultivate_amount][/color]。"
	card_blossom.card_hint = "回复生命（完整度）；打出后本场战斗不再出现。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_blossom.card_keyword_object_ids = ["keyword_cultivate"]
	card_blossom.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_blossom.card_type = CardData.CARD_TYPES.SKILL
	card_blossom.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_blossom.card_requires_target = false
	card_blossom.card_play_destination = HandManager.EXHAUST_PILE
	card_blossom.card_values = { "health_amount": 6, "cultivate_amount": 2 }
	card_blossom.card_upgrade_value_improvements = { "health_amount": 3 }
	card_blossom.card_play_actions = [
		{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_blossom)

	# Bud
	var card_bud: CardData = CardData.new("card_bud")
	card_bud.card_name = "仿生花蕾"
	card_bud.card_color_id = "color_{0}".format([color])
	card_bud.card_texture_path = "sprites/card/green/card_bud.png"
	card_bud.card_description = "自己获得 [parent_status_charge_amount] 层 [status_icon:status_effect_pointy]。目标获得 [target_status_charge_amount] 层 [status_icon:status_effect_pointy]。[color=green]培育 [cultivate_amount][/color]。"
	card_bud.card_hint = "给自己和目标叠加 [status_icon:status_effect_pointy]（受到攻击时会反弹等量伤害给攻击者）。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_bud.card_keyword_object_ids = ["keyword_cultivate"]
	card_bud.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_bud.card_type = CardData.CARD_TYPES.SKILL
	card_bud.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_bud.card_requires_target = true
	card_bud.card_play_destination = HandManager.EXHAUST_PILE
	card_bud.card_values = { "parent_status_charge_amount": 5, "target_status_charge_amount": 2, "cultivate_amount": 2 }
	card_bud.card_upgrade_value_improvements = { "parent_status_charge_amount": 3 }
	card_bud.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_pointy",
				"custom_key_names": { "status_charge_amount": "target_status_charge_amount" },
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_pointy",
				"custom_key_names": { "status_charge_amount": "parent_status_charge_amount" },
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_bud)

	# Cell Wall
	var card_cell_wall: CardData = CardData.new("card_cell_wall")
	card_cell_wall.card_name = "细胞防火墙"
	card_cell_wall.card_color_id = "color_{0}".format([color])
	card_cell_wall.card_texture_path = "sprites/card/green/card_cell_wall.png"
	card_cell_wall.card_description = "移除防火墙，并获得与防火墙数值一致的 [status_icon:status_effect_overshield]。[color=green]培育 [cultivate_amount][/color]。"
	card_cell_wall.card_hint = "把当前护盾（防火墙）全部转成等量的 [status_icon:status_effect_overshield]（可跨回合保留、不会每回合清零的护盾）。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_cell_wall.card_keyword_object_ids = ["keyword_cultivate"]
	card_cell_wall.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_cell_wall.card_type = CardData.CARD_TYPES.SKILL
	card_cell_wall.card_rarity = CardData.CARD_RARITIES.COMMON
	card_cell_wall.card_requires_target = false
	card_cell_wall.card_values = { "cultivate_amount": 1 }
	card_cell_wall.card_first_upgrade_property_changes = { "card_energy_cost": 0 }
	card_cell_wall.card_play_actions = [
		{
			Scripts.ACTION_BLOCK_TO_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_cell_wall)

	# Chloroplast
	var card_chloroplast: CardData = CardData.new("card_chloroplast")
	card_chloroplast.card_name = "光合引擎"
	card_chloroplast.card_color_id = "color_{0}".format([color])
	card_chloroplast.card_texture_path = "sprites/card/green/card_chloroplast.png"
	card_chloroplast.card_description = "对所有敌人造成 [damage] 点伤害。被物理删除时，对所有单位造成 [exhaust_damage] 点伤害。[color=green]培育 [cultivate_amount][/color]。"
	card_chloroplast.card_hint = "对所有敌人造成高额伤害；当它被物理删除（进入坏道区）时，再对包括你自己在内的全场造成一次伤害。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_chloroplast.card_keyword_object_ids = ["keyword_cultivate"]
	card_chloroplast.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_chloroplast.card_type = CardData.CARD_TYPES.ATTACK
	card_chloroplast.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_chloroplast.card_energy_cost = 3
	card_chloroplast.card_requires_target = false
	card_chloroplast.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_chloroplast.card_values = { "damage": 35, "exhaust_damage": 10, "impact_vfx_animation_id": "animation_vfx_magic_green", "cultivate_amount": 3 }
	card_chloroplast.card_upgrade_value_improvements = { "damage": 10 }
	card_chloroplast.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"number_of_attacks": 1,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	card_chloroplast.card_exhaust_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"custom_key_names": { "damage": "exhaust_damage" },
				"number_of_attacks": 1,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS,
			},
		},
	]
	Global.register_rod(card_chloroplast)

	# Clippers
	var card_clippers: CardData = CardData.new("card_clippers")
	card_clippers.card_name = "基因剪刀"
	card_clippers.card_color_id = "color_{0}".format([color])
	card_clippers.card_texture_path = "sprites/card/green/card_clippers.png"
	card_clippers.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害。获得 [status_charge_amount] 层 [status_icon:status_effect_damage_increase]。加入脚本库时，失去 [health_amount] 点完整度。[color=green]培育 [cultivate_amount][/color]。"
	card_clippers.card_hint = "多段攻击并获得 [status_icon:status_effect_damage_increase]（提高之后的攻击伤害）；此牌加入牌组时会扣一次生命，且只扣这一次。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_clippers.card_type = CardData.CARD_TYPES.ATTACK
	card_clippers.card_rarity = CardData.CARD_RARITIES.COMMON
	card_clippers.card_keyword_object_ids = ["keyword_cultivate"]
	card_clippers.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_clippers.card_values = { "damage": 5, "number_of_attacks": 2, "health_amount": -5, "status_effect_object_id": "status_effect_damage_increase", "status_charge_amount": 2, "impact_vfx_animation_id": "animation_vfx_slash_green", "cultivate_amount": 2 }
	card_clippers.card_upgrade_value_improvements = { "damage": 2 }
	card_clippers.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: { "status_effect_object_id": "status_effect_damage_increase", "time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.PARENT },
		},
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB,  "time_delay": 0.3 },
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	card_clippers.card_add_to_deck_actions = [
		{
			Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT },
		},
	]
	Global.register_rod(card_clippers)

	# Differentiation
	var card_differentiation: CardData = CardData.new("card_differentiation")
	card_differentiation.card_name = "进程分化"
	card_differentiation.card_color_id = "color_{0}".format([color])
	card_differentiation.card_texture_path = "sprites/card/green/card_differentiation.png"
	card_differentiation.card_description = "造成 [damage] 点伤害。失去 [self_damage] 点完整度。[color=green]培育 [cultivate_amount][/color]。"
	card_differentiation.card_hint = "对目标造成高伤害，但你自己也会损失少量生命（完整度）。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_differentiation.card_keyword_object_ids = ["keyword_cultivate"]
	card_differentiation.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_differentiation.card_type = CardData.CARD_TYPES.ATTACK
	card_differentiation.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_differentiation.card_requires_target = true
	card_differentiation.card_values = { "damage": 12, "self_damage": 2, "cultivate_amount": 3 }
	card_differentiation.card_upgrade_value_improvements = { "damage": 5 }
	card_differentiation.card_play_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": { "damage": "self_damage" },
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"bypass_block": true,
			},
		},
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"number_of_attacks": 1,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_differentiation)

	# Fertilize
	var card_fertilize: CardData = CardData.new("card_fertilize")
	card_fertilize.card_name = "过载注入"
	card_fertilize.card_color_id = "color_{0}".format([color])
	card_fertilize.card_texture_path = "sprites/card/green/card_fertilize.png"
	card_fertilize.card_description = "失去 [self_damage] 点完整度，获得 [energy_amount] 点算力。将当前防火墙全部转化为 [status_icon:status_effect_overshield]。[color=green]培育 [cultivate_amount][/color]。"
	card_fertilize.card_hint = "损失部分生命（完整度）换取大量能量（算力），并把当前护盾全部转成可跨回合保留的 [status_icon:status_effect_overshield]。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_fertilize.card_keyword_object_ids = ["keyword_cultivate"]
	card_fertilize.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_fertilize.card_rarity = CardData.CARD_RARITIES.RARE
	card_fertilize.card_requires_target = false
	card_fertilize.card_values = { "self_damage": 10, "energy_amount": 3, "cultivate_amount": 6 }
	card_fertilize.card_upgrade_value_improvements = { "energy_amount": 1 }
	card_fertilize.card_first_upgrade_property_changes = { "card_description": "失去 [self_damage] 点完整度，获得 [energy_amount] 点算力。将当前防火墙全部转化为 [status_icon:status_effect_overshield]。[color=green]培育 [cultivate_amount][/color]。" }
	card_fertilize.card_play_actions = [
		{
			Scripts.ACTION_BLOCK_TO_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
		{ Scripts.ACTION_ADD_ENERGY: { } },
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": { "damage": "self_damage" },
				"bypass_block": true,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_fertilize)

	# Fruit
	var card_fruit: CardData = CardData.new("card_fruit")
	card_fruit.card_name = "数据果实"
	card_fruit.card_color_id = "color_{0}".format([color])
	card_fruit.card_texture_path = "sprites/card/green/card_fruit.png"
	card_fruit.card_description = "随机触发以下一项：获得 [small_max_health_amount] 点最大完整度，或获得 [big_max_health_amount] 点最大完整度，或获得 [energy_amount] 点算力。[color=green]培育 [cultivate_amount][/color]。"
	card_fruit.card_hint = "随机获得最大生命提升，或立刻获得能量（算力）；用后从牌组永久移除。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_fruit.card_keyword_object_ids = ["keyword_cultivate"]
	card_fruit.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_fruit.card_type = CardData.CARD_TYPES.SKILL
	card_fruit.card_rarity = CardData.CARD_RARITIES.COMMON
	card_fruit.card_requires_target = false
	card_fruit.card_play_destination = HandManager.BANISH_PILE
	card_fruit.card_values = { "small_max_health_amount": 1, "big_max_health_amount": 3, "energy_amount": 1, "cultivate_amount": 6 }
	card_fruit.card_upgrade_value_improvements = { "small_max_health_amount": 1, "big_max_health_amount": 1 }
	card_fruit.card_play_actions = [
		{
			Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {
				"pick_played_card": true
			}
		},
		{
			Scripts.ACTION_RANDOM_SELECTION: {
				"weights": { "small_max_hp": 25, "big_max_hp": 25, "energy": 50 },
				"weighted_action_data": {
					"small_max_hp": [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_amount": 0, "custom_key_names": { "health_max_amount": "small_max_health_amount" } } }],
					"big_max_hp": [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_amount": 0, "custom_key_names": { "health_max_amount": "big_max_health_amount" } } }],
					"energy": [{ Scripts.ACTION_ADD_ENERGY: { } }],
				},
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_fruit)

	# Growth
	var card_growth: CardData = CardData.new("card_growth")
	card_growth.card_name = "动态扩容"
	card_growth.card_color_id = "color_{0}".format([color])
	card_growth.card_texture_path = "sprites/card/green/card_growth.png"
	card_growth.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_overshield]。读取 [draw_count] 个脚本。[color=green]培育 [cultivate_amount][/color]。"
	card_growth.card_hint = "获得 [status_icon:status_effect_overshield]（可跨回合保留的护盾）并摸牌；打出后本场战斗不再出现。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_growth.card_keyword_object_ids = ["keyword_cultivate"]
	card_growth.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_growth.card_type = CardData.CARD_TYPES.SKILL
	card_growth.card_rarity = CardData.CARD_RARITIES.COMMON
	card_growth.card_requires_target = false
	card_growth.card_play_destination = HandManager.EXHAUST_PILE
	card_growth.card_values = { "status_charge_amount": 5, "draw_count": 1, "cultivate_amount": 3 }
	card_growth.card_upgrade_value_improvements = { "status_charge_amount": 3 }
	card_growth.card_play_actions = [
		{
			Scripts.ACTION_DRAW_GENERATOR: { },
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_growth)

	# Lotus
	var card_lotus: CardData = CardData.new("card_lotus")
	card_lotus.card_name = "黑莲花协议"
	card_lotus.card_color_id = "color_{0}".format([color])
	card_lotus.card_texture_path = "sprites/card/green/card_lotus.png"
	card_lotus.card_description = "使 [status_icon:status_effect_overshield] 层数变为 [status_effect_multiplier_amount] 倍。[color=green]培育 [cultivate_amount][/color]。"
	card_lotus.card_hint = "把你当前的 [status_icon:status_effect_overshield] 层数翻倍；打出后本场战斗不再出现。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_lotus.card_keyword_object_ids = ["keyword_cultivate"]
	card_lotus.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_lotus.card_rarity = CardData.CARD_RARITIES.COMMON
	card_lotus.card_requires_target = false
	card_lotus.card_play_destination = HandManager.EXHAUST_PILE
	card_lotus.card_values = { "status_effect_multiplier_amount": 2, "cultivate_amount": 6 }
	card_lotus.card_upgrade_value_improvements = { "status_effect_multiplier_amount": 1 }
	card_lotus.card_first_upgrade_property_changes = { "card_description": "使 [status_icon:status_effect_overshield] 层数变为 [status_effect_multiplier_amount] 倍。[color=green]培育 [cultivate_amount][/color]。" }
	card_lotus.card_play_actions = [
		{
			Scripts.ACTION_MULTIPLY_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_lotus)

	# Moss
	var card_moss: CardData = CardData.new("card_moss")
	card_moss.card_name = "寄生脚本"
	card_moss.card_color_id = "color_{0}".format([color])
	card_moss.card_texture_path = "sprites/card/green/card_moss.png"
	card_moss.card_description = "造成等同于 [status_icon:status_effect_overshield] 层数的伤害。获得 [status_charge_amount] 层 [status_icon:status_effect_overshield]。[color=green]培育 [cultivate_amount][/color]。"
	card_moss.card_hint = "先获得 [status_icon:status_effect_overshield]（可跨回合保留的护盾），再造成等同于当前 [status_icon:status_effect_overshield] 层数的伤害。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_moss.card_keyword_object_ids = ["keyword_cultivate"]
	card_moss.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_moss.card_type = CardData.CARD_TYPES.ATTACK
	card_moss.card_rarity = CardData.CARD_RARITIES.COMMON
	card_moss.card_energy_cost = 2
	card_moss.card_requires_target = true
	card_moss.card_values = { "status_charge_amount": 8, "cultivate_amount": 2 }
	card_moss.card_upgrade_value_improvements = { "status_charge_amount": 4 }
	card_moss.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS,
				"forced_interceptor_ids": ["interceptor_damage_from_overshield"],
				"time_delay": 0.3,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_moss)

	# Pollen
	var card_pollen: CardData = CardData.new("card_pollen")
	card_pollen.card_name = "数据花粉"
	card_pollen.card_color_id = "color_{0}".format([color])
	card_pollen.card_texture_path = "sprites/card/green/card_pollen.png"
	card_pollen.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_pollen]，副层数为 [status_secondary_charge_amount]。[color=green]培育 [cultivate_amount][/color]。"
	card_pollen.card_hint = "获得 [status_icon:status_effect_pollen]：之后每回合会损失少量生命，但同时多摸几张牌。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_pollen.card_keyword_object_ids = ["keyword_cultivate"]
	card_pollen.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_pollen.card_type = CardData.CARD_TYPES.POWER
	card_pollen.card_rarity = CardData.CARD_RARITIES.RARE
	card_pollen.card_energy_cost = 3
	card_pollen.card_requires_target = false
	card_pollen.card_values = { "status_charge_amount": 5, "status_secondary_charge_amount": 2, "cultivate_amount": 4 }
	card_pollen.card_upgrade_value_improvements = { "status_secondary_charge_amount": 1 }
	card_pollen.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_pollen",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_pollen)

	# Petals
	var card_petals: CardData = CardData.new("card_petals")
	card_petals.card_name = "碎片化"
	card_petals.card_color_id = "color_{0}".format([color])
	card_petals.card_texture_path = "sprites/card/green/card_petals.png"
	card_petals.card_description = "获得 [block] 点防火墙。获得 [status_charge_amount] 层 [status_icon:status_effect_temp_preserve_block]。加入脚本库时，失去 [health_amount] 点完整度。[color=green]培育 [cultivate_amount][/color]。"
	card_petals.card_hint = "获得大量护盾，并用 [status_icon:status_effect_temp_preserve_block] 让护盾在回合结束时不清零；此牌加入牌组时扣一次生命。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_petals.card_type = CardData.CARD_TYPES.SKILL
	card_petals.card_rarity = CardData.CARD_RARITIES.RARE
	card_petals.card_requires_target = false
	card_petals.card_play_destination = HandManager.EXHAUST_PILE
	card_petals.card_energy_cost = 3
	card_petals.card_keyword_object_ids = ["keyword_cultivate"]
	card_petals.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_petals.card_values = { "block": 20, "status_charge_amount": 2, "health_amount": -5, "cultivate_amount": 4 }
	card_petals.card_upgrade_value_improvements = { "block": 5, "status_charge_amount": 1 }
	card_petals.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"time_delay": 0.5,
				"status_effect_object_id": "status_effect_temp_preserve_block",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	card_petals.card_add_to_deck_actions = [
		{
			Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT },
		},
	]
	Global.register_rod(card_petals)

	# Reap
	var card_reap: CardData = CardData.new("card_reap")
	card_reap.card_name = "内存收割"
	card_reap.card_color_id = "color_{0}".format([color])
	card_reap.card_texture_path = "sprites/card/green/card_reap.png"
	card_reap.card_description = "造成 [damage] 点伤害。获得等同于实际伤害量的 [status_icon:status_effect_overshield]。[color=green]培育 [cultivate_amount][/color]。"
	card_reap.card_hint = "造成伤害，并按实际造成的伤害获得等量 [status_icon:status_effect_overshield]（可跨回合保留的护盾）。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_reap.card_keyword_object_ids = ["keyword_cultivate"]
	card_reap.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_reap.card_type = CardData.CARD_TYPES.ATTACK
	card_reap.card_rarity = CardData.CARD_RARITIES.COMMON
	card_reap.card_energy_cost = 2
	card_reap.card_requires_target = true
	card_reap.card_values = { "damage": 10, "impact_vfx_animation_id": "animation_vfx_magic_green", "cultivate_amount": 3 }
	card_reap.card_upgrade_value_improvements = { "damage": 4 }
	card_reap.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"custom_key_names": { "status_charge_amount": "unblocked_damage_capped" },
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS,
				"time_delay": 0.3,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_reap)

	# Wildflower
	var card_wildflower: CardData = CardData.new("card_wildflower")
	card_wildflower.card_name = "野生进程"
	card_wildflower.card_color_id = "color_{0}".format([color])
	card_wildflower.card_texture_path = "sprites/card/green/card_wildflower.png"
	card_wildflower.card_energy_cost = 2
	card_wildflower.card_description = "造成 [damage] 点伤害。若[前置时钟周期]受到过伤害，则耗能为 0。[color=green]培育 [cultivate_amount][/color]。"
	card_wildflower.card_hint = "会留在手里的攻击牌；若你在上一回合受到过伤害，这回合打出它不花费用。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_wildflower.card_is_retained = true
	card_wildflower.card_keyword_object_ids = ["keyword_retain", "keyword_cultivate"]
	card_wildflower.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_wildflower.card_type = CardData.CARD_TYPES.ATTACK
	card_wildflower.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_wildflower.card_requires_target = true
	card_wildflower.card_values = { "damage": 15, "number_of_attacks": 1, "cultivate_amount": 2, "impact_vfx_animation_id": "animation_vfx_magic_green" }
	card_wildflower.card_upgrade_value_improvements = { "damage": 5 }
	card_wildflower.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB,  },
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	card_wildflower.add_card_decorator(
		"card_decorator_dynamic_cost_modifier",
		{
			"modifiy_card_energy_cost_until_combat": false,
			"modifiy_card_energy_cost_until_played": false,
			"modifiy_card_energy_cost_until_turn": true,
			"stat_enum": CombatStatsData.STATS.PLAYER_DAMAGED_COUNT,
			"turn_stat_type": 1,
			"energy_per_stat": -10,
		},
	)

	Global.register_rod(card_wildflower)

	# Symbiosis
	var card_symbiosis: CardData = CardData.new("card_symbiosis")
	card_symbiosis.card_name = "共生协议"
	card_symbiosis.card_color_id = "color_{0}".format([color])
	card_symbiosis.card_texture_path = "sprites/card/green/card_symbiosis.png"
	card_symbiosis.card_description = "获得 [status_icon:status_effect_preserve_overshield]。[color=green]伊甸母树获得 [ring_amount] 层年轮[/color]。"
	card_symbiosis.card_hint = "获得 [status_icon:status_effect_preserve_overshield]，使你的 [status_icon:status_effect_overshield] 不再每回合衰减。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_symbiosis.card_status_effect_object_ids = ["status_effect_world_tree_rings"]
	card_symbiosis.card_type = CardData.CARD_TYPES.POWER
	card_symbiosis.card_rarity = CardData.CARD_RARITIES.RARE
	card_symbiosis.card_energy_cost = 3
	card_symbiosis.card_requires_target = false
	card_symbiosis.card_values = { "status_charge_amount": 0, "ring_amount": 1 }
	card_symbiosis.card_upgrade_value_improvements = { "status_charge_amount": 20 }
	card_symbiosis.card_first_upgrade_property_changes = {
		"card_description": "获得 [status_icon:status_effect_preserve_overshield]。获得 [status_charge_amount] 层 [status_icon:status_effect_overshield]。[color=green]伊甸母树获得 [ring_amount] 层年轮[/color]。",
		"card_play_actions": [
			{
				Scripts.ACTION_APPLY_STATUS: {
					"status_effect_object_id": "status_effect_overshield",
					"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				},
			},
			{
				Scripts.ACTION_APPLY_STATUS: {
					"status_effect_object_id": "status_effect_preserve_overshield",
					"status_charge_amount": 1,
					"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				},
			},
			{
				Scripts.ACTION_OPERATE_FRIENDLY: {
					"artifact_id": "artifact_eden_root_core",
					"friendly_ids": ["friendly_eden_world_tree"],
					"force_dead_targets": true,
					"friendly_action_data": [
						{Scripts.ACTION_APPLY_STATUS: {
							"status_effect_object_id": "status_effect_world_tree_rings",
							"custom_key_names": {"status_charge_amount": "ring_amount"},
							"status_secondary_charge_amount": 0,
							"status_force_apply_new_effect": false,
							"status_custom_values": {},
						}},
					],
				},
			},
		],
	}
	card_symbiosis.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_preserve_overshield",
				"status_charge_amount": 1,
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_rings",
						"custom_key_names": {"status_charge_amount": "ring_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
				],
			},
		},
	]

	Global.register_rod(card_symbiosis)

	# Thorns
	var card_thorns: CardData = CardData.new("card_thorns")
	card_thorns.card_name = "反伤木马"
	card_thorns.card_color_id = "color_{0}".format([color])
	card_thorns.card_texture_path = "sprites/card/green/card_thorns.png"
	card_thorns.card_description = "获得 [block] 点防火墙。获得 [status_charge_amount] 层 [status_icon:status_effect_pointy]。[color=green]培育 [cultivate_amount][/color]。"
	card_thorns.card_hint = "获得护盾（防火墙）和 [status_icon:status_effect_pointy]（受到攻击时反弹等量伤害给攻击者）。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_thorns.card_keyword_object_ids = ["keyword_cultivate"]
	card_thorns.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_thorns.card_type = CardData.CARD_TYPES.SKILL
	card_thorns.card_rarity = CardData.CARD_RARITIES.COMMON
	card_thorns.card_energy_cost = 1
	card_thorns.card_requires_target = false
	card_thorns.card_values = { "block": 6, "status_charge_amount": 2, "cultivate_amount": 1 }
	card_thorns.card_upgrade_value_improvements = { "block": 3, "status_charge_amount": 1 }
	card_thorns.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_pointy",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_BLOCK: {
				"time_delay": 0.2,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_thorns)

	# Verdant
	var card_verdant: CardData = CardData.new("card_verdant")
	card_verdant.card_name = "翠绿脚本"
	card_verdant.card_color_id = "color_{0}".format([color])
	card_verdant.card_texture_path = "sprites/card/green/card_verdant.png"
	card_verdant.card_description = "被读取时，获得 [status_charge_amount] 层 [status_icon:status_effect_cap_damage]，副层数为 [status_secondary_charge_amount]。[color=green]被读取时，培育 [cultivate_amount][/color]。"
	card_verdant.card_hint = "这张牌不能主动打出；被摸到时会自动物理删除，并给你 [status_icon:status_effect_cap_damage]（限制单次掉血上限）。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_verdant.card_keyword_object_ids = ["keyword_cultivate"]
	card_verdant.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_verdant.card_type = CardData.CARD_TYPES.SKILL
	card_verdant.card_rarity = CardData.CARD_RARITIES.COMMON
	card_verdant.card_requires_target = false
	card_verdant.card_is_playable = false
	card_verdant.card_values = { "status_charge_amount": 1, "status_secondary_charge_amount": 7, "cultivate_amount": 2 }
	card_verdant.card_upgrade_value_improvements = { "status_secondary_charge_amount": -2 }
	card_verdant.card_draw_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_PARENT_CARD,
				"action_data": [
					{
						Scripts.ACTION_EXHAUST_CARDS: { },
					},
				],
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_cap_damage",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_verdant)

	# Vines
	var card_vines: CardData = CardData.new("card_vines")
	card_vines.card_name = "网络藤蔓"
	card_vines.card_color_id = "color_{0}".format([color])
	card_vines.card_texture_path = "sprites/card/green/card_vines.png"
	card_vines.card_description = "对所有敌人造成 [number_of_attacks] 次 [damage] 点伤害。不受 [status_icon:status_effect_pointy] 影响。[color=green]培育 [cultivate_amount][/color]。"
	card_vines.card_hint = "对所有敌人多段攻击，且不会触发敌人的 [status_icon:status_effect_pointy] 反伤。若没有伊甸根核，会先自动获得并召唤伊甸母树。"
	card_vines.card_keyword_object_ids = ["keyword_cultivate"]
	card_vines.card_status_effect_object_ids = ["status_effect_world_tree_growth"]
	card_vines.card_type = CardData.CARD_TYPES.ATTACK
	card_vines.card_rarity = CardData.CARD_RARITIES.COMMON
	card_vines.card_requires_target = false
	card_vines.card_values = { "damage": 5, "number_of_attacks": 2, "self_damage": 2, "impact_vfx_animation_id": "animation_vfx_slash_green", "cultivate_amount": 2 }
	card_vines.card_upgrade_value_improvements = { "damage": 5 }
	card_vines.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"time_delay": 0.4,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
				"ignored_interceptor_ids": ["interceptor_pointy"],
			},
		},
		{
			Scripts.ACTION_OPERATE_FRIENDLY: {
				"artifact_id": "artifact_eden_root_core",
				"friendly_ids": ["friendly_eden_world_tree"],
				"force_dead_targets": true,
				"friendly_action_data": [
					{Scripts.ACTION_APPLY_STATUS: {
						"status_effect_object_id": "status_effect_world_tree_growth",
						"custom_key_names": {"status_charge_amount": "cultivate_amount"},
						"status_secondary_charge_amount": 0,
						"status_force_apply_new_effect": false,
						"status_custom_values": {},
					}},
					{Scripts.ACTION_ADD_HEALTH: {
						"custom_key_names": {"health_amount": "cultivate_amount"},
						"health_max_amount": 0,
						"health_max_percent": 0.0,
					}},
				],
			},
		},
	]
	Global.register_rod(card_vines)
	#endregion
	#region Research Archetype
	# Conclusion
	var card_conclusion: CardData = CardData.new("card_conclusion")
	card_conclusion.card_name = "终局"
	card_conclusion.card_color_id = "color_{0}".format([color])
	card_conclusion.card_texture_path = "sprites/card/green/card_conclusion.png"
	card_conclusion.card_description = "造成 [damage] 点伤害。保留时，每回合结束后每个未使用的 [energy_icon] 使本脚本伤害永久增加 [damage_growth] 点。"
	card_conclusion.card_hint = "会留在手里的攻击牌；只要保留不打出，每回合结束时每点没用掉的能量都会永久提高它的伤害。"
	card_conclusion.card_rarity = CardData.CARD_RARITIES.COMMON
	card_conclusion.card_energy_cost = 3
	card_conclusion.card_requires_target = true
	card_conclusion.card_is_retained = true
	card_conclusion.card_play_destination = HandManager.EXHAUST_PILE
	card_conclusion.card_values = { "damage": 12, "number_of_attacks": 1, "damage_growth": 4, "card_value_improvements": { "damage": 4 }, "impact_vfx_animation_id": "animation_vfx_magic_green" }
	card_conclusion.card_first_upgrade_property_changes = {
		"card_description": "造成 [damage] 点伤害。保留时，每回合结束后每个未使用的 [energy_icon] 使本脚本伤害永久增加 [damage_growth] 点。",
		"card_value_improvements": { "damage": 6 },
	}
	card_conclusion.card_first_upgrade_value_changes = { "damage_growth": 6 }
	card_conclusion.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"time_delay": 0.3,
				"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS,
			},
		},
	]
	card_conclusion.card_end_of_turn_actions = [
		{
			Scripts.ACTION_IMPROVE_CARD_VALUES_UNUSED_ENERGY: {
				"time_delay": 0.1,
				"pick_played_card": true,
				"modify_parent_card": false,
			},
		},
	]

	Global.register_rod(card_conclusion)

	# Datum
	var card_datum: CardData = CardData.new("card_datum")
	card_datum.card_name = "数据点"
	card_datum.card_color_id = "color_{0}".format([color])
	card_datum.card_texture_path = "sprites/card/green/card_datum.png"
	card_datum.card_description = "获得 [block] 点防火墙。被读取时自动复制自身。保留时，时钟周期结束后本卡耗能永久减少 [energy_cost_reduction] 点。"
	card_datum.card_hint = "获得护盾（防火墙）；被摸到时自动复制一张到手牌；保留在手里则每回合结束永久降低它的费用；用后从牌组永久移除。"
	card_datum.card_type = CardData.CARD_TYPES.SKILL
	card_datum.card_rarity = CardData.CARD_RARITIES.COMMON
	card_datum.card_energy_cost = 3
	card_datum.card_requires_target = false
	card_datum.card_is_retained = true
	card_datum.card_play_destination = HandManager.BANISH_PILE
	card_datum.card_values = { "block": 10, "modified_energy_cost": card_datum.card_energy_cost, "energy_cost_reduction": 1 }
	card_datum.card_upgrade_value_improvements = { "block": 4 }
	card_datum.card_play_actions = [
		{
			Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {
				"pick_played_card": true
			}
		},
		{
			Scripts.ACTION_BLOCK: {
				"time_delay": 0.2,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
	]
	card_datum.card_draw_actions = [
		# pick this card and duplicate it then add the duplicate to hand
		{
			Scripts.ACTION_PICK_DUPLICATE_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_PARENT_CARD,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"random_selection": true,
				"card_pick_text": "选择 {0} 个脚本加入当前线程。已选 {1} 个",
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_HAND: {
							# must alias the generated cards from ActionPickDuplicateCards
							"custom_key_names": { "picked_cards": "generated_cards" },
						},
					},
				],
			},
		},
	]
	card_datum.card_end_of_turn_actions = [
		{
			Scripts.ACTION_IMPROVE_CARD_PROPERTIES: {
				"modify_parent_card": true,
				"pick_played_card": true,
				"card_property_improvements": {"card_energy_cost": -card_datum.card_values["energy_cost_reduction"]},
			},
		},
	]

	Global.register_rod(card_datum)

	# Photoelectric Synthesis
	var card_photoelectric_synthesis: CardData = CardData.new("card_photoelectric_synthesis")
	card_photoelectric_synthesis.card_name = "光电合成"
	card_photoelectric_synthesis.card_color_id = "color_{0}".format([color])
	card_photoelectric_synthesis.card_texture_path = "sprites/card/green/card_photoelectric_synthesis.png"
	card_photoelectric_synthesis.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_damage_increase]。需吸收 [required_absorbed_energy_energy_icons] 后才能调用。已吸收 [card_absorbed_energy_energy_icons]。"
	card_photoelectric_synthesis.card_hint = "留在手里，累计吸收足够能量（算力）后才能打出；打出后获得大量 [status_icon:status_effect_damage_increase]（提高攻击伤害）。"
	card_photoelectric_synthesis.card_type = CardData.CARD_TYPES.POWER
	card_photoelectric_synthesis.card_rarity = CardData.CARD_RARITIES.RARE
	card_photoelectric_synthesis.card_energy_cost = 0
	card_photoelectric_synthesis.card_requires_target = false
	card_photoelectric_synthesis.card_is_retained = true
	card_photoelectric_synthesis.card_values = {
		"card_absorbed_energy": 0,
		"required_absorbed_energy": 5,
		"card_value_improvements": { "card_absorbed_energy": 1 },
		"status_effect_object_id": "status_effect_damage_increase",
		"status_charge_amount": 7,
	}
	card_photoelectric_synthesis.card_upgrade_value_improvements = { "status_charge_amount": 3 }
	card_photoelectric_synthesis.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_damage_increase",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	card_photoelectric_synthesis.card_end_of_turn_actions = [
		{
			Scripts.ACTION_IMPROVE_CARD_VALUES_UNUSED_ENERGY: {
				"time_delay": 0.1,
				"pick_played_card": true,
				"modify_parent_card": false,
			},
		},
	]
	card_photoelectric_synthesis.card_play_validators = [
		{
			Scripts.VALIDATOR_CARD_VALUES: {
				"card_value_name": "card_absorbed_energy",
				"operator": ">=",
				"comparison_value": 5,
			},
		},
	]

	Global.register_rod(card_photoelectric_synthesis)

	#endregion
	#region Critical Archetype

	# Big Boom
	var card_big_boom: CardData = CardData.new("card_big_boom")
	card_big_boom.card_name = "大爆炸"
	card_big_boom.card_color_id = "color_{0}".format([color])
	card_big_boom.card_texture_path = "sprites/card/green/card_big_boom.png"
	card_big_boom.card_description = "对所有敌人造成 [damage] 点伤害。获得 [status_charge_amount] 层 [status_icon:status_effect_overheat]。"
	card_big_boom.card_hint = "对所有敌人造成伤害，并获得 [status_icon:status_effect_overheat]（内核过热，层数够高会爆裂波及全场）。"
	card_big_boom.card_type = CardData.CARD_TYPES.ATTACK
	card_big_boom.card_rarity = CardData.CARD_RARITIES.COMMON
	card_big_boom.card_requires_target = false
	card_big_boom.card_energy_cost = 2
	card_big_boom.card_values = { "damage": 12, "status_charge_amount": 5, "time_delay": 0.2, "impact_vfx_animation_id": "animation_vfx_slash_green" }
	card_big_boom.card_upgrade_value_improvements = { "damage": 14 }
	card_big_boom.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overheat",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]

	Global.register_rod(card_big_boom)

	# Creates cards and adds them to hand
	var card_containment: CardData = CardData.new("card_containment")
	card_containment.card_name = "收容"
	card_containment.card_color_id = "color_{0}".format([color])
	card_containment.card_texture_path = "sprites/card/green/card_containment.png"
	card_containment.card_description = "获得 [block] 点防火墙。将 [number_of_cards] 个 [card_name:card_waste] 加入当前线程。"
	card_containment.card_hint = "获得大量护盾（防火墙），并生成 [number_of_cards] 张“冗余数据”到手牌。"
	card_containment.card_type = CardData.CARD_TYPES.SKILL
	card_containment.card_rarity = CardData.CARD_RARITIES.COMMON
	card_containment.card_requires_target = false
	card_containment.card_keyword_object_ids = []
	card_containment.card_values = { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "block": 15, "created_card_object_id": "card_waste", "number_of_cards": 2 }
	card_containment.card_upgrade_value_improvements = { "block": 5 }
	card_containment.card_play_actions = [
		{
			Scripts.ACTION_CREATE_CARDS: {
				"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_HAND: { } }],
			},
		},
		{
			Scripts.ACTION_BLOCK: {
				"time_delay": 0.3,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
	]

	Global.register_rod(card_containment)

	# Critical
	var card_critical: CardData = CardData.new("card_critical")
	card_critical.card_name = "临界"
	card_critical.card_color_id = "color_{0}".format([color])
	card_critical.card_texture_path = "sprites/card/green/card_critical.png"
	card_critical.card_description = "每回合开始时，获得 [status_charge_amount] 层 [status_icon:status_effect_critical]。"
	card_critical.card_hint = "打出后每回合开始都会获得 [status_icon:status_effect_critical]（每回合自动累积 [status_icon:status_effect_overheat] 内核过热）。"
	card_critical.card_rarity = CardData.CARD_RARITIES.COMMON
	card_critical.card_requires_target = false
	card_critical.card_energy_cost = 1
	card_critical.card_values = { "status_charge_amount": 5, "time_delay": 0.2 }
	card_critical.card_upgrade_value_improvements = { "status_charge_amount": 2 }
	card_critical.card_first_upgrade_property_changes = {
		"card_description": "每回合开始时，获得 [status_charge_amount] 层 [status_icon:status_effect_critical]。打出时对所有敌人造成 [damage] 点伤害。",
		"card_play_actions": [
			{
				Scripts.ACTION_APPLY_STATUS: {
					"status_effect_object_id": "status_effect_critical",
					"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				},
			},
			{
				Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
					"time_delay": 0.3,
					"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
				},
			},
		],
	}
	card_critical.card_first_upgrade_value_changes = { "damage": 8 }
	card_critical.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_critical",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]

	Global.register_rod(card_critical)

	# Feedback Loop
	var card_feedback_loop: CardData = CardData.new("card_feedback_loop")
	card_feedback_loop.card_name = "反馈循环"
	card_feedback_loop.card_color_id = "color_{0}".format([color])
	card_feedback_loop.card_texture_path = "sprites/card/green/card_feedback_loop.png"
	card_feedback_loop.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_feedback_loop]。"
	card_feedback_loop.card_hint = "打出后获得 [status_icon:status_effect_feedback_loop]：之后每次 [status_icon:status_effect_overheat] 爆裂都会为你回复能量（算力）。"
	card_feedback_loop.card_type = CardData.CARD_TYPES.POWER
	card_feedback_loop.card_rarity = CardData.CARD_RARITIES.COMMON
	card_feedback_loop.card_requires_target = false
	card_feedback_loop.card_energy_cost = 2
	card_feedback_loop.card_values = { "status_charge_amount": 1, "time_delay": 0.2 }
	card_feedback_loop.card_upgrade_value_improvements = { "status_charge_amount": 1 }
	card_feedback_loop.card_first_upgrade_property_changes = {
		"card_energy_cost": 1,
		"card_description": "获得 [status_charge_amount] 层 [status_icon:status_effect_feedback_loop]。读取 [draw_count] 个脚本。",
		"card_play_actions": [
			{
				Scripts.ACTION_APPLY_STATUS: {
					"status_effect_object_id": "status_effect_feedback_loop",
					"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				},
			},
			{
				Scripts.ACTION_DRAW_GENERATOR: {
					"time_delay": 0.2,
				},
			},
		],
	}
	card_feedback_loop.card_first_upgrade_value_changes = { "draw_count": 1 }
	card_feedback_loop.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_feedback_loop",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]

	Global.register_rod(card_feedback_loop)

	# Fusion Cannon
	var card_fusion_cannon: CardData = CardData.new("card_fusion_cannon")
	card_fusion_cannon.card_name = "聚变炮"
	card_fusion_cannon.card_color_id = "color_{0}".format([color])
	card_fusion_cannon.card_texture_path = "sprites/card/green/card_fusion_cannon.png"
	card_fusion_cannon.card_description = "将 [number_of_cards] 个 [card_name:card_waste] 加入坏道区，然后坏道区中每有 1 个 [card_name:card_waste]，造成 [damage] 点伤害。"
	card_fusion_cannon.card_hint = "生成数张“冗余数据”丢进坏道区，再按坏道区里“冗余数据”的数量成倍造成伤害。"
	card_fusion_cannon.card_rarity = CardData.CARD_RARITIES.RARE
	card_fusion_cannon.card_energy_cost = 4
	card_fusion_cannon.card_requires_target = true
	card_fusion_cannon.card_values = {
		"damage": 4,
		"number_of_attacks": 1,
		"number_of_cards": 3,
		"created_card_object_id": "card_waste",
		"impact_vfx_animation_id": "animation_vfx_slash_green",
	}
	card_fusion_cannon.card_upgrade_value_improvements = { "damage": 2 }
	card_fusion_cannon.card_first_upgrade_property_changes = {
		"card_description": "将 [number_of_cards] 个 [card_name:card_waste] 加入坏道区，然后坏道区中每有 1 个 [card_name:card_waste]，造成 [damage] 点伤害。",
	}
	card_fusion_cannon.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"min_card_amount": 99,
				"max_card_amount": 99,
				"min_cards_are_required_for_action": false,
				"random_selection": true,
				"card_pick_type": HandManager.EXHAUST_PILE,
				"card_pick_text": "选择至多 {0} 个脚本丢弃。已选 {1} 个",
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_ID: { "card_object_ids": ["card_waste"] } },
				],
				"action_data": [
					{
						Scripts.ACTION_VARIABLE_CARDSET_MODIFIER: {
							"multiplied_values": ["damage"],
							"action_data": [
								{
									Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB, 
										"time_delay": 0.5,
									},
								},
							],
						},
					},
				],
			},
		},
		{
			Scripts.ACTION_CREATE_CARDS: {
				"action_data": [{ Scripts.ACTION_EXHAUST_CARDS: { } }],
			},
		},
	]

	Global.register_rod(card_fusion_cannon)

	# Meltdown
	var card_meltdown: CardData = CardData.new("card_meltdown")
	card_meltdown.card_name = "熔毁"
	card_meltdown.card_color_id = "color_{0}".format([color])
	card_meltdown.card_texture_path = "sprites/card/green/card_meltdown.png"
	card_meltdown.card_description = "获得等同于 [status_icon:status_effect_overheat] 层数的防火墙。获得 [status_charge_amount] 层 [status_icon:status_effect_overheat]。"
	card_meltdown.card_type = CardData.CARD_TYPES.SKILL
	card_meltdown.card_rarity = CardData.CARD_RARITIES.COMMON
	card_meltdown.card_requires_target = false
	card_meltdown.card_values = { "status_charge_amount": 15, "block": 1 }
	card_meltdown.card_keyword_object_ids = []
	card_meltdown.card_hint = "获得等同于 [status_icon:status_effect_overheat] 层数的护盾，并大量叠加 [status_icon:status_effect_overheat]；护盾正好可以吸收过热爆裂造成的伤害。"
	card_meltdown.card_upgrade_value_improvements = { "status_charge_amount": 10 }
	card_meltdown.card_first_upgrade_property_changes = {}
	card_meltdown.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overheat",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_BLOCK_BY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_effect_object_id": "status_effect_overheat",
				"block_multiplier": 1,
				"include_pending_status_charges": true,
			},
		},
	]

	Global.register_rod(card_meltdown)

	# Particle Accelerator
	var card_particle_accelerator: CardData = CardData.new("card_particle_accelerator")
	card_particle_accelerator.card_name = "粒子加速器"
	card_particle_accelerator.card_color_id = "color_{0}".format([color])
	card_particle_accelerator.card_texture_path = "sprites/card/green/card_particle_accelerator.png"
	card_particle_accelerator.card_description = "获得 [energy_amount_energy_icons]。将 [number_of_cards] 个 [card_name:card_waste] 加入回收站。"
	card_particle_accelerator.card_hint = "立刻获得能量（算力），代价是生成数张“冗余数据”进入弃牌堆（回收站）。"
	card_particle_accelerator.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_particle_accelerator.card_requires_target = false
	card_particle_accelerator.card_energy_cost = 0
	card_particle_accelerator.card_keyword_object_ids = []
	card_particle_accelerator.card_values = {
		"energy_amount": 3,
		"time_delay": 0.0,
		"is_manual_discard": false,
		"created_card_object_id": "card_waste",
		"number_of_cards": 3,
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
	}
	card_particle_accelerator.card_upgrade_value_improvements = { "energy_amount": 1 }
	card_particle_accelerator.card_first_upgrade_property_changes = { "card_description": "获得 [energy_amount_energy_icons]。将 [number_of_cards] 个 [card_name:card_waste] 加入回收站。" }
	card_particle_accelerator.card_play_actions = [
		{
			Scripts.ACTION_CREATE_CARDS: {
				"action_data": [{ Scripts.ACTION_DISCARD_CARDS: { } }],
			},
		},
		{
			Scripts.ACTION_ADD_ENERGY: {
				"time_delay": 0.1,
			},
		},
	]

	Global.register_rod(card_particle_accelerator)

	# Unstable
	var card_unstable: CardData = CardData.new("card_unstable")
	card_unstable.card_name = "不稳定"
	card_unstable.card_color_id = "color_{0}".format([color])
	card_unstable.card_texture_path = "sprites/card/green/card_unstable.png"
	card_unstable.card_description = "读取 [draw_count] 个脚本。获得 [status_charge_amount] 层 [status_icon:status_effect_overheat]。"
	card_unstable.card_hint = "摸数张牌，并获得 [status_icon:status_effect_overheat]（内核过热，层数够高会爆裂波及全场）。"
	card_unstable.card_type = CardData.CARD_TYPES.SKILL
	card_unstable.card_rarity = CardData.CARD_RARITIES.COMMON
	card_unstable.card_requires_target = false
	card_unstable.card_energy_cost = 0
	card_unstable.card_values = { "status_charge_amount": 4, "draw_count": 3 }
	card_unstable.card_upgrade_value_improvements = { "draw_count": 1 }
	card_unstable.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overheat",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_DRAW_GENERATOR: { },
		},
	]

	Global.register_rod(card_unstable)

	# Waste
	var card_waste: CardData = CardData.new("card_waste")
	card_waste.card_name = "冗余数据"
	card_waste.card_color_id = "color_{0}".format([color])
	card_waste.card_texture_path = "sprites/card/green/card_waste.png"
	card_waste.card_description = "如果保留在当前线程中，时钟周期结束时获得 [status_charge_amount] 层 [status_icon:status_effect_overheat]，并对随机敌人造成 [damage] 点伤害。"
	card_waste.card_hint = "一张废牌：若回合结束仍留在手里，你会获得 [status_icon:status_effect_overheat]，并对随机一个敌人造成少量伤害。"
	card_waste.card_type = CardData.CARD_TYPES.STATUS
	card_waste.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_waste.card_requires_target = false
	card_waste.card_play_destination = HandManager.EXHAUST_PILE
	card_waste.card_energy_cost = 1
	card_waste.card_upgrade_amount_max = 0 # cannot be upgraded
	card_waste.card_values = { "damage": 3, "status_charge_amount": 2, "impact_vfx_animation_id": "animation_vfx_magic_green" }
	card_waste.card_end_of_turn_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overheat",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"bypass_block": false,
				"time_delay": 0.2,
				"target_override": BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY,
			},
		},
	]

	Global.register_rod(card_waste)

	# Garbage Collection
	var card_garbage_collection: CardData = CardData.new("card_garbage_collection")
	card_garbage_collection.card_name = "垃圾回收"
	card_garbage_collection.card_color_id = "color_{0}".format([color])
	card_garbage_collection.card_texture_path = "sprites/card/green/card_garbage_collection.png"
	card_garbage_collection.card_description = "选择当前线程中 [exhaust_amount] 个 [card_name:card_waste] 加入坏道区。获得 [block] 点防火墙并读取 [draw_count] 个脚本。"
	card_garbage_collection.card_hint = "选择手里的“冗余数据”物理删除掉，换取护盾（防火墙）并摸牌。"
	card_garbage_collection.card_type = CardData.CARD_TYPES.SKILL
	card_garbage_collection.card_rarity = CardData.CARD_RARITIES.COMMON
	card_garbage_collection.card_requires_target = false
	card_garbage_collection.card_energy_cost = 1
	card_garbage_collection.card_values = { "exhaust_amount": 1, "block": 5, "draw_count": 1 }
	card_garbage_collection.card_upgrade_value_improvements = { "block": 3, "draw_count": 1 }
	var garbage_collection_target_validators: Array[Dictionary] = [
		{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": ["card_waste"]}},
	]
	card_garbage_collection.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.HAND_PILE],
				"validator_data": garbage_collection_target_validators,
				"exclude_validated_card": true,
				"comparison_value": 1,
			}
		},
	]
	card_garbage_collection.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "exhaust_amount", "min_card_amount": "exhaust_amount"},
				"min_cards_are_required_for_action": true,
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择要加入坏道区的冗余数据",
				"validator_data": garbage_collection_target_validators,
				"action_data": [
					{ Scripts.ACTION_EXHAUST_CARDS: {} },
				],
			},
		},
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
		{
			Scripts.ACTION_DRAW_GENERATOR: { },
		},
	]
	Global.register_rod(card_garbage_collection)

	#region 扩展牌组：适应、循环与进化改写

	# 应激性角质层 — 受伤后获得额外的持久防御
	var card_stress_cuticle: CardData = CardData.new("card_stress_cuticle")
	card_stress_cuticle.card_name = "应激性角质层"
	card_stress_cuticle.card_texture_path = "sprites/card/green/card_stress_cuticle.png"
	card_stress_cuticle.card_color_id = "color_{0}".format([color])
	card_stress_cuticle.card_description = "获得 [block] 点防火墙。若你在上个时钟周期内损失过完整度，额外获得 [bonus_overshield] 层 [status_icon:status_effect_overshield]。"
	card_stress_cuticle.card_hint = "总会获得防火墙；若你在上回合受到过未被防火墙抵消的伤害，还会获得可跨回合保留的过载防火墙。"
	card_stress_cuticle.card_type = CardData.CARD_TYPES.SKILL
	card_stress_cuticle.card_rarity = CardData.CARD_RARITIES.COMMON
	card_stress_cuticle.card_requires_target = false
	card_stress_cuticle.card_energy_cost = 1
	card_stress_cuticle.card_values = {"block": 7, "bonus_overshield": 5}
	card_stress_cuticle.card_upgrade_value_improvements = {"block": 3, "bonus_overshield": 2}
	var stress_cuticle_bonus_validators: Array[Dictionary] = [
		{
			Scripts.VALIDATOR_COMBAT_STATS: {
				"stat_enum": CombatStatsData.STATS.PLAYER_DAMAGED_AMOUNT,
				"turn_stat_type": 1,
				"operator": ">",
				"comparison_value": 0,
			}
		},
	]
	card_stress_cuticle.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": stress_cuticle_bonus_validators,
				"passed_action_data": [
					{
						Scripts.ACTION_APPLY_STATUS: {
							"custom_key_names": {"status_charge_amount": "bonus_overshield"},
							"status_effect_object_id": "status_effect_overshield",
							"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
						}
					},
				],
			}
		},
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			}
		},
	]
	Global.register_rod(card_stress_cuticle)

	# 坏道萌发 — 将一张已经物理删除的牌带回手牌
	var card_bad_sector_germination: CardData = CardData.new("card_bad_sector_germination")
	card_bad_sector_germination.card_name = "坏道萌发"
	card_bad_sector_germination.card_texture_path = "sprites/card/green/card_bad_sector_germination.png"
	card_bad_sector_germination.card_color_id = "color_{0}".format([color])
	card_bad_sector_germination.card_description = "选择坏道区中的 1 个脚本，将其加入当前线程，并使其在本时钟周期内耗能变为 0。获得 [status_charge_amount] 层 [status_icon:status_effect_overheat]。"
	card_bad_sector_germination.card_hint = "坏道区中有可选脚本时才能打出。选中的脚本会回到手牌，且本回合耗能为 0；作为代价，你会获得内核过热。"
	card_bad_sector_germination.card_type = CardData.CARD_TYPES.SKILL
	card_bad_sector_germination.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_bad_sector_germination.card_requires_target = false
	card_bad_sector_germination.card_energy_cost = 1
	card_bad_sector_germination.card_play_destination = HandManager.BANISH_PILE
	card_bad_sector_germination.card_values = {"status_charge_amount": 3, "recovered_card_energy_cost": 0}
	card_bad_sector_germination.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_bad_sector_germination.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.EXHAUST_PILE],
				"comparison_value": 1,
			}
		},
	]
	card_bad_sector_germination.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overheat",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			}
		},
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.EXHAUST_PILE,
				"card_pick_text": "选择一个要从坏道区恢复的脚本",
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"action_data": [
					{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
					{
						Scripts.ACTION_CHANGE_CARD_ENERGIES: {
							"custom_key_names": {"card_energy_cost_until_turn": "recovered_card_energy_cost"},
						}
					},
				],
			}
		},
	]
	Global.register_rod(card_bad_sector_germination)

	# 热能堆肥 — 将所有战斗牌区中的冗余数据转化为防御并降温
	var card_thermal_compost: CardData = CardData.new("card_thermal_compost")
	card_thermal_compost.card_name = "热能堆肥"
	card_thermal_compost.card_texture_path = "sprites/card/green/card_thermal_compost.png"
	card_thermal_compost.card_color_id = "color_{0}".format([color])
	card_thermal_compost.card_description = "物理删除当前线程、内存队列和回收站中的所有 [card_name:card_waste]。每物理删除 1 个，以此法获得 [overshield_per_waste] 层 [status_icon:status_effect_overshield]，并移除 [overheat_decay_per_waste] 层 [status_icon:status_effect_overheat]。"
	card_thermal_compost.card_hint = "物理删除手牌、抽牌堆和弃牌堆中的全部冗余数据。每删除 1 张，都会获得可跨回合保留的过载防火墙，并减少内核过热。"
	card_thermal_compost.card_type = CardData.CARD_TYPES.SKILL
	card_thermal_compost.card_rarity = CardData.CARD_RARITIES.COMMON
	card_thermal_compost.card_requires_target = false
	card_thermal_compost.card_energy_cost = 0
	card_thermal_compost.card_values = {
		"overshield_per_waste": 3,
		"overheat_decay_per_waste": 2,
		"overheat_decay_delta": -2,
	}
	card_thermal_compost.card_first_upgrade_value_changes = {
		"overshield_per_waste": 4,
		"overheat_decay_per_waste": 3,
		"overheat_decay_delta": -3,
	}
	card_thermal_compost.card_play_actions = [
		{
			Scripts.ACTION_LOW_LEVEL_FORMAT: {
				"source_zones": [HandManager.HAND_PILE, HandManager.DRAW_PILE, HandManager.DISCARD_PILE],
				"filter_card_ids": ["card_waste"],
				"operation": CardMoveOperation.TYPES.EXHAUST,
				"variable_name_to_export": "format_count",
				"action_data": [
					{
						Scripts.ACTION_VARIABLE_ACTION_GENERATOR: {
							"custom_key_names": {"action_count": "format_count"},
							"action_data": [
								{
									Scripts.ACTION_DECAY_STATUS: {
										"custom_key_names": {"status_charge_delta": "overheat_decay_delta"},
										"status_effect_object_id": "status_effect_overheat",
										"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
									}
								},
								{
									Scripts.ACTION_APPLY_STATUS: {
										"custom_key_names": {"status_charge_amount": "overshield_per_waste"},
										"status_effect_object_id": "status_effect_overshield",
										"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
									}
								},
							],
						}
					},
				],
			}
		},
	]
	Global.register_rod(card_thermal_compost)

	# 休眠孢子 — 使用专门的 Action 延迟状态保存下回合效果
	var card_dormant_spore: CardData = CardData.new("card_dormant_spore")
	card_dormant_spore.card_name = "休眠孢子"
	card_dormant_spore.card_texture_path = "sprites/card/green/card_dormant_spore.png"
	card_dormant_spore.card_color_id = "color_{0}".format([color])
	card_dormant_spore.card_description = "下个时钟周期开始、读取脚本前，获得 [block] 点防火墙并读取 [draw_count] 个脚本。"
	card_dormant_spore.card_hint = "打出后不会立即获得防火墙或抽牌；这两个效果会在下回合正常抽牌前自动执行。"
	card_dormant_spore.card_type = CardData.CARD_TYPES.SKILL
	card_dormant_spore.card_rarity = CardData.CARD_RARITIES.COMMON
	card_dormant_spore.card_requires_target = false
	card_dormant_spore.card_energy_cost = 1
	card_dormant_spore.card_play_destination = HandManager.EXHAUST_PILE
	card_dormant_spore.card_values = {"block": 8, "draw_count": 2}
	card_dormant_spore.card_first_upgrade_value_changes = {"draw_count": 3}
	card_dormant_spore.card_play_actions = [
		{
			Scripts.ACTION_SCHEDULE_DELAYED_ACTIONS: {
				"status_effect_id": "status_effect_delayed_action_execution",
				"status_charges": 1,
				"action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {}},
					{
						Scripts.ACTION_BLOCK: {
							"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
							"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
						}
					},
				],
			}
		},
	]
	Global.register_rod(card_dormant_spore)

	# 逆境选择 — 主动弃置会永久培养伤害
	var card_adversity_selection: CardData = CardData.new("card_adversity_selection")
	card_adversity_selection.card_name = "逆境选择"
	card_adversity_selection.card_texture_path = "sprites/card/green/card_adversity_selection.png"
	card_adversity_selection.card_color_id = "color_{0}".format([color])
	card_adversity_selection.card_description = "造成 [damage] 点伤害。此脚本被其他卡牌的效果丢弃时，其伤害永久提高 [damage_growth] 点。"
	card_adversity_selection.card_hint = "让其他卡牌主动丢弃此牌，可以永久提高它的伤害。回合结束时的自然弃牌，以及打出后进入弃牌堆，均不会触发该效果。"
	card_adversity_selection.card_type = CardData.CARD_TYPES.ATTACK
	card_adversity_selection.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_adversity_selection.card_requires_target = true
	card_adversity_selection.card_energy_cost = 1
	card_adversity_selection.card_is_retained = true
	card_adversity_selection.card_keyword_object_ids = ["keyword_retain"]
	card_adversity_selection.card_values = {
		"damage": 9,
		"damage_growth": 4,
		"card_value_improvements": {"damage": 4},
		"number_of_attacks": 1,
	}
	card_adversity_selection.card_first_upgrade_value_changes = {
		"damage_growth": 6,
		"card_value_improvements": {"damage": 6},
	}
	card_adversity_selection.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: {"audio_path": AudioConstants.SFX_GROUP_DAGGER_STAB}},
	]
	card_adversity_selection.card_discard_actions = [
		{
			Scripts.ACTION_IMPROVE_CARD_VALUES: {
				"pick_played_card": true,
				"modify_parent_card": true,
			}
		},
	]
	Global.register_rod(card_adversity_selection)

	# 表观遗传 — 给一张永久牌组卡随机施加兼容附魔
	var card_epigenetic_editing: CardData = CardData.new("card_epigenetic_editing")
	card_epigenetic_editing.card_name = "表观遗传"
	card_epigenetic_editing.card_texture_path = "sprites/card/green/card_epigenetic_editing.png"
	card_epigenetic_editing.card_color_id = "color_{0}".format([color])
	card_epigenetic_editing.card_description = "选择当前线程中 1 个拥有空附魔槽的非生成脚本，为其永久施加 1 个随机兼容附魔。"
	card_epigenetic_editing.card_hint = "手牌中有符合条件的非生成牌时才能打出。选中的牌会随机获得一种与其兼容的附魔，且该附魔在本局游戏中永久保留。"
	card_epigenetic_editing.card_type = CardData.CARD_TYPES.SKILL
	card_epigenetic_editing.card_rarity = CardData.CARD_RARITIES.RARE
	card_epigenetic_editing.card_requires_target = false
	card_epigenetic_editing.card_energy_cost = 3
	card_epigenetic_editing.card_play_destination = HandManager.EXHAUST_PILE
	card_epigenetic_editing.card_first_upgrade_property_changes = {"card_energy_cost": 2}
	var epigenetic_decorators: Dictionary[String, Dictionary] = {
		"card_decorator_block_on_play": {},
		"card_decorator_remove_exhaust": {},
		"card_decorator_extra_draw": {},
		"card_decorator_damage_on_play": {},
		"card_decorator_energy_on_play": {},
		"card_decorator_add_retain": {},
		"card_decorator_heal_on_play": {},
	}
	var epigenetic_validator_data: Array[Dictionary] = [
		{
			Scripts.VALIDATOR_CARD_IS_DECORATABLE: {
				"card_decorator_ids": epigenetic_decorators.keys(),
			}
		},
		{
			Scripts.VALIDATOR_CARD_RARITY: {
				"card_rarities_exclude": [CardData.CARD_RARITIES.GENERATED],
			}
		},
		{
			Scripts.VALIDATOR_CARD_PROPERTIES: {
				"card_property_name": "parent_card",
				"operator": "!=",
				"comparison_value": null,
			}
		},
	]
	card_epigenetic_editing.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.HAND_PILE],
				"validator_data": epigenetic_validator_data,
				"exclude_validated_card": true,
			}
		},
	]
	card_epigenetic_editing.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择一个要进行表观遗传改造的脚本",
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"validator_data": epigenetic_validator_data,
				"action_data": [
					{
						Scripts.ACTION_DECORATE_CARDS: {
							"decorate_parent_card": true,
							"random_card_decorators": epigenetic_decorators,
						}
					},
				],
			}
		},
	]
	Global.register_rod(card_epigenetic_editing)

	# 菌丝网络 — 通过不可见专属状态监听物理删除事件
	var card_mycelial_network: CardData = CardData.new("card_mycelial_network")
	card_mycelial_network.card_name = "菌丝网络"
	card_mycelial_network.card_texture_path = "sprites/card/green/card_mycelial_network.png"
	card_mycelial_network.card_color_id = "color_{0}".format([color])
	card_mycelial_network.card_description = "打出后，每当一个脚本被物理删除，获得 [status_charge_amount] 层 [status_icon:status_effect_overshield]。若该脚本是 [card_name:card_waste]，再读取 1 个脚本。重复打出时，获得的过载防火墙可以叠加，但读取数量不会叠加。"
	card_mycelial_network.card_hint = "打出后持续生效。重复打出会提高每次物理删除脚本时获得的过载防火墙；物理删除冗余数据时始终只额外抽 1 张牌。"
	card_mycelial_network.card_type = CardData.CARD_TYPES.POWER
	card_mycelial_network.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_mycelial_network.card_requires_target = false
	card_mycelial_network.card_energy_cost = 2
	card_mycelial_network.card_values = {"status_charge_amount": 3}
	card_mycelial_network.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_mycelial_network.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_mycelial_network",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			}
		},
	]
	Global.register_rod(card_mycelial_network)

	# 指数培养 — X 费同时缩放持久防御与冗余数据数量
	var card_exponential_culture: CardData = CardData.new("card_exponential_culture")
	card_exponential_culture.card_name = "指数培养"
	card_exponential_culture.card_texture_path = "sprites/card/green/card_exponential_culture.png"
	card_exponential_culture.card_color_id = "color_{0}".format([color])
	card_exponential_culture.card_description = "消耗所有当前可消耗的算力。每消耗 1 点算力，获得 [status_charge_amount] 层 [status_icon:status_effect_overshield]，并将 1 个 [card_name:card_waste] 加入回收站。"
	card_exponential_culture.card_hint = "这是可变耗能牌，会消耗你当前所有可用算力。实际消耗多少点算力，就会获得对应倍数的过载防火墙，并生成同等数量的冗余数据进入弃牌堆；消耗 0 点时没有效果。"
	card_exponential_culture.card_type = CardData.CARD_TYPES.SKILL
	card_exponential_culture.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_exponential_culture.card_requires_target = false
	card_exponential_culture.card_energy_cost = 0
	card_exponential_culture.card_energy_cost_is_variable = true
	card_exponential_culture.card_values = {
		"status_charge_amount": 4,
		"number_of_cards": 1,
	}
	card_exponential_culture.card_first_upgrade_value_changes = {
		"status_charge_amount": 5,
	}
	card_exponential_culture.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COST_MODIFIER: {
				"multiplied_values": ["status_charge_amount", "number_of_cards"],
				"multiplied_values_bases": {"status_charge_amount": 0, "number_of_cards": 0},
				"action_data": [
					{
						Scripts.ACTION_CREATE_CARDS: {
							"created_card_object_id": "card_waste",
							"action_data": [
								{Scripts.ACTION_DISCARD_CARDS: {"is_manual_discard": false}},
							],
						}
					},
					{
						Scripts.ACTION_APPLY_STATUS: {
							"status_effect_object_id": "status_effect_overshield",
							"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
						}
					},
				],
			}
		},
	]
	Global.register_rod(card_exponential_culture)

	# 灾变演替 — 消耗全部冗余数据，对所有敌人重复造成伤害
	var card_catastrophic_succession: CardData = CardData.new("card_catastrophic_succession")
	card_catastrophic_succession.card_name = "灾变演替"
	card_catastrophic_succession.card_texture_path = "sprites/card/green/card_catastrophic_succession.png"
	card_catastrophic_succession.card_color_id = "color_{0}".format([color])
	card_catastrophic_succession.card_description = "物理删除当前线程、内存队列和回收站中的所有 [card_name:card_waste]。每物理删除 1 个，以此法对所有敌人造成 [damage] 点伤害。上述区域中至少有 1 个 [card_name:card_waste] 时才能打出。"
	card_catastrophic_succession.card_hint = "物理删除手牌、抽牌堆和弃牌堆中的全部冗余数据；每删除 1 张，就对所有敌人造成 1 次伤害。没有冗余数据时无法打出。"
	card_catastrophic_succession.card_type = CardData.CARD_TYPES.ATTACK
	card_catastrophic_succession.card_rarity = CardData.CARD_RARITIES.RARE
	card_catastrophic_succession.card_requires_target = false
	card_catastrophic_succession.card_energy_cost = 3
	card_catastrophic_succession.card_play_destination = HandManager.EXHAUST_PILE
	card_catastrophic_succession.card_values = {"damage": 6, "number_of_attacks": 1}
	card_catastrophic_succession.card_upgrade_value_improvements = {"damage": 2}
	card_catastrophic_succession.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.HAND_PILE, HandManager.DRAW_PILE, HandManager.DISCARD_PILE],
				"validator_data": [
					{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": ["card_waste"]}},
				],
				"comparison_value": 1,
			}
		},
	]
	card_catastrophic_succession.card_play_actions = [
		{
			Scripts.ACTION_LOW_LEVEL_FORMAT: {
				"source_zones": [HandManager.HAND_PILE, HandManager.DRAW_PILE, HandManager.DISCARD_PILE],
				"filter_card_ids": ["card_waste"],
				"operation": CardMoveOperation.TYPES.EXHAUST,
				"variable_name_to_export": "format_count",
				"action_data": [
					{
						Scripts.ACTION_VARIABLE_ACTION_GENERATOR: {
							"custom_key_names": {"action_count": "format_count"},
							"action_data": [
								{
									Scripts.ACTION_ATTACK_GENERATOR: {
										"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
										"audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST,
									}
								},
							],
						}
					},
				],
			}
		},
	]
	Global.register_rod(card_catastrophic_succession)

	#endregion

	#endregion

