class_name GlobalProdDataGeneratorOrangeCards
extends RefCounted

static func add_cards_orange() -> void:
	var color: String = "orange"

	# 1. 短路打击 (Short-circuit Strike)
	var card_short_circuit_strike: CardData = CardData.new("card_short_circuit_strike")
	card_short_circuit_strike.card_name = "短路打击"
	card_short_circuit_strike.card_color_id = "color_{0}".format([color])
	card_short_circuit_strike.card_texture_path = "sprites/cards/card_basic_attack_{0}.png".format([color]) # Temp sprite
	card_short_circuit_strike.card_description = "造成 [damage] 点伤害。[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷1」[/color]。"
	card_short_circuit_strike.card_type = CardData.CARD_TYPES.ATTACK
	card_short_circuit_strike.card_rarity = CardData.CARD_RARITIES.COMMON
	card_short_circuit_strike.card_requires_target = true
	card_short_circuit_strike.card_energy_cost = 1
	card_short_circuit_strike.card_values = {"damage": 5, "forge_damage": 5}
	card_short_circuit_strike.card_upgrade_value_improvements = {"damage": 2, "forge_damage": 2}
	card_short_circuit_strike.card_play_actions = [
		{Scripts.ACTION_DIRECT_DAMAGE: {}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage"}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_short_circuit_strike)

	# 2. 结构防御 (Structural Defense)
	var card_structural_defense: CardData = CardData.new("card_structural_defense")
	card_structural_defense.card_name = "结构防御"
	card_structural_defense.card_color_id = "color_{0}".format([color])
	card_structural_defense.card_texture_path = "sprites/cards/card_basic_defense_{0}.png".format([color]) # Temp sprite
	card_structural_defense.card_description = "获得 [block] 点防火墙。[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷1」[/color]。"
	card_structural_defense.card_type = CardData.CARD_TYPES.SKILL
	card_structural_defense.card_rarity = CardData.CARD_RARITIES.COMMON
	card_structural_defense.card_requires_target = false
	card_structural_defense.card_energy_cost = 1
	card_structural_defense.card_values = {"block": 3, "forge_block": 5}
	card_structural_defense.card_upgrade_value_improvements = {"block": 2, "forge_block": 2}
	card_structural_defense.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_structural_defense)

	# 3. 穿孔指令 (Punch-hole Instruction)
	var card_punch_hole_instruction: CardData = CardData.new("card_punch_hole_instruction")
	card_punch_hole_instruction.card_name = "穿孔指令"
	card_punch_hole_instruction.card_color_id = "color_{0}".format([color])
	card_punch_hole_instruction.card_texture_path = "sprites/cards/card_basic_attack_{0}.png".format([color]) # Temp sprite
	card_punch_hole_instruction.card_description = "造成 [damage] 点伤害。[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷2」[/color]。"
	card_punch_hole_instruction.card_type = CardData.CARD_TYPES.ATTACK
	card_punch_hole_instruction.card_rarity = CardData.CARD_RARITIES.COMMON
	card_punch_hole_instruction.card_requires_target = true
	card_punch_hole_instruction.card_energy_cost = 1
	card_punch_hole_instruction.card_values = {"damage": 4, "forge_damage": 8}
	card_punch_hole_instruction.card_upgrade_value_improvements = {"damage": 2, "forge_damage": 2}
	card_punch_hole_instruction.card_play_actions = [
		{Scripts.ACTION_DIRECT_DAMAGE: {}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage"}}, "forge_action_load": 2}}
	]
	Global.register_rod(card_punch_hole_instruction)

	# 4. 厚重框架 (Heavy Framework)
	var card_heavy_framework: CardData = CardData.new("card_heavy_framework")
	card_heavy_framework.card_name = "厚重框架"
	card_heavy_framework.card_color_id = "color_{0}".format([color])
	card_heavy_framework.card_texture_path = "sprites/cards/card_basic_defense_{0}.png".format([color]) # Temp sprite
	card_heavy_framework.card_description = "获得 [block] 点防火墙。[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷1」[/color]。"
	card_heavy_framework.card_type = CardData.CARD_TYPES.SKILL
	card_heavy_framework.card_rarity = CardData.CARD_RARITIES.COMMON
	card_heavy_framework.card_requires_target = false
	card_heavy_framework.card_energy_cost = 1
	card_heavy_framework.card_values = {"block": 6, "forge_block": 4}
	card_heavy_framework.card_upgrade_value_improvements = {"block": 2, "forge_block": 2}
	card_heavy_framework.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_heavy_framework)

	# 5. 防御脚本 (Defense Script)
	var card_defense_script: CardData = CardData.new("card_defense_script")
	card_defense_script.card_name = "防御脚本"
	card_defense_script.card_color_id = "color_{0}".format([color])
	card_defense_script.card_texture_path = "sprites/cards/card_basic_defense_{0}.png".format([color]) # Temp sprite
	card_defense_script.card_description = "获得 [block] 点防火墙。[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷2」[/color]。"
	card_defense_script.card_type = CardData.CARD_TYPES.SKILL
	card_defense_script.card_rarity = CardData.CARD_RARITIES.COMMON
	card_defense_script.card_requires_target = false
	card_defense_script.card_energy_cost = 1
	card_defense_script.card_values = {"block": 3, "forge_block": 8}
	card_defense_script.card_upgrade_value_improvements = {"block": 1, "forge_block": 3}
	card_defense_script.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}, "forge_action_load": 2}}
	]
	Global.register_rod(card_defense_script)

	# 6. 连锁弹道 (Chain Ballistics)
	var card_chain_ballistics: CardData = CardData.new("card_chain_ballistics")
	card_chain_ballistics.card_name = "连锁弹道"
	card_chain_ballistics.card_color_id = "color_{0}".format([color])
	card_chain_ballistics.card_texture_path = "sprites/cards/card_basic_attack_{0}.png".format([color]) # Temp sprite
	card_chain_ballistics.card_description = "[color=orange]向锻造台加入「造成 [forge_damage] 点伤害 [forge_amount] 次，载荷3」[/color]。获得 [block] 点防火墙。"
	card_chain_ballistics.card_type = CardData.CARD_TYPES.ATTACK
	card_chain_ballistics.card_rarity = CardData.CARD_RARITIES.COMMON
	card_chain_ballistics.card_requires_target = false
	card_chain_ballistics.card_energy_cost = 1
	card_chain_ballistics.card_values = {"block": 3, "forge_damage": 3, "forge_amount": 3}
	card_chain_ballistics.card_upgrade_value_improvements = {"forge_damage": 1}
	card_chain_ballistics.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK_GENERATOR: {"damage": "forge_damage", "number_of_attacks": "forge_amount"}}, "forge_action_load": 3}},
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}
	]
	Global.register_rod(card_chain_ballistics)

	# 7. 弱点标记 (Weakness Mark)
	var card_weakness_mark: CardData = CardData.new("card_weakness_mark")
	card_weakness_mark.card_name = "弱点标记"
	card_weakness_mark.card_color_id = "color_{0}".format([color])
	card_weakness_mark.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color]) # Temp sprite
	card_weakness_mark.card_description = "给予目标 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]。[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷1」[/color]。"
	card_weakness_mark.card_type = CardData.CARD_TYPES.SKILL
	card_weakness_mark.card_rarity = CardData.CARD_RARITIES.COMMON
	card_weakness_mark.card_requires_target = true
	card_weakness_mark.card_energy_cost = 1
	card_weakness_mark.card_values = {"status_charge_amount": 1, "forge_damage": 6}
	card_weakness_mark.card_upgrade_value_improvements = {"forge_damage": 2}
	card_weakness_mark.card_play_actions = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable"}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage"}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_weakness_mark)

	# 8. 过热射击 (Overheat Shot)
	var card_overheat_shot: CardData = CardData.new("card_overheat_shot")
	card_overheat_shot.card_name = "过热射击"
	card_overheat_shot.card_color_id = "color_{0}".format([color])
	card_overheat_shot.card_texture_path = "sprites/cards/card_basic_attack_{0}.png".format([color]) # Temp sprite
	card_overheat_shot.card_description = "造成 [damage] 点伤害。本回合每有2点载荷，额外造成 [additional_damage] 点伤害。"
	card_overheat_shot.card_type = CardData.CARD_TYPES.ATTACK
	card_overheat_shot.card_rarity = CardData.CARD_RARITIES.COMMON
	card_overheat_shot.card_requires_target = true
	card_overheat_shot.card_energy_cost = 1
	card_overheat_shot.card_values = {"damage": 6, "additional_damage": 2, "impact_vfx_animation_id": "animation_vfx_slash_orange"}
	card_overheat_shot.card_upgrade_value_improvements = {"damage": 2, "additional_damage": 0}
	card_overheat_shot.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_PLAYER_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_turn_forge_load",
						"operator": ">=",
						"status_effect_charge_comparison_value": 2,
					}},
				],
				"passed_action_data": [
					{
						Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
							"combat_stat_name": "player_status_effect_charges",
							"stat_variable_name": "status_effect_turn_forge_load",
							"stat_divisor": 2,
							"multiplied_values": ["additional_damage"],
							"multiplied_values_bases": {"additional_damage": 0},
							"action_data": [
								{Scripts.ACTION_ATTACK_GENERATOR: {}}
							]
						}
					}
				],
				"failed_action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: {}}
				]
			}
		}
	]
	Global.register_rod(card_overheat_shot)

	# 9. 压力护盾 (Pressure Shield)
	var card_pressure_shield: CardData = CardData.new("card_pressure_shield")
	card_pressure_shield.card_name = "压力护盾"
	card_pressure_shield.card_color_id = "color_{0}".format([color])
	card_pressure_shield.card_texture_path = "sprites/cards/card_basic_block_{0}.png".format([color]) # Temp sprite
	card_pressure_shield.card_description = "获得 [block] 点格挡。本回合每有2点载荷，额外获得 [additional_block] 点格挡。"
	card_pressure_shield.card_type = CardData.CARD_TYPES.SKILL
	card_pressure_shield.card_rarity = CardData.CARD_RARITIES.COMMON
	card_pressure_shield.card_requires_target = false
	card_pressure_shield.card_energy_cost = 1
	card_pressure_shield.card_values = {"block": 5, "additional_block": 2}
	card_pressure_shield.card_upgrade_value_improvements = {"block": 2, "additional_block": 0}
	card_pressure_shield.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_PLAYER_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_turn_forge_load",
						"operator": ">=",
						"status_effect_charge_comparison_value": 2,
					}},
				],
				"passed_action_data": [
					{
						Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
							"combat_stat_name": "player_status_effect_charges",
							"stat_variable_name": "status_effect_turn_forge_load",
							"stat_divisor": 2,
							"multiplied_values": ["additional_block"],
							"multiplied_values_bases": {"additional_block": 0},
							"action_data": [
								{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
							]
						}
					}
				],
				"failed_action_data": [
					{Scripts.ACTION_BLOCK: {"custom_key_names": {"additional_block": "none"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
				]
			}
		}
	]
	Global.register_rod(card_pressure_shield)

	# 10. 应急屏障 (Emergency Barrier)
	var card_emergency_barrier: CardData = CardData.new("card_emergency_barrier")
	card_emergency_barrier.card_name = "应急屏障"
	card_emergency_barrier.card_color_id = "color_{0}".format([color])
	card_emergency_barrier.card_texture_path = "sprites/cards/card_basic_block_{0}.png".format([color]) # Temp sprite
	card_emergency_barrier.card_description = "消耗至多3点载荷。每消耗1点载荷，获得 [block_per_load] 点格挡。消耗。"
	card_emergency_barrier.card_type = CardData.CARD_TYPES.SKILL
	card_emergency_barrier.card_rarity = CardData.CARD_RARITIES.COMMON
	card_emergency_barrier.card_requires_target = false
	card_emergency_barrier.card_energy_cost = 0
	card_emergency_barrier.card_play_destination = HandManager.EXHAUST_PILE
	card_emergency_barrier.card_values = {"block_per_load": 3, "block_2": 6, "block_3": 9}
	card_emergency_barrier.card_upgrade_value_improvements = {"block_per_load": 1, "block_2": 2, "block_3": 3}
	card_emergency_barrier.card_play_actions = [
		{
			Scripts.ACTION_PICK_OPTIONS: {
				"can_back_out": true,
				"options": [
					{
						"option_name": "消耗 1 点载荷",
						"option_description": "获得 3 点格挡。",
						"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 1}}],
						"option_sub_actions": [
							{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 1}},
							{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_per_load"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
						]
					},
					{
						"option_name": "消耗 2 点载荷",
						"option_description": "获得 6 点格挡。",
						"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 2}}],
						"option_sub_actions": [
							{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 2}},
							{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_2"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
						]
					},
					{
						"option_name": "消耗 3 点载荷",
						"option_description": "获得 9 点格挡。",
						"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 3}}],
						"option_sub_actions": [
							{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 3}},
							{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_3"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
						]
					}
				]
			}
		}
	]
	
	card_emergency_barrier.card_first_upgrade_property_changes = {
		"card_play_actions": [
			{
				Scripts.ACTION_PICK_OPTIONS: {
					"can_back_out": true,
					"options": [
						{
							"option_name": "消耗 1 点载荷",
							"option_description": "获得 4 点格挡。",
							"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 1}}],
							"option_sub_actions": [
								{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 1}},
								{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_per_load"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
							]
						},
						{
							"option_name": "消耗 2 点载荷",
							"option_description": "获得 8 点格挡。",
							"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 2}}],
							"option_sub_actions": [
								{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 2}},
								{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_2"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
							]
						},
						{
							"option_name": "消耗 3 点载荷",
							"option_description": "获得 12 点格挡。",
							"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 3}}],
							"option_sub_actions": [
								{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 3}},
								{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_3"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
							]
						}
					]
				}
			}
		]
	}
	Global.register_rod(card_emergency_barrier)

	# 11. 试运行 (Trial Run)
	var card_trial_run: CardData = CardData.new("card_trial_run")
	card_trial_run.card_name = "试运行"
	card_trial_run.card_color_id = "color_{0}".format([color])
	card_trial_run.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color])
	card_trial_run.card_description = "将锻造台中的最后一段代码段封装为一张融合牌加入手牌，不移除代码段。\n如果锻造台为空，抽1张牌。"
	card_trial_run.card_type = CardData.CARD_TYPES.SKILL
	card_trial_run.card_rarity = CardData.CARD_RARITIES.COMMON
	card_trial_run.card_requires_target = false
	card_trial_run.card_energy_cost = 1
	card_trial_run.card_first_upgrade_property_changes = {"card_energy_cost": 0, "card_description": "将锻造台中的最后一段代码段封装为一张融合牌加入手牌，不移除代码段。\n如果锻造台为空，抽1张牌。"}
	card_trial_run.card_play_actions = [
		{
			Scripts.ACTION_TAKE_FROM_FORGE: {
				"take_type": 1,
				"clear_after_take": false,
				"execute_directly": false,
				"override_load": 0,
				"fallback_action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {"draw_amount": 1}}
				]
			}
		}
	]
	Global.register_rod(card_trial_run)

	# 12. 片段提取 (Snippet Extraction)
	var card_snippet_extraction: CardData = CardData.new("card_snippet_extraction")
	card_snippet_extraction.card_name = "片段提取"
	card_snippet_extraction.card_color_id = "color_{0}".format([color])
	card_snippet_extraction.card_texture_path = "sprites/cards/card_basic_attack_{0}.png".format([color])
	card_snippet_extraction.card_description = "造成 [damage] 点伤害。\n执行锻造台中的第一段代码段，然后移除代码段。"
	card_snippet_extraction.card_type = CardData.CARD_TYPES.ATTACK
	card_snippet_extraction.card_rarity = CardData.CARD_RARITIES.COMMON
	card_snippet_extraction.card_requires_target = true
	card_snippet_extraction.card_energy_cost = 1
	card_snippet_extraction.card_values = {"damage": 5}
	card_snippet_extraction.card_upgrade_value_improvements = {"damage": 2}
	card_snippet_extraction.card_play_actions = [
		{
			Scripts.ACTION_TAKE_FROM_FORGE: {
				"take_type": 0,
				"clear_after_take": true,
				"execute_directly": true,
				"override_load": 0
			}
		},
		{Scripts.ACTION_DIRECT_DAMAGE: {}}
	]
	Global.register_rod(card_snippet_extraction)

	# 13. 数据回流 (Data Backflow)
	var card_data_backflow: CardData = CardData.new("card_data_backflow")
	card_data_backflow.card_name = "数据回流"
	card_data_backflow.card_color_id = "color_{0}".format([color])
	card_data_backflow.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color])
	card_data_backflow.card_description = "消耗2点载荷。\n抽2张牌。\n如果载荷不足，抽1张牌。"
	card_data_backflow.card_type = CardData.CARD_TYPES.SKILL
	card_data_backflow.card_rarity = CardData.CARD_RARITIES.COMMON
	card_data_backflow.card_requires_target = false
	card_data_backflow.card_energy_cost = 1
	card_data_backflow.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_data_backflow.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 2}}
				],
				"passed_action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 2}},
					{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 2}}
				],
				"failed_action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}}
				]
			}
		}
	]
	Global.register_rod(card_data_backflow)

	# 15. 轻量语句 (Lightweight Statement)
	var card_lightweight_statement: CardData = CardData.new("card_lightweight_statement")
	card_lightweight_statement.card_name = "轻量语句"
	card_lightweight_statement.card_color_id = "color_{0}".format([color])
	card_lightweight_statement.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color]) # Temp sprite
	card_lightweight_statement.card_description = "[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷1」[/color]。"
	card_lightweight_statement.card_type = CardData.CARD_TYPES.SKILL
	card_lightweight_statement.card_rarity = CardData.CARD_RARITIES.COMMON
	card_lightweight_statement.card_requires_target = false
	card_lightweight_statement.card_energy_cost = 0
	card_lightweight_statement.card_play_destination = HandManager.EXHAUST_PILE
	card_lightweight_statement.card_values = {"forge_damage": 3}
	card_lightweight_statement.card_upgrade_value_improvements = {"forge_damage": 2}
	card_lightweight_statement.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage"}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_lightweight_statement)

	# 16. 轻量护盾 (Lightweight Shield)
	var card_lightweight_shield: CardData = CardData.new("card_lightweight_shield")
	card_lightweight_shield.card_name = "轻量护盾"
	card_lightweight_shield.card_color_id = "color_{0}".format([color])
	card_lightweight_shield.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color]) # Temp sprite
	card_lightweight_shield.card_description = "[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷1」[/color]。"
	card_lightweight_shield.card_type = CardData.CARD_TYPES.SKILL
	card_lightweight_shield.card_rarity = CardData.CARD_RARITIES.COMMON
	card_lightweight_shield.card_requires_target = false
	card_lightweight_shield.card_energy_cost = 0
	card_lightweight_shield.card_play_destination = HandManager.EXHAUST_PILE
	card_lightweight_shield.card_values = {"forge_block": 4}
	card_lightweight_shield.card_upgrade_value_improvements = {"forge_block": 2}
	card_lightweight_shield.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_lightweight_shield)

	# 18. 余热护甲 (Residual Heat Armor)
	var card_residual_heat_armor: CardData = CardData.new("card_residual_heat_armor")
	card_residual_heat_armor.card_name = "余热护甲"
	card_residual_heat_armor.card_color_id = "color_{0}".format([color])
	card_residual_heat_armor.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color]) # Temp sprite
	card_residual_heat_armor.card_description = "获得 [block] 点防火墙。\n如果本回合载荷为4或更高，额外获得 [additional_block] 点防火墙。"
	card_residual_heat_armor.card_type = CardData.CARD_TYPES.SKILL
	card_residual_heat_armor.card_rarity = CardData.CARD_RARITIES.COMMON
	card_residual_heat_armor.card_requires_target = false
	card_residual_heat_armor.card_energy_cost = 1
	card_residual_heat_armor.card_values = {"block": 5, "additional_block": 6}
	card_residual_heat_armor.card_upgrade_value_improvements = {"block": 2, "additional_block": 1}
	card_residual_heat_armor.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"custom_key_names": {"additional_block": "none"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_PLAYER_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_turn_forge_load",
						"operator": ">=",
						"status_effect_charge_comparison_value": 4,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "additional_block", "additional_block": "none"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
				]
			}
		}
	]
	Global.register_rod(card_residual_heat_armor)

	# 19. 预置弹头 (Preset Warhead)
	var card_preset_warhead: CardData = CardData.new("card_preset_warhead")
	card_preset_warhead.card_name = "预置弹头"
	card_preset_warhead.card_color_id = "color_{0}".format([color])
	card_preset_warhead.card_texture_path = "sprites/cards/card_basic_attack_{0}.png".format([color]) # Temp sprite
	card_preset_warhead.card_description = "造成 [damage] 点伤害。\n如果锻造台中已有攻击代码，[color=orange]向锻造台加入「造成 [bonus_damage] 点伤害，负载2」[/color]。"
	card_preset_warhead.card_type = CardData.CARD_TYPES.ATTACK
	card_preset_warhead.card_rarity = CardData.CARD_RARITIES.COMMON
	card_preset_warhead.card_requires_target = true
	card_preset_warhead.card_energy_cost = 1
	card_preset_warhead.card_values = {"damage": 6, "bonus_damage": 7}
	card_preset_warhead.card_upgrade_value_improvements = {"damage": 2, "bonus_damage": 2}
	card_preset_warhead.card_play_actions = [
		{Scripts.ACTION_ATTACK: {}},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_FORGE_HAS_ACTION_TYPE: {
						"action_types": [Scripts.ACTION_ATTACK, Scripts.ACTION_ATTACK_GENERATOR, Scripts.ACTION_DIRECT_DAMAGE],
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_ADD_TO_FORGE: {
						"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "bonus_damage"}},
						"forge_action_load": 2,
						"forge_action_description": "造成 [damage] 点伤害"
					}}
				]
			}
		}
	]
	Global.register_rod(card_preset_warhead)

	# 20. 稳固结构 (Solid Structure)
	var card_solid_structure: CardData = CardData.new("card_solid_structure")
	card_solid_structure.card_name = "稳固结构"
	card_solid_structure.card_color_id = "color_{0}".format([color])
	card_solid_structure.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color]) # Temp sprite
	card_solid_structure.card_description = "获得 [block] 点防火墙。\n如果锻造台中已有防御代码，[color=orange]向锻造台加入「获得 [bonus_block] 点防火墙，负载2」[/color]。"
	card_solid_structure.card_type = CardData.CARD_TYPES.SKILL
	card_solid_structure.card_rarity = CardData.CARD_RARITIES.COMMON
	card_solid_structure.card_requires_target = false
	card_solid_structure.card_energy_cost = 1
	card_solid_structure.card_values = {"block": 4, "bonus_block": 7}
	card_solid_structure.card_upgrade_value_improvements = {"block": 2, "bonus_block": 2}
	card_solid_structure.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_FORGE_HAS_ACTION_TYPE: {
						"action_types": [Scripts.ACTION_BLOCK, Scripts.ACTION_BLOCK_BY_STATUS],
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_ADD_TO_FORGE: {
						"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "bonus_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
						"forge_action_load": 2,
						"forge_action_description": "获得 [block] 点防火墙"
					}}
				]
			}
		}
	]
	Global.register_rod(card_solid_structure)

	# 21. 载荷打击 (Payload Strike)
	var card_payload_strike: CardData = CardData.new("card_payload_strike")
	card_payload_strike.card_name = "载荷打击"
	card_payload_strike.card_color_id = "color_{0}".format([color])
	card_payload_strike.card_texture_path = "sprites/cards/card_basic_attack_{0}.png".format([color]) # Temp sprite
	card_payload_strike.card_description = "造成 [damage] 点伤害。\n如果本回合载荷为3或更高，抽 [draw] 张牌。"
	card_payload_strike.card_type = CardData.CARD_TYPES.ATTACK
	card_payload_strike.card_rarity = CardData.CARD_RARITIES.COMMON
	card_payload_strike.card_requires_target = true
	card_payload_strike.card_energy_cost = 1
	card_payload_strike.card_values = {"damage": 7, "draw": 1}
	card_payload_strike.card_upgrade_value_improvements = {"damage": 2}
	card_payload_strike.card_play_actions = [
		{Scripts.ACTION_DIRECT_DAMAGE: {}},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_PLAYER_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_turn_forge_load",
						"operator": ">=",
						"status_effect_charge_comparison_value": 3,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {"custom_key_names": {"draw_count": "draw"}}}
				]
			}
		}
	]
	Global.register_rod(card_payload_strike)

	# 22. 执行前检查 (Pre-execution Check)
	var card_pre_execution_check: CardData = CardData.new("card_pre_execution_check")
	card_pre_execution_check.card_name = "执行前检查"
	card_pre_execution_check.card_color_id = "color_{0}".format([color])
	card_pre_execution_check.card_texture_path = "sprites/cards/card_basic_skill_{0}.png".format([color]) # Temp sprite
	card_pre_execution_check.card_description = "如果当前总载荷为5或更高，获得 [block] 点防火墙。\n消耗。"
	card_pre_execution_check.card_type = CardData.CARD_TYPES.SKILL
	card_pre_execution_check.card_rarity = CardData.CARD_RARITIES.COMMON
	card_pre_execution_check.card_requires_target = false
	card_pre_execution_check.card_play_destination = HandManager.EXHAUST_PILE
	card_pre_execution_check.card_energy_cost = 0
	card_pre_execution_check.card_values = {"block": 7}
	card_pre_execution_check.card_upgrade_value_improvements = {"block": 3}
	card_pre_execution_check.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_FORGE_LOAD: {
						"load_required": 5,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
				]
			}
		}
	]
	Global.register_rod(card_pre_execution_check)
