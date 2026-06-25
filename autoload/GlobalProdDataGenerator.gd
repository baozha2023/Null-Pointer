## Singleton for data generation in actual production.
## This is used to make content programmatically instead of messing with more fragile external JSON files.
extends Node

## Wrapper method used to generate all data used in production.
## After running this you can use Fileloader.export_read_only_data() to output to json files.
func generate_production_data() -> void:
	add_rest_actions()
	add_consumables()

	add_status_effects() # must be defined before enemies
	add_action_interceptors()

	add_enemies()
	add_events()
	add_dialogue()
	add_acts()

	add_colors()
	add_keywords()

	add_combat_vfx_animations()

	add_characters()
	add_player_data()

	add_run_modifiers()
	add_run_start_options()

	add_custom_ui()
	add_custom_signals()

	add_artifacts()
	add_card_decorators()
	add_cards()

	add_card_packs()
	add_artifact_packs()
	add_consumable_packs()

#region Artifacts
func add_artifacts() -> void:
	var artifact_add_money: ArtifactData = ArtifactData.new("artifact_add_money")
	artifact_add_money.artifact_name = "数据币外设插件"
	artifact_add_money.artifact_texture_path = "sprites/artifacts/artifact_add_money.png"
	artifact_add_money.artifact_description = "获得时增加 200 数据币"
	artifact_add_money.artifact_add_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 200 } }]

	Global.register_rod(artifact_add_money)

	var artifact_negate_money_gain: ArtifactData = ArtifactData.new("artifact_negate_money_gain")
	artifact_negate_money_gain.artifact_name = "算力外设插件"
	artifact_negate_money_gain.artifact_texture_path = "sprites/artifacts/artifact_negate_money_gain.png"
	artifact_negate_money_gain.artifact_description = "每时钟周期获得 {0}。无法再获得数据币".format([Card.ENERGY_ICON_KEYWORD])
	artifact_negate_money_gain.artifact_add_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_overrides": BaseAction.TARGET_OVERRIDES.PLAYER,
				"energy_amount_max": 1,
			},
		},
	]
	artifact_negate_money_gain.artifact_remove_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_overrides": BaseAction.TARGET_OVERRIDES.PLAYER,
				"energy_amount_max": -1,
			},
		},
	]
	artifact_negate_money_gain.artifact_interceptor_ids = ["interceptor_negate_add_money"]

	Global.register_rod(artifact_negate_money_gain)

	var artifact_heal_on_combat_ended: ArtifactData = ArtifactData.new("artifact_heal_on_combat_ended")
	artifact_heal_on_combat_ended.artifact_name = "战后治疗外设插件"
	artifact_heal_on_combat_ended.artifact_texture_path = "sprites/artifacts/artifact_heal_on_combat_ended.png"
	artifact_heal_on_combat_ended.artifact_description = "战斗结束时恢复5点完整度"
	artifact_heal_on_combat_ended.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_heal_on_combat_ended.artifact_end_of_combat_actions = [
		{
			Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 5 },
		},
	]

	Global.register_rod(artifact_heal_on_combat_ended)

	var artifact_full_heal: ArtifactData = ArtifactData.new("artifact_full_heal")
	artifact_full_heal.artifact_name = "完全治疗外设插件"
	artifact_full_heal.artifact_texture_path = "sprites/artifacts/artifact_full_heal.png"
	artifact_full_heal.artifact_description = "获得时完全恢复完整度"
	artifact_full_heal.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_full_heal.artifact_add_actions = [
		{
			Scripts.ACTION_HEAL_PERCENT: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"percentage_heal_amount": 1.0,
			},
		},
	]

	Global.register_rod(artifact_full_heal)

	var artifact_draw_on_kill: ArtifactData = ArtifactData.new("artifact_draw_on_kill")
	artifact_draw_on_kill.artifact_name = "击杀加载脚本外设插件"
	artifact_draw_on_kill.artifact_texture_path = "sprites/artifacts/artifact_draw_on_kill.png"
	artifact_draw_on_kill.artifact_description = "击杀敌人时加载一个脚本"
	artifact_draw_on_kill.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_draw_on_kill.artifact_script_path = "res://scripts/artifacts/ArtifactDrawOnKill.gd"
	Global.register_rod(artifact_draw_on_kill)

	var artifact_draw_on_combat_start: ArtifactData = ArtifactData.new("artifact_draw_on_combat_start")
	artifact_draw_on_combat_start.artifact_name = "初始加载脚本外设插件"
	artifact_draw_on_combat_start.artifact_description = "首时钟周期额外加载2个脚本"
	artifact_draw_on_combat_start.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_draw_on_combat_start.artifact_color_id = "color_green"
	artifact_draw_on_combat_start.artifact_texture_path = "sprites/artifacts/artifact_draw_on_combat_start.png"
	artifact_draw_on_combat_start.artifact_first_turn_actions = [{ Scripts.ACTION_DRAW_GENERATOR: { "draw_count": 2 } }]

	Global.register_rod(artifact_draw_on_combat_start)

	var artifact_energy_on_combat_start: ArtifactData = ArtifactData.new("artifact_energy_on_combat_start")
	artifact_energy_on_combat_start.artifact_name = "初始算力外设插件"
	artifact_energy_on_combat_start.artifact_description = "首时钟周期获得 {0}。".format([Card.ENERGY_ICON_KEYWORD])
	artifact_energy_on_combat_start.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_energy_on_combat_start.artifact_color_id = "color_white"
	artifact_energy_on_combat_start.artifact_texture_path = "sprites/artifacts/artifact_energy_on_combat_start.png"
	artifact_energy_on_combat_start.artifact_first_turn_actions = [{ Scripts.ACTION_ADD_ENERGY: { "energy_amount": 1 } }]

	Global.register_rod(artifact_energy_on_combat_start)

	var artifact_easy_mode: ArtifactData = ArtifactData.new("artifact_easy_mode")
	artifact_easy_mode.artifact_name = "安全模式外设插件"
	artifact_easy_mode.artifact_texture_path = "sprites/artifacts/artifact_easy_mode.png"
	artifact_easy_mode.artifact_description = "将敌人完整度设为1"
	artifact_easy_mode.artifact_counter = 999
	artifact_easy_mode.artifact_counter_max = 999
	artifact_easy_mode.artifact_counter_reset_on_combat_end = -1
	artifact_easy_mode.artifact_counter_reset_on_turn_start = -1
	artifact_easy_mode.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_easy_mode.artifact_script_path = "res://scripts/artifacts/ArtifactEasyMode.gd"

	Global.register_rod(artifact_easy_mode)

	var artifact_block_on_attacks: ArtifactData = ArtifactData.new("artifact_block_on_attacks")
	artifact_block_on_attacks.artifact_name = "攻击防火墙外设插件"
	artifact_block_on_attacks.artifact_description = "每3次攻击获得5点防火墙"
	artifact_block_on_attacks.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_block_on_attacks.artifact_color_id = "color_red"
	artifact_block_on_attacks.artifact_texture_path = "sprites/artifacts/artifact_block_on_attacks.png"
	artifact_block_on_attacks.artifact_script_path = "res://scripts/artifacts/ArtifactBlockOnAttacks.gd"
	artifact_block_on_attacks.artifact_counter_max = 3
	artifact_block_on_attacks.artifact_counter_wraparound = true
	artifact_block_on_attacks.artifact_counter_reset_on_turn_start = 0
	artifact_block_on_attacks.artifact_counter_reset_on_combat_end = 0
	artifact_block_on_attacks.artifact_max_counter_actions = [
		{
			Scripts.ACTION_BLOCK: { "block": 5, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER },
		},
	]

	Global.register_rod(artifact_block_on_attacks)

	var artifact_retain_hand: ArtifactData = ArtifactData.new("artifact_retain_hand")
	artifact_retain_hand.artifact_name = "当前线程保留外设插件"
	artifact_retain_hand.artifact_texture_path = "sprites/artifacts/artifact_retain_hand.png"
	artifact_retain_hand.artifact_description = "时钟周期结束时，当前线程中的所有脚本不会被丢弃"
	artifact_retain_hand.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_retain_hand.artifact_script_path = "res://scripts/artifacts/ArtifactRetainHand.gd"

	Global.register_rod(artifact_retain_hand)

	# preserves energy between turns
	var artifact_preserve_energy: ArtifactData = ArtifactData.new("artifact_preserve_energy")
	artifact_preserve_energy.artifact_name = "算力保留外设插件"
	artifact_preserve_energy.artifact_texture_path = "sprites/artifacts/artifact_preserve_energy.png"
	artifact_preserve_energy.artifact_description = "时钟周期结束时，未消耗的算力将保留至下一周期"
	artifact_preserve_energy.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_preserve_energy.artifact_first_turn_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_effect_object_id": "status_effect_preserve_energy",
			},
		},
	]
	artifact_preserve_energy.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"

	Global.register_rod(artifact_preserve_energy)

	# Enables a rest action when obtained, which grants a damage increase at the start of combat
	var artifact_increase_attack_on_rest: ArtifactData = ArtifactData.new("artifact_increase_attack_on_rest")
	artifact_increase_attack_on_rest.artifact_name = "碎片整理增伤外设插件"
	artifact_increase_attack_on_rest.artifact_description = "在维护终端可永久提升 1 点攻击力（最高提升 3 点）"
	artifact_increase_attack_on_rest.artifact_counter = 0
	artifact_increase_attack_on_rest.artifact_counter_max = 3
	artifact_increase_attack_on_rest.artifact_color_id = "color_orange"
	artifact_increase_attack_on_rest.artifact_texture_path = "sprites/artifacts/artifact_increase_attack_on_rest.png"
	artifact_increase_attack_on_rest.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_increase_attack_on_rest.artifact_add_actions = [
		{
			Scripts.ACTION_UPDATE_REST_ACTIONS: { "add_rest_action_object_ids": ["rest_action_increase_attack_on_rest"] },
		},
	]
	artifact_increase_attack_on_rest.artifact_first_turn_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_effect_object_id": "status_effect_damage_increase",
				"custom_key_names": {
					# convert artifact counter passed in from BaseArtifact, into the status charges
					"status_charge_amount": "artifact_counter",
				},
			},
		},
	]

	Global.register_rod(artifact_increase_attack_on_rest)

	var artifact_see_top_of_draw_pile: ArtifactData = ArtifactData.new("artifact_see_top_of_draw_pile")
	artifact_see_top_of_draw_pile.artifact_name = "查看脚本库外设插件"
	artifact_see_top_of_draw_pile.artifact_description = "查看脚本库顶部的脚本"
	artifact_see_top_of_draw_pile.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_see_top_of_draw_pile.artifact_color_id = "color_blue"
	artifact_see_top_of_draw_pile.artifact_texture_path = "sprites/artifacts/artifact_see_top_of_draw_pile.png"

	Global.register_rod(artifact_see_top_of_draw_pile)

	# Makes an attack card top deck when obtained
	var artifact_top_deck_attack_card: ArtifactData = ArtifactData.new("artifact_top_deck_attack_card")
	artifact_top_deck_attack_card.artifact_name = "攻击脚本置顶外设插件"
	artifact_top_deck_attack_card.artifact_texture_path = "sprites/artifacts/artifact_top_deck_attack_card.png"
	artifact_top_deck_attack_card.artifact_description = "选择一个攻击脚本置于脚本库顶部。"
	artifact_top_deck_attack_card.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_top_deck_attack_card.artifact_add_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"max_card_amount": 1,
				"min_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"random_selection": false,
				"quick_pick": true,
				"card_pick_type": HandManager.DECK,
				"card_pick_text": "选择一个脚本置于脚本库顶",
				"action_data": [
					# convert the card to top deck
					{
						Scripts.ACTION_CHANGE_CARD_PROPERTIES: {
							"modify_parent_card": false,
							"card_properties": { "card_unremovable_from_deck": true, "card_untransformable_from_deck": true, "card_first_shuffle_priority": 1 },
						},
					},
				],
				# only non-generated removable attack cards allowed
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_TYPE: { "card_types": [CardData.CARD_TYPES.ATTACK] } },
					{ Scripts.VALIDATOR_CARD_RARITY: { "card_rarities_exclude": [CardData.CARD_RARITIES.GENERATED] } },
					{ Scripts.VALIDATOR_CARD_PROPERTIES: { "card_property_name": "card_unremovable_from_deck", "operator": "==", "comparison_value": false } },
				],
			},
		},
	]

	Global.register_rod(artifact_top_deck_attack_card)

	var artifact_right_click_shuffle_deck: ArtifactData = ArtifactData.new("artifact_right_click_shuffle_deck")
	artifact_right_click_shuffle_deck.artifact_name = "重洗外设插件"
	artifact_right_click_shuffle_deck.artifact_description = "右键将回收站的数据重新分配入内存队列。"
	artifact_right_click_shuffle_deck.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_right_click_shuffle_deck.artifact_color_id = "color_green"
	artifact_right_click_shuffle_deck.artifact_texture_path = "sprites/artifacts/artifact_right_click_shuffle_deck.png"
	artifact_right_click_shuffle_deck.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_right_click_shuffle_deck.artifact_right_click_actions = [
		{ Scripts.ACTION_RESHUFFLE: { } },
	]

	Global.register_rod(artifact_right_click_shuffle_deck)

	### Filler Artifacts




#endregion

#region Consumables
func add_consumables() -> void:
	# health consumable
	var consumable_heal: ConsumableData = ConsumableData.new("consumable_heal")
	consumable_heal.consumable_name = "治疗道具"
	consumable_heal.consumable_color_id = "color_white"
	consumable_heal.consumable_description = "回复20%最大完整度"
	consumable_heal.consumable_use_text = "饮用"
	consumable_heal.consumable_requires_target = false
	consumable_heal.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_heal.consumable_texture_path = "sprites/consumables/consumable_heal.png"
	consumable_heal.consumable_values = {
		"percentage_heal_amount": 0.20,
	}
	consumable_heal.consumable_actions = [
		{
			Scripts.ACTION_HEAL_PERCENT: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_heal)

	# block consumable
	var consumable_block: ConsumableData = ConsumableData.new("consumable_block")
	consumable_block.consumable_name = "防火墙道具"
	consumable_block.consumable_color_id = "color_white"
	consumable_block.consumable_description = "获得10点防火墙"
	consumable_block.consumable_use_text = "饮用"
	consumable_block.consumable_requires_target = false
	consumable_block.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_block.consumable_texture_path = "sprites/consumables/consumable_block.png"
	consumable_block.consumable_values = {
		"block": 10,
	}
	consumable_block.consumable_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_block)

	# damaging consumable
	var consumable_damaging: ConsumableData = ConsumableData.new("consumable_damaging")
	consumable_damaging.consumable_name = "伤害道具"
	consumable_damaging.consumable_color_id = "color_white"
	consumable_damaging.consumable_description = "对一个目标造成10点伤害"
	consumable_damaging.consumable_use_text = "投掷"
	consumable_damaging.consumable_requires_target = true
	consumable_damaging.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_damaging.consumable_texture_path = "sprites/consumables/consumable_damaging.png"
	consumable_damaging.consumable_values = {
		"damage": 10,
		"bypass_block": false,
	}
	consumable_damaging.consumable_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS,
			},
		},
	]
	Global.register_rod(consumable_damaging)

	# multi enemy damaging consumable
	var consumable_multi_damaging: ConsumableData = ConsumableData.new("consumable_multi_damaging")
	consumable_multi_damaging.consumable_name = "群体伤害道具"
	consumable_multi_damaging.consumable_color_id = "color_white"
	consumable_multi_damaging.consumable_use_text = "投掷"
	consumable_multi_damaging.consumable_description = "对所有敌人造成10点伤害"
	consumable_multi_damaging.consumable_requires_target = false
	consumable_multi_damaging.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_multi_damaging.consumable_texture_path = "sprites/consumables/consumable_multi_damaging.png"
	consumable_multi_damaging.consumable_values = {
		"damage": 10,
		"bypass_block": false,
	}
	consumable_multi_damaging.consumable_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]
	Global.register_rod(consumable_multi_damaging)

#endregion

#region Rest Actions
func add_rest_actions() -> void:
	# rest action
	var rest_action_rest: RestActionData = RestActionData.new("rest_action_rest")
	rest_action_rest.rest_action_name = "碎片整理"
	rest_action_rest.rest_action_stat_name = "REST_REST_COUNT"
	rest_action_rest.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_rest.rest_actions = [
		{
			Scripts.ACTION_HEAL_PERCENT: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"percentage_heal_amount": 0.40,
			},
		},
	]

	Global.register_rod(rest_action_rest)

	# upgrade card rest action
	# example of a cancelable rest action
	var rest_action_upgrade_card: RestActionData = RestActionData.new("rest_action_upgrade_card")
	rest_action_upgrade_card.rest_action_name = "升级"
	rest_action_upgrade_card.rest_action_stat_name = "REST_UPGRADE_CARDS_COUNT"
	rest_action_upgrade_card.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE
	rest_action_upgrade_card.rest_action_auto_end = false # allows canceling
	rest_action_upgrade_card.rest_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"min_card_amount": 1,
				"max_card_amount": 1,
				"card_pick_type": HandManager.DECK,
				"card_pick_text": "选择至多 {0} 个脚本升级。已选 {1} 个",
				"min_cards_are_required_for_action": true, # won't fire if you cancel it
				"quick_pick": false,
				"can_back_out": true, # allows rest action to be canceled
				"random_selection": false,
				# only upgradeable cards allowed
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } },
				],
				"action_data": [
					# embed the rest action end in the pick card action payload
					{ Scripts.ACTION_REST_ACTION_END: { "rest_action_id": "rest_action_upgrade_card" } },
					{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": true } },
				],
			},
		},
	]

	rest_action_upgrade_card.rest_action_validators = [
		{
			Scripts.VALIDATOR_DECK_HAS_UPGRADEABLE_CARD: { },
		},
	]

	Global.register_rod(rest_action_upgrade_card)

	# remove cards action
	# example of a cancelable rest action
	var rest_action_remove_cards: RestActionData = RestActionData.new("rest_action_remove_cards")
	rest_action_remove_cards.rest_action_name = "移除脚本"
	rest_action_remove_cards.rest_action_stat_name = "REST_REMOVE_CARDS_COUNT"
	rest_action_remove_cards.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE
	rest_action_remove_cards.rest_action_auto_end = false # can be cancelled
	rest_action_remove_cards.rest_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false,
				"min_card_amount": 1,
				"max_card_amount": 2,
				"min_cards_are_required_for_action": true,
				"quick_pick": false,
				"can_back_out": true, # allows rest action to be canceled
				"random_selection": false,
				"card_pick_text": "选择 {0} 个脚本移除。已选 {1} 个",
				"card_pick_type": HandManager.DECK,
				"action_data": [
					# embed the rest action end in the pick card action payload
					{ Scripts.ACTION_REST_ACTION_END: { "rest_action_id": "rest_action_remove_cards" } },
					{ Scripts.ACTION_REMOVE_CARDS_FROM_DECK: { } },
				],
			},
		},
	]
	rest_action_remove_cards.rest_action_validators = [
		{
			Scripts.VALIDATOR_PILE_SIZE: {
				"card_pick_type": HandManager.DECK,
				"card_type_maximum": 4,
				"card_types": CardData.CARD_TYPES.values(), # any card
				"invert_validation": false,
			},
		},
	]

	Global.register_rod(rest_action_remove_cards)

	# enchant a selected card from your deck
	# randomly chooses an enchant
	# must have at least one card that can be decorated and enough money
	# NOTE: To add more random enchants, you must update the random selection, the pick validator, and the rest action deck validator
	var rest_action_enchant_cards: RestActionData = RestActionData.new("rest_action_enchant_cards")
	rest_action_enchant_cards.rest_action_name = "附魔脚本 (25)"
	rest_action_enchant_cards.rest_action_stat_name = "REST_ENCHANT_CARDS_COUNT"
	rest_action_enchant_cards.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE
	rest_action_enchant_cards.rest_action_auto_end = false
	rest_action_enchant_cards.rest_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"quick_pick": false,
				"can_back_out": true, # allows rest action to be canceled
				"random_selection": false,
				"card_pick_text": "选择一个脚本附魔",
				"card_pick_type": HandManager.DECK,
				# only decoratable cards allowed, must be able to slot one of the provided decorators
				"validator_data": [
					{
						Scripts.VALIDATOR_CARD_IS_DECORATABLE: {
							"card_decorator_ids": [
								"card_decorator_extra_draw",
								"card_decorator_block_on_play",
							],
						},
					},
				],
				"action_data": [
					# finish rest action
					{ Scripts.ACTION_REST_ACTION_END: { "rest_action_id": "rest_action_enchant_cards" } },
					# remove money
					{ Scripts.ACTION_ADD_MONEY: { "money_amount": -25 } },
					# randomly decorate the card
					{
						Scripts.ACTION_DECORATE_CARDS: {
							"decorate_parent_card": false, # already selecting the deck card
							"random_card_decorators": {
								"card_decorator_extra_draw": { },
								"card_decorator_block_on_play": { },
							},
						},
					},
				],
			},
		},
	]
	rest_action_enchant_cards.rest_action_validators = [
		{
			# must have enough money
			Scripts.VALIDATOR_MONEY: {
				"money_amount": 25,
			},
		},
		{
			# must have at least one card that can slot a decorator
			Scripts.VALIDATOR_DECK_HAS_DECORATABLE_CARD: {
				"card_pick_type": HandManager.DECK,
				"card_decorator_ids": [
					"card_decorator_extra_draw",
					"card_decorator_block_on_play",
				],
				"card_types": CardData.CARD_TYPES.values(), # any card
				"invert_validation": false,
			},
		},
	]

	Global.register_rod(rest_action_enchant_cards)

	# add random consumable action
	var rest_action_add_random_consumable: RestActionData = RestActionData.new("rest_action_add_random_consumable")
	rest_action_add_random_consumable.rest_action_name = "随机物理删除品"
	rest_action_add_random_consumable.rest_action_stat_name = "REST_GAIN_CONSUMABLE_COUNT"
	rest_action_add_random_consumable.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_add_random_consumable.rest_actions = [
		{ Scripts.ACTION_ADD_CONSUMABLE: { "random_consumable": true } },
	]

	Global.register_rod(rest_action_add_random_consumable)

	# increase damage artifact action
	# paired with corresponding artifact
	var rest_action_increase_attack_on_rest: RestActionData = RestActionData.new("rest_action_increase_attack_on_rest")
	rest_action_increase_attack_on_rest.rest_action_name = "提升伤害"
	rest_action_increase_attack_on_rest.rest_action_stat_name = "REST_INCREASE_DAMAGE_COUNT"
	rest_action_increase_attack_on_rest.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_increase_attack_on_rest.rest_actions = [
		{ Scripts.ACTION_INCREASE_ARTIFACT_CHARGE: { "artifact_id": "artifact_increase_attack_on_rest" } },
	]

	Global.register_rod(rest_action_increase_attack_on_rest)

#endregion

#region Status Effects
func add_status_effects() -> void:
	var status_effect_overshield: StatusEffectData = StatusEffectData.new("status_effect_overshield")
	status_effect_overshield.status_effect_name = "防火墙过载"
	status_effect_overshield.status_effect_description = "抵挡等同于层数的伤害。"
	status_effect_overshield.status_effect_texture_path = "sprites/status_effects/icon_overshield.png"
	status_effect_overshield.status_effect_decay_rate = -5
	status_effect_overshield.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_overshield.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_overshield.status_effect_interceptor_ids = ["interceptor_overshield"]
	status_effect_overshield.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_overshield.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]

	Global.register_rod(status_effect_overshield)

	# Preserve Energy
	var status_effect_preserve_energy: StatusEffectData = StatusEffectData.new("status_effect_preserve_energy")
	status_effect_preserve_energy.status_effect_name = "算力保留"
	status_effect_preserve_energy.status_effect_texture_path = "sprites/status_effects/icon_preserve_energy.png"
	status_effect_preserve_energy.status_effect_charge_upper_bound = 1
	status_effect_preserve_energy.status_effect_is_visible = false
	status_effect_preserve_energy.status_effect_decay_rate = 0
	status_effect_preserve_energy.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_preserve_energy.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_preserve_energy.status_effect_interceptor_ids = ["interceptor_preserve_energy"]
	status_effect_preserve_energy.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_preserve_energy.status_effect_action_process_times = []

	Global.register_rod(status_effect_preserve_energy)

	var status_effect_preserve_overshield: StatusEffectData = StatusEffectData.new("status_effect_preserve_overshield")
	status_effect_preserve_overshield.status_effect_name = "持久化过载"
	status_effect_preserve_overshield.status_effect_description = "时钟周期结束时，保留所有的防火墙过载。"
	status_effect_preserve_overshield.status_effect_texture_path = "sprites/status_effects/icon_preserve_overshield.png"
	status_effect_preserve_overshield.status_effect_decay_rate = 0
	status_effect_preserve_overshield.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_preserve_overshield.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_preserve_overshield.status_effect_interceptor_ids = ["interceptor_preserve_overshield"]
	status_effect_preserve_overshield.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_preserve_overshield.status_effect_action_process_times = []

	Global.register_rod(status_effect_preserve_overshield)

	var status_effect_pointy: StatusEffectData = StatusEffectData.new("status_effect_pointy")
	status_effect_pointy.status_effect_name = "反伤模块"
	status_effect_pointy.status_effect_description = "受到攻击时，对攻击者造成等同于层数的伤害。"
	status_effect_pointy.status_effect_texture_path = "sprites/status_effects/icon_pointy.png"
	status_effect_pointy.status_effect_decay_rate = 0
	status_effect_pointy.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_pointy.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_pointy.status_effect_interceptor_ids = ["interceptor_pointy"]
	status_effect_pointy.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_pointy.status_effect_action_process_times = []

	Global.register_rod(status_effect_pointy)

	# damages the player at the start of their turn and increases number of cards drawn
	var status_effect_pollen: StatusEffectData = StatusEffectData.new("status_effect_pollen")
	status_effect_pollen.status_effect_name = "数据污染"
	status_effect_pollen.status_effect_description = "每时钟周期触发时，失去等同于层数的完整度，并读取等同于副层数个脚本。"
	status_effect_pollen.status_effect_texture_path = "sprites/status_effects/icon_pollen.png"
	status_effect_pollen.status_effect_decay_rate = 0
	status_effect_pollen.status_effect_priority = 10
	status_effect_pollen.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_pollen.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_pollen.status_effect_interceptor_ids = []
	status_effect_pollen.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_pollen.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DRAW_PLAYER_START_TURN]
	status_effect_pollen.status_effect_player_process_actions = [
		{
			Scripts.ACTION_DRAW_GENERATOR: {
				"custom_key_names": {
					# convert the secondary status charges, passed in from BaseStatusEffect, into card draw
					"draw_count": "invoking_status_effect_secondary_charges",
				},
				"time_delay": 0.0,
				"is_start_of_turn_draw": false,
			},
		},
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the status charges, passed in from BaseStatusEffect, into poison damage
					"damage": "invoking_status_effect_charges",
				},
				"time_delay": 0.2,
				"bypass_block": true,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]

	Global.register_rod(status_effect_pollen)

	# poison like effect
	# example of status effect that reserves health bar
	var status_effect_corrosion: StatusEffectData = StatusEffectData.new("status_effect_corrosion")
	status_effect_corrosion.status_effect_name = "底层腐蚀"
	status_effect_corrosion.status_effect_description = "每时钟周期结束时，失去等同于层数的完整度（无视防火墙）。"
	status_effect_corrosion.status_effect_texture_path = "sprites/status_effects/icon_corrosion.png"
	status_effect_corrosion.status_effect_decay_rate = -2
	# status_effect_corrosion.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.HALF_LIFE_ROUND_UP # uncomment to change to half life decay
	status_effect_corrosion.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_corrosion.status_effect_interceptor_ids = []
	status_effect_corrosion.status_effect_healthbar_layer_color = Color.DARK_GREEN.to_html(false)
	status_effect_corrosion.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.STATUS_CHARGES
	status_effect_corrosion.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_ENEMY_TURN,
	]
	status_effect_corrosion.status_effect_player_process_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the status charges, passed in from BaseStatusEffect, into poison damage
					"damage": "invoking_status_effect_charges",
				},
				"time_delay": 0.5,
				"bypass_block": true,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	status_effect_corrosion.status_effect_enemy_process_actions = status_effect_corrosion.status_effect_player_process_actions.duplicate()

	Global.register_rod(status_effect_corrosion)

	# status effect that grants overheat each turn
	var status_effect_critical: StatusEffectData = StatusEffectData.new("status_effect_critical")
	status_effect_critical.status_effect_name = "临界"
	status_effect_critical.status_effect_description = "每时钟周期开始时，获得等同于层数的内核过热。"
	status_effect_critical.status_effect_texture_path = "sprites/status_effects/icon_critical.png"
	status_effect_critical.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_critical.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_critical.status_effect_charge_upper_bound = 100
	status_effect_critical.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_ENEMY_INTENT,
	]
	status_effect_critical.status_effect_player_process_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"custom_key_names": {
					"status_charge_amount": "invoking_status_effect_charges",
				},
				"time_delay": 0.1,
				"status_effect_object_id": "status_effect_overheat",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	status_effect_critical.status_effect_enemy_process_actions = []
	status_effect_critical.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_critical)

	# status effect that damages all combatants when overflowed
	var status_effect_overheat: StatusEffectData = StatusEffectData.new("status_effect_overheat")
	status_effect_overheat.status_effect_name = "内核过热"
	status_effect_overheat.status_effect_description = "当层数达到或超过 10 层时触发爆裂，对全场所有单位造成 10 点伤害，随后层数减半。"
	status_effect_overheat.status_effect_texture_path = "sprites/status_effects/icon_overheat.png"
	status_effect_overheat.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.HALF_LIFE_ROUND_UP
	status_effect_overheat.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_overheat.status_effect_charge_upper_bound = 10
	status_effect_overheat.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_overheat.status_effect_charge_overflows = true
	status_effect_overheat.status_effect_player_flow_actions = [
		{
			Scripts.ACTION_EMIT_CUSTOM_SIGNAL: {
				"custom_signal_object_id": "custom_signal_overheated",
				"custom_signal_value": 1,
			},
		},
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"damage": 10,
				"bypass_block": false,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS,
			},
		},
	]
	status_effect_overheat.status_effect_enemy_process_actions = []
	status_effect_overheat.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_overheat)

	# grants energy on overheat
	var status_effect_feedback_loop: StatusEffectData = StatusEffectData.new("status_effect_feedback_loop")
	status_effect_feedback_loop.status_effect_name = "反馈循环"
	status_effect_feedback_loop.status_effect_description = "每当内核过热触发爆裂时，获得等同于层数的 {0}。".format([Card.ENERGY_ICON_KEYWORD])
	status_effect_feedback_loop.status_effect_texture_path = "sprites/status_effects/icon_feedback_loop.png"
	status_effect_feedback_loop.status_effect_script_path = "res://scripts/status_effects/StatusEffectFeedbackLoop.gd"
	status_effect_feedback_loop.status_effect_decay_rate = 0
	status_effect_feedback_loop.status_effect_allows_multiples = false
	status_effect_feedback_loop.status_effect_action_process_times = [] # does not process or decay normally. See status script
	status_effect_feedback_loop.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_feedback_loop.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_feedback_loop)

	# bomb effect that counts down and damages all enemies
	# uses unique status logic
	var status_effect_bomb: StatusEffectData = StatusEffectData.new("status_effect_bomb")
	status_effect_bomb.status_effect_name = "逻辑炸弹"
	status_effect_bomb.status_effect_description = "倒计时结束时，对所有敌人造成等同于副层数的伤害。"
	status_effect_bomb.status_effect_texture_path = "sprites/status_effects/icon_bomb.png"
	status_effect_bomb.status_effect_script_path = "res://scripts/status_effects/StatusEffectBomb.gd"
	status_effect_bomb.status_effect_decay_rate = -1
	status_effect_bomb.status_effect_allows_multiples = true
	status_effect_bomb.status_effect_secondary_charge_collision_strategy = StatusEffectData.STATUS_EFFECT_SECONDARY_CHARGE_COLLISION_STRATEGIES.KEEP
	status_effect_bomb.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_bomb.status_effect_player_process_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the bomb's status secondary charges, passed in from BaseStatusEffect, into bomb damage
					"damage": "invoking_status_effect_secondary_charges",
				},
				"bypass_block": false,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES, # player bombs hit all enemies
			},
		},
	]
	status_effect_bomb.status_effect_enemy_process_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the bomb's status secondary charges, passed in from BaseStatusEffect, into bomb damage
					"damage": "invoking_status_effect_secondary_charges",
				},
				"bypass_block": false,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, # enemy bombs hit player
			},
		},
	]
	status_effect_bomb.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_bomb.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_bomb)

	# increases attack damage by charge amount
	# uses an interceptor
	var status_effect_damage_increase: StatusEffectData = StatusEffectData.new("status_effect_damage_increase")
	status_effect_damage_increase.status_effect_name = "算力增幅"
	status_effect_damage_increase.status_effect_description = "造成的攻击伤害增加等同于层数的数值。"
	status_effect_damage_increase.status_effect_texture_path = "sprites/status_effects/icon_damage_increase.png"
	status_effect_damage_increase.status_effect_decay_rate = 0
	status_effect_damage_increase.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_damage_increase.status_effect_interceptor_ids = ["interceptor_damage_increase"]

	Global.register_rod(status_effect_damage_increase)

	# decreases damage done by attackers
	# uses an interceptor
	var status_effect_weaken: StatusEffectData = StatusEffectData.new("status_effect_weaken")
	status_effect_weaken.status_effect_name = "输出降级"
	status_effect_weaken.status_effect_description = "造成的攻击伤害降低 25%。"
	status_effect_weaken.status_effect_texture_path = "sprites/status_effects/icon_weaken.png"
	status_effect_weaken.status_effect_decay_rate = -1
	status_effect_weaken.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_weaken.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_weaken.status_effect_interceptor_ids = ["interceptor_weaken"]

	Global.register_rod(status_effect_weaken)

	# increases attack damage on attacked combatant
	# uses an interceptor
	var status_effect_vulnerable: StatusEffectData = StatusEffectData.new("status_effect_vulnerable")
	status_effect_vulnerable.status_effect_name = "漏洞暴露"
	status_effect_vulnerable.status_effect_description = "受到的攻击伤害增加 50%。"
	status_effect_vulnerable.status_effect_texture_path = "sprites/status_effects/icon_vulnerable.png"
	status_effect_vulnerable.status_effect_decay_rate = -1
	status_effect_vulnerable.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_weaken.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_vulnerable.status_effect_interceptor_ids = ["interceptor_vulnerable"]

	Global.register_rod(status_effect_vulnerable)

	# gain block at the end of the turn
	# doesn't use an interceptor
	var status_effect_block_on_turn_end: StatusEffectData = StatusEffectData.new("status_effect_block_on_turn_end")
	status_effect_block_on_turn_end.status_effect_name = "周期防御"
	status_effect_block_on_turn_end.status_effect_description = "时钟周期结束时，获得等同于层数的防火墙。"
	status_effect_block_on_turn_end.status_effect_texture_path = "sprites/status_effects/icon_block_on_turn_end.png"
	status_effect_block_on_turn_end.status_effect_decay_rate = 0
	status_effect_block_on_turn_end.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_block_on_turn_end.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_block_on_turn_end.status_effect_player_process_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"custom_key_names": { "block": "invoking_status_effect_charges" },
				"time_delay": 0.5,
			},
		},
	]
	status_effect_block_on_turn_end.status_effect_enemy_process_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"custom_key_names": { "block": "invoking_status_effect_charges" },
				"time_delay": 0.5,
			},
		},
	]
	status_effect_block_on_turn_end.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_block_on_turn_end)

	# gain energy at the start of next turn
	# doesn't use an interceptor
	var status_effect_energy_next_turn: StatusEffectData = StatusEffectData.new("status_effect_energy_next_turn")
	status_effect_energy_next_turn.status_effect_name = "算力预分配"
	status_effect_energy_next_turn.status_effect_description = "下个时钟周期开始时，额外获得等同于层数的算力。"
	status_effect_energy_next_turn.status_effect_texture_path = "sprites/status_effects/icon_energy_next_turn.png"
	status_effect_energy_next_turn.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.ZERO_OUT
	status_effect_energy_next_turn.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_energy_next_turn.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_energy_next_turn.status_effect_player_process_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"custom_key_names": { "energy_amount": "invoking_status_effect_charges" },
				"time_delay": 0.5,
			},
		},
	]
	status_effect_energy_next_turn.status_effect_enemy_process_actions = []
	status_effect_energy_next_turn.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_energy_next_turn)

	# draws extra cards next turn
	# uses an interceptor
	# this status does not decay naturally. It is removed after turn draw
	var status_effect_increase_turn_draw: StatusEffectData = StatusEffectData.new("status_effect_increase_turn_draw")
	status_effect_increase_turn_draw.status_effect_name = "扩容内存队列"
	status_effect_increase_turn_draw.status_effect_description = "每个时钟周期开始时，额外抽取等同于层数的脚本。"
	status_effect_increase_turn_draw.status_effect_texture_path = "sprites/status_effects/icon_increase_turn_draw.png"
	status_effect_increase_turn_draw.status_effect_decay_rate = 0
	status_effect_increase_turn_draw.status_effect_allows_multiples = false
	status_effect_increase_turn_draw.status_effect_charge_upper_bound = 10
	status_effect_increase_turn_draw.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_increase_turn_draw.status_effect_action_process_times = []
	status_effect_increase_turn_draw.status_effect_interceptor_ids = ["interceptor_increase_turn_draw"]

	Global.register_rod(status_effect_increase_turn_draw)

	# status that binds a card to an enemy, adding it to the player's hand when killed
	var status_effect_attached_card: StatusEffectData = StatusEffectData.new("status_effect_attached_card")
	status_effect_attached_card.status_effect_name = "捆绑进程"
	status_effect_attached_card.status_effect_description = "当前携带着一个或多个后台附着脚本，将在特定条件下被触发。"
	status_effect_attached_card.status_effect_texture_path = "sprites/status_effects/icon_attached_card.png"
	status_effect_attached_card.status_effect_script_path = "res://scripts/status_effects/StatusEffectAttachedCard.gd"
	status_effect_attached_card.status_effect_decay_rate = 0
	status_effect_attached_card.status_effect_allows_multiples = true
	status_effect_attached_card.status_effect_charge_upper_bound = 1
	status_effect_attached_card.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_attached_card.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_attached_card)

	# uses an interceptor to stop an attack from processing
	var status_effect_negate_damage: StatusEffectData = StatusEffectData.new("status_effect_negate_damage")
	status_effect_negate_damage.status_effect_name = "伤害阻断"
	status_effect_negate_damage.status_effect_description = "完全抵消下一次受到的伤害。"
	status_effect_negate_damage.status_effect_texture_path = "sprites/status_effects/icon_negate_damage.png"
	status_effect_negate_damage.status_effect_decay_rate = 0
	status_effect_negate_damage.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_negate_damage.status_effect_interceptor_ids = ["interceptor_negate_damage"]

	Global.register_rod(status_effect_negate_damage)

	# uses an interceptor to cap incoming damage
	var status_effect_cap_damage: StatusEffectData = StatusEffectData.new("status_effect_cap_damage")
	status_effect_cap_damage.status_effect_name = "硬件承伤上限"
	status_effect_cap_damage.status_effect_description = "单次受到的完整度扣除（无视防火墙阻挡）最多不会超过等同于副层数的点数。"
	status_effect_cap_damage.status_effect_texture_path = "sprites/status_effects/icon_cap_damage.png"
	status_effect_cap_damage.status_effect_decay_rate = -1
	status_effect_cap_damage.status_effect_allows_multiples = false
	status_effect_cap_damage.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_cap_damage.status_effect_secondary_charge_collision_strategy = StatusEffectData.STATUS_EFFECT_SECONDARY_CHARGE_COLLISION_STRATEGIES.KEEP
	status_effect_cap_damage.status_effect_interceptor_ids = ["interceptor_cap_damage"]

	Global.register_rod(status_effect_cap_damage)

	# uses an interceptor to prevent block from resetting
	var status_effect_temp_preserve_block: StatusEffectData = StatusEffectData.new("status_effect_temp_preserve_block")
	status_effect_temp_preserve_block.status_effect_name = "缓存防御"
	status_effect_temp_preserve_block.status_effect_description = "本时钟周期结束时，所有防火墙都不会被清除。"
	status_effect_temp_preserve_block.status_effect_texture_path = "sprites/status_effects/icon_temp_preserve_block.png"
	status_effect_temp_preserve_block.status_effect_decay_rate = -1
	status_effect_temp_preserve_block.status_effect_interceptor_ids = ["interceptor_temp_preserve_block"]

	Global.register_rod(status_effect_temp_preserve_block)

	# uses an interceptor to prevent block from resetting
	var status_effect_preserve_block: StatusEffectData = StatusEffectData.new("status_effect_preserve_block")
	status_effect_preserve_block.status_effect_name = "持久化防御"
	status_effect_preserve_block.status_effect_description = "每个时钟周期结束时，所有防火墙都不会被清除。"
	status_effect_preserve_block.status_effect_texture_path = "sprites/status_effects/icon_preserve_block.png"
	status_effect_preserve_block.status_effect_decay_rate = 0
	status_effect_preserve_block.status_effect_charge_upper_bound = 1
	status_effect_preserve_block.status_effect_interceptor_ids = ["interceptor_preserve_block"]

	Global.register_rod(status_effect_preserve_block)

	# uses an interceptor to stop a debuff from happening
	var status_effect_negate_debuff: StatusEffectData = StatusEffectData.new("status_effect_negate_debuff")
	status_effect_negate_debuff.status_effect_name = "异常阻断"
	status_effect_negate_debuff.status_effect_description = "完全抵消下一次受到的减益效果。"
	status_effect_negate_debuff.status_effect_texture_path = "sprites/status_effects/icon_negate_debuff.png"
	status_effect_negate_debuff.status_effect_decay_rate = 0
	status_effect_negate_debuff.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_negate_debuff.status_effect_interceptor_ids = ["interceptor_negate_debuff"]

	Global.register_rod(status_effect_negate_debuff)

	# uses an interceptor to rebound card plays to draw pile
	var status_effect_rebound_card_plays: StatusEffectData = StatusEffectData.new("status_effect_rebound_card_plays")
	status_effect_rebound_card_plays.status_effect_name = "回调执行"
	status_effect_rebound_card_plays.status_effect_description = "下一次打出的脚本将直接返回脚本库顶部。"
	status_effect_rebound_card_plays.status_effect_texture_path = "sprites/status_effects/icon_rebound_card_plays.png"
	status_effect_rebound_card_plays.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.ZERO_OUT
	status_effect_rebound_card_plays.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_rebound_card_plays.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_ENEMY_TURN,
	]
	status_effect_rebound_card_plays.status_effect_interceptor_ids = ["interceptor_rebound_card_plays"]

	Global.register_rod(status_effect_rebound_card_plays)

	# rebounds incoming card plays to the draw pile
	var interceptor_rebound_card_plays: ActionInterceptorData = ActionInterceptorData.new("interceptor_rebound_card_plays")
	interceptor_rebound_card_plays.action_interceptor_priority = 10000
	interceptor_rebound_card_plays.action_interceptor_modifies_parent = true
	interceptor_rebound_card_plays.action_interceptor_script_path = Scripts.INTERCEPTOR_REBOUND_CARD_PLAYS
	interceptor_rebound_card_plays.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]

	Global.register_rod(interceptor_rebound_card_plays)

	# uses an interceptor to duplicate the first card play each turn
	var status_effect_duplicate_card_plays: StatusEffectData = StatusEffectData.new("status_effect_duplicate_card_plays")
	status_effect_duplicate_card_plays.status_effect_name = "多线程执行"
	status_effect_duplicate_card_plays.status_effect_description = "下一次打出的脚本将被立刻额外执行一次。"
	status_effect_duplicate_card_plays.status_effect_texture_path = "sprites/status_effects/icon_duplicate_card_plays.png"
	status_effect_duplicate_card_plays.status_effect_script_path = "res://scripts/status_effects/StatusEffectDuplicateCardPlays.gd"
	status_effect_duplicate_card_plays.status_effect_decay_rate = 0
	status_effect_duplicate_card_plays.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_duplicate_card_plays.status_effect_interceptor_ids = ["interceptor_duplicate_card_plays"]

	Global.register_rod(status_effect_duplicate_card_plays)

	# uses an interceptor to duplicate attack card plays
	var status_effect_duplicate_attacks: StatusEffectData = StatusEffectData.new("status_effect_duplicate_attacks")
	status_effect_duplicate_attacks.status_effect_name = "多线程攻击"
	status_effect_duplicate_attacks.status_effect_description = "下一次打出的攻击脚本将被立刻额外执行一次。"
	status_effect_duplicate_attacks.status_effect_texture_path = "sprites/status_effects/icon_duplicate_attacks.png"
	status_effect_duplicate_attacks.status_effect_decay_rate = -999
	status_effect_duplicate_attacks.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_duplicate_attacks.status_effect_interceptor_ids = ["interceptor_duplicate_attacks"]

	Global.register_rod(status_effect_duplicate_attacks)

	# uses an interceptor to duplicate attack card plays
	var status_effect_block_on_special_discard: StatusEffectData = StatusEffectData.new("status_effect_block_on_special_discard")
	status_effect_block_on_special_discard.status_effect_name = "缓存回收"
	status_effect_block_on_special_discard.status_effect_description = "被其他效果强制丢弃进入回收站时，获得等同于层数的防火墙。"
	status_effect_block_on_special_discard.status_effect_texture_path = "sprites/status_effects/icon_block_on_special_discard.png"
	status_effect_block_on_special_discard.status_effect_decay_rate = 0
	status_effect_block_on_special_discard.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_block_on_special_discard.status_effect_interceptor_ids = ["interceptor_duplicate_attacks"]

	Global.register_rod(status_effect_block_on_special_discard)

#endregion

#region Acts
func add_acts() -> void:
	GlobalProdDataGeneratorActOne.add_act()
	GlobalProdDataGeneratorActTwo.add_act()
	GlobalProdDataGeneratorActThree.add_act()

#endregion

#region Events and Event Pools
func add_events() -> void:
	GlobalProdDataGeneratorActOne.add_events()
	GlobalProdDataGeneratorActTwo.add_events()
	GlobalProdDataGeneratorActThree.add_events()

#endregion

#region Dialogue

## Adds test DialogueData, and their embedded DialogueStateData and DialogueOptionData payloads
func add_dialogue() -> void:
	### Dialogue Event 1
	# Dialogue 1
	var dialogue_pick_something: DialogueData = DialogueData.new("dialogue_pick_something")
	dialogue_pick_something.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=green]异常处理[/color][/wave]"
	Global.register_rod(dialogue_pick_something)

	# Option 1
	var dialogue_pick_something_option_1: DialogueOptionData = DialogueOptionData.new("dialogue_pick_something_option_1")
	dialogue_pick_something_option_1.dialogue_option_bbcode = "[color=red]失去 10 点完整度[/color] 并且 [color=green]获得 100 数据币[/color]"
	dialogue_pick_something_option_1.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足[/color]"
	dialogue_pick_something_option_1.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -10 } },
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": 100 } },
	]
	dialogue_pick_something_option_1.dialogue_option_validators = [
		{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 11 } },
	]
	dialogue_pick_something_option_1.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue

	dialogue_pick_something._assign_option(dialogue_pick_something_option_1)

	# Option 2
	var dialogue_pick_something_option_2: DialogueOptionData = DialogueOptionData.new("dialogue_pick_something_option_2")
	dialogue_pick_something_option_2.dialogue_option_bbcode = "[color=red]失去 50 数据币[/color] 并且 [color=green]随机获得 1 张零日脚本[/color]"
	dialogue_pick_something_option_2.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 数据币不足[/color]"
	dialogue_pick_something_option_2.dialogue_option_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_RARITY: { "card_rarities": [CardData.CARD_RARITIES.RARE] } },
					{ Scripts.VALIDATOR_CARD_DRAFTABLE: { } },
				],
				"rng_name": "rng_events",
				"draft_use_player_draft": false, # this should always be false if using a validator based draft
				"draft_is_weighted": false,
				"draft_use_pity_system": false,
				"random_selection": true, # auto pick it
				"draft_max_card_amount": 1, # auto pick it
				"min_card_amount": 1,
				"max_card_amount": 1,
			},
		},
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": -50 } },
	]
	dialogue_pick_something_option_2.dialogue_option_validators = [
		{ Scripts.VALIDATOR_MONEY: { "money_amount": 50 } },
	]
	dialogue_pick_something_option_2.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue

	dialogue_pick_something._assign_option(dialogue_pick_something_option_2)

	# State 1
	var dialogue_state_pick_something_initial: DialogueStateData = DialogueStateData.new("dialogue_state_pick_something_initial")
	dialogue_state_pick_something_initial.dialogue_state_prompt_bbcode = "测试事件。请选择一个选项..."
	dialogue_state_pick_something_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	dialogue_state_pick_something_initial.dialogue_state_dialogue_option_object_ids = [
		dialogue_pick_something_option_1.object_id,
		dialogue_pick_something_option_2.object_id,
	]

	dialogue_pick_something._assign_state(dialogue_state_pick_something_initial)
	dialogue_pick_something._assign_initial_state(dialogue_state_pick_something_initial)

#endregion

#region Action Interceptors
func add_action_interceptors() -> void:
	# increases damage done by attackers
	var interceptor_damage_increase: ActionInterceptorData = ActionInterceptorData.new("interceptor_damage_increase")
	interceptor_damage_increase.action_interceptor_priority = 10000
	interceptor_damage_increase.action_interceptor_modifies_parent = true
	interceptor_damage_increase.action_interceptor_script_path = Scripts.INTERCEPTOR_DAMAGE_INCREASE
	interceptor_damage_increase.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_damage_increase)

	# decreases damage done by attackers
	var interceptor_weaken: ActionInterceptorData = ActionInterceptorData.new("interceptor_weaken")
	interceptor_weaken.action_interceptor_priority = 9500
	interceptor_weaken.action_interceptor_modifies_parent = true
	interceptor_weaken.action_interceptor_script_path = Scripts.INTERCEPTOR_WEAKEN
	interceptor_weaken.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_weaken)

	# increases damage done to the attacked
	var interceptor_vulnerable: ActionInterceptorData = ActionInterceptorData.new("interceptor_vulnerable")
	interceptor_vulnerable.action_interceptor_priority = 9000
	interceptor_vulnerable.action_interceptor_modifies_parent = false
	interceptor_vulnerable.action_interceptor_script_path = Scripts.INTERCEPTOR_VULNERABLE
	interceptor_vulnerable.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_vulnerable)

	# increases number of cards drawn
	var interceptor_increase_turn_draw: ActionInterceptorData = ActionInterceptorData.new("interceptor_increase_turn_draw")
	interceptor_increase_turn_draw.action_interceptor_priority = 9000
	interceptor_increase_turn_draw.action_interceptor_modifies_parent = true
	interceptor_increase_turn_draw.action_interceptor_script_path = Scripts.INTERCEPTOR_INCREASE_TURN_DRAW
	interceptor_increase_turn_draw.action_intercepted_action_paths = [Scripts.ACTION_DRAW_GENERATOR]

	Global.register_rod(interceptor_increase_turn_draw)

	# provides extra health
	var interceptor_overshield: ActionInterceptorData = ActionInterceptorData.new("interceptor_overshield")
	interceptor_overshield.action_interceptor_priority = 8000
	interceptor_overshield.action_interceptor_modifies_parent = false
	interceptor_overshield.action_interceptor_script_path = Scripts.INTERCEPTOR_OVERSHIELD
	interceptor_overshield.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]

	Global.register_rod(interceptor_overshield)

	# prevents energy from reseting
	var interceptor_preserve_energy: ActionInterceptorData = ActionInterceptorData.new("interceptor_preserve_energy")
	interceptor_preserve_energy.action_interceptor_priority = 10000
	interceptor_preserve_energy.action_interceptor_modifies_parent = true
	interceptor_preserve_energy.action_interceptor_script_path = Scripts.INTERCEPTOR_PRESERVE_ENERGY
	interceptor_preserve_energy.action_intercepted_action_paths = [Scripts.ACTION_RESET_ENERGY]

	Global.register_rod(interceptor_preserve_energy)

	# prevents overshield from decaying
	var interceptor_preserve_overshield: ActionInterceptorData = ActionInterceptorData.new("interceptor_preserve_overshield")
	interceptor_preserve_overshield.action_interceptor_priority = 10000
	interceptor_preserve_overshield.action_interceptor_modifies_parent = false
	interceptor_preserve_overshield.action_interceptor_script_path = Scripts.INTERCEPTOR_PRESERVE_OVERSHIELD
	interceptor_preserve_overshield.action_intercepted_action_paths = [Scripts.ACTION_DECAY_STATUS]

	Global.register_rod(interceptor_preserve_overshield)

	# damages attackers
	var interceptor_pointy: ActionInterceptorData = ActionInterceptorData.new("interceptor_pointy")
	interceptor_pointy.action_interceptor_priority = 0
	interceptor_pointy.action_interceptor_modifies_parent = false
	interceptor_pointy.action_interceptor_script_path = Scripts.INTERCEPTOR_POINTY
	interceptor_pointy.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_pointy)

	# increases attack power from overshield charges
	# typically a forced interceptor
	var interceptor_damage_from_overshield: ActionInterceptorData = ActionInterceptorData.new("interceptor_damage_from_overshield")
	interceptor_damage_from_overshield.action_interceptor_priority = 10000
	interceptor_damage_from_overshield.action_interceptor_modifies_parent = false
	interceptor_damage_from_overshield.action_interceptor_script_path = Scripts.INTERCEPTOR_DAMAGE_FROM_OVERSHIELD
	interceptor_damage_from_overshield.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_damage_from_overshield)

	# increases attack power from block
	# typically a forced interceptor
	var interceptor_damage_from_block: ActionInterceptorData = ActionInterceptorData.new("interceptor_damage_from_block")
	interceptor_damage_from_block.action_interceptor_priority = 10000
	interceptor_damage_from_block.action_interceptor_modifies_parent = false
	interceptor_damage_from_block.action_interceptor_script_path = Scripts.INTERCEPTOR_DAMAGE_FROM_BLOCK
	interceptor_damage_from_block.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_damage_from_block)

	# negates incoming non zero damage actions
	var interceptor_negate_damage: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_damage")
	interceptor_negate_damage.action_interceptor_priority = -10000
	interceptor_negate_damage.action_interceptor_modifies_parent = false
	interceptor_negate_damage.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_DAMAGE
	interceptor_negate_damage.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]

	Global.register_rod(interceptor_negate_damage)

	# caps incoming damage to status effect secondary charges
	var interceptor_cap_damage: ActionInterceptorData = ActionInterceptorData.new("interceptor_cap_damage")
	interceptor_cap_damage.action_interceptor_priority = -9000
	interceptor_cap_damage.action_interceptor_modifies_parent = false
	interceptor_cap_damage.action_interceptor_script_path = Scripts.INTERCEPTOR_CAP_DAMAGE
	interceptor_cap_damage.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]

	Global.register_rod(interceptor_cap_damage)

	# rejects block reset actions
	var interceptor_temp_preserve_block: ActionInterceptorData = ActionInterceptorData.new("interceptor_temp_preserve_block")
	interceptor_temp_preserve_block.action_interceptor_priority = 10000
	interceptor_temp_preserve_block.action_interceptor_modifies_parent = true
	interceptor_temp_preserve_block.action_interceptor_script_path = Scripts.INTERCEPTOR_TEMP_PRESERVE_BLOCK
	interceptor_temp_preserve_block.action_intercepted_action_paths = [Scripts.ACTION_RESET_BLOCK]

	Global.register_rod(interceptor_temp_preserve_block)

	# rejects block reset actions
	var interceptor_preserve_block: ActionInterceptorData = ActionInterceptorData.new("interceptor_preserve_block")
	interceptor_preserve_block.action_interceptor_priority = 10000
	interceptor_preserve_block.action_interceptor_modifies_parent = true
	interceptor_preserve_block.action_interceptor_script_path = Scripts.INTERCEPTOR_PRESERVE_BLOCK
	interceptor_preserve_block.action_intercepted_action_paths = [Scripts.ACTION_RESET_BLOCK]

	Global.register_rod(interceptor_preserve_block)

	# rejects debuffing status actions
	var interceptor_negate_debuff: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_debuff")
	interceptor_negate_debuff.action_interceptor_priority = 10000
	interceptor_negate_debuff.action_interceptor_modifies_parent = false
	interceptor_negate_debuff.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_DEBUFF
	interceptor_negate_debuff.action_intercepted_action_paths = [Scripts.ACTION_APPLY_STATUS]

	Global.register_rod(interceptor_negate_debuff)

	# duplicates incoming card plays
	var interceptor_duplicate_card_plays: ActionInterceptorData = ActionInterceptorData.new("interceptor_duplicate_card_plays")
	interceptor_duplicate_card_plays.action_interceptor_priority = 10000
	interceptor_duplicate_card_plays.action_interceptor_modifies_parent = true
	interceptor_duplicate_card_plays.action_interceptor_script_path = Scripts.INTERCEPTOR_DUPLICATE_CARD_PLAYS
	interceptor_duplicate_card_plays.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]

	Global.register_rod(interceptor_duplicate_card_plays)

	# duplicates incoming attack card plays
	var interceptor_duplicate_attacks: ActionInterceptorData = ActionInterceptorData.new("interceptor_duplicate_attacks")
	interceptor_duplicate_attacks.action_interceptor_priority = 10000
	interceptor_duplicate_attacks.action_interceptor_modifies_parent = true
	interceptor_duplicate_attacks.action_interceptor_script_path = Scripts.INTERCEPTOR_DUPLICATE_ATTACKS
	interceptor_duplicate_attacks.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]

	Global.register_rod(interceptor_duplicate_attacks)

	# uses a consumable to prevent player death
	var interceptor_consumable_auto_revive: ActionInterceptorData = ActionInterceptorData.new("interceptor_consumable_auto_revive")
	interceptor_consumable_auto_revive.action_interceptor_priority = 10000
	interceptor_consumable_auto_revive.action_interceptor_modifies_parent = true
	interceptor_consumable_auto_revive.action_interceptor_script_path = Scripts.INTERCEPTOR_CONSUMABLE_AUTO_REVIVE
	interceptor_consumable_auto_revive.action_intercepted_action_paths = [Scripts.ACTION_DEATH]

	Global.register_rod(interceptor_consumable_auto_revive)

	# prevents gaining money
	var interceptor_negate_add_money: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_add_money")
	interceptor_negate_add_money.action_interceptor_priority = 10000
	interceptor_negate_add_money.action_interceptor_modifies_parent = true
	interceptor_negate_add_money.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_ADD_MONEY
	interceptor_negate_add_money.action_intercepted_action_paths = [Scripts.ACTION_ADD_MONEY]

	Global.register_rod(interceptor_negate_add_money)

#endregion

#region Colors

func add_colors() -> void:
	var color_green: ColorData = ColorData.new("color_green")
	color_green.color = Color.WEB_GREEN
	color_green.color_name = "青绿"
	color_green.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_green)

	var color_orange: ColorData = ColorData.new("color_orange")
	color_orange.color = Color.CORAL
	color_orange.color_name = "亮橙"
	color_orange.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_orange)

	var color_red: ColorData = ColorData.new("color_red")
	color_red.color = Color.FIREBRICK
	color_red.color_name = "猩红"
	color_red.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_red)

	var color_blue: ColorData = ColorData.new("color_blue")
	color_blue.color = Color.ROYAL_BLUE
	color_blue.color_name = "深蓝"
	color_blue.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_blue)

	var color_white: ColorData = ColorData.new("color_white")
	color_white.color = Color.WHITE_SMOKE
	color_white.color_name = "纯白"
	color_white.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_white)

	var color_purple: ColorData = ColorData.new("color_purple")
	color_purple.color = Color.REBECCA_PURPLE
	color_purple.color_name = "暗紫"
	color_purple.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_purple)

#endregion

#region Keywords
func add_keywords() -> void:
	var keyword_block: KeywordData = KeywordData.new("keyword_block")
	keyword_block.keyword_name = "防火墙"
	keyword_block.keyword_text_bb_code = "抵消等量的伤害。"
	Global.register_rod(keyword_block)



	### These are automatically added to cards based on flags
	var keyword_top_deck: KeywordData = KeywordData.new("keyword_top_deck")
	keyword_top_deck.keyword_name = "置顶"
	keyword_top_deck.keyword_prefix = "[前置] "
	keyword_top_deck.keyword_text_bb_code = "战斗开始时置于脚本库顶部"
	Global.register_rod(keyword_top_deck)

	var keyword_bottom_deck: KeywordData = KeywordData.new("keyword_bottom_deck")
	keyword_bottom_deck.keyword_name = "置底"
	keyword_bottom_deck.keyword_prefix = "[前置] "
	keyword_bottom_deck.keyword_text_bb_code = "战斗开始时置于脚本库底部"
	Global.register_rod(keyword_bottom_deck)

	var keyword_retain: KeywordData = KeywordData.new("keyword_retain")
	keyword_retain.keyword_name = "保留"
	keyword_retain.keyword_prefix = "[前置] "
	keyword_retain.keyword_text_bb_code = "时钟周期结束时，该脚本不会被丢弃到回收站。"
	Global.register_rod(keyword_retain)

	var keyword_exhaust: KeywordData = KeywordData.new("keyword_exhaust")
	keyword_exhaust.keyword_name = "物理删除"
	keyword_exhaust.keyword_prefix = "[后置] "
	keyword_exhaust.keyword_text_bb_code = "使用后进入【物理删除区】，本场战斗内无法再次抽取。"
	Global.register_rod(keyword_exhaust)

	var keyword_rebound: KeywordData = KeywordData.new("keyword_rebound")
	keyword_rebound.keyword_name = "回弹"
	keyword_rebound.keyword_prefix = "[后置] "
	keyword_rebound.keyword_text_bb_code = "打出下一个脚本后，将其置于脚本库顶部。对不会进入回收站的脚本无效。"
	Global.register_rod(keyword_rebound)

	var keyword_discard: KeywordData = KeywordData.new("keyword_discard")
	keyword_discard.keyword_name = "丢弃"
	keyword_discard.keyword_prefix = "[后置] "
	keyword_discard.keyword_text_bb_code = "将脚本直接放入回收站。"
	Global.register_rod(keyword_discard)

	var keyword_ethereal: KeywordData = KeywordData.new("keyword_ethereal")
	keyword_ethereal.keyword_name = "虚无"
	keyword_ethereal.keyword_prefix = "[前置] "
	keyword_ethereal.keyword_text_bb_code = "时钟周期结束时，若仍在当前线程中，则会被物理删除。"
	keyword_ethereal.keyword_child_keyword_object_ids = ["keyword_exhaust"]
	Global.register_rod(keyword_ethereal)

	var keyword_banish: KeywordData = KeywordData.new("keyword_banish")
	keyword_banish.keyword_name = "放逐"
	keyword_banish.keyword_prefix = "[后置] "
	keyword_banish.keyword_text_bb_code = "将该脚本从本场战斗中彻底抹除，不再进入任何卡池（包括回收站或物理删除区）。"
	keyword_banish.keyword_child_keyword_object_ids = []
	Global.register_rod(keyword_banish)

	var keyword_unplayable: KeywordData = KeywordData.new("keyword_unplayable")
	keyword_unplayable.keyword_name = "不可打出"
	keyword_unplayable.keyword_prefix = "[前置] "
	keyword_unplayable.keyword_text_bb_code = "该脚本无法被主动打出。"
	Global.register_rod(keyword_unplayable)

#endregion

#region VFX Animations
func add_combat_vfx_animations() -> void:
	var animation_vfx_impact_default: AnimationData = AnimationData.new("animation_vfx_impact_default")
	animation_vfx_impact_default.add_vfx_animations(
		[
			"external/sprites/animated_effects/impact_default/vfx_impact_default_01.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_02.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_03.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_04.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_05.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_06.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_07.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_08.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_09.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_10.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_11.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_12.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_13.png",
			"external/sprites/animated_effects/impact_default/vfx_impact_default_14.png",
		],
		25,
	)
	Global.register_rod(animation_vfx_impact_default)
#endregion

#region Characters

func add_characters() -> void:
	var character_color: String = "" # used to make writing boilerplate colors faster

	# green character
	character_color = "green"
	var character_green: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_green.character_player_id = "player_{0}".format([character_color])
	character_green.character_name = "赛博植物学家"
	character_green.character_description = "一个觉醒了仿生逻辑的流氓进程。它将计算机病毒伪装成植物的生态系统，用‘数据花粉’和‘反伤木马’感染防火墙，通过‘光电合成’窃取系统算力。它不仅是播种者，也是这台冰冷机器的毁灭者。"
	character_green.character_color_id = "color_{0}".format([character_color])
	character_green.character_icon_texture_path = "sprites/characters/character_green/character_green_idle.png"
	character_green.character_background_texture_path = "sprites/characters/character_green/character_green_poster.png"
	character_green.character_starting_health = 75
	character_green.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_green.character_starting_artifact_ids = ["artifact_draw_on_combat_start"]
	character_green.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_green.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_green.character_starting_card_object_ids = [
		"card_basic_attack_green",
		"card_basic_attack_green",
		"card_basic_attack_green",
		"card_basic_attack_green",
		"card_basic_block_green",
		"card_basic_block_green",
		"card_basic_block_green",
		"card_basic_block_green",
		#"card_growth", "card_growth", "card_growth", "card_fertilize",
		#"card_cell_wall", "card_thorns",
		#"card_datum", "card_conclusion",
		#"card_clippers", "card_petals",
		"card_particle_accelerator",
		"card_particle_accelerator",
		#"card_fusion_cannon", "card_fusion_cannon",
		#"card_verdant", "card_verdant",
		#"card_containment", "card_containment",
		"card_critical",
		"card_wildflower",
		"card_wildflower",
		"card_wildflower",
		"card_wildflower",
		#"card_energy_next_turn", "card_energy_next_turn",
		"card_meltdown",
		"card_meltdown",
		"card_photoelectric_synthesis",
		"card_photoelectric_synthesis",
		#"card_feedback_loop",
		#"card_pollen",
		#"card_symbiosis",
		#"card_bud", "card_bud", "card_bud", 
		#"card_moss", "card_moss",
	]

	# green character animations
	var animation_character_green: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_green.character_animation_id = animation_character_green.object_id
	animation_character_green.add_combatant_animations(
		["sprites/characters/character_green/character_green_idle.png"],
		[
			"sprites/characters/character_green/attack/character_green_attack_1.png",
			"sprites/characters/character_green/attack/character_green_attack_2.png",
			"sprites/characters/character_green/attack/character_green_attack_3.png",
			"sprites/characters/character_green/attack/character_green_attack_4.png",
		],
		[
			"sprites/characters/character_green/death/character_green_death_1.png",
			"sprites/characters/character_green/death/character_green_death_2.png",
			"sprites/characters/character_green/death/character_green_death_3.png",
			"sprites/characters/character_green/death/character_green_death_4.png",
		],
	)

	Global.register_rod(animation_character_green)
	Global.register_rod(character_green)

	# red character - 码农 / 程序员
	character_color = "red"
	var character_red: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_red.character_player_id = "player_{0}".format([character_color])
	character_red.character_name = "码农"
	character_red.character_description = "一个平凡的程序员，在数字世界中用代码对抗混乱。他擅长简洁的逻辑复用，能将有限的资源转化为可观战力。"
	character_red.character_color_id = "color_{0}".format([character_color])
	character_red.character_icon_texture_path = "external/sprites/characters/character_{0}/character_{0}_icon.png".format([character_color])
	character_red.character_background_texture_path = "external/sprites/characters/character_{0}/character_{0}_poster.png".format([character_color])
	character_red.character_starting_health = 80
	character_red.character_starting_artifact_ids = ["artifact_block_on_attacks"]
	character_red.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_red.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_red.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_red.character_starting_card_object_ids = [
		"card_basic_attack_red",
		"card_basic_attack_red",
		"card_basic_attack_red",
		"card_basic_attack_red",
		"card_basic_block_red",
		"card_basic_block_red",
		"card_basic_block_red",
		"card_basic_block_red",
		"card_energy_next_turn",
	]

	# 暂时没有动画资源图片，全部使用默认单帧
	var animation_character_red: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_red.character_animation_id = animation_character_red.object_id
	animation_character_red.add_combatant_animations(
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
	)

	Global.register_rod(animation_character_red)
	Global.register_rod(character_red)

	# blue character - 渗透专家 / 白帽黑客
	character_color = "blue"
	var character_blue: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_blue.character_player_id = "player_{0}".format([character_color])
	character_blue.character_name = "渗透专家"
	character_blue.character_description = "一名游走于暗网与内核之间的白帽黑客。他不是在破坏，而是在渗透——窃取情报、混淆视听、将敌人的算力玩弄于股掌之间。在他的字典里，'防御'永远是过时的概念。"
	character_blue.character_color_id = "color_{0}".format([character_color])
	character_blue.character_icon_texture_path = "external/sprites/characters/character_{0}/character_{0}_icon.png".format([character_color])
	character_blue.character_background_texture_path = "external/sprites/characters/character_{0}/character_{0}_poster.png".format([character_color])
	character_blue.character_starting_health = 75
	character_blue.character_starting_artifact_ids = ["artifact_see_top_of_draw_pile"]
	character_blue.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_blue.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_blue.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_blue.character_starting_card_object_ids = [
		"card_basic_attack_blue",
		"card_basic_attack_blue",
		"card_basic_attack_blue",
		"card_basic_attack_blue",
		"card_basic_block_blue",
		"card_basic_block_blue",
		"card_basic_block_blue",
		"card_basic_block_blue",
	]

	# 暂时没有动画资源图片，全部使用默认单帧
	var animation_character_blue: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_blue.character_animation_id = animation_character_blue.object_id
	animation_character_blue.add_combatant_animations(
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
	)

	Global.register_rod(animation_character_blue)
	Global.register_rod(character_blue)

#endregion

#region Run Modifiers

func add_run_modifiers() -> void:
	### Standard Difficulty Run Modifiers
	var run_modifier_difficulty_0: RunModifierData = RunModifierData.new("run_modifier_difficulty_0")
	run_modifier_difficulty_0.run_modifier_name = "基础难度：正常执行"
	run_modifier_difficulty_0.run_modifier_modifier_script_path = ""

	Global.register_rod(run_modifier_difficulty_0)

	var run_modifier_difficulty_1: RunModifierData = RunModifierData.new("run_modifier_difficulty_1")
	run_modifier_difficulty_1.run_modifier_name = "难度 1：强化敌方进程"
	run_modifier_difficulty_1.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_1

	Global.register_rod(run_modifier_difficulty_1)

	var run_modifier_difficulty_2: RunModifierData = RunModifierData.new("run_modifier_difficulty_2")
	run_modifier_difficulty_2.run_modifier_name = "难度 2：强化精英怪"
	run_modifier_difficulty_2.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_2

	Global.register_rod(run_modifier_difficulty_2)

	var run_modifier_difficulty_3: RunModifierData = RunModifierData.new("run_modifier_difficulty_3")
	run_modifier_difficulty_3.run_modifier_name = "难度 3：强化Boss"
	run_modifier_difficulty_3.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_3

	Global.register_rod(run_modifier_difficulty_3)

	var run_modifier_difficulty_4: RunModifierData = RunModifierData.new("run_modifier_difficulty_4")
	run_modifier_difficulty_4.run_modifier_name = "难度 4：内存压缩"
	run_modifier_difficulty_4.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_4

	Global.register_rod(run_modifier_difficulty_4)

	var run_modifier_difficulty_5: RunModifierData = RunModifierData.new("run_modifier_difficulty_5")
	run_modifier_difficulty_5.run_modifier_name = "难度 5：内核级危机"
	run_modifier_difficulty_5.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_5

	Global.register_rod(run_modifier_difficulty_5)

	# register the modifiers as standard difficulty
	Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS.append_array(
		[
			run_modifier_difficulty_0.object_id,
			run_modifier_difficulty_1.object_id,
			run_modifier_difficulty_2.object_id,
			run_modifier_difficulty_3.object_id,
			run_modifier_difficulty_4.object_id,
			run_modifier_difficulty_5.object_id,
		],
	)

	### Custom Run Modifiers
	var run_modifier_custom_easy_mode: RunModifierData = RunModifierData.new("run_modifier_custom_easy_mode")
	run_modifier_custom_easy_mode.run_modifier_name = "安全模式"
	run_modifier_custom_easy_mode.run_modifier_description = "[作弊] 将最大能量上限修改为99。并在首个时钟周期，强制将遭遇的所有敌方进程的最大完整度锁定为1。"
	run_modifier_custom_easy_mode.run_modifier_is_custom = true
	run_modifier_custom_easy_mode.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_custom_easy_mode.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_EASYMODE

	Global.register_rod(run_modifier_custom_easy_mode)

	var run_modifier_endless_mode: RunModifierData = RunModifierData.new("run_modifier_endless_mode")
	run_modifier_endless_mode.run_modifier_name = "死循环模式"
	run_modifier_endless_mode.run_modifier_description = "突破系统防线，通关第3节点后游戏不会结束，您将带着现有配置继续深入，直至核心被摧毁。"
	run_modifier_endless_mode.run_modifier_is_custom = true
	run_modifier_endless_mode.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_endless_mode.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_ENDLESS_MODE

	Global.register_rod(run_modifier_endless_mode)

	var run_modifier_draft_all_colors: RunModifierData = RunModifierData.new("run_modifier_draft_all_colors")
	run_modifier_draft_all_colors.run_modifier_name = "跨域授权"
	run_modifier_draft_all_colors.run_modifier_description = "解除隔离协议。在挑选脚本奖励时，系统将无视您的当前角色权限，提供来自所有角色的脚本。"
	run_modifier_draft_all_colors.run_modifier_is_custom = true
	run_modifier_draft_all_colors.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_draft_all_colors.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_DRAFT_ALL_COLORS

	Global.register_rod(run_modifier_draft_all_colors)

	### Automatic Modifiers

	# this allows for auto revive consumables to work each run
	var run_modifier_consumable_auto_revive: RunModifierData = RunModifierData.new("run_modifier_consumable_auto_revive")
	run_modifier_consumable_auto_revive.run_modifier_name = "自动重启"
	run_modifier_consumable_auto_revive.run_modifier_description = "包含自动重启外设"
	run_modifier_consumable_auto_revive.run_modifier_is_automatic = true # registered regardless of difficulty
	run_modifier_consumable_auto_revive.run_modifier_modifier_script_path = Scripts.BASE_RUN_MODIFIER # does nothing
	run_modifier_consumable_auto_revive.run_modifier_interceptor_ids = ["interceptor_consumable_auto_revive"] # ensures auto revive always active

	Global.register_rod(run_modifier_consumable_auto_revive)

#endregion

#region Run Start Options

func add_run_start_options() -> void:
	### Downsides
	# remove max hp
	var run_start_option_reduce_max_hp: RunStartOptionData = RunStartOptionData.new("run_start_option_reduce_max_hp")
	run_start_option_reduce_max_hp.run_start_option_bb_code = "[color=red]失去10点最大完整度[/color]"
	run_start_option_reduce_max_hp.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_reduce_max_hp.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_max_amount": -10 } }]

	Global.register_rod(run_start_option_reduce_max_hp)

	# take damage
	var run_start_option_take_damage: RunStartOptionData = RunStartOptionData.new("run_start_option_take_damage")
	run_start_option_take_damage.run_start_option_bb_code = "[color=red]失去5点完整度[/color]"
	run_start_option_take_damage.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_take_damage.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_amount": -5 } }]

	Global.register_rod(run_start_option_take_damage)

	# lose all money
	var run_start_option_lose_money: RunStartOptionData = RunStartOptionData.new("run_start_option_lose_money")
	run_start_option_lose_money.run_start_option_bb_code = "[color=red]失去所有数据币[/color]"
	run_start_option_lose_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_lose_money.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": -1000 } }]

	Global.register_rod(run_start_option_lose_money)

	### Upsides
	# add money
	var run_start_option_add_money: RunStartOptionData = RunStartOptionData.new("run_start_option_add_money")
	run_start_option_add_money.run_start_option_bb_code = "[color=green]获得50数据币[/color]"
	run_start_option_add_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_add_money.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 50 } }]

	Global.register_rod(run_start_option_add_money)

	# gain max hp
	var run_start_option_gain_max_hp: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_max_hp")
	run_start_option_gain_max_hp.run_start_option_bb_code = "[color=green]获得10点最大完整度[/color]"
	run_start_option_gain_max_hp.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_max_hp.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 10, "health_max_amount": 10 } }]

	Global.register_rod(run_start_option_gain_max_hp)

	# draft a card from player's pool
	# functions identically to a standard draft
	var run_start_option_draft_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_card")
	run_start_option_draft_card.run_start_option_bb_code = "[color=green]选择一张脚本[/color]"
	run_start_option_draft_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_card.run_start_option_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
				# use same rng as player drafting so it counts as draft
				"rng_name": "rng_card_drafting",
				"validator_data": [], # this should always be empty if draft_use_player_draft = true
				# weighted draft from player draft pool with pity system
				"draft_use_player_draft": true,
				"draft_is_weighted": false,
				"draft_use_pity_system": false,
			},
		},
	]

	Global.register_rod(run_start_option_draft_card)

	# draft common card available to the player
	# this uses validators to scan the entire card pool for a draft
	# you could also use a card pack to achieve a similar effect
	var run_start_option_draft_common_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_common_card")
	run_start_option_draft_common_card.run_start_option_bb_code = "[color=green]选择一张普通脚本[/color]"
	run_start_option_draft_common_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_common_card.run_start_option_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_RARITY: { "card_rarities": [CardData.CARD_RARITIES.COMMON] } },
					{ Scripts.VALIDATOR_CARD_DRAFTABLE: { } },
				],
				# use same rng as player drafting so it counts as draft
				"rng_name": "rng_card_drafting",
				"draft_use_player_draft": false, # this should always be false if using a validator based draft
				"draft_is_weighted": false,
				"draft_use_pity_system": false,
			},
		},
	]

	Global.register_rod(run_start_option_draft_common_card)

	# gain a random common artifact
	var run_start_option_gain_common_artifact: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_common_artifact")
	run_start_option_gain_common_artifact.run_start_option_bb_code = "[color=green]获得一个随机普通外设插件[/color]"
	run_start_option_gain_common_artifact.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_common_artifact.run_start_option_actions = [
		{
			Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"artifact_count": 1,
				"artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON],
			},
		},
	]

	Global.register_rod(run_start_option_gain_common_artifact)

	# draft a colorless card from the white card pack
	var run_start_option_draft_colorless_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_colorless_card")
	run_start_option_draft_colorless_card.run_start_option_bb_code = "[color=green]选择一张无色脚本[/color]"
	run_start_option_draft_colorless_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_colorless_card.run_start_option_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
				"validator_data": [],
				# use same rng as player drafting so it counts as draft
				"rng_name": "rng_card_drafting",
				# get white cards
				"draft_card_pack_id": "card_pack_white",
			},
		},
	]

	Global.register_rod(run_start_option_draft_colorless_card)

	### Complete

	# replace starting artifact with a random boss one
	var run_start_option_artifact_swap: RunStartOptionData = RunStartOptionData.new("run_start_option_artifact_swap")
	run_start_option_artifact_swap.run_start_option_bb_code = "[color=green]将初始外设插件替换为随机Boss外设插件[/color]"
	run_start_option_artifact_swap.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_artifact_swap.run_start_option_actions = [{ Scripts.ACTION_SWAP_BOSS_ARTIFACT: { } }]

	Global.register_rod(run_start_option_artifact_swap)

#endregion

#region Custom UI

func add_custom_ui() -> void:
	var custom_ui_see_top_of_draw_pile: CustomUIData = CustomUIData.new("custom_ui_see_top_of_draw_pile")
	custom_ui_see_top_of_draw_pile.custom_ui_asset_path = "res://scenes/ui/custom/CustomUISeeTopOfDrawPile.tscn"
	# custom_ui_see_top_of_draw_pile.custom_ui_requires_target = true
	Global.register_rod(custom_ui_see_top_of_draw_pile)

#endregion

#region Custom UI

func add_custom_signals() -> void:
	var custom_signal_special_discard: CustomSignalData = CustomSignalData.new("custom_signal_special_discard")
	custom_signal_special_discard.custom_signal_is_stat = true
	custom_signal_special_discard.custom_signal_stat_name = "CUSTOM_STAT_SPECIAL_DISCARD"
	Global.register_rod(custom_signal_special_discard)

	var custom_signal_overheated: CustomSignalData = CustomSignalData.new("custom_signal_overheated")
	custom_signal_overheated.custom_signal_is_stat = true
	custom_signal_overheated.custom_signal_stat_name = "CUSTOM_STAT_OVERHEATED"
	Global.register_rod(custom_signal_overheated)

#endregion

#region Enemies
func add_enemies() -> void:
	GlobalProdDataGeneratorGlobalEnemies.add_enemies()
	GlobalProdDataGeneratorActOne.add_enemies()
	GlobalProdDataGeneratorActTwo.add_enemies()
	GlobalProdDataGeneratorActThree.add_enemies()

#endregion

#region Player Data Prototypes

func add_player_data() -> void:
	var player_red: PlayerData = PlayerData.new("player_red")
	player_red.player_character_object_id = "character_red"

	Global.register_rod(player_red)

	var player_blue: PlayerData = PlayerData.new("player_blue")
	player_blue.player_character_object_id = "character_blue"

	Global.register_rod(player_blue)

	var player_green: PlayerData = PlayerData.new("player_green")
	player_green.player_character_object_id = "character_green"

	Global.register_rod(player_green)

	var player_orange: PlayerData = PlayerData.new("player_orange")
	player_orange.player_character_object_id = "character_orange"

	Global.register_rod(player_orange)

#endregion

#region Card Decorators
func add_card_decorators() -> void:
	# decorator that changes card cost based on combat stats
	var card_decorator_dynamic_cost_modifier: CardDecoratorData = CardDecoratorData.new("card_decorator_dynamic_cost_modifier")
	card_decorator_dynamic_cost_modifier.card_decorator_script_path = Scripts.DECORATOR_DYNAMIC_COST_MODIFIER

	Global.register_rod(card_decorator_dynamic_cost_modifier)

	# decorator that modifies card_values based on combat stats
	var card_decorator_dynamic_value_modifier: CardDecoratorData = CardDecoratorData.new("card_decorator_dynamic_value_modifier")
	card_decorator_dynamic_value_modifier.card_decorator_script_path = Scripts.DECORATOR_DYNAMIC_VALUE_MODIFIER

	Global.register_rod(card_decorator_dynamic_value_modifier)

	# decorator that applies block on card play
	# applies a custom decorator value to the card and displays the number on the decorator
	var card_decorator_block_on_play: CardDecoratorData = CardDecoratorData.new("card_decorator_block_on_play")
	card_decorator_block_on_play.card_decorator_name = "防御固化"
	card_decorator_block_on_play.card_decorator_description = "打出时，额外提供 [decorator_value_block] 点防火墙。"
	card_decorator_block_on_play.card_decorator_texture_path = "sprites/card-borders/purple_decorator.png"
	card_decorator_block_on_play.card_decorator_value_improvements = {
		"decorator_value_block": 5,
	}
	# Pre/post description replaced by card_decorator_description tooltip (see CardDecorator.gd)
	#card_decorator_block_on_play.card_decorator_pre_description = "[center][color=purple]Block [decorator_value_block][/color][/center]\n"
	card_decorator_block_on_play.card_decorator_label_value_name = "decorator_value_block"
	card_decorator_block_on_play.card_decorator_add_keyword_ids = ["keyword_block"]
	card_decorator_block_on_play.card_decorator_pre_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				# convert the decorator's block into actual block
				"custom_key_names": { "block": "decorator_value_block" },
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	Global.register_rod(card_decorator_block_on_play)

	# decorator that removes exhaust from a card
	# should be combined with a validator to prevent it from being applied to a non exhausting card
	var card_decorator_remove_exhaust: CardDecoratorData = CardDecoratorData.new("card_decorator_remove_exhaust")
	card_decorator_remove_exhaust.card_decorator_name = "持久运行"
	card_decorator_remove_exhaust.card_decorator_description = "失去物理删除属性，使用后进入回收站。"
	card_decorator_remove_exhaust.card_decorator_texture_path = "sprites/card-borders/yellow_decorator.png"
	card_decorator_remove_exhaust.card_decorator_card_pack_id = "card_pack_exhaust_cards"
	card_decorator_remove_exhaust.card_decorator_property_changes = {
		"card_play_destination": HandManager.DISCARD_PILE,
	}
	Global.register_rod(card_decorator_remove_exhaust)

	# decorator that draws extra cards when the card is drawn the first time
	# applies a custom decorator value to the card and displays the number on the decorator
	var card_decorator_extra_draw: CardDecoratorData = CardDecoratorData.new("card_decorator_extra_draw")
	card_decorator_extra_draw.card_decorator_name = "初始加载"
	card_decorator_extra_draw.card_decorator_description = "本局游戏中首次抽到此牌时，额外抽取 2 个脚本。"
	card_decorator_extra_draw.card_decorator_texture_path = "sprites/card-borders/green_decorator.png"
	card_decorator_extra_draw.card_decorator_value_changes = {
		# add a flag to the card used to check for first time
		"decorator_value_extra_draw": 2,
	}
	# Pre/post description replaced by card_decorator_description tooltip (see CardDecorator.gd)
	#card_decorator_extra_draw.card_decorator_post_description = "[center][color=green]首次抽到时，抽取 2 个脚本。[/color][/center]\n"
	card_decorator_extra_draw.card_decorator_label_value_name = "decorator_value_extra_draw"
	card_decorator_extra_draw.card_decorator_post_draw_actions = [
		{
			# check flag when drawn
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{
						Scripts.VALIDATOR_CARD_VALUES: {
							"card_value_name": "decorator_value_extra_draw",
							"operator": ">",
							"comparison_value": 0,
							"invert_validation": false,
						},
					},
				],
				# draw cards and change flag
				"passed_action_data": [
					{
						Scripts.ACTION_CHANGE_CARD_VALUES: {
							"pick_played_card": true,
							"modify_parent_card": false,
							"new_card_values": { "decorator_value_extra_draw": 0 },
						},
					},
					{
						Scripts.ACTION_DRAW_GENERATOR: {
							# alias the extra draw count
							"custom_key_names": { "draw_count": "decorator_value_extra_draw" },
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_decorator_extra_draw)
#endregion

#region Cards

func add_cards() -> void:
	add_card_basics()
	add_cards_misc()
	add_cards_red()
	add_cards_blue()
	add_cards_green()
	add_cards_orange()


func add_card_basics() -> void:
	var colors: Array[String] = []

	for character_data: CharacterData in Global._id_to_character_data.values():
		colors.append(character_data.character_color_id.replace("color_", ""))

	for i: int in len(colors):
		# Basic attack card
		var card_basic_attack: CardData = CardData.new("card_basic_attack_{0}".format([colors[i]]))
		card_basic_attack.card_name = "基础攻击"
		card_basic_attack.card_color_id = "color_{0}".format([colors[i]])
		card_basic_attack.card_description = "造成 [damage] 点伤害。"
		card_basic_attack.card_texture_path = "sprites/card/green/card_basic_attack_green.png" if colors[i] == "green" else "external/sprites/cards/{0}/card_basic_attack_{0}.png".format([colors[i]])
		card_basic_attack.card_hint = "这是最基础的攻击指令。虽然伤害不高，但在游戏前期是主要输出手段。"
		card_basic_attack.card_type = CardData.CARD_TYPES.ATTACK
		card_basic_attack.card_rarity = CardData.CARD_RARITIES.BASIC
		card_basic_attack.card_keyword_object_ids = []
		card_basic_attack.card_values = { "damage": 7, "number_of_attacks": 1 }
		card_basic_attack.card_upgrade_value_improvements = { "damage": 3, "number_of_attacks": 1 }
		card_basic_attack.card_play_actions = [
			{
				Scripts.ACTION_ATTACK_GENERATOR: { "time_delay": 0.0, "actions_on_lethal": [] },
				Scripts.ACTION_PLAY_SOUND: { "audio_path": "external/audio/sounds/slash.wav" },
			},
		]

		Global.register_rod(card_basic_attack)

		# Basic block card
		var card_basic_block: CardData = CardData.new("card_basic_block_{0}".format([colors[i]]))
		card_basic_block.card_name = "基础防火墙"
		card_basic_block.card_color_id = "color_{0}".format([colors[i]])
		card_basic_block.card_description = "获得 [block] 点防火墙"
		card_basic_block.card_texture_path = "sprites/card/green/card_basic_block_green.png" if colors[i] == "green" else "external/sprites/cards/{0}/card_basic_block_{0}.png".format([colors[i]])
		card_basic_block.card_hint = "这是最基础的防御指令。保持健康状态是走得更远的关键，不要忽略防御。"
		card_basic_block.card_type = CardData.CARD_TYPES.SKILL
		card_basic_block.card_rarity = CardData.CARD_RARITIES.BASIC
		card_basic_block.card_requires_target = false
		card_basic_block.card_keyword_object_ids = ["keyword_block"]
		card_basic_block.card_values = { "block": 5 }
		card_basic_block.card_upgrade_value_improvements = { "block": 3 }
		card_basic_block.card_play_actions = [
			{
				Scripts.ACTION_BLOCK: {
					"time_delay": 0.2,
					"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				},
			},
		]

		Global.register_rod(card_basic_block)


## Adds cards that have not yet been sorted into a color
func add_cards_misc() -> void:
	GlobalProdDataGeneratorWhiteCards.add_cards_white()


func add_cards_green() -> void:
	GlobalProdDataGeneratorGreenCards.add_cards_green()


func add_cards_orange() -> void:
	var color: String = "orange"


func add_cards_red() -> void:
	GlobalProdDataGeneratorRedCards.add_cards_red()


func add_cards_blue() -> void:
	GlobalProdDataGeneratorBlueCards.add_cards_blue()

#region Card Packs

func add_card_packs() -> void:
	# all cards in game, with no filtering
	var card_pack_all: CardPackData = CardPackData.new("card_pack_all")
	card_pack_all.exclude_non_standard_rarities = false
	card_pack_all.exclude_non_standard_types = false
	card_pack_all.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_all)

	# all draftable cards, ignoring non-standard types and rarities
	var card_pack_prismatic: CardPackData = CardPackData.new("card_pack_prismatic")
	Global.register_rod(card_pack_prismatic)

	var card_pack_red: CardPackData = CardPackData.new("card_pack_red")
	card_pack_red.card_pack_color_id = "color_red"
	card_pack_red.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_red)

	var card_pack_blue: CardPackData = CardPackData.new("card_pack_blue")
	card_pack_blue.card_pack_color_id = "color_blue"
	card_pack_blue.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_blue)

	var card_pack_green: CardPackData = CardPackData.new("card_pack_green")
	card_pack_green.card_pack_color_id = "color_green"
	card_pack_green.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_green)

	# 物理删除卡牌池，供"持久运行"附魔等使用
	var card_pack_exhaust_cards: CardPackData = CardPackData.new("card_pack_exhaust_cards")
	card_pack_exhaust_cards.card_pack_displays_in_codex = false
	card_pack_exhaust_cards.card_pack_validators = [
		{
			Scripts.VALIDATOR_CARD_PROPERTIES: {
				"card_property_name": "card_play_destination",
				"operator": "==",
				"comparison_value": HandManager.EXHAUST_PILE,
			},
		},
	]
	Global.register_rod(card_pack_exhaust_cards)

	var card_pack_orange: CardPackData = CardPackData.new("card_pack_orange")
	card_pack_orange.card_pack_color_id = "color_orange"
	card_pack_orange.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_orange)

	var card_pack_white: CardPackData = CardPackData.new("card_pack_white")
	card_pack_white.card_pack_color_id = "color_white"
	card_pack_white.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_white)

#endregion
#region Artifact Packs

func add_artifact_packs() -> void:
	# all artifacts in game, with no filtering
	var artifact_pack_all: ArtifactPackData = ArtifactPackData.new("artifact_pack_all")
	artifact_pack_all.exclude_non_standard_rarities = false
	Global.register_rod(artifact_pack_all)

	# common pool artifacts, ignoring non-standard types and rarities
	# all characters should have this and their color by default
	var artifact_pack_white: ArtifactPackData = ArtifactPackData.new("artifact_pack_white")
	artifact_pack_white.artifact_pack_color_id = "color_white"
	Global.register_rod(artifact_pack_white)

	var artifact_pack_red: ArtifactPackData = ArtifactPackData.new("artifact_pack_red")
	artifact_pack_red.artifact_pack_color_id = "color_red"
	Global.register_rod(artifact_pack_red)

	var artifact_pack_blue: ArtifactPackData = ArtifactPackData.new("artifact_pack_blue")
	artifact_pack_blue.artifact_pack_color_id = "color_blue"
	Global.register_rod(artifact_pack_blue)

	var artifact_pack_green: ArtifactPackData = ArtifactPackData.new("artifact_pack_green")
	artifact_pack_green.artifact_pack_color_id = "color_green"
	Global.register_rod(artifact_pack_green)

	var artifact_pack_orange: ArtifactPackData = ArtifactPackData.new("artifact_pack_orange")
	artifact_pack_orange.artifact_pack_color_id = "color_orange"
	Global.register_rod(artifact_pack_orange)

#endregion

#region Consumable Packs
func add_consumable_packs() -> void:
	# all consumables in game, with no filtering
	var consumable_pack_all: ConsumablePackData = ConsumablePackData.new("consumable_pack_all")
	Global.register_rod(consumable_pack_all)

	# common pool consumables, ignoring non-standard types and rarities
	# all characters should have this and their color by default
	var consumable_pack_white: ConsumablePackData = ConsumablePackData.new("consumable_pack_white")
	consumable_pack_white.consumable_pack_color_id = "color_white"
	Global.register_rod(consumable_pack_white)

	var consumable_pack_red: ConsumablePackData = ConsumablePackData.new("consumable_pack_red")
	consumable_pack_red.consumable_pack_color_id = "color_red"
	Global.register_rod(consumable_pack_red)

	var consumable_pack_blue: ConsumablePackData = ConsumablePackData.new("consumable_pack_blue")
	consumable_pack_blue.consumable_pack_color_id = "color_blue"
	Global.register_rod(consumable_pack_blue)

	var consumable_pack_green: ConsumablePackData = ConsumablePackData.new("consumable_pack_green")
	consumable_pack_green.consumable_pack_color_id = "color_green"
	Global.register_rod(consumable_pack_green)

	var consumable_pack_orange: ConsumablePackData = ConsumablePackData.new("consumable_pack_orange")
	consumable_pack_orange.consumable_pack_color_id = "color_orange"
	Global.register_rod(consumable_pack_orange)

#endregion
