class_name GlobalProdDataGeneratorOrangeCards
extends RefCounted

static func add_cards_orange() -> void:
	var color: String = "orange"

	# 1. 短路打击 (Short-circuit Strike)
	var card_short_circuit_strike: CardData = CardData.new("card_short_circuit_strike")
	card_short_circuit_strike.card_name = "短路打击"
	card_short_circuit_strike.card_color_id = "color_{0}".format([color])
	card_short_circuit_strike.card_texture_path = "sprites/card/orange/card_short_circuit_strike.png"
	card_short_circuit_strike.card_description = "造成 [damage] 点伤害。[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷1」[/color]。"
	card_short_circuit_strike.card_type = CardData.CARD_TYPES.ATTACK
	card_short_circuit_strike.card_rarity = CardData.CARD_RARITIES.COMMON
	card_short_circuit_strike.card_requires_target = true
	card_short_circuit_strike.card_energy_cost = 1
	card_short_circuit_strike.card_values = {"damage": 5, "forge_damage": 5}
	card_short_circuit_strike.card_upgrade_value_improvements = {"damage": 2, "forge_damage": 2}
	card_short_circuit_strike.card_play_actions = [
		{Scripts.ACTION_DIRECT_DAMAGE: {}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_short_circuit_strike)

	# 2. 结构防御 (Structural Defense)
	var card_structural_defense: CardData = CardData.new("card_structural_defense")
	card_structural_defense.card_name = "结构防御"
	card_structural_defense.card_color_id = "color_{0}".format([color])
	card_structural_defense.card_texture_path = "sprites/card/orange/card_structural_defense.png"
	card_structural_defense.card_description = "获得 [block] 点防火墙。[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷1」[/color]。"
	card_structural_defense.card_type = CardData.CARD_TYPES.SKILL
	card_structural_defense.card_rarity = CardData.CARD_RARITIES.COMMON
	card_structural_defense.card_requires_target = false
	card_structural_defense.card_energy_cost = 1
	card_structural_defense.card_values = {"block": 3, "forge_block": 5}
	card_structural_defense.card_upgrade_value_improvements = {"block": 2, "forge_block": 2}
	card_structural_defense.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_structural_defense)

	# 3. 穿孔指令 (Punch-hole Instruction)
	var card_punch_hole_instruction: CardData = CardData.new("card_punch_hole_instruction")
	card_punch_hole_instruction.card_name = "穿孔指令"
	card_punch_hole_instruction.card_color_id = "color_{0}".format([color])
	card_punch_hole_instruction.card_texture_path = "sprites/card/orange/card_punch_hole_instruction.png"
	card_punch_hole_instruction.card_description = "造成 [damage] 点伤害。[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷2」[/color]。"
	card_punch_hole_instruction.card_type = CardData.CARD_TYPES.ATTACK
	card_punch_hole_instruction.card_rarity = CardData.CARD_RARITIES.COMMON
	card_punch_hole_instruction.card_requires_target = true
	card_punch_hole_instruction.card_energy_cost = 1
	card_punch_hole_instruction.card_values = {"damage": 4, "forge_damage": 8}
	card_punch_hole_instruction.card_upgrade_value_improvements = {"damage": 2, "forge_damage": 2}
	card_punch_hole_instruction.card_play_actions = [
		{Scripts.ACTION_DIRECT_DAMAGE: {}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}}, "forge_action_load": 2}}
	]
	Global.register_rod(card_punch_hole_instruction)

	# 4. 厚重框架 (Heavy Framework)
	var card_heavy_framework: CardData = CardData.new("card_heavy_framework")
	card_heavy_framework.card_name = "厚重框架"
	card_heavy_framework.card_color_id = "color_{0}".format([color])
	card_heavy_framework.card_texture_path = "sprites/card/orange/card_heavy_framework.png"
	card_heavy_framework.card_description = "获得 [block] 点防火墙。[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷1」[/color]。"
	card_heavy_framework.card_type = CardData.CARD_TYPES.SKILL
	card_heavy_framework.card_rarity = CardData.CARD_RARITIES.COMMON
	card_heavy_framework.card_requires_target = false
	card_heavy_framework.card_energy_cost = 1
	card_heavy_framework.card_values = {"block": 6, "forge_block": 4}
	card_heavy_framework.card_upgrade_value_improvements = {"block": 2, "forge_block": 2}
	card_heavy_framework.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_heavy_framework)

	# 5. 防御脚本 (Defense Script)
	var card_defense_script: CardData = CardData.new("card_defense_script")
	card_defense_script.card_name = "防御脚本"
	card_defense_script.card_color_id = "color_{0}".format([color])
	card_defense_script.card_texture_path = "sprites/card/orange/card_defense_script.png"
	card_defense_script.card_description = "获得 [block] 点防火墙。[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷2」[/color]。"
	card_defense_script.card_type = CardData.CARD_TYPES.SKILL
	card_defense_script.card_rarity = CardData.CARD_RARITIES.COMMON
	card_defense_script.card_requires_target = false
	card_defense_script.card_energy_cost = 1
	card_defense_script.card_values = {"block": 3, "forge_block": 8}
	card_defense_script.card_upgrade_value_improvements = {"block": 1, "forge_block": 3}
	card_defense_script.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}}, "forge_action_load": 2}}
	]
	Global.register_rod(card_defense_script)

	# 6. 连锁弹道 (Chain Ballistics)
	var card_chain_ballistics: CardData = CardData.new("card_chain_ballistics")
	card_chain_ballistics.card_name = "连锁弹道"
	card_chain_ballistics.card_color_id = "color_{0}".format([color])
	card_chain_ballistics.card_texture_path = "sprites/card/orange/card_chain_ballistics.png"
	card_chain_ballistics.card_description = "[color=orange]向锻造台加入「造成 [forge_damage] 点伤害 [forge_amount] 次，载荷3」[/color]。获得 [block] 点防火墙。"
	card_chain_ballistics.card_type = CardData.CARD_TYPES.ATTACK
	card_chain_ballistics.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_chain_ballistics.card_requires_target = false
	card_chain_ballistics.card_energy_cost = 1
	card_chain_ballistics.card_values = {"block": 3, "forge_damage": 3, "forge_amount": 3}
	card_chain_ballistics.card_upgrade_value_improvements = {"forge_damage": 1}
	card_chain_ballistics.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK_GENERATOR: {"damage": "forge_damage", "number_of_attacks": "forge_amount", "time_delay": 0.2}}, "forge_action_load": 3}},
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}
	]
	Global.register_rod(card_chain_ballistics)

	# 7. 弱点标记 (Weakness Mark)
	var card_weakness_mark: CardData = CardData.new("card_weakness_mark")
	card_weakness_mark.card_name = "弱点标记"
	card_weakness_mark.card_color_id = "color_{0}".format([color])
	card_weakness_mark.card_texture_path = "sprites/card/orange/card_weakness_mark.png"
	card_weakness_mark.card_description = "给予目标 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]。[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷1」[/color]。"
	card_weakness_mark.card_type = CardData.CARD_TYPES.SKILL
	card_weakness_mark.card_rarity = CardData.CARD_RARITIES.COMMON
	card_weakness_mark.card_requires_target = true
	card_weakness_mark.card_energy_cost = 1
	card_weakness_mark.card_values = {"status_charge_amount": 2, "forge_damage": 6}
	card_weakness_mark.card_upgrade_value_improvements = {"forge_damage": 2}
	card_weakness_mark.card_play_actions = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable"}},
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_weakness_mark)

	# 8. 过热射击 (Overheat Shot)
	var card_overheat_shot: CardData = CardData.new("card_overheat_shot")
	card_overheat_shot.card_name = "过热射击"
	card_overheat_shot.card_color_id = "color_{0}".format([color])
	card_overheat_shot.card_texture_path = "sprites/card/orange/card_overheat_shot.png"
	card_overheat_shot.card_description = "造成 [damage] 点伤害。每有 2 层 [status_icon:status_effect_turn_forge_load]，额外造成 [additional_damage] 点伤害。"
	card_overheat_shot.card_type = CardData.CARD_TYPES.ATTACK
	card_overheat_shot.card_rarity = CardData.CARD_RARITIES.UNCOMMON
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
	card_pressure_shield.card_texture_path = "sprites/card/orange/card_pressure_shield.png"
	card_pressure_shield.card_description = "获得 [block] 点格挡。每有 2 层 [status_icon:status_effect_turn_forge_load]，额外获得 [additional_block] 点格挡。"
	card_pressure_shield.card_type = CardData.CARD_TYPES.SKILL
	card_pressure_shield.card_rarity = CardData.CARD_RARITIES.UNCOMMON
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
	card_emergency_barrier.card_texture_path = "sprites/card/orange/card_emergency_barrier.png"
	card_emergency_barrier.card_description = "使用至多 3 层 [status_icon:status_effect_turn_forge_load]。每使用 1 层 [status_icon:status_effect_turn_forge_load]，获得 [block_per_load] 点格挡。"
	card_emergency_barrier.card_type = CardData.CARD_TYPES.SKILL
	card_emergency_barrier.card_rarity = CardData.CARD_RARITIES.UNCOMMON
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
						"option_name": "使用 1 点载荷",
						"option_description": "获得 3 点格挡。",
						"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 1}}],
						"option_sub_actions": [
							{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 1}},
							{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_per_load"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
						]
					},
					{
						"option_name": "使用 2 点载荷",
						"option_description": "获得 6 点格挡。",
						"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 2}}],
						"option_sub_actions": [
							{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 2}},
							{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_2"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
						]
					},
					{
						"option_name": "使用 3 点载荷",
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
							"option_name": "使用 1 点载荷",
							"option_description": "获得 4 点格挡。",
							"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 1}}],
							"option_sub_actions": [
								{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 1}},
								{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_per_load"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
							]
						},
						{
							"option_name": "使用 2 点载荷",
							"option_description": "获得 8 点格挡。",
							"option_validators": [{Scripts.VALIDATOR_FORGE_LOAD: {"load_required": 2}}],
							"option_sub_actions": [
								{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 2}},
								{Scripts.ACTION_BLOCK: {"custom_key_names": {"block": "block_2"}, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}}
							]
						},
						{
							"option_name": "使用 3 点载荷",
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
	card_trial_run.card_texture_path = "sprites/card/orange/card_trial_run.png"
	card_trial_run.card_description = "将锻造台中的最后一段代码段封装为一张融合牌加入手牌，不移除代码段。 如果锻造台为空，抽1张牌。"
	card_trial_run.card_type = CardData.CARD_TYPES.SKILL
	card_trial_run.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_trial_run.card_requires_target = false
	card_trial_run.card_energy_cost = 1
	card_trial_run.card_first_upgrade_property_changes = {"card_energy_cost": 0, "card_description": "将锻造台中的最后一段代码段封装为一张融合牌加入手牌，不移除代码段。 如果锻造台为空，抽1张牌。"}
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
	card_snippet_extraction.card_texture_path = "sprites/card/orange/card_snippet_extraction.png"
	card_snippet_extraction.card_description = "造成 [damage] 点伤害。执行锻造台中的第一段代码段，然后移除代码段。"
	card_snippet_extraction.card_type = CardData.CARD_TYPES.ATTACK
	card_snippet_extraction.card_rarity = CardData.CARD_RARITIES.UNCOMMON
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
	card_data_backflow.card_texture_path = "sprites/card/orange/card_data_backflow.png"
	card_data_backflow.card_description = "使用 2 层 [status_icon:status_effect_turn_forge_load]。 抽2张牌。 如果 [status_icon:status_effect_turn_forge_load] 不足，抽1张牌。"
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
	card_lightweight_statement.card_texture_path = "sprites/card/orange/card_lightweight_statement.png"
	card_lightweight_statement.card_description = "[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷1」[/color]。"
	card_lightweight_statement.card_type = CardData.CARD_TYPES.SKILL
	card_lightweight_statement.card_rarity = CardData.CARD_RARITIES.COMMON
	card_lightweight_statement.card_requires_target = false
	card_lightweight_statement.card_energy_cost = 0
	card_lightweight_statement.card_play_destination = HandManager.EXHAUST_PILE
	card_lightweight_statement.card_values = {"forge_damage": 3}
	card_lightweight_statement.card_upgrade_value_improvements = {"forge_damage": 2}
	card_lightweight_statement.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_lightweight_statement)

	# 16. 轻量护盾 (Lightweight Shield)
	var card_lightweight_shield: CardData = CardData.new("card_lightweight_shield")
	card_lightweight_shield.card_name = "轻量护盾"
	card_lightweight_shield.card_color_id = "color_{0}".format([color])
	card_lightweight_shield.card_texture_path = "sprites/card/orange/card_lightweight_shield.png"
	card_lightweight_shield.card_description = "[color=orange]向锻造台加入「获得 [forge_block] 点防火墙，载荷1」[/color]。"
	card_lightweight_shield.card_type = CardData.CARD_TYPES.SKILL
	card_lightweight_shield.card_rarity = CardData.CARD_RARITIES.COMMON
	card_lightweight_shield.card_requires_target = false
	card_lightweight_shield.card_energy_cost = 0
	card_lightweight_shield.card_play_destination = HandManager.EXHAUST_PILE
	card_lightweight_shield.card_values = {"forge_block": 4}
	card_lightweight_shield.card_upgrade_value_improvements = {"forge_block": 2}
	card_lightweight_shield.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}}, "forge_action_load": 1}}
	]
	Global.register_rod(card_lightweight_shield)

	# 18. 余热护甲 (Residual Heat Armor)
	var card_residual_heat_armor: CardData = CardData.new("card_residual_heat_armor")
	card_residual_heat_armor.card_name = "余热护甲"
	card_residual_heat_armor.card_color_id = "color_{0}".format([color])
	card_residual_heat_armor.card_texture_path = "sprites/card/orange/card_residual_heat_armor.png"
	card_residual_heat_armor.card_description = "获得 [block] 点防火墙。 如果 [status_icon:status_effect_turn_forge_load] 为4层或更高，额外获得 [additional_block] 点防火墙。"
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
	card_preset_warhead.card_texture_path = "sprites/card/orange/card_preset_warhead.png"
	card_preset_warhead.card_description = "造成 [damage] 点伤害。 如果锻造台中已有攻击代码，[color=orange]向锻造台加入「造成 [bonus_damage] 点伤害，载荷2」[/color]。"
	card_preset_warhead.card_type = CardData.CARD_TYPES.ATTACK
	card_preset_warhead.card_rarity = CardData.CARD_RARITIES.UNCOMMON
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
						"action_types": ActionTypeGroups.ATTACK_ACTIONS,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_ADD_TO_FORGE: {
						"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "bonus_damage", "time_delay": 0.2}},
						"forge_action_load": 2,
						"forge_action_description": "造成 [bonus_damage] 点伤害"
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
	card_solid_structure.card_texture_path = "sprites/card/orange/card_solid_structure.png"
	card_solid_structure.card_description = "获得 [block] 点防火墙。 如果锻造台中已有防御代码，[color=orange]向锻造台加入「获得 [bonus_block] 点防火墙，载荷2」[/color]。"
	card_solid_structure.card_type = CardData.CARD_TYPES.SKILL
	card_solid_structure.card_rarity = CardData.CARD_RARITIES.UNCOMMON
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
						"action_types": ActionTypeGroups.DEFENSE_ACTIONS,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_ADD_TO_FORGE: {
						"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "bonus_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}},
						"forge_action_load": 2,
						"forge_action_description": "获得 [bonus_block] 点防火墙"
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
	card_payload_strike.card_texture_path = "sprites/card/orange/card_payload_strike.png"
	card_payload_strike.card_description = "造成 [damage] 点伤害。 如果 [status_icon:status_effect_turn_forge_load] 为3层或更高，抽 [draw] 张牌。"
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
	card_pre_execution_check.card_texture_path = "sprites/card/orange/card_pre_execution_check.png"
	card_pre_execution_check.card_description = "如果 [status_icon:status_effect_turn_forge_load] 为5层或更高，获得 [block] 点防火墙。"
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

	# 23. 热能释放 (Thermal Release)
	var card_thermal_release: CardData = CardData.new("card_thermal_release")
	card_thermal_release.card_name = "热能释放"
	card_thermal_release.card_color_id = "color_{0}".format([color])
	card_thermal_release.card_texture_path = "sprites/card/orange/card_thermal_release.png"
	card_thermal_release.card_description = "造成 [damage] 点伤害。使用所有 [status_icon:status_effect_turn_forge_load]。每使用 1 层 [status_icon:status_effect_turn_forge_load]，额外造成 [bonus_damage] 点伤害。"
	card_thermal_release.card_type = CardData.CARD_TYPES.ATTACK
	card_thermal_release.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_thermal_release.card_requires_target = true
	card_thermal_release.card_energy_cost = 2
	card_thermal_release.card_values = {"damage": 12, "bonus_damage": 2, "impact_vfx_animation_id": "animation_vfx_magic_orange"}
	card_thermal_release.card_upgrade_value_improvements = {"damage": 4}
	card_thermal_release.card_play_actions = [
		{
			Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 999}
		},
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "player_status_effect_charges",
				"stat_variable_name": "status_effect_turn_forge_load",
				"multiplied_values": ["bonus_damage"],
				"multiplied_values_bases": {"bonus_damage": 0},
				"action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: {
						"custom_key_names": {"additional_damage": "bonus_damage"}
					}}
				]
			}
		}
	]
	Global.register_rod(card_thermal_release)

	# 24. 超频冷却 (Overclock Cooling)
	var card_overclock_cooling: CardData = CardData.new("card_overclock_cooling")
	card_overclock_cooling.card_name = "超频冷却"
	card_overclock_cooling.card_color_id = "color_{0}".format([color])
	card_overclock_cooling.card_texture_path = "sprites/card/orange/card_overclock_cooling.png"
	card_overclock_cooling.card_description = "使用所有 [status_icon:status_effect_turn_forge_load]。每使用 1 层 [status_icon:status_effect_turn_forge_load]，获得 [bonus_block] 点格挡。如果使用了至少 5 层 [status_icon:status_effect_turn_forge_load]，抽1张牌。"
	card_overclock_cooling.card_type = CardData.CARD_TYPES.SKILL
	card_overclock_cooling.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_overclock_cooling.card_requires_target = false
	card_overclock_cooling.card_energy_cost = 1
	card_overclock_cooling.card_values = {"block": 0, "bonus_block": 2}
	card_overclock_cooling.card_upgrade_value_improvements = {"bonus_block": 1}
	card_overclock_cooling.card_play_actions = [
		{
			Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 999}
		},
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "player_status_effect_charges",
				"stat_variable_name": "status_effect_turn_forge_load",
				"multiplied_values": ["bonus_block"],
				"multiplied_values_bases": {"bonus_block": 0},
				"action_data": [
					{Scripts.ACTION_BLOCK: {
						"custom_key_names": {"additional_block": "bonus_block"},
						"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, 
						"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP
					}}
				]
			}
		},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_PLAYER_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_turn_forge_load",
						"operator": ">=",
						"status_effect_charge_comparison_value": 5,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}}
				]
			}
		}
	]
	Global.register_rod(card_overclock_cooling)

	# 25. 功率回收 (Power Recovery)
	var card_power_recovery: CardData = CardData.new("card_power_recovery")
	card_power_recovery.card_name = "功率回收"
	card_power_recovery.card_color_id = "color_{0}".format([color])
	card_power_recovery.card_texture_path = "sprites/card/orange/card_power_recovery.png"
	card_power_recovery.card_description = "使用 3 层 [status_icon:status_effect_turn_forge_load]。获得1点能量。"
	card_power_recovery.card_type = CardData.CARD_TYPES.SKILL
	card_power_recovery.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_power_recovery.card_requires_target = false
	card_power_recovery.card_energy_cost = 0
	card_power_recovery.card_play_destination = HandManager.EXHAUST_PILE
	card_power_recovery.card_first_upgrade_property_changes = {"card_play_destination": HandManager.DISCARD_PILE, "card_description": "使用 3 层 [status_icon:status_effect_turn_forge_load]。获得1点能量。"}
	card_power_recovery.card_play_actions = [
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
					{Scripts.ACTION_CONSUME_FORGE_LOAD: {"load_amount": 3}},
					{Scripts.ACTION_ADD_ENERGY: {"energy_amount": 1}}
				]
			}
		}
	]
	Global.register_rod(card_power_recovery)

	# 强制运行 (Force Run)
	var card_force_run: CardData = CardData.new("card_force_run")
	card_force_run.card_name = "强制运行"
	card_force_run.card_color_id = "color_{0}".format([color])
	card_force_run.card_texture_path = "sprites/card/orange/card_force_run.png"
	card_force_run.card_description = "直接融合锻造台所有代码段，融合牌0费，锻造台中的代码段全消除。"
	card_force_run.card_type = CardData.CARD_TYPES.SKILL
	card_force_run.card_rarity = CardData.CARD_RARITIES.RARE
	card_force_run.card_requires_target = false
	card_force_run.card_energy_cost = 2
	card_force_run.card_play_destination = HandManager.EXHAUST_PILE
	card_force_run.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_force_run.card_play_actions = [
		{
			Scripts.ACTION_TAKE_FROM_FORGE: {
				"take_type": 2,
				"clear_after_take": true,
				"execute_directly": false,
				"override_load": 0,
			}
		}
	]
	Global.register_rod(card_force_run)

	# 弹道整合 (Ballistics Integration)
	var card_ballistics_integration: CardData = CardData.new("card_ballistics_integration")
	card_ballistics_integration.card_name = "弹道整合"
	card_ballistics_integration.card_color_id = "color_{0}".format([color])
	card_ballistics_integration.card_texture_path = "sprites/card/orange/card_ballistics_integration.png"
	card_ballistics_integration.card_description = "锻造台中每有一段攻击代码，获得 [block] 点防火墙。 然后读取1个脚本。"
	card_ballistics_integration.card_type = CardData.CARD_TYPES.SKILL
	card_ballistics_integration.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_ballistics_integration.card_requires_target = false
	card_ballistics_integration.card_energy_cost = 1
	card_ballistics_integration.card_values = {"block": 3}
	card_ballistics_integration.card_upgrade_value_improvements = {"block": 1}
	card_ballistics_integration.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "actions_in_forge",
				"action_types": ActionTypeGroups.ATTACK_ACTIONS,
				"multiplied_values": ["block"],
				"action_data": [
					{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}
				]
			}
		},
		{
			Scripts.ACTION_DRAW_GENERATOR: {"draw_amount": 1}
		}
	]
	Global.register_rod(card_ballistics_integration)

	# 防火墙协议 (Firewall Protocol)
	var card_firewall_protocol: CardData = CardData.new("card_firewall_protocol")
	card_firewall_protocol.card_name = "防火墙协议"
	card_firewall_protocol.card_color_id = "color_{0}".format([color])
	card_firewall_protocol.card_texture_path = "sprites/card/orange/card_firewall_protocol.png"
	card_firewall_protocol.card_description = "在脚本库中生效。 每当你打出 [card_name:card_forge_fusion] 时，获得 [status_stacks] 点防火墙。"
	card_firewall_protocol.card_type = CardData.CARD_TYPES.POWER
	card_firewall_protocol.card_rarity = CardData.CARD_RARITIES.RARE
	card_firewall_protocol.card_requires_target = false
	card_firewall_protocol.card_energy_cost = 2
	card_firewall_protocol.card_play_destination = HandManager.EXHAUST_PILE
	card_firewall_protocol.card_values = {"status_stacks": 8, "remove_stacks": -8}
	card_firewall_protocol.card_upgrade_value_improvements = {"status_stacks": 3, "remove_stacks": -3}
	card_firewall_protocol.card_status_effect_object_ids = ["status_effect_firewall_protocol"]
	
	var apply_firewall_action = {
		Scripts.ACTION_APPLY_STATUS: {
			"status_effect_object_id": "status_effect_firewall_protocol",
			"custom_key_names": {"status_charge_amount": "status_stacks"},
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
		}
	}
	card_firewall_protocol.card_initial_combat_actions = [apply_firewall_action]
	card_firewall_protocol.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_firewall_protocol",
				"custom_key_names": {"status_charge_amount": "remove_stacks"},
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
			}
		}
	]
	Global.register_rod(card_firewall_protocol)

	# 26. 负载涡轮 (Payload Turbine)
	var card_payload_turbine: CardData = CardData.new("card_payload_turbine")
	card_payload_turbine.card_name = "负载涡轮"
	card_payload_turbine.card_color_id = "color_{0}".format([color])
	card_payload_turbine.card_texture_path = "sprites/card/orange/card_payload_turbine.png"
	card_payload_turbine.card_description = "在脚本库中生效。 每回合第一次获得载荷时，额外获得 [status_stacks] 层载荷。"
	card_payload_turbine.card_type = CardData.CARD_TYPES.POWER
	card_payload_turbine.card_rarity = CardData.CARD_RARITIES.RARE
	card_payload_turbine.card_requires_target = false
	card_payload_turbine.card_energy_cost = 1
	card_payload_turbine.card_values = {"status_stacks": 2}
	card_payload_turbine.card_upgrade_value_improvements = {"status_stacks": 1}
	card_payload_turbine.card_status_effect_object_ids = ["status_effect_payload_turbine"]
	
	var apply_payload_turbine_action = {
		Scripts.ACTION_APPLY_STATUS: {
			"status_effect_object_id": "status_effect_payload_turbine",
			"custom_key_names": {"status_charge_amount": "status_stacks"},
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
		}
	}
	card_payload_turbine.card_initial_combat_actions = [apply_payload_turbine_action]
	card_payload_turbine.card_play_actions = []
	Global.register_rod(card_payload_turbine)

	# 27. 递归加载 (Recursive Loading)
	var card_recursive_loading: CardData = CardData.new("card_recursive_loading")
	card_recursive_loading.card_name = "递归加载"
	card_recursive_loading.card_color_id = "color_{0}".format([color])
	card_recursive_loading.card_texture_path = "sprites/card/orange/card_recursive_loading.png"
	card_recursive_loading.card_description = "[color=orange]向锻造台加入「获得 [forge_load_amount] 层载荷，载荷1」[/color]。"
	card_recursive_loading.card_type = CardData.CARD_TYPES.SKILL
	card_recursive_loading.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_recursive_loading.card_requires_target = false
	card_recursive_loading.card_energy_cost = 0
	card_recursive_loading.card_play_destination = HandManager.EXHAUST_PILE
	card_recursive_loading.card_values = {"forge_load_amount": 2}
	card_recursive_loading.card_upgrade_value_improvements = {"forge_load_amount": 1}
	card_recursive_loading.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {
			"forge_action_data": {Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_turn_forge_load",
				"status_charge_amount": "forge_load_amount",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
			}},
			"forge_action_load": 1
		}}
	]
	Global.register_rod(card_recursive_loading)

	# 28. 模块选择 (Module Selection)
	var card_module_selection: CardData = CardData.new("card_module_selection")
	card_module_selection.card_name = "模块选择"
	card_module_selection.card_color_id = "color_{0}".format([color])
	card_module_selection.card_texture_path = "sprites/card/orange/card_module_selection.png"
	card_module_selection.card_description = "[color=orange]选择以下一段代码加入锻造台[/color]：\n「造成 [forge_damage] 点伤害，载荷2」\n「获得 [forge_block] 点防火墙，载荷2」\n「获得 [forge_load] 层载荷，载荷1」"
	card_module_selection.card_type = CardData.CARD_TYPES.SKILL
	card_module_selection.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_module_selection.card_requires_target = false
	card_module_selection.card_energy_cost = 1
	card_module_selection.card_values = {"forge_damage": 8, "forge_block": 8, "forge_load": 3}
	card_module_selection.card_upgrade_value_improvements = {"forge_damage": 2, "forge_block": 2, "forge_load": 1}
	card_module_selection.card_play_actions = [
		{
			Scripts.ACTION_PICK_OPTIONS: {
				"can_back_out": true,
				"options": [
					{
						"option_name": "攻击代码",
						"option_description": "向锻造台加入「造成 8 点伤害，载荷2」。",
						"option_sub_actions": [
							{Scripts.ACTION_ADD_TO_FORGE: {
								"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}},
								"forge_action_load": 2
							}}
						]
					},
					{
						"option_name": "防御代码",
						"option_description": "向锻造台加入「获得 8 点防火墙，载荷2」。",
						"option_sub_actions": [
							{Scripts.ACTION_ADD_TO_FORGE: {
								"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}},
								"forge_action_load": 2
							}}
						]
					},
					{
						"option_name": "载荷代码",
						"option_description": "向锻造台加入「获得 3 层载荷，载荷1」。",
						"option_sub_actions": [
							{Scripts.ACTION_ADD_TO_FORGE: {
								"forge_action_data": {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_turn_forge_load", "status_charge_amount": "forge_load", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
								"forge_action_load": 1
							}}
						]
					}
				]
			}
		}
	]
	card_module_selection.card_first_upgrade_property_changes = {
		"card_play_actions": [
			{
				Scripts.ACTION_PICK_OPTIONS: {
					"can_back_out": true,
					"options": [
						{
							"option_name": "攻击代码",
							"option_description": "向锻造台加入「造成 10 点伤害，载荷2」。",
							"option_sub_actions": [
								{Scripts.ACTION_ADD_TO_FORGE: {
									"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}},
									"forge_action_load": 2
								}}
							]
						},
						{
							"option_name": "防御代码",
							"option_description": "向锻造台加入「获得 10 点防火墙，载荷2」。",
							"option_sub_actions": [
								{Scripts.ACTION_ADD_TO_FORGE: {
									"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}},
									"forge_action_load": 2
								}}
							]
						},
						{
							"option_name": "载荷代码",
							"option_description": "向锻造台加入「获得 4 层载荷，载荷1」。",
							"option_sub_actions": [
								{Scripts.ACTION_ADD_TO_FORGE: {
									"forge_action_data": {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_turn_forge_load", "status_charge_amount": "forge_load", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
									"forge_action_load": 1
								}}
							]
						}
					]
				}
			}
		]
	}
	Global.register_rod(card_module_selection)

	# 29. 代码审计 (Code Audit)
	var card_code_audit: CardData = CardData.new("card_code_audit")
	card_code_audit.card_name = "代码审计"
	card_code_audit.card_color_id = "color_{0}".format([color])
	card_code_audit.card_texture_path = "sprites/card/orange/card_code_audit.png"
	card_code_audit.card_description = "将锻造台中所有代码段封装为一张融合牌加入手牌，不移除代码段。如果锻造台为空，抽2张牌。"
	card_code_audit.card_type = CardData.CARD_TYPES.SKILL
	card_code_audit.card_rarity = CardData.CARD_RARITIES.RARE
	card_code_audit.card_requires_target = false
	card_code_audit.card_energy_cost = 1
	card_code_audit.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_code_audit.card_play_actions = [
		{
			Scripts.ACTION_TAKE_FROM_FORGE: {
				"take_type": 2,
				"clear_after_take": false,
				"execute_directly": false,
				"override_load": -1,
				"fallback_action_data": [
					{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 2}}
				]
			}
		}
	]
	Global.register_rod(card_code_audit)

	# 30. 双重编译 (Dual Compile)
	var card_dual_compile: CardData = CardData.new("card_dual_compile")
	card_dual_compile.card_name = "双重编译"
	card_dual_compile.card_color_id = "color_{0}".format([color])
	card_dual_compile.card_texture_path = "sprites/card/orange/card_dual_compile.png"
	card_dual_compile.card_description = "造成 [damage] 点伤害。[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷1」和「获得 [forge_block] 点防火墙，载荷1」[/color]。"
	card_dual_compile.card_type = CardData.CARD_TYPES.ATTACK
	card_dual_compile.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_dual_compile.card_requires_target = true
	card_dual_compile.card_energy_cost = 2
	card_dual_compile.card_values = {"damage": 8, "forge_damage": 6, "forge_block": 6}
	card_dual_compile.card_upgrade_value_improvements = {"damage": 2, "forge_damage": 2, "forge_block": 2}
	card_dual_compile.card_play_actions = [
		{Scripts.ACTION_DIRECT_DAMAGE: {}},
		{Scripts.ACTION_ADD_TO_FORGE: {
			"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}},
			"forge_action_load": 1
		}},
		{Scripts.ACTION_ADD_TO_FORGE: {
			"forge_action_data": {Scripts.ACTION_BLOCK: {"block": "forge_block", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "time_delay": 0.2}},
			"forge_action_load": 1
		}}
	]
	Global.register_rod(card_dual_compile)

	# 31. 载荷共振 (Payload Resonance)
	var card_payload_resonance: CardData = CardData.new("card_payload_resonance")
	card_payload_resonance.card_name = "载荷共振"
	card_payload_resonance.card_color_id = "color_{0}".format([color])
	card_payload_resonance.card_texture_path = "sprites/card/orange/card_payload_resonance.png"
	card_payload_resonance.card_description = "获得 [block] 点防火墙。[color=orange]向锻造台加入「获得 [forge_load_amount] 层载荷，载荷1」[/color]。"
	card_payload_resonance.card_type = CardData.CARD_TYPES.SKILL
	card_payload_resonance.card_rarity = CardData.CARD_RARITIES.COMMON
	card_payload_resonance.card_requires_target = false
	card_payload_resonance.card_energy_cost = 1
	card_payload_resonance.card_values = {"block": 4, "forge_load_amount": 2}
	card_payload_resonance.card_upgrade_value_improvements = {"block": 2, "forge_load_amount": 1}
	card_payload_resonance.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{Scripts.ACTION_ADD_TO_FORGE: {
			"forge_action_data": {Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_turn_forge_load",
				"status_charge_amount": "forge_load_amount",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
			}},
			"forge_action_load": 1
		}}
	]
	Global.register_rod(card_payload_resonance)

	# 32. 发现漏洞 (Find Vulnerability)
	var card_find_vulnerability: CardData = CardData.new("card_find_vulnerability")
	card_find_vulnerability.card_name = "发现漏洞"
	card_find_vulnerability.card_color_id = "color_{0}".format([color])
	card_find_vulnerability.card_texture_path = "sprites/card/orange/card_find_vulnerability.png"
	card_find_vulnerability.card_description = "给予敌人 [vulnerable] 层漏洞暴露。[color=orange]向锻造台加入「给予敌人 [forge_vulnerable] 层漏洞暴露，载荷2」[/color]。"
	card_find_vulnerability.card_type = CardData.CARD_TYPES.SKILL
	card_find_vulnerability.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_find_vulnerability.card_requires_target = true
	card_find_vulnerability.card_energy_cost = 1
	card_find_vulnerability.card_values = {"damage": 5, "vulnerable": 1, "forge_vulnerable": 1}
	card_find_vulnerability.card_first_upgrade_property_changes = {
		"card_description": "造成 [damage] 点伤害。给予敌人 [vulnerable] 层漏洞暴露。[color=orange]向锻造台加入「给予敌人 [forge_vulnerable] 层漏洞暴露，载荷2」[/color]。",
		"card_play_actions": [
			{Scripts.ACTION_DIRECT_DAMAGE: {}},
			{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "custom_key_names": {"status_charge_amount": "vulnerable"}}},
			{Scripts.ACTION_ADD_TO_FORGE: {
				"forge_action_data": {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": "forge_vulnerable"}},
				"forge_action_load": 2
			}}
		]
	}
	card_find_vulnerability.card_play_actions = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "custom_key_names": {"status_charge_amount": "vulnerable"}}},
		{Scripts.ACTION_ADD_TO_FORGE: {
			"forge_action_data": {Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": "forge_vulnerable"}},
			"forge_action_load": 2
		}}
	]
	Global.register_rod(card_find_vulnerability)

	# 33. 巨型弹头 (Giant Warhead)
	var card_giant_warhead: CardData = CardData.new("card_giant_warhead")
	card_giant_warhead.card_name = "巨型弹头"
	card_giant_warhead.card_color_id = "color_{0}".format([color])
	card_giant_warhead.card_texture_path = "sprites/card/orange/card_giant_warhead.png"
	card_giant_warhead.card_description = "[color=orange]向锻造台加入「造成 [forge_damage] 点伤害，载荷6」[/color]。"
	card_giant_warhead.card_type = CardData.CARD_TYPES.SKILL
	card_giant_warhead.card_rarity = CardData.CARD_RARITIES.RARE
	card_giant_warhead.card_requires_target = false
	card_giant_warhead.card_energy_cost = 2
	card_giant_warhead.card_play_destination = HandManager.EXHAUST_PILE
	card_giant_warhead.card_values = {"forge_damage": 25}
	card_giant_warhead.card_upgrade_value_improvements = {"forge_damage": 5}
	card_giant_warhead.card_play_actions = [
		{Scripts.ACTION_ADD_TO_FORGE: {
			"forge_action_data": {Scripts.ACTION_ATTACK: {"damage": "forge_damage", "time_delay": 0.2}},
			"forge_action_load": 6
		}}
	]
	Global.register_rod(card_giant_warhead)

	# 34. 终局运行 (Final Run)
	var card_final_run: CardData = CardData.new("card_final_run")
	card_final_run.card_name = "终局运行"
	card_final_run.card_color_id = "color_{0}".format([color])
	card_final_run.card_texture_path = "sprites/card/orange/card_final_run.png"
	card_final_run.card_description = "造成 [damage] 点伤害。立即融合锻造台中所有代码段。"
	card_final_run.card_type = CardData.CARD_TYPES.ATTACK
	card_final_run.card_rarity = CardData.CARD_RARITIES.RARE
	card_final_run.card_requires_target = true
	card_final_run.card_energy_cost = 3
	card_final_run.card_play_destination = HandManager.EXHAUST_PILE
	card_final_run.card_values = {"damage": 10}
	card_final_run.card_upgrade_value_improvements = {"damage": 6}
	card_final_run.card_play_actions = [
		{Scripts.ACTION_DIRECT_DAMAGE: {}},
		{Scripts.ACTION_TAKE_FROM_FORGE: {
			"take_type": 2,
			"clear_after_take": true,
			"execute_directly": false,
			"override_load": 0
		}}
	]
	Global.register_rod(card_final_run)
