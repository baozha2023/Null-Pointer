## Singleton for data generation used to test the framework as well as any internal development testing.
## This is used to make content programmatically instead of messing with more fragile external JSON files.
extends Node

## Wrapper method used to generate all data used in testing.
## After running this you can use Fileloader.export_read_only_data() to output to json files.
func generate_test_data() -> void:
	add_test_rest_actions()
	add_test_consumables()
	
	add_test_status_effects() # must be defined before enemies
	add_test_action_interceptors()
	
	add_test_enemies()
	add_test_events()
	add_test_dialogue()
	add_test_acts()
	
	add_test_colors()
	add_test_keywords()
	
	add_test_combat_vfx_animations()
	
	add_test_characters()
	add_test_player_data()
	
	add_test_run_modifiers()
	add_test_run_start_options()
	
	add_test_custom_ui()
	add_test_custom_signals()
	
	add_test_artifacts()
	add_test_card_decorators()
	add_test_cards()
	
	add_test_card_packs()
	add_test_artifact_packs()
	add_test_consumable_packs()


#region Artifacts
func add_test_artifacts_to_player() -> void:
	Global.player_data.add_artifact("artifact_draw_on_kill")
	Global.player_data.add_artifact("artifact_draw_on_combat_start")
	Global.player_data.add_artifact("artifact_block_on_attacks")
	Global.player_data.add_artifact("artifact_retain_hand")
	Global.player_data.add_artifact("artifact_increase_attack_on_rest")
	Global.player_data.add_artifact("artifact_negate_money_gain")
	Global.player_data.add_artifact("artifact_add_money")
	Global.player_data.add_artifact("artifact_top_deck_attack_card")
	Global.player_data.add_artifact("artifact_right_click_shuffle_deck")
	

func add_test_artifacts() -> void:
	var artifact_add_money: ArtifactData = ArtifactData.new("artifact_add_money")
	artifact_add_money.artifact_name = "外设插件：获得数据币"
	artifact_add_money.artifact_texture_path = "sprites/artifacts/artifact_add_money.png"
	artifact_add_money.artifact_description = "获得时增加 200 数据币"
	artifact_add_money.artifact_add_actions = [{Scripts.ACTION_ADD_MONEY: {"money_amount": 200}}]
	
	Global.register_rod(artifact_add_money)
	
	var artifact_negate_money_gain: ArtifactData = ArtifactData.new("artifact_negate_money_gain")
	artifact_negate_money_gain.artifact_name = "外设插件：数据币禁止"
	artifact_negate_money_gain.artifact_texture_path = "sprites/artifacts/artifact_negate_money_gain.png"
	artifact_negate_money_gain.artifact_description = "每时钟周期获得 {0}。无法再获得数据币".format([Card.ENERGY_ICON_KEYWORD])
	artifact_negate_money_gain.artifact_add_actions = [{Scripts.ACTION_ADD_ENERGY:{
		"target_overrides": BaseAction.TARGET_OVERRIDES.PLAYER,
		"energy_amount_max": 1,
	}}]
	artifact_negate_money_gain.artifact_remove_actions = [{Scripts.ACTION_ADD_ENERGY:{
		"target_overrides": BaseAction.TARGET_OVERRIDES.PLAYER,
		"energy_amount_max": -1,
	}}]
	artifact_negate_money_gain.artifact_interceptor_ids = ["interceptor_negate_add_money"]
	
	Global.register_rod(artifact_negate_money_gain)
	
	var artifact_heal_on_combat_ended: ArtifactData = ArtifactData.new("artifact_heal_on_combat_ended")
	artifact_heal_on_combat_ended.artifact_name = "外设插件：战后回复"
	artifact_heal_on_combat_ended.artifact_texture_path = "sprites/artifacts/artifact_heal_on_combat_ended.png"
	artifact_heal_on_combat_ended.artifact_description = "战斗结束时回复5点完整度"
	artifact_heal_on_combat_ended.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_heal_on_combat_ended.artifact_end_of_combat_actions = [{
			Scripts.ACTION_ADD_HEALTH: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"health_amount": 5
				}
			}]
	
	Global.register_rod(artifact_heal_on_combat_ended)
	
	var artifact_full_heal: ArtifactData = ArtifactData.new("artifact_full_heal")
	artifact_full_heal.artifact_name = "外设插件：完全回复"
	artifact_full_heal.artifact_texture_path = "sprites/artifacts/artifact_full_heal.png"
	artifact_full_heal.artifact_description = "获得时完全回复玩家完整度"
	artifact_full_heal.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_full_heal.artifact_add_actions = [{
			Scripts.ACTION_HEAL_PERCENT: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"percentage_heal_amount": 1.0
				}
			}]
	
	Global.register_rod(artifact_full_heal)
	
	var artifact_draw_on_kill: ArtifactData = ArtifactData.new("artifact_draw_on_kill")
	artifact_draw_on_kill.artifact_name = "外设插件：击杀加载脚本"
	artifact_draw_on_kill.artifact_texture_path = "sprites/artifacts/artifact_draw_on_kill.png"
	artifact_draw_on_kill.artifact_description = "击杀敌人时加载一个脚本"
	artifact_draw_on_kill.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_draw_on_kill.artifact_script_path = "res://scripts/artifacts/ArtifactDrawOnKill.gd"
	Global.register_rod(artifact_draw_on_kill)
	
	
	var artifact_draw_on_combat_start: ArtifactData = ArtifactData.new("artifact_draw_on_combat_start")
	artifact_draw_on_combat_start.artifact_name = "外设插件：战斗加载脚本"
	artifact_draw_on_combat_start.artifact_description = "首时钟周期额外加载2个脚本"
	artifact_draw_on_combat_start.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_draw_on_combat_start.artifact_color_id = "color_green"
	artifact_draw_on_combat_start.artifact_texture_path = "sprites/artifacts/artifact_draw_on_combat_start.png"
	artifact_draw_on_combat_start.artifact_first_turn_actions = [{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 2}}]
	
	Global.register_rod(artifact_draw_on_combat_start)
	
	
	var artifact_easy_mode: ArtifactData = ArtifactData.new("artifact_easy_mode")
	artifact_easy_mode.artifact_name = "外设插件：安全模式"
	artifact_easy_mode.artifact_texture_path = "sprites/artifacts/artifact_easy_mode.png"
	artifact_easy_mode.artifact_description = "将所有敌人的完整度设为1"
	artifact_easy_mode.artifact_counter = 999
	artifact_easy_mode.artifact_counter_max = 999
	artifact_easy_mode.artifact_counter_reset_on_combat_end = -1
	artifact_easy_mode.artifact_counter_reset_on_turn_start = -1
	artifact_easy_mode.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_easy_mode.artifact_script_path = "res://scripts/artifacts/ArtifactEasyMode.gd"
	
	Global.register_rod(artifact_easy_mode)
	
	var artifact_block_on_attacks: ArtifactData = ArtifactData.new("artifact_block_on_attacks")
	artifact_block_on_attacks.artifact_name = "外设插件：攻击加盾"
	artifact_block_on_attacks.artifact_description = "每攻击3次获得5点防火墙"
	artifact_block_on_attacks.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_block_on_attacks.artifact_color_id = "color_red"
	artifact_block_on_attacks.artifact_texture_path = "sprites/artifacts/artifact_block_on_attacks.png"
	artifact_block_on_attacks.artifact_script_path = "res://scripts/artifacts/ArtifactBlockOnAttacks.gd"
	artifact_block_on_attacks.artifact_counter_max = 3
	artifact_block_on_attacks.artifact_counter_wraparound = true
	artifact_block_on_attacks.artifact_counter_reset_on_turn_start = 0
	artifact_block_on_attacks.artifact_counter_reset_on_combat_end = 0
	artifact_block_on_attacks.artifact_max_counter_actions = [{
			Scripts.ACTION_BLOCK: {"block": 5, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}
			}]
	
	Global.register_rod(artifact_block_on_attacks)
	
	var artifact_retain_hand: ArtifactData = ArtifactData.new("artifact_retain_hand")
	artifact_retain_hand.artifact_name = "外设插件：当前线程保留"
	artifact_retain_hand.artifact_texture_path = "sprites/artifacts/artifact_retain_hand.png"
	artifact_retain_hand.artifact_description = "时钟周期结束时，当前线程中的所有脚本不会被丢弃"
	artifact_retain_hand.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_retain_hand.artifact_script_path = "res://scripts/artifacts/ArtifactRetainHand.gd"
	
	Global.register_rod(artifact_retain_hand)
	
	# Enables a rest action when obtained, which grants a damage increase at the start of combat
	var artifact_increase_attack_on_rest: ArtifactData = ArtifactData.new("artifact_increase_attack_on_rest")
	artifact_increase_attack_on_rest.artifact_name = "外设插件：碎片整理增伤"
	artifact_increase_attack_on_rest.artifact_description = "在维护终端可永久提升 1 点攻击力（最高提升 3 点）"
	artifact_increase_attack_on_rest.artifact_counter = 0
	artifact_increase_attack_on_rest.artifact_counter_max = 3
	artifact_increase_attack_on_rest.artifact_color_id = "color_orange"
	artifact_increase_attack_on_rest.artifact_texture_path = "sprites/artifacts/artifact_increase_attack_on_rest.png"
	artifact_increase_attack_on_rest.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_increase_attack_on_rest.artifact_add_actions = [{
		Scripts.ACTION_UPDATE_REST_ACTIONS: {"add_rest_action_object_ids": ["rest_action_increase_attack_on_rest"]}
	}]
	artifact_increase_attack_on_rest.artifact_first_turn_actions = [{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_effect_object_id": "status_effect_damage_increase",
				"custom_key_names": {
					# convert artifact counter passed in from BaseArtifact, into the status charges
					"status_charge_amount": "artifact_counter"
				}}
			}]
	
	Global.register_rod(artifact_increase_attack_on_rest)
	
	var artifact_see_top_of_draw_pile: ArtifactData = ArtifactData.new("artifact_see_top_of_draw_pile")
	artifact_see_top_of_draw_pile.artifact_name = "外设插件：查看内存队列"
	artifact_see_top_of_draw_pile.artifact_description = "可以查看内存队列顶部的脚本"
	artifact_see_top_of_draw_pile.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_see_top_of_draw_pile.artifact_color_id = "color_blue"
	artifact_see_top_of_draw_pile.artifact_texture_path = "sprites/artifacts/artifact_see_top_of_draw_pile.png"
	
	Global.register_rod(artifact_see_top_of_draw_pile)
	
	# Makes an attack card top deck when obtained
	var artifact_top_deck_attack_card: ArtifactData = ArtifactData.new("artifact_top_deck_attack_card")
	artifact_top_deck_attack_card.artifact_name = "外设插件：攻击脚本置顶"
	artifact_top_deck_attack_card.artifact_texture_path = "sprites/artifacts/artifact_top_deck_attack_card.png"
	artifact_top_deck_attack_card.artifact_description = "选择一个攻击脚本，使其出现在脚本库顶部。"
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
		"card_pick_text": "选择一个脚本将其置顶",
		"action_data": [
			# convert the card to top deck
			{Scripts.ACTION_CHANGE_CARD_PROPERTIES: 
				{
				"modify_parent_card": false,
				"card_properties": {"card_unremovable_from_deck": true, "card_untransformable_from_deck": true, "card_first_shuffle_priority": 1, }
				}
				},
			],
		# only non-generated removable attack cards allowed
		"validator_data": [
			{Scripts.VALIDATOR_CARD_TYPE: {"card_types": [CardData.CARD_TYPES.ATTACK]}},
			{Scripts.VALIDATOR_CARD_RARITY: {"card_rarities_exclude": [CardData.CARD_RARITIES.GENERATED]}},
			{Scripts.VALIDATOR_CARD_PROPERTIES: {"card_property_name": "card_unremovable_from_deck", "operator": "==", "comparison_value": false}},
		],
		}
	},
	]
	
	Global.register_rod(artifact_top_deck_attack_card)
	
	
	var artifact_right_click_shuffle_deck: ArtifactData = ArtifactData.new("artifact_right_click_shuffle_deck")
	artifact_right_click_shuffle_deck.artifact_name = "外设插件：重新分配"
	artifact_right_click_shuffle_deck.artifact_description = "右键将回收站重新分配入内存队列。"
	artifact_right_click_shuffle_deck.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_right_click_shuffle_deck.artifact_color_id = "color_green"
	artifact_right_click_shuffle_deck.artifact_texture_path = "sprites/artifacts/artifact_right_click_shuffle_deck.png"
	artifact_right_click_shuffle_deck.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_right_click_shuffle_deck.artifact_right_click_actions = [
		{Scripts.ACTION_RESHUFFLE:{}}
	]
	
	Global.register_rod(artifact_right_click_shuffle_deck)
	
	### Filler Artifacts
	var artifact_boss_red: ArtifactData = ArtifactData.new("artifact_boss_red")
	artifact_boss_red.artifact_name = "外设插件：红色Boss"
	artifact_boss_red.artifact_description = "测试用红色Boss外设插件。"
	artifact_boss_red.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_boss_red.artifact_color_id = "color_red"
	artifact_boss_red.artifact_texture_path = "sprites/artifacts/artifact_boss_red.png"
	
	Global.register_rod(artifact_boss_red)
	
	var artifact_shop_red: ArtifactData = ArtifactData.new("artifact_shop_red")
	artifact_shop_red.artifact_name = "外设插件：红色暗网节点"
	artifact_shop_red.artifact_description = "测试用红色暗网节点外设插件。"
	artifact_shop_red.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.SHOP
	artifact_shop_red.artifact_color_id = "color_red"
	artifact_shop_red.artifact_texture_path = "sprites/artifacts/artifact_shop_red.png"
	
	Global.register_rod(artifact_shop_red)
	
	var artifact_boss_blue: ArtifactData = ArtifactData.new("artifact_boss_blue")
	artifact_boss_blue.artifact_name = "外设插件：蓝色Boss"
	artifact_boss_blue.artifact_description = "测试用蓝色Boss外设插件。"
	artifact_boss_blue.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_boss_blue.artifact_color_id = "color_blue"
	artifact_boss_blue.artifact_texture_path = "sprites/artifacts/artifact_boss_blue.png"
	
	Global.register_rod(artifact_boss_blue)
	
	var artifact_shop_blue: ArtifactData = ArtifactData.new("artifact_shop_blue")
	artifact_shop_blue.artifact_name = "外设插件：蓝色暗网节点"
	artifact_shop_blue.artifact_description = "测试用蓝色暗网节点外设插件。"
	artifact_shop_blue.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.SHOP
	artifact_shop_blue.artifact_color_id = "color_blue"
	artifact_shop_blue.artifact_texture_path = "sprites/artifacts/artifact_shop_blue.png"
	
	Global.register_rod(artifact_shop_blue)
	
	var artifact_boss_green: ArtifactData = ArtifactData.new("artifact_boss_green")
	artifact_boss_green.artifact_name = "外设插件：绿色Boss"
	artifact_boss_green.artifact_description = "测试用绿色Boss外设插件。"
	artifact_boss_green.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_boss_green.artifact_color_id = "color_green"
	artifact_boss_green.artifact_texture_path = "sprites/artifacts/artifact_boss_green.png"
	
	Global.register_rod(artifact_boss_green)
	
	var artifact_shop_green: ArtifactData = ArtifactData.new("artifact_shop_green")
	artifact_shop_green.artifact_name = "外设插件：绿色暗网节点"
	artifact_shop_green.artifact_description = "测试用绿色暗网节点外设插件。"
	artifact_shop_green.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.SHOP
	artifact_shop_green.artifact_color_id = "color_green"
	artifact_shop_green.artifact_texture_path = "sprites/artifacts/artifact_shop_green.png"
	
	Global.register_rod(artifact_shop_green)
	
	var artifact_boss_orange: ArtifactData = ArtifactData.new("artifact_boss_orange")
	artifact_boss_orange.artifact_name = "外设插件：橙色Boss"
	artifact_boss_orange.artifact_description = "测试用橙色Boss外设插件。"
	artifact_boss_orange.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_boss_orange.artifact_color_id = "color_orange"
	artifact_boss_orange.artifact_texture_path = "sprites/artifacts/artifact_boss_orange.png"
	
	Global.register_rod(artifact_boss_orange)
	
	var artifact_shop_orange: ArtifactData = ArtifactData.new("artifact_shop_orange")
	artifact_shop_orange.artifact_name = "外设插件：橙色暗网节点"
	artifact_shop_orange.artifact_description = "测试用橙色暗网节点外设插件。"
	artifact_shop_orange.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.SHOP
	artifact_shop_orange.artifact_color_id = "color_orange"
	artifact_shop_orange.artifact_texture_path = "sprites/artifacts/artifact_shop_orange.png"
	
	Global.register_rod(artifact_shop_orange)
	
	var artifact_boss_white: ArtifactData = ArtifactData.new("artifact_boss_white")
	artifact_boss_white.artifact_name = "外设插件：白色Boss"
	artifact_boss_white.artifact_description = "测试用白色Boss外设插件。"
	artifact_boss_white.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_boss_white.artifact_color_id = "color_white"
	artifact_boss_white.artifact_texture_path = "sprites/artifacts/artifact_boss_white.png"
	
	Global.register_rod(artifact_boss_white)
	
	var artifact_shop_white: ArtifactData = ArtifactData.new("artifact_shop_white")
	artifact_shop_white.artifact_name = "外设插件：白色暗网节点"
	artifact_shop_white.artifact_description = "测试用白色暗网节点外设插件。"
	artifact_shop_white.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.SHOP
	artifact_shop_white.artifact_color_id = "color_white"
	artifact_shop_white.artifact_texture_path = "sprites/artifacts/artifact_shop_white.png"
	
	Global.register_rod(artifact_shop_white)
	
	

#endregion

#region Consumables
func add_test_consumables_to_player() -> void:
	#Global.player_data.player_consumable_slot_to_consumable_object_id["0"] = "consumable_heal"
	#Global.player_data.player_consumable_slot_to_consumable_object_id["1"] = "consumable_block"
	#Global.player_data.player_consumable_slot_to_consumable_object_id["2"] = "consumable_damaging"
	Global.player_data.player_consumable_slot_to_consumable_object_id["2"] = "consumable_multi_damaging"

func add_test_consumables() -> void:
	# health consumable
	var consumable_heal: ConsumableData = ConsumableData.new("consumable_heal")
	consumable_heal.consumable_name = "治疗试剂"
	consumable_heal.consumable_color_id = "color_white"
	consumable_heal.consumable_description = "回复20%最大完整度"
	consumable_heal.consumable_use_text = "饮用"
	consumable_heal.consumable_requires_target = false
	consumable_heal.consumable_energy_cost = 1
	consumable_heal.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_heal.consumable_texture_path = "sprites/consumables/consumable_heal.png"
	consumable_heal.consumable_values = {
		"percentage_heal_amount": 0.20
	}
	consumable_heal.consumable_actions = [
		{
		Scripts.ACTION_HEAL_PERCENT: {
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
		}
		}
	]
	Global.register_rod(consumable_heal)
	
	# block consumable
	var consumable_block: ConsumableData = ConsumableData.new("consumable_block")
	consumable_block.consumable_name = "防火墙试剂"
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
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
			}
		}
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
			"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS
			}
		}
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
		Scripts.ACTION_DIRECT_DAMAGE: 
			{
			"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			}
		}
	]
	Global.register_rod(consumable_multi_damaging)
	
	# auto revive consumable
	# example of consumable not usable by the player
	# Uses force_dead_targets to work even on a dead player.
	# Uses an automatic run modifier and interceptor to intercept ActionDeath.
	# See InterceptorConsumableAutoRevive and interceptor_consumable_auto_revive RunModifierData for more
	var consumable_auto_revive: ConsumableData = ConsumableData.new("consumable_auto_revive")
	consumable_auto_revive.consumable_name = "自动复活护符"
	consumable_auto_revive.consumable_color_id = "color_white"
	consumable_auto_revive.consumable_description = "玩家死亡时回复20%完整度"
	consumable_auto_revive.consumable_use_text = "使用"
	consumable_auto_revive.consumable_requires_target = false
	consumable_auto_revive.consumable_use_disabled = true # cannot be manually used
	consumable_auto_revive.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_auto_revive.consumable_texture_path = "sprites/consumables/consumable_auto_revive.png"
	consumable_auto_revive.consumable_values = {
		"percentage_heal_amount": 0.20,
		"force_dead_targets": true # will work even if the target is dead
	}
	consumable_auto_revive.consumable_actions = [
		{
		Scripts.ACTION_HEAL_PERCENT: {
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
		}
		}
	]
	
	Global.register_rod(consumable_auto_revive)

#endregion

#region Rest Actions

func add_test_rest_actions() -> void:
	# rest action
	var rest_action_rest: RestActionData = RestActionData.new("rest_action_rest")
	rest_action_rest.rest_action_name = "碎片整理"
	rest_action_rest.rest_action_stat_name = "REST_REST_COUNT"
	rest_action_rest.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_rest.rest_actions = [
		{
		Scripts.ACTION_HEAL_PERCENT: {
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			"percentage_heal_amount": 0.40
			}
		}
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
		"card_pick_text": "选择最多 {0} 个脚本升级。已选 {1} 个",
		"min_cards_are_required_for_action": true, # won't fire if you cancel it
		"quick_pick": false,
		"can_back_out": true, # allows rest action to be canceled
		"random_selection": false,
		# only upgradeable cards allowed
		"validator_data": [
			{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}}
		],
		"action_data": [
			# embed the rest action end in the pick card action payload
			{Scripts.ACTION_REST_ACTION_END: {"rest_action_id": "rest_action_upgrade_card"}},
			{Scripts.ACTION_UPGRADE_CARDS: {"upgrade_parent_card": true}}
			]
		}
	}
	]
	
	rest_action_upgrade_card.rest_action_validators = [
		{
		Scripts.VALIDATOR_DECK_HAS_UPGRADEABLE_CARD: {}
		}
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
				{Scripts.ACTION_REST_ACTION_END: {"rest_action_id": "rest_action_remove_cards"}},
				{Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {}}
				]
			}
		}
	]
	rest_action_remove_cards.rest_action_validators = [
		{
		Scripts.VALIDATOR_PILE_SIZE: 
			{
			"card_pick_type": HandManager.DECK,
			"card_type_maximum": 4,
			"card_types": CardData.CARD_TYPES.values(),	# any card
			"invert_validation": false,
			}
		}
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
				{Scripts.VALIDATOR_CARD_IS_DECORATABLE: {
					"card_decorator_ids": 
					[
						"card_decorator_extra_draw",
						"card_decorator_block_on_play"
					]
				}}
			],
			"action_data": [
				# finish rest action
				{Scripts.ACTION_REST_ACTION_END: {"rest_action_id": "rest_action_enchant_cards"}},
				# remove money
				{Scripts.ACTION_ADD_MONEY:{"money_amount": -25}},
				# randomly decorate the card
				{Scripts.ACTION_DECORATE_CARDS: 
				{
					"decorate_parent_card": false, # already selecting the deck card
					"random_card_decorators": 
						{
							"card_decorator_extra_draw": {},
							"card_decorator_block_on_play": {}
						}
				}}
				]
			}
		}
	]
	rest_action_enchant_cards.rest_action_validators = [
		{
		# must have enough money
		Scripts.VALIDATOR_MONEY:
			{
				"money_amount": 25
			}
		},
		{
		# must have at least one card that can slot a decorator
		Scripts.VALIDATOR_DECK_HAS_DECORATABLE_CARD: 
			{
			"card_pick_type": HandManager.DECK,
			"card_decorator_ids": 
				[
					"card_decorator_extra_draw",
					"card_decorator_block_on_play"
				],
			"card_types": CardData.CARD_TYPES.values(),	# any card
			"invert_validation": false,
			}
		}
	]
	
	Global.register_rod(rest_action_enchant_cards)
	
	# add random consumable action
	var rest_action_add_random_consumable: RestActionData = RestActionData.new("rest_action_add_random_consumable")
	rest_action_add_random_consumable.rest_action_name = "随机获得\n物理删除品"
	rest_action_add_random_consumable.rest_action_stat_name = "REST_GAIN_CONSUMABLE_COUNT"
	rest_action_add_random_consumable.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_add_random_consumable.rest_actions = [
		{Scripts.ACTION_ADD_CONSUMABLE: {"random_consumable": true}},
	]
	
	Global.register_rod(rest_action_add_random_consumable)
	
	# increase damage artifact action
	# paired with corresponding artifact
	var rest_action_increase_attack_on_rest: RestActionData = RestActionData.new("rest_action_increase_attack_on_rest")
	rest_action_increase_attack_on_rest.rest_action_name = "增强伤害"
	rest_action_increase_attack_on_rest.rest_action_stat_name = "REST_INCREASE_DAMAGE_COUNT"
	rest_action_increase_attack_on_rest.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_increase_attack_on_rest.rest_actions = [
		{Scripts.ACTION_INCREASE_ARTIFACT_CHARGE: {"artifact_id": "artifact_increase_attack_on_rest"}},
	]
	
	Global.register_rod(rest_action_increase_attack_on_rest)
	
	# transforms a quest card into a reward card
	var rest_action_transform_quest_card: RestActionData = RestActionData.new("rest_action_transform_quest_card")
	rest_action_transform_quest_card.rest_action_name = "任务脚本"
	rest_action_transform_quest_card.rest_action_stat_name = "REST_QUEST_CARD_COUNT"
	rest_action_transform_quest_card.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_transform_quest_card.rest_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"max_card_amount": 999,
		"min_card_amount": 999,
		"min_cards_are_required_for_action": false,
		"random_selection": false,
		"card_pick_type": HandManager.DECK,
		"action_data": [
			# remove this rest action
			{Scripts.ACTION_UPDATE_REST_ACTIONS: {"remove_rest_action_object_ids": ["rest_action_transform_quest_card"]}},
			# transform the card into a reward card
			{Scripts.ACTION_TRANSFORM_CARDS: 
				{
				"transform_parent_card": false,
				"transform_into_card_object_id": "card_quest_reward"
				}
				},
			],
		# only quest card selected
		"validator_data": [
			{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": ["card_quest"]}},
		],
		}
	},
	]
	
	Global.register_rod(rest_action_transform_quest_card)
	

#endregion

#region Status Effects
func add_test_status_effects() -> void:
	# poison like effect
	# example of status effect that reserves health bar
	var status_effect_corrosion: StatusEffectData = StatusEffectData.new("status_effect_corrosion")
	status_effect_corrosion.status_effect_name = "腐蚀"
	status_effect_corrosion.status_effect_description = "每时钟周期结束时，受到等同于层数的物理伤害。"
	status_effect_corrosion.status_effect_texture_path = "external/sprites/status_effects/status_effect_green.png"
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
						"damage": "invoking_status_effect_charges"
					},
			"time_delay": 0.5,
			"bypass_block": true,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
			}
		}
	]
	status_effect_corrosion.status_effect_enemy_process_actions = status_effect_corrosion.status_effect_player_process_actions.duplicate()
	
	Global.register_rod(status_effect_corrosion)
	
	# bomb effect that counts down and damages all enemies
	# uses timer status effect
	var status_effect_bomb: StatusEffectData = StatusEffectData.new("status_effect_bomb")
	status_effect_bomb.status_effect_name = "炸弹"
	status_effect_bomb.status_effect_texture_path = "external/sprites/status_effects/status_effect_purple.png"
	status_effect_bomb.status_effect_script_path = "res://scripts/status_effects/StatusEffectTimedStatus.gd"
	status_effect_bomb.status_effect_decay_rate = -1
	status_effect_bomb.status_effect_allows_multiples = true
	status_effect_bomb.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_bomb.status_effect_player_process_actions = [
				{
				Scripts.ACTION_DIRECT_DAMAGE: {
					"custom_key_names": {
						# convert the bomb's status secondary charges, passed in from BaseStatusEffect, into bomb damage
						"damage": "invoking_status_effect_secondary_charges"
					},
					"bypass_block": false,
					"time_delay": 0.5,
					"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES # player bombs hit all enemies
					}
				}
			]
	status_effect_bomb.status_effect_enemy_process_actions = [
				{
				Scripts.ACTION_DIRECT_DAMAGE: {
					"custom_key_names": {
						# convert the bomb's status secondary charges, passed in from BaseStatusEffect, into bomb damage
						"damage": "invoking_status_effect_secondary_charges"
					},
					"bypass_block": false,
					"time_delay": 0.5,
					"target_override": BaseAction.TARGET_OVERRIDES.PLAYER # enemy bombs hit player
					}
				}
			]
	status_effect_bomb.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_bomb.status_effect_interceptor_ids = []
	
	Global.register_rod(status_effect_bomb)
	
	# increases attack damage by charge amount
	# uses an interceptor
	var status_effect_damage_increase: StatusEffectData = StatusEffectData.new("status_effect_damage_increase")
	status_effect_damage_increase.status_effect_name = "伤害提升"
	status_effect_damage_increase.status_effect_texture_path = "external/sprites/status_effects/status_effect_red.png"
	status_effect_damage_increase.status_effect_decay_rate = 0
	status_effect_damage_increase.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_damage_increase.status_effect_interceptor_ids = ["interceptor_damage_increase"]
	
	Global.register_rod(status_effect_damage_increase)
	
	# decreases damage done by attackers
	# uses an interceptor
	var status_effect_weakness: StatusEffectData = StatusEffectData.new("status_effect_weakness")
	status_effect_weakness.status_effect_name = "虚弱"
	status_effect_weakness.status_effect_description = "造成的攻击伤害降低 25%。"
	status_effect_weakness.status_effect_texture_path = "external/sprites/status_effects/status_effect_yellow.png"
	status_effect_weakness.status_effect_decay_rate = -1
	status_effect_weakness.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_weakness.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_weakness.status_effect_interceptor_ids = ["interceptor_weaken"]
	
	Global.register_rod(status_effect_weakness)
	
	# increases attack damage on attacked combatant
	# uses an interceptor
	var status_effect_vulnerable: StatusEffectData = StatusEffectData.new("status_effect_vulnerable")
	status_effect_vulnerable.status_effect_name = "易伤"
	status_effect_vulnerable.status_effect_texture_path = "external/sprites/status_effects/status_effect_blue.png"
	status_effect_vulnerable.status_effect_decay_rate = -1
	status_effect_vulnerable.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_weakness.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_vulnerable.status_effect_interceptor_ids = ["interceptor_vulnerable"]
	
	Global.register_rod(status_effect_vulnerable)
	
	# status that binds a card to an enemy, adding it to the player's hand when killed
	var status_effect_attached_card: StatusEffectData = StatusEffectData.new("status_effect_attached_card")
	status_effect_attached_card.status_effect_name = "附属脚本"
	status_effect_attached_card.status_effect_texture_path = "external/sprites/status_effects/status_effect_red.png"
	status_effect_attached_card.status_effect_script_path = "res://scripts/status_effects/StatusEffectAttachedCard.gd"
	status_effect_attached_card.status_effect_decay_rate = 0
	status_effect_attached_card.status_effect_allows_multiples = true
	status_effect_attached_card.status_effect_charge_upper_bound = 1
	status_effect_attached_card.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_attached_card.status_effect_interceptor_ids = []
	
	Global.register_rod(status_effect_attached_card)
	
	# uses an interceptor to stop an attack from processing
	var status_effect_negate_damage: StatusEffectData = StatusEffectData.new("status_effect_negate_damage")
	status_effect_negate_damage.status_effect_name = "伤害免疫"
	status_effect_negate_damage.status_effect_description = "完全抵消下一次受到的伤害。"
	status_effect_negate_damage.status_effect_texture_path = "external/sprites/status_effects/status_effect_green.png"
	status_effect_negate_damage.status_effect_decay_rate = 0
	status_effect_negate_damage.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_negate_damage.status_effect_interceptor_ids = ["interceptor_negate_damage"]
	
	Global.register_rod(status_effect_negate_damage)
	
	# uses an interceptor to prevent block from resetting
	var status_effect_preserve_block: StatusEffectData = StatusEffectData.new("status_effect_preserve_block")
	status_effect_preserve_block.status_effect_name = "防火墙保留"
	status_effect_preserve_block.status_effect_texture_path = "external/sprites/status_effects/status_effect_purple.png"
	status_effect_preserve_block.status_effect_decay_rate = 0
	status_effect_preserve_block.status_effect_charge_upper_bound = 1
	status_effect_preserve_block.status_effect_interceptor_ids = ["interceptor_preserve_block"]
	
	Global.register_rod(status_effect_preserve_block)
	
	# uses an interceptor to stop a debuff from happening
	var status_effect_negate_debuff: StatusEffectData = StatusEffectData.new("status_effect_negate_debuff")
	status_effect_negate_debuff.status_effect_name = "减益免疫"
	status_effect_negate_debuff.status_effect_texture_path = "external/sprites/status_effects/status_effect_yellow.png"
	status_effect_negate_debuff.status_effect_decay_rate = 0
	status_effect_negate_debuff.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_negate_debuff.status_effect_interceptor_ids = ["interceptor_negate_debuff"]
	
	Global.register_rod(status_effect_negate_debuff)
	
	# uses an interceptor to make the next N attack card plays free
	# this will affect card energy display logic, see Card._update_energy_display()
	var status_effect_next_attack_free: StatusEffectData = StatusEffectData.new("status_effect_next_attack_free")
	status_effect_next_attack_free.status_effect_name = "下次攻击免费"
	status_effect_next_attack_free.status_effect_texture_path = "external/sprites/status_effects/status_effect_red.png"
	status_effect_next_attack_free.status_effect_decay_rate = 0
	status_effect_next_attack_free.status_effect_charge_upper_bound = 99
	status_effect_next_attack_free.status_effect_interceptor_ids = ["interceptor_next_attack_free"]
	
	Global.register_rod(status_effect_next_attack_free)
	
	# uses an interceptor to rebound card plays to draw pile
	var status_effect_rebound_card_plays: StatusEffectData = StatusEffectData.new("status_effect_rebound_card_plays")
	status_effect_rebound_card_plays.status_effect_name = "回弹调用"
	status_effect_rebound_card_plays.status_effect_texture_path = "external/sprites/status_effects/status_effect_blue.png"
	status_effect_rebound_card_plays.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.ZERO_OUT
	status_effect_rebound_card_plays.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_rebound_card_plays.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_ENEMY_TURN,
	]
	status_effect_rebound_card_plays.status_effect_interceptor_ids = ["interceptor_rebound_card_plays"]
	
	Global.register_rod(status_effect_rebound_card_plays)
	
	# uses an interceptor to duplicate the first card play each turn
	var status_effect_duplicate_card_plays: StatusEffectData = StatusEffectData.new("status_effect_duplicate_card_plays")
	status_effect_duplicate_card_plays.status_effect_name = "双重调用"
	status_effect_duplicate_card_plays.status_effect_texture_path = "external/sprites/status_effects/status_effect_purple.png"
	status_effect_duplicate_card_plays.status_effect_script_path = "res://scripts/status_effects/StatusEffectDuplicateCardPlays.gd"
	status_effect_duplicate_card_plays.status_effect_decay_rate = 0
	status_effect_duplicate_card_plays.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_duplicate_card_plays.status_effect_interceptor_ids = ["interceptor_duplicate_card_plays"]
	
	Global.register_rod(status_effect_duplicate_card_plays)

	# uses an interceptor to duplicate attack card plays
	var status_effect_duplicate_attacks: StatusEffectData = StatusEffectData.new("status_effect_duplicate_attacks")
	status_effect_duplicate_attacks.status_effect_name = "双重调用"
	status_effect_duplicate_attacks.status_effect_texture_path = "external/sprites/status_effects/status_effect_purple.png"
	status_effect_duplicate_attacks.status_effect_decay_rate = -999
	status_effect_duplicate_attacks.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_duplicate_attacks.status_effect_interceptor_ids = ["interceptor_duplicate_attacks"]
	
	Global.register_rod(status_effect_duplicate_attacks)
	
	# uses an interceptor to duplicate attack card plays
	var status_effect_block_on_special_discard: StatusEffectData = StatusEffectData.new("status_effect_block_on_special_discard")
	status_effect_block_on_special_discard.status_effect_name = "缓存回收"
	status_effect_block_on_special_discard.status_effect_texture_path = "external/sprites/status_effects/status_effect_yellow.png"
	status_effect_block_on_special_discard.status_effect_decay_rate = 0
	status_effect_block_on_special_discard.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_block_on_special_discard.status_effect_interceptor_ids = ["interceptor_duplicate_attacks"]
	
	Global.register_rod(status_effect_block_on_special_discard)

#endregion

#region Acts
func add_test_acts() -> void:
	var act_1: ActData = ActData.new("act_1")
	act_1.act_name = "第1章"
	act_1.act_codex_number = 1
	act_1.act_codex_color = Color.AQUA
	act_1.act_next_act_ids = ["act_2"]
	act_1.act_easy_combat_event_pool_object_id = "event_pool_act_1_easy"
	act_1.act_hard_combat_event_pool_object_id = "event_pool_act_1_hard"
	act_1.act_miniboss_event_pool_object_id = "event_pool_act_1_miniboss"
	act_1.act_non_combat_event_pool_object_id = "event_pool_act_1_dialogue"
	act_1.act_boss_event_pool_object_id = "event_pool_act_1_boss"
	
	Global.register_rod(act_1)
	
	var act_2: ActData = ActData.new("act_2")
	act_2.act_name = "第2章"
	act_2.act_codex_number = 2
	act_2.act_codex_color = Color.GREEN_YELLOW
	act_2.act_next_act_ids = ["act_3"]
	act_2.act_easy_combat_event_pool_object_id = "event_pool_act_1_easy"
	act_2.act_hard_combat_event_pool_object_id = "event_pool_act_1_easy"
	act_2.act_miniboss_event_pool_object_id = "event_pool_act_1_miniboss"
	act_2.act_non_combat_event_pool_object_id = "event_pool_act_1_dialogue"
	act_2.act_boss_event_pool_object_id = "event_pool_act_1_boss"
	Global.register_rod(act_2)
	
	var act_3: ActData = ActData.new("act_3")
	act_3.act_name = "第3章"
	act_3.act_codex_number = 3
	act_3.act_codex_color = Color.MEDIUM_PURPLE
	act_3.act_next_act_ids = ["act_1"] # only works in endless
	act_3.act_easy_combat_event_pool_object_id = "event_pool_act_1_easy"
	act_3.act_hard_combat_event_pool_object_id = "event_pool_act_1_easy"
	act_3.act_miniboss_event_pool_object_id = "event_pool_act_1_miniboss"
	act_3.act_non_combat_event_pool_object_id = "event_pool_act_1_dialogue"
	act_3.act_boss_event_pool_object_id = "event_pool_act_1_boss"
	Global.register_rod(act_3)
	
	
#endregion
	
#region Events and Event Pools

func add_test_events() -> void:
	## Act 1 Combat
	# has an equal chance of spawning 1 of 3 enemies in each slot
	var event_act_1_easy_combat_1: EventData = EventData.new("event_act_1_easy_combat_1")
	event_act_1_easy_combat_1.event_death_message_bbcode = "死于简单战斗"
	event_act_1_easy_combat_1.event_weighted_enemy_object_ids = [
		{"enemy_1": 1, "enemy_2": 1, "enemy_3": 1},
		{"enemy_1": 1, "enemy_2": 1, "enemy_3": 1},
		{"enemy_1": 1, "enemy_2": 1, "enemy_3": 1},
		]
	
	Global.register_rod(event_act_1_easy_combat_1)
	
	var event_act_1_easy_combat_2: EventData = EventData.new("event_act_1_easy_combat_2")
	event_act_1_easy_combat_2.event_weighted_enemy_object_ids = [
		{"enemy_3": 1}
		]
	
	Global.register_rod(event_act_1_easy_combat_2)
	
	var event_act_1_easy_combat_3: EventData = EventData.new("event_act_1_easy_combat_3")
	event_act_1_easy_combat_3.event_weighted_enemy_object_ids = [
		{"enemy_1": 1},
		{"enemy_2": 1},
		]
	
	Global.register_rod(event_act_1_easy_combat_3)
	
	var event_act_1_easy_combat_4: EventData = EventData.new("event_act_1_easy_combat_4")
	event_act_1_easy_combat_4.event_weighted_enemy_object_ids = [
		{"enemy_4": 1},
		]
	
	Global.register_rod(event_act_1_easy_combat_4)
	
	var event_act_1_miniboss_1: EventData = EventData.new("event_act_1_miniboss_1")
	event_act_1_miniboss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_1_miniboss_1": 1},
		]
	
	Global.register_rod(event_act_1_miniboss_1)
	
	var event_act_1_miniboss_2: EventData = EventData.new("event_act_1_miniboss_2")
	event_act_1_miniboss_2.event_weighted_enemy_object_ids = [
		{"enemy_act_1_miniboss_2": 1},
		{"enemy_act_1_miniboss_2": 1},
		]
	
	Global.register_rod(event_act_1_miniboss_2)
	
	var event_act_1_miniboss_3: EventData = EventData.new("event_act_1_miniboss_3")
	event_act_1_miniboss_3.event_weighted_enemy_object_ids = [
		{"enemy_act_1_miniboss_1": 1},
		]
	
	Global.register_rod(event_act_1_miniboss_3)
	
	var event_act_1_boss_1: EventData = EventData.new("event_act_1_boss_1")
	event_act_1_boss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_1_boss_1": 1},
		]
	event_act_1_boss_1.event_enemy_placement_is_automatic = false
	event_act_1_boss_1.event_enemy_placement_positions = [[0,0], [180,0], [360,0]]
	event_act_1_boss_1.event_death_message_bbcode = "Boss很强大"
	
	Global.register_rod(event_act_1_boss_1)
	
	## Act 1 Dialogue Events
	# see add_test_dialogue()
	
	var event_pick_something: EventData = EventData.new("event_pick_something")
	event_pick_something.event_dialogue_object_id = "dialogue_pick_something"
	Global.register_rod(event_pick_something)
	
	var event_modify_card: EventData = EventData.new("event_modify_card")
	event_modify_card.event_dialogue_object_id = "dialogue_modify_card"
	Global.register_rod(event_modify_card)
	
	var event_gain_items: EventData = EventData.new("event_gain_items")
	event_gain_items.event_dialogue_object_id = "dialogue_gain_items"
	Global.register_rod(event_gain_items)
	
	### Event Pools
	# act 1 easy pool
	var event_pool_act_1_easy: EventPoolData = EventPoolData.new("event_pool_act_1_easy")
	event_pool_act_1_easy.add_events_to_pool(
		event_act_1_easy_combat_1,
		[
		event_act_1_easy_combat_1,
		event_act_1_easy_combat_2,
		event_act_1_easy_combat_3,
		event_act_1_easy_combat_4,
		])
	
	Global.register_rod(event_pool_act_1_easy)
	
	# act 1 hard pool
	var event_pool_act_1_hard: EventPoolData = EventPoolData.new("event_pool_act_1_hard")
	event_pool_act_1_hard.add_events_to_pool(
		event_act_1_easy_combat_1,
		[
		event_act_1_easy_combat_1,
		event_act_1_easy_combat_2,
		event_act_1_easy_combat_3,
		event_act_1_easy_combat_4,
		])
	
	Global.register_rod(event_pool_act_1_hard)
	
	# act 1 dialogue event pool
	var event_pool_act_1_dialogue: EventPoolData = EventPoolData.new("event_pool_act_1_dialogue")
	event_pool_act_1_dialogue.add_events_to_pool(
		event_pick_something,
		[
		event_pick_something,
		event_modify_card,
		event_gain_items,
		])
	
	Global.register_rod(event_pool_act_1_dialogue)
	
	# act 1 miniboss pool
	var event_pool_act_1_miniboss: EventPoolData = EventPoolData.new("event_pool_act_1_miniboss")
	event_pool_act_1_miniboss.add_events_to_pool(
		event_act_1_miniboss_1,
		[
		event_act_1_miniboss_1,
		event_act_1_miniboss_2,
		])
	Global.register_rod(event_pool_act_1_miniboss)
	
	# act 1 boss pool
	var event_pool_act_1_boss: EventPoolData = EventPoolData.new("event_pool_act_1_boss")
	event_pool_act_1_boss.add_events_to_pool(
		event_act_1_boss_1,
		[
		event_act_1_boss_1,
		])
	
	Global.register_rod(event_pool_act_1_boss)
	
#endregion

# Dialogue

## Adds test DialogueData, and their embedded DialogueStateData and DialogueOptionData payloads
func add_test_dialogue() -> void:
	#region Dialogue Event 1
	# Dialogue 1
	var dialogue_pick_something: DialogueData = DialogueData.new("dialogue_pick_something")
	dialogue_pick_something.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=green]选择物品[/color][/wave]"
	Global.register_rod(dialogue_pick_something)
	
	# Option 1
	var dialogue_pick_something_option_1: DialogueOptionData = DialogueOptionData.new("dialogue_pick_something_option_1")
	dialogue_pick_something_option_1.dialogue_option_bbcode = "[color=red]失去10点完整度[/color]并[color=green]获得100数据币[/color]"
	dialogue_pick_something_option_1.dialogue_option_failed_validator_bbcode = "[color=grey][已锁定]: 完整度不足[/color]"
	dialogue_pick_something_option_1.dialogue_option_actions = [
		{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -10}},
		{Scripts.ACTION_ADD_MONEY: {"money_amount": 100}},
		]
	dialogue_pick_something_option_1.dialogue_option_validators = [
		{Scripts.VALIDATOR_PLAYER_HEALTH: {"health_amount": 11}},
	]
	dialogue_pick_something_option_1.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	
	dialogue_pick_something._assign_option(dialogue_pick_something_option_1)
	
	# Option 2
	var dialogue_pick_something_option_2: DialogueOptionData = DialogueOptionData.new("dialogue_pick_something_option_2")
	dialogue_pick_something_option_2.dialogue_option_bbcode = "[color=red]失去50数据币[/color]并[color=green]获得随机稀有脚本[/color]"
	dialogue_pick_something_option_2.dialogue_option_failed_validator_bbcode = "[color=grey][已锁定]: 数据币不足[/color]"
	dialogue_pick_something_option_2.dialogue_option_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": ActionBasePickCards.PICK_DRAFT,
			"pick_draft_cards": false,
			"draft_from_card_pool": true,
			"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
			"validator_data": [
				{Scripts.VALIDATOR_CARD_RARITY: {"card_rarities": [CardData.CARD_RARITIES.RARE]}},
				{Scripts.VALIDATOR_CARD_DRAFTABLE: {}},
			],
			"rng_name": "rng_events",
			"draft_use_player_draft": false, # this should always be false if using a validator based draft
			"draft_is_weighted": false,
			"draft_use_pity_system": false,
			"random_selection": true, # auto pick it
			"draft_max_card_amount": 1, # auto pick it
			"min_card_amount": 1,
			"max_card_amount": 1,
			}
		},
		{Scripts.ACTION_ADD_MONEY: {"money_amount": -50}},
	]
	dialogue_pick_something_option_2.dialogue_option_validators = [
		{Scripts.VALIDATOR_MONEY: {"money_amount": 50}},
	]
	dialogue_pick_something_option_2.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	
	dialogue_pick_something._assign_option(dialogue_pick_something_option_2)
	
	# State 1
	var dialogue_state_pick_something_initial: DialogueStateData = DialogueStateData.new("dialogue_state_pick_something_initial")
	dialogue_state_pick_something_initial.dialogue_state_prompt_bbcode = "测试事件。选择一个选项..."
	dialogue_state_pick_something_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	dialogue_state_pick_something_initial.add_state_dialogue_options(
		[
			dialogue_pick_something_option_1,
			dialogue_pick_something_option_2,
		]
	)
	
	dialogue_pick_something._assign_state(dialogue_state_pick_something_initial)
	dialogue_pick_something._assign_initial_state(dialogue_state_pick_something_initial)
	
	#endregion
	#region Dialogue Event 2
	# Dialogue 2
	var dialogue_modify_card: DialogueData = DialogueData.new("dialogue_modify_card")
	dialogue_modify_card.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=blue]选择物品[/color][/wave]"
	Global.register_rod(dialogue_modify_card)
	
	# Option 1
	# Remove a card from deck
	var dialogue_modify_card_option_1: DialogueOptionData = DialogueOptionData.new("dialogue_modify_card_option_1")
	dialogue_modify_card_option_1.dialogue_option_bbcode = "[color=blue]移除一个脚本[/color]"
	dialogue_modify_card_option_1.dialogue_option_failed_validator_bbcode = "[color=grey][已锁定]: 没有剩余脚本[/color]"
	dialogue_modify_card_option_1.dialogue_option_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"use_parent_card": false,
			"min_card_amount": 1,
			"max_card_amount": 1,
			"min_cards_are_required_for_action": true,
			"quick_pick": false,
			"random_selection": false,
			"card_pick_text": "选择 {0} 个脚本移除。已选 {1} 个",
			"card_pick_type": HandManager.DECK,
			"action_data": [
				{Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {}}
				]
			}
		}
	]
	dialogue_modify_card_option_1.dialogue_option_validators = [
		{
		Scripts.VALIDATOR_DECK_HAS_REMOVABLE_CARD: {}
		}
	]
	dialogue_modify_card_option_1.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	
	dialogue_modify_card._assign_option(dialogue_modify_card_option_1)
	
	# Option 2
	# Remove exhaust from a card
	var dialogue_modify_card_option_2: DialogueOptionData = DialogueOptionData.new("dialogue_modify_card_option_2")
	dialogue_modify_card_option_2.dialogue_option_bbcode = "[color=orange]移除脚本的物理删除效果[/color]"
	dialogue_modify_card_option_2.dialogue_option_failed_validator_bbcode = "[color=grey][已锁定]: 没有带物理删除效果的脚本[/color]"
	dialogue_modify_card_option_2.dialogue_option_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": HandManager.DECK,
			"action_data": [
				{Scripts.ACTION_DECORATE_CARDS: {
					"card_decorator_object_id": "card_decorator_remove_exhaust",
					"decorate_parent_card": false,
				}}
				],
			"validator_data": [
				# must be able to be decorated
				{Scripts.VALIDATOR_CARD_IS_DECORATABLE: {
					"card_decorator_ids": 
					[
						"card_decorator_remove_exhaust",
					]
				}},
				# can only apply to cards that exhaust
				{Scripts.VALIDATOR_CARD_PROPERTIES: {
					"card_property_name": "card_play_destination",
					"operator": "==",
					"comparison_value": HandManager.EXHAUST_PILE,
					}
				},
			],
			"min_card_amount": 1,
			"max_card_amount": 1,
			"min_cards_are_required_for_action": true,
			"is_quick_pick": false,
			"card_pick_text": "选择一个脚本移除物理删除效果。"
			}
		},
	]
	dialogue_modify_card_option_2.dialogue_option_validators = [
		# deck must have a card that exhausts and can be decorated
		{Scripts.VALIDATOR_DECK_HAS_VALIDATED_CARDS: {"validator_data": [
			# must be able to be decorated
				{Scripts.VALIDATOR_CARD_IS_DECORATABLE: {
					"card_decorator_ids": 
					[
						"card_decorator_remove_exhaust",
					]
				}},
				# can only apply to cards that exhaust
				{Scripts.VALIDATOR_CARD_PROPERTIES: {
					"card_property_name": "card_play_destination",
					"operator": "==",
					"comparison_value": HandManager.EXHAUST_PILE,
					}
				},
		]}},
	]
	dialogue_modify_card_option_2.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	dialogue_modify_card._assign_option(dialogue_modify_card_option_2)
	
	# Option 3
	# Upgrade a card
	var dialogue_modify_card_option_3: DialogueOptionData = DialogueOptionData.new("dialogue_modify_card_option_3")
	dialogue_modify_card_option_3.dialogue_option_bbcode = "[color=green]升级一个脚本[/color]"
	dialogue_modify_card_option_3.dialogue_option_failed_validator_bbcode = "[color=grey][已锁定]: 没有可升级的脚本[/color]"
	dialogue_modify_card_option_3.dialogue_option_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": HandManager.DECK,
			"action_data": [{Scripts.ACTION_UPGRADE_CARDS: {}}],
			"validator_data": [
				{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}}
			],
			"min_card_amount": 1,
			"max_card_amount": 1,
			"min_cards_are_required_for_action": 1,
			"is_quick_pick": false,
			"card_pick_text": "选择一个脚本升级。",
			}
		},
	]
	dialogue_modify_card_option_3.dialogue_option_validators =  [
		{
		Scripts.VALIDATOR_DECK_HAS_UPGRADEABLE_CARD: {}
		}
	]
	dialogue_modify_card_option_3.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	dialogue_modify_card._assign_option(dialogue_modify_card_option_3)
	
	# State 1
	var dialogue_state_modify_card_initial: DialogueStateData = DialogueStateData.new("dialogue_state_modify_card_initial")
	dialogue_state_modify_card_initial.dialogue_state_prompt_bbcode = "你必须对一个脚本做些什么..."
	dialogue_state_modify_card_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_modify_card.png"
	dialogue_state_modify_card_initial.add_state_dialogue_options(
		[
			dialogue_modify_card_option_1,
			dialogue_modify_card_option_2,
			dialogue_modify_card_option_3,
		]
	)

	
	dialogue_modify_card._assign_state(dialogue_state_modify_card_initial)
	dialogue_modify_card._assign_initial_state(dialogue_state_modify_card_initial)

	#endregion
	#region Dialogue Event 3
	# Dialogue 1
	var dialogue_gain_items: DialogueData = DialogueData.new("dialogue_gain_items")
	dialogue_gain_items.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=red]选择物品[/color][/wave]"
	Global.register_rod(dialogue_gain_items)
	
	# Option 1
	var dialogue_gain_items_option_1: DialogueOptionData = DialogueOptionData.new("dialogue_gain_items_option_1")
	dialogue_gain_items_option_1.dialogue_option_bbcode = "[color=green]获得2个随机物理删除品[/color]"
	dialogue_gain_items_option_1.dialogue_option_actions = [
			{
			Scripts.ACTION_ADD_CONSUMABLE: 
				{
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"slot_count": 2,
				"random_consumable": true,
				}
			},
		]
	dialogue_gain_items_option_1.dialogue_option_validators = []
	dialogue_gain_items_option_1.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	
	dialogue_gain_items._assign_option(dialogue_gain_items_option_1)
	
	# Option 2
	var dialogue_gain_items_option_2: DialogueOptionData = DialogueOptionData.new("dialogue_gain_items_option_2")
	dialogue_gain_items_option_2.dialogue_option_bbcode = "[color=purple]获得随机稀有外设插件[/color]"
	dialogue_gain_items_option_2.dialogue_option_failed_validator_bbcode = "[color=grey][已锁定]: 数据币不足[/color]"
	dialogue_gain_items_option_2.dialogue_option_actions = [{Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL:
		{
		"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
		"artifact_count": 1,
		"artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.RARE]
		}
		}]
	dialogue_gain_items_option_2.dialogue_option_validators = []
	dialogue_gain_items_option_2.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	
	dialogue_gain_items._assign_option(dialogue_gain_items_option_2)
	
	# Option 3
	var dialogue_gain_items_option_3: DialogueOptionData = DialogueOptionData.new("dialogue_gain_items_option_3")
	dialogue_gain_items_option_3.dialogue_option_bbcode = "[color=purple]获得任务脚本[/color]"
	dialogue_gain_items_option_3.dialogue_option_failed_validator_bbcode = ""
	dialogue_gain_items_option_3.dialogue_option_actions = [
		# add the quest card to deck
		{
			Scripts.ACTION_ADD_CARDS_TO_DECK: {
			# create an alias to grab generated_cards from ACTION_CREATE_CARDS into picked_cards
			# so it can be added to deck
			"custom_key_names": {
				"picked_cards": "generated_cards"
			}
		}},
		# generate a quest card
		# created cards gets stored in picked_cards in CardPlayRequest shared between actions
		{
		Scripts.ACTION_CREATE_CARDS: 
			{
			"created_card_object_id": "card_quest",
			"number_of_cards": 1,
			}
		}
	]
	dialogue_gain_items_option_3.dialogue_option_validators = []
	dialogue_gain_items_option_3.dialogue_option_next_dialogue_state_id = "" # empty ends dialogue
	
	dialogue_gain_items._assign_option(dialogue_gain_items_option_3)
	
	# State 1
	var dialogue_state_gain_items_initial: DialogueStateData = DialogueStateData.new("dialogue_state_gain_items_initial")
	dialogue_state_gain_items_initial.dialogue_state_prompt_bbcode = "测试事件。选择一个选项..."
	dialogue_state_gain_items_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_gain_items.png"
	dialogue_state_gain_items_initial.add_state_dialogue_options(
		[
			dialogue_gain_items_option_1,
			dialogue_gain_items_option_2,
			dialogue_gain_items_option_3,
		]
	)
	
	dialogue_gain_items._assign_state(dialogue_state_gain_items_initial)
	dialogue_gain_items._assign_initial_state(dialogue_state_gain_items_initial)
	
	#endregion

#region Action Interceptors
func add_test_action_interceptors() -> void:
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
	
	# negates incoming non zero damage actions
	var interceptor_negate_damage: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_damage")
	interceptor_negate_damage.action_interceptor_priority = -10000
	interceptor_negate_damage.action_interceptor_modifies_parent = false
	interceptor_negate_damage.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_DAMAGE
	interceptor_negate_damage.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]
	
	Global.register_rod(interceptor_negate_damage)
	
	# rejects block reset actions
	var interceptor_preserve_block: ActionInterceptorData = ActionInterceptorData.new("interceptor_preserve_block")
	interceptor_preserve_block.action_interceptor_priority = 10000
	interceptor_preserve_block.action_interceptor_modifies_parent = false
	interceptor_preserve_block.action_interceptor_script_path = Scripts.INTERCEPTOR_PRESERVE_BLOCK
	interceptor_preserve_block.action_intercepted_action_paths = [Scripts.ACTION_RESET_BLOCK]
	
	Global.register_rod(interceptor_preserve_block)
	
	# makes the next non-zero attack cost 0
	var interceptor_next_attack_free: ActionInterceptorData = ActionInterceptorData.new("interceptor_next_attack_free")
	interceptor_next_attack_free.action_interceptor_priority = 10000
	interceptor_next_attack_free.action_interceptor_modifies_parent = true
	interceptor_next_attack_free.action_interceptor_script_path = Scripts.INTERCEPTOR_NEXT_ATTACK_FREE
	interceptor_next_attack_free.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]
	
	Global.register_rod(interceptor_next_attack_free)
	
	# rejects debuffing status actions
	var interceptor_negate_debuff: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_debuff")
	interceptor_negate_debuff.action_interceptor_priority = 10000
	interceptor_negate_debuff.action_interceptor_modifies_parent = false
	interceptor_negate_debuff.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_DEBUFF
	interceptor_negate_debuff.action_intercepted_action_paths = [Scripts.ACTION_APPLY_STATUS]
	
	Global.register_rod(interceptor_negate_debuff)
	
	# rebounds incoming card plays to the draw pile
	var interceptor_rebound_card_plays: ActionInterceptorData = ActionInterceptorData.new("interceptor_rebound_card_plays")
	interceptor_rebound_card_plays.action_interceptor_priority = 10000
	interceptor_rebound_card_plays.action_interceptor_modifies_parent = true
	interceptor_rebound_card_plays.action_interceptor_script_path = Scripts.INTERCEPTOR_REBOUND_CARD_PLAYS
	interceptor_rebound_card_plays.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]
	
	Global.register_rod(interceptor_rebound_card_plays)
	
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

func add_test_colors() -> void:
	var color_green: ColorData = ColorData.new("color_green")
	color_green.color = Color.WEB_GREEN
	color_green.color_name = "绿色"
	color_green.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_green)
	
	var color_orange: ColorData = ColorData.new("color_orange")
	color_orange.color = Color.CORAL
	color_orange.color_name = "橙色"
	color_orange.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_orange)
	
	var color_red: ColorData = ColorData.new("color_red")
	color_red.color = Color.FIREBRICK
	color_red.color_name = "红色"
	color_red.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_red)
	
	var color_blue: ColorData = ColorData.new("color_blue")
	color_blue.color = Color.ROYAL_BLUE
	color_blue.color_name = "蓝色"
	color_blue.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_blue)
	
	var color_white: ColorData = ColorData.new("color_white")
	color_white.color = Color.WHITE_SMOKE
	color_white.color_name = "白色"
	color_white.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_white)
	
	var color_purple: ColorData = ColorData.new("color_purple")
	color_purple.color = Color.REBECCA_PURPLE
	color_purple.color_name = "紫色"
	color_purple.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_purple)

#endregion

#region Keywords
func add_test_keywords() -> void:
	var keyword_block: KeywordData = KeywordData.new("keyword_block")
	keyword_block.keyword_name = "防火墙"
	keyword_block.keyword_text_bb_code = "抵消等量的伤害。"
	Global.register_rod(keyword_block)
	
	var keyword_discard: KeywordData = KeywordData.new("keyword_discard")
	keyword_discard.keyword_name = "丢弃"
	keyword_discard.keyword_text_bb_code = "放入回收站"
	Global.register_rod(keyword_discard)
	
	# status effect keywords
	var keyword_corrosion: KeywordData = KeywordData.new("keyword_corrosion")
	keyword_corrosion.keyword_name = "腐蚀"
	keyword_corrosion.keyword_status_effect_id = "status_effect_corrosion"
	keyword_corrosion.keyword_text_bb_code = "每时钟周期造成伤害"
	Global.register_rod(keyword_corrosion)
	
	var keyword_rebound_card_plays: KeywordData = KeywordData.new("keyword_rebound_card_plays")
	keyword_rebound_card_plays.keyword_name = "回弹"
	keyword_rebound_card_plays.keyword_status_effect_id = "status_effect_rebound_card_plays"
	keyword_rebound_card_plays.keyword_text_bb_code = "调用时将下一个脚本置于内存队列顶部。不影响不进入回收站的脚本。"
	Global.register_rod(keyword_rebound_card_plays)
	
	var keyword_vulnerable: KeywordData = KeywordData.new("keyword_vulnerable")
	keyword_vulnerable.keyword_name = "易伤"
	keyword_vulnerable.keyword_status_effect_id = "status_effect_vulnerable"
	keyword_vulnerable.keyword_text_bb_code = "受到的伤害增加50%"
	Global.register_rod(keyword_vulnerable)
	
	var keyword_weakness: KeywordData = KeywordData.new("keyword_weakness")
	keyword_weakness.keyword_name = "虚弱"
	keyword_weakness.keyword_status_effect_id = "status_effect_weakness"
	keyword_weakness.keyword_text_bb_code = "造成的伤害减少25%"
	Global.register_rod(keyword_weakness)
	
	var keyword_damage_increase: KeywordData = KeywordData.new("keyword_damage_increase")
	keyword_damage_increase.keyword_name = "伤害提升"
	keyword_damage_increase.keyword_status_effect_id = "status_effect_damage_increase"
	keyword_damage_increase.keyword_text_bb_code = "增加攻击伤害"
	Global.register_rod(keyword_damage_increase)
	
	var keyword_bomb: KeywordData = KeywordData.new("keyword_bomb")
	keyword_bomb.keyword_name = "炸弹"
	keyword_bomb.keyword_status_effect_id = "status_effect_bomb"
	keyword_bomb.keyword_text_bb_code = "计时结束时对所有敌人造成伤害"
	Global.register_rod(keyword_bomb)
	
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
	keyword_exhaust.keyword_text_bb_code = "用完一次直接消失。"
	Global.register_rod(keyword_exhaust)
	
	var keyword_ethereal: KeywordData = KeywordData.new("keyword_ethereal")
	keyword_ethereal.keyword_name = "虚无"
	keyword_ethereal.keyword_prefix = "[前置] "
	keyword_ethereal.keyword_text_bb_code = "时钟周期结束时，若仍在当前线程中，则会被物理删除。"
	keyword_ethereal.keyword_child_keyword_object_ids = ["keyword_exhaust"]
	Global.register_rod(keyword_ethereal)
	
	var keyword_banish: KeywordData = KeywordData.new("keyword_banish")
	keyword_banish.keyword_name = "放逐"
	keyword_banish.keyword_prefix = "[后置] "
	keyword_banish.keyword_text_bb_code = "在本场战斗中完全移除一个脚本"
	keyword_banish.keyword_child_keyword_object_ids = []
	Global.register_rod(keyword_banish)
	
	var keyword_unplayable: KeywordData = KeywordData.new("keyword_unplayable")
	keyword_unplayable.keyword_name = "不可打出"
	keyword_unplayable.keyword_prefix = "[前置] "
	keyword_unplayable.keyword_text_bb_code = "该脚本无法被主动打出。"
	Global.register_rod(keyword_unplayable)

#endregion

#region VFX Animations
func add_test_combat_vfx_animations() -> void:
	var animation_vfx_impact_default: AnimationData = AnimationData.new("animation_vfx_impact_default")
	animation_vfx_impact_default.add_vfx_animations([
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
	], 25)
	Global.register_rod(animation_vfx_impact_default)
#endregion

#region Characters

func add_test_characters() -> void:
	var character_color: String = "" # used to make writing boilerplate colors faster
	
	# red character
	character_color = "red"
	var character_red: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_red.character_player_id = "player_{0}".format([character_color])
	character_red.character_name = "红色进程"
	character_red.character_description = "曾参与红色战争"
	character_red.character_color_id = "color_{0}".format([character_color])
	character_red.character_icon_texture_path = "external/sprites/characters/character_{0}/character_{0}_icon.png".format([character_color])
	
	character_red.character_starting_health = 80
	character_red.character_starting_artifact_ids = ["artifact_block_on_attacks"]
	character_red.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_red.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_red.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_red.character_starting_card_object_ids = [
		"card_attack_basic", "card_attack_basic", "card_attack_basic",
		"card_block_basic", "card_block_basic", "card_block_basic",
		"card_attack_all",
		"card_attack_in_center",
		"card_attack_money_on_lethal",
		"card_next_attack_free",
		"card_law", "card_law",
		#"card_requires_adjacency",
		"card_attack_with_conditional_block",
		#"card_attack_number_of_cards_played","card_attack_number_of_cards_played","card_attack_number_of_cards_played",
		"card_damage_increase", "card_attack_ignore_damage_increase",
		# "card_block_without_attacks",
		"card_weaken_enemies", "card_vulnerable_enemies", "card_grant_energy",
		#"card_add_consumable", "card_upgrade_entire_deck", "card_attack_increase_cost_on_damage_taken",
		"card_right_click_transform_mode_a",
	]
	character_red.character_starting_card_draft_card_pack_ids = ["card_pack_red"]
	
	Global.register_rod(character_red)
	
	# red character animations
	var animation_character_red: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_red.character_animation_id = animation_character_red.object_id
	animation_character_red.add_combatant_animations(
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		)
	
	Global.register_rod(animation_character_red)
	
	# blue character
	character_color = "blue"
	var character_blue: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_blue.character_player_id = "player_{0}".format([character_color])
	character_blue.character_name = "蓝色进程"
	character_blue.character_description = "要是变成绿色就会死。"
	character_blue.character_color_id = "color_{0}".format([character_color])
	character_blue.character_icon_texture_path = "external/sprites/characters/character_{0}/character_{0}_icon.png".format([character_color])
	
	character_blue.character_starting_health = 70
	character_blue.character_starting_artifact_ids = ["artifact_see_top_of_draw_pile"]
	character_blue.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_blue.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_blue.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_blue.character_starting_card_object_ids = [
		#"card_attack_basic", "card_attack_basic", "card_attack_basic",
		#"card_block_basic", "card_block_basic", "card_block_basic",
		"card_improving_retain_block", "card_randomize_hand_energy_costs", "card_attack_corrosion",
		 "card_end_turn", "card_add_health", "card_transform_hand", "card_reshuffle_draw",
		 "card_duplicate_attacks", "card_attack_heal_unblocked_damage", "card_attack_rng",
	]
	
	Global.register_rod(character_blue)
	
	# blue character animations
	var animation_character_blue: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_blue.character_animation_id = animation_character_blue.object_id
	animation_character_blue.add_combatant_animations(
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		)
	
	Global.register_rod(animation_character_blue)
	
	# green character
	character_color = "green"
	var character_green: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_green.character_player_id = "player_{0}".format([character_color])
	character_green.character_name = "绿色进程"
	character_green.character_description = "在披萨上放菠萝"
	character_green.character_color_id = "color_{0}".format([character_color])
	character_green.character_icon_texture_path = "external/sprites/characters/character_{0}/character_{0}_icon.png".format([character_color])
	
	character_green.character_starting_health = 75
	character_green.character_starting_artifact_ids = ["artifact_draw_on_combat_start"]
	character_green.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_green.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_green.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_green.character_starting_card_object_ids = [
		"card_attack_basic", "card_attack_basic", "card_attack_basic",
		#"card_block_basic", "card_block_basic", "card_block_basic",
		#"card_attack_variable_cost", "card_discard_block", "card_attack_corrosion", "card_energy_on_discard",
		"card_custom_block", "card_attack_lower_cost_on_discard", "card_preserve_block",
		"card_duplicate_plays", "card_draft_random_attack",
	]
	
	Global.register_rod(character_green)
	
	# green character animations
	var animation_character_green: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_green.character_animation_id = animation_character_green.object_id
	animation_character_green.add_combatant_animations(
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		)
	
	Global.register_rod(animation_character_green)
	
	# orange character
	character_color = "orange"
	var character_orange: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_orange.character_player_id = "player_{0}".format([character_color])
	character_orange.character_name = "橙色进程"
	character_orange.character_description = "有一段悲惨的过往"
	character_orange.character_color_id = "color_{0}".format([character_color])
	character_orange.character_icon_texture_path = "external/sprites/characters/character_{0}/character_{0}_icon.png".format([character_color])

	character_orange.character_starting_health = 70
	character_orange.character_starting_artifact_ids = ["artifact_increase_attack_on_rest", "artifact_see_top_of_draw_pile"]
	character_orange.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_orange.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_orange.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_orange.character_starting_card_object_ids = [
		"card_attack_basic", "card_attack_basic", "card_attack_basic",
		"card_restart_combat",
		"card_block_basic", "card_block_basic", "card_block_basic",
		"card_retain_hand", "card_play_from_discard", "card_draw", "card_energy_on_draw",
		"card_improving_block", "card_attack_improve_on_lethal", "card_play_random_cards_from_hand", "card_bomb",
		"card_add_to_draw_from_discard", "card_add_to_draw_from_discard", "card_banish_attack",
	]
	
	Global.register_rod(character_orange)
	
	# orange animations
	var animation_character_orange: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_orange.character_animation_id = animation_character_orange.object_id
	animation_character_orange.add_combatant_animations(
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		["external/sprites/characters/character_{0}/character_{0}.png".format([character_color])],
		)
	
	Global.register_rod(animation_character_orange)
	
#endregion

#region Run Modifiers

func add_test_run_modifiers() -> void:
	### Standard Difficulty Run Modifiers
	var run_modifier_difficulty_0: RunModifierData = RunModifierData.new("run_modifier_difficulty_0")
	run_modifier_difficulty_0.run_modifier_name = "基础难度"
	run_modifier_difficulty_0.run_modifier_modifier_script_path = ""

	Global.register_rod(run_modifier_difficulty_0)
	
	var run_modifier_difficulty_1: RunModifierData = RunModifierData.new("run_modifier_difficulty_1")
	run_modifier_difficulty_1.run_modifier_name = "难度1: 强化普通敌人"
	run_modifier_difficulty_1.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_1

	Global.register_rod(run_modifier_difficulty_1)
	
	var run_modifier_difficulty_2: RunModifierData = RunModifierData.new("run_modifier_difficulty_2")
	run_modifier_difficulty_2.run_modifier_name = "难度 2：强化精英怪"
	run_modifier_difficulty_2.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_2

	Global.register_rod(run_modifier_difficulty_2)
	
	var run_modifier_difficulty_3: RunModifierData = RunModifierData.new("run_modifier_difficulty_3")
	run_modifier_difficulty_3.run_modifier_name = "难度3: 强化Boss"
	run_modifier_difficulty_3.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_3

	Global.register_rod(run_modifier_difficulty_3)
	
	var run_modifier_difficulty_4: RunModifierData = RunModifierData.new("run_modifier_difficulty_4")
	run_modifier_difficulty_4.run_modifier_name = "难度4"
	run_modifier_difficulty_4.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_4

	Global.register_rod(run_modifier_difficulty_4)
	
	var run_modifier_difficulty_5: RunModifierData = RunModifierData.new("run_modifier_difficulty_5")
	run_modifier_difficulty_5.run_modifier_name = "难度5"
	run_modifier_difficulty_5.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_5

	Global.register_rod(run_modifier_difficulty_5)
	
	# register the modifiers as standard difficulty
	Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS.append_array([
		run_modifier_difficulty_0.object_id,
		run_modifier_difficulty_1.object_id,
		run_modifier_difficulty_2.object_id,
		run_modifier_difficulty_3.object_id,
		run_modifier_difficulty_4.object_id,
		run_modifier_difficulty_5.object_id,
	])
	
	### Custom Run Modifiers
	var run_modifier_custom_easy_mode: RunModifierData = RunModifierData.new("run_modifier_custom_easy_mode")
	run_modifier_custom_easy_mode.run_modifier_name = "安全模式"
	run_modifier_custom_easy_mode.run_modifier_description = "[作弊] 将最大能量上限修改为99。并在首个时钟周期，强制将遭遇的所有敌方进程的最大完整度锁定为1。"
	run_modifier_custom_easy_mode.run_modifier_is_custom =  true
	run_modifier_custom_easy_mode.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_custom_easy_mode.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_EASYMODE

	Global.register_rod(run_modifier_custom_easy_mode)
	
	var run_modifier_endless_mode: RunModifierData = RunModifierData.new("run_modifier_endless_mode")
	run_modifier_endless_mode.run_modifier_name = "死循环模式"
	run_modifier_endless_mode.run_modifier_description = "突破系统防线，通关第3节点后游戏不会结束，您将带着现有配置继续深入，直至核心被摧毁。"
	run_modifier_endless_mode.run_modifier_is_custom =  true
	run_modifier_endless_mode.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_endless_mode.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_ENDLESS_MODE

	Global.register_rod(run_modifier_endless_mode)
	
	var run_modifier_draft_all_colors: RunModifierData = RunModifierData.new("run_modifier_draft_all_colors")
	run_modifier_draft_all_colors.run_modifier_name = "跨域授权"
	run_modifier_draft_all_colors.run_modifier_description = "解除隔离协议。在挑选脚本奖励时，系统将无视您的当前角色权限，提供来自所有角色的脚本。"
	run_modifier_draft_all_colors.run_modifier_is_custom =  true
	run_modifier_draft_all_colors.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_draft_all_colors.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_DRAFT_ALL_COLORS

	Global.register_rod(run_modifier_draft_all_colors)
	
	### Automatic Modifiers
	
	# this allows for auto revive consumables to work each run
	var run_modifier_consumable_auto_revive: RunModifierData = RunModifierData.new("run_modifier_consumable_auto_revive")
	run_modifier_consumable_auto_revive.run_modifier_name = "自动复活"
	run_modifier_consumable_auto_revive.run_modifier_description = "自动使用复活物理删除品"
	run_modifier_consumable_auto_revive.run_modifier_is_automatic = true # registered regardless of difficulty
	run_modifier_consumable_auto_revive.run_modifier_modifier_script_path = Scripts.BASE_RUN_MODIFIER # does nothing
	run_modifier_consumable_auto_revive.run_modifier_interceptor_ids = ["interceptor_consumable_auto_revive"] # ensures auto revive always active
	
	Global.register_rod(run_modifier_consumable_auto_revive)
	
#endregion

#region Run Start Options

func add_test_run_start_options() -> void:
	### Downsides
	# remove max hp
	var run_start_option_reduce_max_hp: RunStartOptionData = RunStartOptionData.new("run_start_option_reduce_max_hp")
	run_start_option_reduce_max_hp.run_start_option_bb_code = "[color=red]失去10点最大完整度[/color]"
	run_start_option_reduce_max_hp.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_reduce_max_hp.run_start_option_actions = [{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -10}}]
	
	Global.register_rod(run_start_option_reduce_max_hp)
	
	# take damage
	var run_start_option_take_damage: RunStartOptionData = RunStartOptionData.new("run_start_option_take_damage")
	run_start_option_take_damage.run_start_option_bb_code = "[color=red]失去5点完整度[/color]"
	run_start_option_take_damage.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_take_damage.run_start_option_actions = [{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -5}}]

	Global.register_rod(run_start_option_take_damage)
	
	# lose all money
	var run_start_option_lose_money: RunStartOptionData = RunStartOptionData.new("run_start_option_lose_money")
	run_start_option_lose_money.run_start_option_bb_code = "[color=red]失去所有数据币[/color]"
	run_start_option_lose_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_lose_money.run_start_option_actions = [{Scripts.ACTION_ADD_MONEY: {"money_amount": -1000}}]

	Global.register_rod(run_start_option_lose_money)
	
	
	### Upsides
	# add money
	var run_start_option_add_money: RunStartOptionData = RunStartOptionData.new("run_start_option_add_money")
	run_start_option_add_money.run_start_option_bb_code = "[color=green]获得50数据币[/color]"
	run_start_option_add_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_add_money.run_start_option_actions = [{Scripts.ACTION_ADD_MONEY: {"money_amount": 50}}]

	Global.register_rod(run_start_option_add_money)
	
	# gain max hp
	var run_start_option_gain_max_hp: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_max_hp")
	run_start_option_gain_max_hp.run_start_option_bb_code = "[color=green]获得10点最大完整度[/color]"
	run_start_option_gain_max_hp.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_max_hp.run_start_option_actions = [{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 10, "health_max_amount": 10}}]
	
	Global.register_rod(run_start_option_gain_max_hp)
	
	# gain a random common artifact
	var run_start_option_gain_common_artifact: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_common_artifact")
	run_start_option_gain_common_artifact.run_start_option_bb_code = "[color=green]获得随机普通外设插件[/color]"
	run_start_option_gain_common_artifact.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_common_artifact.run_start_option_actions = [{Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL:
		{
		"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
		"artifact_count": 1,
		"artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON]
		}
		}]
	
	Global.register_rod(run_start_option_gain_common_artifact)
	
	# draft a card from player's pool
	# functions identically to a standard draft
	var run_start_option_draft_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_card")
	run_start_option_draft_card.run_start_option_bb_code = "[color=green]选取一个脚本[/color]"
	run_start_option_draft_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_card.run_start_option_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": ActionBasePickCards.PICK_DRAFT,
			"pick_draft_cards": false,
			"draft_from_card_pool": true,
			"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
			# use same rng as player drafting so it counts as draft
			"rng_name": "rng_card_drafting",
			"validator_data": [], # this should always be empty if draft_use_player_draft = true
			# weighted draft from player draft pool with pity system
			"draft_use_player_draft": true,
			"draft_is_weighted": false,
			"draft_use_pity_system": false,
			}
		}
	]
	
	Global.register_rod(run_start_option_draft_card)
	
	# draft common card available to the player
	# this uses validators to scan the entire card pool for a draft
	# you could also use a card pack to achieve a similar effect
	var run_start_option_draft_common_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_common_card")
	run_start_option_draft_common_card.run_start_option_bb_code = "[color=green]选取一个开源脚本[/color]"
	run_start_option_draft_common_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_common_card.run_start_option_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": ActionBasePickCards.PICK_DRAFT,
			"pick_draft_cards": false,
			"draft_from_card_pool": true,
			"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
			"validator_data": [
				{Scripts.VALIDATOR_CARD_RARITY: {"card_rarities": [CardData.CARD_RARITIES.COMMON]}},
				{Scripts.VALIDATOR_CARD_DRAFTABLE: {}},
			],
			# use same rng as player drafting so it counts as draft
			"rng_name": "rng_card_drafting",
			"draft_use_player_draft": false, # this should always be false if using a validator based draft
			"draft_is_weighted": false,
			"draft_use_pity_system": false,
			}
		}
	]
	
	Global.register_rod(run_start_option_draft_common_card)
	
	# draft a colorless card from the white card pack
	var run_start_option_draft_colorless_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_colorless_card")
	run_start_option_draft_colorless_card.run_start_option_bb_code = "[color=green]选取一个无色脚本[/color]"
	run_start_option_draft_colorless_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_colorless_card.run_start_option_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": ActionBasePickCards.PICK_DRAFT,
			"pick_draft_cards": false,
			"draft_from_card_pool": true,
			"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
			"validator_data": [],
			# use same rng as player drafting so it counts as draft
			"rng_name": "rng_card_drafting",
			# get white cards
			"draft_card_pack_id": "card_pack_white"
			}
		}
	]
	
	Global.register_rod(run_start_option_draft_colorless_card)
	
	### Complete
	
	# replace starting artifact with a random boss one
	var run_start_option_artifact_swap: RunStartOptionData = RunStartOptionData.new("run_start_option_artifact_swap")
	run_start_option_artifact_swap.run_start_option_bb_code = "[color=green]将初始外设插件替换为Boss外设插件[/color]"
	run_start_option_artifact_swap.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_artifact_swap.run_start_option_actions = [{Scripts.ACTION_SWAP_BOSS_ARTIFACT: {}}]
	
	Global.register_rod(run_start_option_artifact_swap)
	
#endregion

#region Custom UI

func add_test_custom_ui() -> void:
	var custom_ui_see_top_of_draw_pile: CustomUIData = CustomUIData.new("custom_ui_see_top_of_draw_pile")
	custom_ui_see_top_of_draw_pile.custom_ui_asset_path = "res://scenes/ui/custom/CustomUISeeTopOfDrawPile.tscn"
	# custom_ui_see_top_of_draw_pile.custom_ui_requires_target = true
	Global.register_rod(custom_ui_see_top_of_draw_pile)

#endregion

#region Custom UI

func add_test_custom_signals() -> void:
	var custom_signal_special_discard: CustomSignalData = CustomSignalData.new("custom_signal_special_discard")
	custom_signal_special_discard.custom_signal_is_stat = true
	custom_signal_special_discard.custom_signal_stat_name = "CUSTOM_STAT_SPECIAL_DISCARD"
	Global.register_rod(custom_signal_special_discard)


#endregion

#region Enemies
func add_test_enemies() -> void:
	const DIFFICULTY_STARTING: int = 0
	const DIFFICULTY_STANDARD_ENEMIES_HARDER: int = 1
	const DIFFICULTY_MINIBOSS_ENEMIES_HARDER: int = 2
	const DIFFICULTY_BOSS_ENEMIES_HARDER: int = 3
	
	# enemy that negates the first damage instance against it
	var enemy_1: EnemyData = EnemyData.new("enemy_1")
	enemy_1.enemy_name = "红色敌人"
	enemy_1.add_health_bounds(17, 20)
	enemy_1.add_health_bounds(25, 30, DIFFICULTY_STANDARD_ENEMIES_HARDER) # gets more health on later difficulty
	enemy_1.enemy_initial_status_effects = {"status_effect_negate_damage": 1}
	enemy_1.enemy_texture_path = "external/sprites/enemies/enemy_red_small.png"
	# initial dummy state used to map initial attack pattern weights on starting combat
	enemy_1.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	# an attack that hits harder on higher difficulties
	enemy_1.add_intent_state([
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 5, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STANDARD_ENEMIES_HARDER, 6, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	enemy_1.add_intent_state([
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 3, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STANDARD_ENEMIES_HARDER, 4, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
		
	var _enemy_1_anim: AnimationData = enemy_1.add_standard_animations(
		["external/sprites/enemies/enemy_red_small.png"]
	)

	Global.register_rod(enemy_1)
	
	# enemy that negates the first debuff against it
	var enemy_2: EnemyData = EnemyData.new("enemy_2")
	enemy_2.enemy_name = "蓝色敌人"
	enemy_2.add_health_bounds(5, 7)
	enemy_2.add_health_bounds(8, 12, DIFFICULTY_STANDARD_ENEMIES_HARDER) # gets more health on later difficulty
	enemy_2.enemy_initial_status_effects = {"status_effect_negate_debuff": 1}
	enemy_2.enemy_texture_path = "external/sprites/enemies/enemy_blue_small.png"
	enemy_2.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1})
		])
	enemy_2.add_intent_state([
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 5, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STANDARD_ENEMIES_HARDER, 6, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	enemy_2.add_intent_state([
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 3, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STANDARD_ENEMIES_HARDER, 4, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
		
	var _enemy_2_anim: AnimationData = enemy_2.add_standard_animations(
		["external/sprites/enemies/enemy_blue_small.png"]
	)
	
	Global.register_rod(enemy_2)
	
	# enemy that applies poison to everyone on death
	var enemy_3: EnemyData = EnemyData.new("enemy_3")
	enemy_3.add_health_bounds(15, 25)
	enemy_3.add_health_bounds(25, 35, DIFFICULTY_STANDARD_ENEMIES_HARDER) # gets more health on later difficulty
	enemy_3.enemy_name = "绿色敌人"
	enemy_3.enemy_texture_path = "external/sprites/enemies/enemy_green_small.png"
	enemy_3.enemy_actions_on_death = [
		{
		Scripts.ACTION_APPLY_STATUS: {"status_charge_amount": 5, "status_effect_object_id": "status_effect_corrosion", "time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS}
		}
	]
	enemy_3.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	enemy_3.add_intent_state([
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 5, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STANDARD_ENEMIES_HARDER, 7, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	enemy_3.add_intent_state([
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 3, 2, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STANDARD_ENEMIES_HARDER, 3, 3, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
	])
	
	var _enemy_3_anim: AnimationData = enemy_3.add_standard_animations(
		["external/sprites/enemies/enemy_green_small.png"]
	)
	
	Global.register_rod(enemy_3)
	
	# enemy that applies vulnerable to player
	var enemy_4: EnemyData = EnemyData.new("enemy_4")
	enemy_4.add_health_bounds(37, 43)
	enemy_4.add_health_bounds(47, 53, DIFFICULTY_STANDARD_ENEMIES_HARDER) # gets more health on later difficulty
	enemy_4.enemy_name = "强攻敌人"
	enemy_4.enemy_texture_path = "external/sprites/enemies/enemy_purple_medium.png"
	enemy_4.enemy_actions_on_death = [
	{
	Scripts.ACTION_APPLY_STATUS: {"status_charge_amount": 5, "status_effect_object_id": "status_effect_corrosion", "time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS}
	}
	]
	enemy_4.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_vulnerable": 1})
		])
	var enemy_4_status_charge_1: int = 2
	var enemy_4_status_actions_1: Array[Dictionary] = [{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": enemy_4_status_charge_1, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}]
	var enemy_4_status_charge_2: int = 4
	var enemy_4_status_actions_2: Array[Dictionary] = [{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": enemy_4_status_charge_2, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}]
	enemy_4.add_intent_state([
		EnemyIntentData.new("intent_attack_vulnerable", DIFFICULTY_STARTING, 10, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_multi": 1}, enemy_4_status_actions_1),
		EnemyIntentData.new("intent_attack_vulnerable", DIFFICULTY_STANDARD_ENEMIES_HARDER, 12, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_multi": 1}, enemy_4_status_actions_2),
	])
	enemy_4.add_intent_state([
		EnemyIntentData.new("intent_attack_multi", DIFFICULTY_STARTING, 5, 2, "animation_vfx_impact_default", 0, "", {"intent_block": 1}),
		EnemyIntentData.new("intent_attack_multi", DIFFICULTY_STANDARD_ENEMIES_HARDER, 6, 2, "animation_vfx_impact_default", 0, "", {"intent_block": 1}),
		])
	enemy_4.add_intent_state([
		EnemyIntentData.new("intent_block", DIFFICULTY_STARTING, 0, 0, "", 10, "", {"intent_attack_vulnerable": 1}),
		EnemyIntentData.new("intent_block", DIFFICULTY_STANDARD_ENEMIES_HARDER, 0, 0, "", 12, "", {"intent_attack_vulnerable": 1}),
	])
	
	var _enemy_4_anim: AnimationData = enemy_4.add_standard_animations(
		["external/sprites/enemies/enemy_purple_medium.png"]
	)
	
	Global.register_rod(enemy_4)
	
	var enemy_act_1_miniboss_1: EnemyData = EnemyData.new("enemy_act_1_miniboss_1")
	enemy_act_1_miniboss_1.add_health_bounds(100,100)
	enemy_act_1_miniboss_1.add_health_bounds(120,120, DIFFICULTY_MINIBOSS_ENEMIES_HARDER) # gets more health on later difficulty
	enemy_act_1_miniboss_1.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_1_miniboss_1.enemy_name = "第1章精英怪"
	enemy_act_1_miniboss_1.enemy_texture_path = "external/sprites/enemies/enemy_green_medium.png"
	enemy_act_1_miniboss_1.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1})
	])
	enemy_act_1_miniboss_1.add_intent_state([
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 18, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 22, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	enemy_act_1_miniboss_1.add_intent_state([
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 8, 2, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 10, 2, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	
	var _enemy_act_1_miniboss_1_anim: AnimationData = enemy_act_1_miniboss_1.add_standard_animations(
		["external/sprites/enemies/enemy_green_medium.png"]
	)
	
	Global.register_rod(enemy_act_1_miniboss_1)
	
	var enemy_act_1_miniboss_2: EnemyData = EnemyData.new("enemy_act_1_miniboss_2")
	enemy_act_1_miniboss_2.add_health_bounds(45, 55)
	enemy_act_1_miniboss_2.add_health_bounds(70, 80, DIFFICULTY_MINIBOSS_ENEMIES_HARDER) # gets more health on later difficulty
	enemy_act_1_miniboss_2.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_1_miniboss_2.enemy_name = "第1章精英怪"
	enemy_act_1_miniboss_2.enemy_texture_path = "external/sprites/enemies/enemy_red_medium.png"
	enemy_act_1_miniboss_2.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1})
		])
	enemy_act_1_miniboss_2.add_intent_state([
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 8, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_1", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 10, 1, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	enemy_act_1_miniboss_2.add_intent_state([
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 4, 2, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		EnemyIntentData.new("intent_attack_2", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 5, 2, "animation_vfx_impact_default", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		])
	
	var _enemy_act_1_miniboss_2_anim: AnimationData = enemy_act_1_miniboss_2.add_standard_animations(
		["external/sprites/enemies/enemy_red_medium.png"]
	)
	
	Global.register_rod(enemy_act_1_miniboss_2)
	
	# boss that summons minions
	var enemy_act_1_boss_1: EnemyData = EnemyData.new("enemy_act_1_boss_1")
	enemy_act_1_boss_1.add_health_bounds(200, 200)
	enemy_act_1_boss_1.add_health_bounds(250, 250, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_act_1_boss_1.enemy_type = EnemyData.ENEMY_TYPES.BOSS
	enemy_act_1_boss_1.enemy_name = "第1章Boss"
	enemy_act_1_boss_1.enemy_texture_path =  "external/sprites/enemies/enemy_red_large.png"
	enemy_act_1_boss_1.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_summon": 1})
		])
	var enemy_act_1_boss_1_summon_actions: Array[Dictionary] = [
				{
				Scripts.ACTION_SUMMON_ENEMIES: {"number_of_spawns": 2, "spawn_slots": [1,2], "time_delay": 0.5, "random_enemy_object_ids": ["enemy_minion_1", "enemy_minion_2"], "target_override": BaseAction.TARGET_OVERRIDES.PARENT}
				}
			]
	enemy_act_1_boss_1.add_intent_state([
		EnemyIntentData.new("intent_summon", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1}, enemy_act_1_boss_1_summon_actions)
		])
	enemy_act_1_boss_1.add_intent_state([
		EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 3, 2, "animation_vfx_impact_default", 7, "", {"intent_attack": 1}),
		EnemyIntentData.new("intent_attack", DIFFICULTY_BOSS_ENEMIES_HARDER, 5, 2, "animation_vfx_impact_default", 7, "", {"intent_attack": 1}),
	])
	
	var _enemy_act_1_boss_1_anim: AnimationData = enemy_act_1_boss_1.add_standard_animations(
		["external/sprites/enemies/enemy_red_large.png"]
	)
	
	Global.register_rod(enemy_act_1_boss_1)
	
	# example of minion enemy
	var enemy_minion_1: EnemyData = EnemyData.new("enemy_minion_1")
	enemy_minion_1.add_health_bounds(4, 4)
	enemy_minion_1.add_health_bounds(7, 7, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_minion_1.enemy_name = "仆从 1"
	enemy_minion_1.enemy_texture_path = "external/sprites/enemies/enemy_purple_small.png"
	enemy_minion_1.enemy_is_minion = true
	enemy_minion_1.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1})
	])
	enemy_minion_1.add_intent_state([
		EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 5, 1, "animation_vfx_impact_default", 0, "", {"intent_attack": 1}),
		EnemyIntentData.new("intent_attack", DIFFICULTY_BOSS_ENEMIES_HARDER, 8, 1, "animation_vfx_impact_default", 5, "", {"intent_attack": 1}),
		])
	
	var _enemy_minion_1_anim: AnimationData = enemy_minion_1.add_standard_animations(
		["external/sprites/enemies/enemy_purple_small.png"]
	)
	
	Global.register_rod(enemy_minion_1)
	
	# example of minion enemy
	var enemy_minion_2: EnemyData = EnemyData.new("enemy_minion_2")
	enemy_minion_2.add_health_bounds(3, 5)
	enemy_minion_2.add_health_bounds(6, 8, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_minion_2.enemy_name = "仆从 2"
	enemy_minion_2.enemy_texture_path = "external/sprites/enemies/enemy_green_small.png"
	enemy_minion_2.enemy_is_minion = true
	enemy_minion_2.add_intent_state([
		EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1})
		])
	enemy_minion_2.add_intent_state([
		EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 3, 1, "animation_vfx_impact_default", 5, "", {"intent_attack": 1}),
		EnemyIntentData.new("intent_attack", DIFFICULTY_BOSS_ENEMIES_HARDER, 5, 1, "animation_vfx_impact_default", 5, "", {"intent_attack": 1}),
		])
	
	var _enemy_minion_2_anim: AnimationData = enemy_minion_2.add_standard_animations(
		["external/sprites/enemies/enemy_green_small.png"]
	)
	
	Global.register_rod(enemy_minion_2)

#endregion

#region Player Data Prototypes
func add_test_player_data() -> void:
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
func add_test_card_decorators() -> void:
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
	card_decorator_block_on_play.card_decorator_texture_path = "sprites/card-borders/purple_decorator.png"
	card_decorator_block_on_play.card_decorator_value_improvements = {
		"decorator_value_block": 5
	}
	card_decorator_block_on_play.card_decorator_pre_description = "[center][color=purple]Block [decorator_value_block][/color][/center]\n"
	card_decorator_block_on_play.card_decorator_label_value_name = "decorator_value_block"
	card_decorator_block_on_play.card_decorator_add_keyword_ids = ["keyword_block"]
	card_decorator_block_on_play.card_decorator_pre_play_actions = 	[
	{
	Scripts.ACTION_BLOCK: 
		{
			# convert the decorator's block into actual block
			"custom_key_names": {"block": "decorator_value_block"},
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	}]
	Global.register_rod(card_decorator_block_on_play)
	
	# decorator that removes exhaust from a card
	# should be combined with a validator to prevent it from being applied to a non exhausting card
	var card_decorator_remove_exhaust: CardDecoratorData = CardDecoratorData.new("card_decorator_remove_exhaust")
	card_decorator_remove_exhaust.card_decorator_texture_path = "sprites/card-borders/yellow_decorator.png"
	card_decorator_remove_exhaust.card_decorator_property_changes = {
		"card_play_destination": HandManager.DISCARD_PILE
	}
	Global.register_rod(card_decorator_remove_exhaust)
	
	# decorator that draws extra cards when the card is drawn the first time
	# applies a custom decorator value to the card and displays the number on the decorator
	var card_decorator_extra_draw: CardDecoratorData = CardDecoratorData.new("card_decorator_extra_draw")
	card_decorator_extra_draw.card_decorator_texture_path = "sprites/card-borders/green_decorator.png"
	card_decorator_extra_draw.card_decorator_value_changes = {
		# add a flag to the card used to check for first time
		"decorator_value_extra_draw": 2
	}
	card_decorator_extra_draw.card_decorator_post_description = "[center][color=green]首次抽到时，抽取 2 个脚本。[/color][/center]\n"
	card_decorator_extra_draw.card_decorator_label_value_name = "decorator_value_extra_draw"
	card_decorator_extra_draw.card_decorator_post_draw_actions = [
		{
			# check flag when drawn
			Scripts.ACTION_VALIDATOR: {
				"validator_data":
				[
					{
					Scripts.VALIDATOR_CARD_VALUES: 
						{
						"card_value_name": "decorator_value_extra_draw",
						"operator": ">",
						"comparison_value": 0,
						"invert_validation": false,
						}
					}
				],
				# draw cards and change flag
				"passed_action_data": 
				[
					{
					Scripts.ACTION_CHANGE_CARD_VALUES: {
						"pick_played_card": true,
						"modify_parent_card": false,
						"new_card_values": {"decorator_value_extra_draw": 0}
						},
					},
					{Scripts.ACTION_DRAW_GENERATOR: {
						# alias the extra draw count
						"custom_key_names": {"draw_count": "decorator_value_extra_draw"}
					}},
				]
			}
		}
		]
	Global.register_rod(card_decorator_extra_draw)
#endregion

#region Cards

## Adds test copies of cards to the player's deck to populate it
func add_test_cards_to_player_deck() -> void:
	Global.player_data.player_deck.append(Global.get_card_data_from_prototype("card_attack_basic"))
	Global.player_data.player_deck.append(Global.get_card_data_from_prototype("card_damage_increase"))
	Global.player_data.player_deck.append(Global.get_card_data_from_prototype("card_preserve_block"))
	Global.player_data.player_deck.append(Global.get_card_data_from_prototype("card_custom_block"))

## Adds test cards to game
func add_test_cards() -> void:
	# Basic attack card
	# also plays an animation
	var card_attack_basic: CardData = CardData.new("card_attack_basic")
	card_attack_basic.card_name = "基础攻击"
	card_attack_basic.card_color_id = "color_white"
	card_attack_basic.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_attack_basic.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害"
	card_attack_basic.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_basic.card_rarity = CardData.CARD_RARITIES.BASIC
	card_attack_basic.card_keyword_object_ids = []
	card_attack_basic.card_values = {"damage": 20, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_attack_basic.card_upgrade_value_improvements = {"damage": 1, "number_of_attacks": 1}
	card_attack_basic.card_play_actions = [{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
	}]
	
	Global.register_rod(card_attack_basic)
	
	# Attack card with rng damage
	var card_attack_rng: CardData = CardData.new("card_attack_rng")

	card_attack_rng.card_name = "随机攻击"
	card_attack_rng.card_color_id = "color_blue"
	card_attack_rng.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_attack_rng.card_description = "造成 [damage] + [damage_random] 点伤害"
	card_attack_rng.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_rng.card_rarity = CardData.CARD_RARITIES.COMMON
	card_attack_rng.card_keyword_object_ids = []
	card_attack_rng.card_values = {"damage": 10, "number_of_attacks": 1, "damage_random": 5, "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_attack_rng.card_upgrade_value_improvements = {"damage_random": 5}
	card_attack_rng.card_play_actions = [{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
	}]
	
	Global.register_rod(card_attack_rng)
	
	# Attack card that applies poison like effect
	var card_attack_corrosion: CardData = CardData.new("card_attack_corrosion")
	card_attack_corrosion.card_name = "腐蚀"
	card_attack_corrosion.card_color_id = "color_green"
	card_attack_corrosion.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_attack_corrosion.card_description = "造成 [damage] 点伤害并附加 [status_charge_amount] 层腐蚀"
	card_attack_corrosion.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_corrosion.card_rarity = CardData.CARD_RARITIES.COMMON
	card_attack_corrosion.card_keyword_object_ids = ["keyword_corrosion"]
	card_attack_corrosion.card_values = {"damage": 5, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default", "status_charge_amount": 5, "status_effect_object_id": "status_effect_corrosion"}
	card_attack_corrosion.card_upgrade_value_improvements = {"status_charge_amount": 3}
	card_attack_corrosion.card_play_actions = [
	{
	Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5}
	},
	{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
	}
	]
	
	Global.register_rod(card_attack_corrosion)
	
	# Card that applies a bomb like effect
	# Demonstrates statuses that can be applied multiple times
	var card_bomb: CardData = CardData.new("card_bomb")
	card_bomb.card_name = "炸弹"
	card_bomb.card_color_id = "color_green"
	card_bomb.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_bomb.card_description = "[status_charge_amount] 时钟周期后对所有敌人造成 [status_secondary_charge_amount] 点伤害"
	card_bomb.card_requires_target = false
	card_bomb.card_type = CardData.CARD_TYPES.SKILL
	card_bomb.card_rarity = CardData.CARD_RARITIES.COMMON
	card_bomb.card_keyword_object_ids = ["keyword_bomb"]
	card_bomb.card_values = {"status_charge_amount": 3, "status_secondary_charge_amount": 30, "status_effect_object_id": "status_effect_bomb", "status_force_apply_new_effect": true}
	card_bomb.card_upgrade_value_improvements = {"status_secondary_charge_amount": 20}
	card_bomb.card_play_actions = [{Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}]
	
	Global.register_rod(card_bomb)
	
	# Card that will duplicate the first <charge count> cards played each turn
	var card_duplicate_plays: CardData = CardData.new("card_duplicate_plays")
	card_duplicate_plays.card_name = "双重调用"
	card_duplicate_plays.card_color_id = "color_green"
	card_duplicate_plays.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_duplicate_plays.card_description = "每时钟周期复制调用的第一个脚本"
	card_duplicate_plays.card_requires_target = false
	card_duplicate_plays.card_rarity = CardData.CARD_RARITIES.RARE
	card_duplicate_plays.card_type = CardData.CARD_TYPES.POWER
	card_duplicate_plays.card_play_destination = HandManager.BANISH_PILE # powers banish
	card_duplicate_plays.card_keyword_object_ids = []
	card_duplicate_plays.card_values = {"status_charge_amount": 1, "status_secondary_charge_amount": 0, "status_effect_object_id": "status_effect_duplicate_card_plays"}
	card_duplicate_plays.card_upgrade_value_improvements = {"status_charge_amount": 3}
	card_duplicate_plays.card_play_actions = [{Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}]
	
	Global.register_rod(card_duplicate_plays)
	
	# Card that will make the next standard card plays rebound to top of draw pile 
	var card_rebound_card_plays: CardData = CardData.new("card_rebound_card_plays")
	card_rebound_card_plays.card_name = "回弹"
	card_rebound_card_plays.card_color_id = "color_blue"
	card_rebound_card_plays.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_rebound_card_plays.card_description = "本时钟周期将接下来调用的 [status_charge_amount] 个脚本放到内存队列顶部"
	card_rebound_card_plays.card_requires_target = false
	card_rebound_card_plays.card_type = CardData.CARD_TYPES.SKILL
	card_rebound_card_plays.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_rebound_card_plays.card_keyword_object_ids = ["keyword_rebound_card_plays"]
	card_rebound_card_plays.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_rebound_card_plays"}
	card_rebound_card_plays.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_rebound_card_plays.card_play_actions = [{Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}]
	
	Global.register_rod(card_rebound_card_plays)
	
	# Card that will duplicate the next <charge count> attack cards
	var card_duplicate_attacks: CardData = CardData.new("card_duplicate_attacks")
	card_duplicate_attacks.card_name = "复制攻击"
	card_duplicate_attacks.card_color_id = "color_red"
	card_duplicate_attacks.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_duplicate_attacks.card_description = "复制本时钟周期接下来的 [status_charge_amount] 次攻击"
	card_duplicate_attacks.card_requires_target = false
	card_duplicate_attacks.card_type = CardData.CARD_TYPES.SKILL
	card_duplicate_attacks.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_duplicate_attacks.card_keyword_object_ids = []
	card_duplicate_attacks.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_duplicate_attacks"}
	card_duplicate_attacks.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_duplicate_attacks.card_play_actions = [{Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}}]
	
	Global.register_rod(card_duplicate_attacks)
	
	# Strengthens the wielder
	var card_damage_increase: CardData = CardData.new("card_damage_increase")
	card_damage_increase.card_name = "伤害增加"
	card_damage_increase.card_color_id = "color_red"
	card_damage_increase.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_damage_increase.card_description = "增加 [status_charge_amount] 点攻击伤害"
	card_damage_increase.card_rarity = CardData.CARD_RARITIES.COMMON
	card_damage_increase.card_type = CardData.CARD_TYPES.POWER
	card_damage_increase.card_play_destination = HandManager.BANISH_PILE # powers banish
	card_damage_increase.card_requires_target = false
	card_damage_increase.card_energy_cost = 0
	card_damage_increase.card_keyword_object_ids = ["keyword_damage_increase"]
	card_damage_increase.card_values = {"status_charge_amount": 5, "status_effect_object_id": "status_effect_damage_increase"}
	card_damage_increase.card_upgrade_value_improvements = {"status_charge_amount": 3}
	card_damage_increase.card_play_actions = [
	{
	Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}
	}
	]
	
	Global.register_rod(card_damage_increase)
	
	# Multihit card that ignores strength increases
	var card_attack_ignore_damage_increase: CardData = CardData.new("card_attack_ignore_damage_increase")
	card_attack_ignore_damage_increase.card_name = "固定伤害攻击"
	card_attack_ignore_damage_increase.card_color_id = "color_red"
	card_attack_ignore_damage_increase.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_ignore_damage_increase.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害。不受伤害增加影响。"
	card_attack_ignore_damage_increase.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_ignore_damage_increase.card_rarity = CardData.CARD_RARITIES.COMMON
	card_attack_ignore_damage_increase.card_keyword_object_ids = []
	card_attack_ignore_damage_increase.card_values = {"damage": 1, "number_of_attacks": 10, "impact_vfx_animation_id": "animation_vfx_impact_default", "time_delay": 0.1, "ignored_interceptor_ids": ["interceptor_damage_increase"]}
	card_attack_ignore_damage_increase.card_upgrade_value_improvements = {"number_of_attacks": 5}
	card_attack_ignore_damage_increase.card_play_actions = [{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.1, "actions_on_lethal": []}
	}]
	
	Global.register_rod(card_attack_ignore_damage_increase)
	
	# Weaken all enemies
	var card_weaken_enemies: CardData = CardData.new("card_weaken_enemies")
	card_weaken_enemies.card_name = "削弱敌人"
	card_weaken_enemies.card_color_id = "color_red"
	card_weaken_enemies.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_weaken_enemies.card_description = "对所有敌人附加 [status_charge_amount] 层虚弱"
	card_weaken_enemies.card_type = CardData.CARD_TYPES.SKILL
	card_weaken_enemies.card_rarity = CardData.CARD_RARITIES.COMMON
	card_weaken_enemies.card_requires_target = false
	card_weaken_enemies.card_energy_cost = 1
	card_weaken_enemies.card_keyword_object_ids = ["keyword_weakness"]
	card_weaken_enemies.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_weakness"}
	card_weaken_enemies.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_weaken_enemies.card_play_actions = [
	{
	Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES}
	}
	]
	
	Global.register_rod(card_weaken_enemies)
	
	# Applies vulnerability to all enemies
	var card_vulnerable_enemies: CardData = CardData.new("card_vulnerable_enemies")
	card_vulnerable_enemies.card_name = "易伤敌人"
	card_vulnerable_enemies.card_color_id = "color_red"
	card_vulnerable_enemies.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_vulnerable_enemies.card_description = "对所有敌人附加 [status_charge_amount] 层易伤"
	card_vulnerable_enemies.card_type = CardData.CARD_TYPES.SKILL
	card_vulnerable_enemies.card_rarity = CardData.CARD_RARITIES.COMMON
	card_vulnerable_enemies.card_requires_target = false
	card_vulnerable_enemies.card_energy_cost = 1
	card_vulnerable_enemies.card_keyword_object_ids = ["keyword_vulnerable"]
	card_vulnerable_enemies.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_vulnerable"}
	card_vulnerable_enemies.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_vulnerable_enemies.card_play_actions = [
	{
	Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES}
	}
	]
	
	Global.register_rod(card_vulnerable_enemies)
	
	# Applies a status that rejects resetting block at start of turn
	var card_preserve_block: CardData = CardData.new("card_preserve_block")
	card_preserve_block.card_name = "保留防火墙"
	card_preserve_block.card_color_id = "color_green"
	card_preserve_block.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_preserve_block.card_description = "防火墙不再重置"
	card_preserve_block.card_rarity = CardData.CARD_RARITIES.RARE
	card_preserve_block.card_type = CardData.CARD_TYPES.POWER
	card_preserve_block.card_play_destination = HandManager.BANISH_PILE # powers banish
	card_preserve_block.card_requires_target = false
	card_preserve_block.card_energy_cost = 2
	card_preserve_block.card_keyword_object_ids = ["keyword_block"]
	card_preserve_block.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_preserve_block"}
	card_preserve_block.card_upgrade_value_improvements = {}
	card_preserve_block.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_preserve_block.card_play_actions = [
	{
	Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}
	}
	]
	
	Global.register_rod(card_preserve_block)
	
	# Applies a status to player that makes the next non 0 cost attack cost 0
	var card_next_attack_free: CardData = CardData.new("card_next_attack_free")
	card_next_attack_free.card_name = "免费攻击"
	card_next_attack_free.card_color_id = "color_red"
	card_next_attack_free.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_next_attack_free.card_description = "接下来的 [status_charge_amount] 个攻击脚本耗能为 0"
	card_next_attack_free.card_type = CardData.CARD_TYPES.SKILL
	card_next_attack_free.card_rarity = CardData.CARD_RARITIES.COMMON
	card_next_attack_free.card_requires_target = false
	card_next_attack_free.card_energy_cost = 1
	card_next_attack_free.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_next_attack_free"}
	card_next_attack_free.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_next_attack_free.card_play_actions = [
	{
	Scripts.ACTION_APPLY_STATUS: {"time_delay": 0.2, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}
	}
	]
	
	Global.register_rod(card_next_attack_free)
	
	# Attack card that applies block if in hand at end of turn
	var card_attack_block_end_of_turn: CardData = CardData.new("card_attack_block_end_of_turn")
	card_attack_block_end_of_turn.card_name = "攻击防火墙"
	card_attack_block_end_of_turn.card_color_id = "color_blue"
	card_attack_block_end_of_turn.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_attack_block_end_of_turn.card_description = "造成 [damage] 点伤害。时钟周期结束时如果在当前线程中则获得 [block] 点防火墙"
	card_attack_block_end_of_turn.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_block_end_of_turn.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_attack_block_end_of_turn.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_attack_block_end_of_turn.card_keyword_object_ids = ["keyword_block"]
	card_attack_block_end_of_turn.card_values = {"damage": 7, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default", "block": 7}
	card_attack_block_end_of_turn.card_upgrade_value_improvements = {"damage": 3, "block": 3}
	card_attack_block_end_of_turn.card_play_actions = [
	{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
	}
	]
	card_attack_block_end_of_turn.card_end_of_turn_actions = [
	{
	Scripts.ACTION_BLOCK: 
		{
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
		"time_delay": 0.5
		}
	}
	]
	
	Global.register_rod(card_attack_block_end_of_turn)
	
	# attack card that hits all enemies
	var card_attack_all: CardData = CardData.new("card_attack_all")
	card_attack_all.card_name = "群体攻击"
	card_attack_all.card_color_id = "color_red"
	card_attack_all.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_all.card_description = "对所有敌人造成 [number_of_attacks] 次 [damage] 点伤害"
	card_attack_all.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_all.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_attack_all.card_keyword_object_ids = []
	card_attack_all.card_requires_target = false
	card_attack_all.card_values = {"damage": 8, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default", "target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES}
	card_attack_all.card_upgrade_value_improvements = {"number_of_attacks": 1}
	card_attack_all.card_play_actions = [{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.3, "actions_on_lethal": []}
	}]
	
	Global.register_rod(card_attack_all)
	
	# Basic block card
	var card_block_basic: CardData = CardData.new("card_block_basic")
	card_block_basic.card_name = "基础防火墙"
	card_block_basic.card_color_id = "color_white"
	card_block_basic.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_block_basic.card_description = "获得 [block] 点防火墙"
	card_block_basic.card_type = CardData.CARD_TYPES.SKILL
	card_block_basic.card_rarity = CardData.CARD_RARITIES.BASIC
	card_block_basic.card_requires_target = false
	card_block_basic.card_keyword_object_ids = ["keyword_block"]
	card_block_basic.card_values = {"block": 10}
	card_block_basic.card_upgrade_value_improvements = {"block": 3}
	card_block_basic.card_play_actions = [{
	Scripts.ACTION_BLOCK: 
		{
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	}]
	
	Global.register_rod(card_block_basic)
	
	# Repeats a block action multiple times
	# example of ACTION_VARIABLE_ACTION_GENERATOR
	var card_repeated_block: CardData = CardData.new("card_repeated_block")
	card_repeated_block.card_name = "连发器"
	card_repeated_block.card_color_id = "color_red"
	card_repeated_block.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_repeated_block.card_description = "获得 [action_count] 次 [block] 点防火墙"
	card_repeated_block.card_type = CardData.CARD_TYPES.SKILL
	card_repeated_block.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_repeated_block.card_requires_target = false
	card_repeated_block.card_play_destination = HandManager.EXHAUST_PILE
	card_repeated_block.card_values = {"block": 3, "action_count": 5}
	card_repeated_block.card_upgrade_value_improvements = {}
	card_repeated_block.card_play_actions = [{
		Scripts.ACTION_VARIABLE_ACTION_GENERATOR: {
			"action_data": [
				{
					Scripts.ACTION_BLOCK: 
						{
							"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
							"time_delay": 0.2
						},
				}
				]
		}}]
	
	Global.register_rod(card_repeated_block)
	
	# Basic draw card
	var card_draw: CardData = CardData.new("card_draw")
	card_draw.card_name = "加载脚本"
	card_draw.card_color_id = "color_blue"
	card_draw.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_draw.card_description = "读取 [draw_count] 个脚本"
	card_draw.card_type = CardData.CARD_TYPES.SKILL
	card_draw.card_rarity = CardData.CARD_RARITIES.COMMON
	card_draw.card_requires_target = false
	card_draw.card_values = {"draw_count": 3}
	card_draw.card_upgrade_value_improvements = {"draw_count": 1}
	card_draw.card_play_actions = [{
	Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 3},
	}]
	
	card_draw.add_card_decorator("card_decorator_extra_draw", {})
	Global.register_rod(card_draw)
	
	# Reshuffle and draw
	var card_reshuffle_draw: CardData = CardData.new("card_reshuffle_draw")
	card_reshuffle_draw.card_name = "重洗并加载脚本"
	card_reshuffle_draw.card_color_id = "color_blue"
	card_reshuffle_draw.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_reshuffle_draw.card_description = "将回收站重新分配入内存队列。\n读取 [draw_count] 个脚本"
	card_reshuffle_draw.card_type = CardData.CARD_TYPES.SKILL
	card_reshuffle_draw.card_rarity = CardData.CARD_RARITIES.COMMON
	card_reshuffle_draw.card_energy_cost = 0
	card_reshuffle_draw.card_requires_target = false
	card_reshuffle_draw.card_values = {"draw_count": 1}
	card_reshuffle_draw.card_upgrade_value_improvements = {"draw_count": 1}
	card_reshuffle_draw.card_play_actions = [{
	Scripts.ACTION_RESHUFFLE: {"shuffle_discard_into_draw": true},
	Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 3},
	}]
	
	Global.register_rod(card_reshuffle_draw)
	
	# Add a consumable
	var card_add_consumable: CardData = CardData.new("card_add_consumable")
	card_add_consumable.card_name = "添加物理删除品"
	card_add_consumable.card_color_id = "color_blue"
	card_add_consumable.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_add_consumable.card_description = "生成一个随机物理删除品"
	card_add_consumable.card_type = CardData.CARD_TYPES.SKILL
	card_add_consumable.card_rarity = CardData.CARD_RARITIES.RARE
	card_add_consumable.card_requires_target = false
	card_add_consumable.card_play_destination = HandManager.EXHAUST_PILE
	card_add_consumable.card_values = {"random_consumable": true, "fill_all_slots": true}
	card_add_consumable.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_add_consumable.card_play_actions = [{
	Scripts.ACTION_ADD_CONSUMABLE: {},
	}]
	
	Global.register_rod(card_add_consumable)
	
	# Large 2 energy attack that exhausts if in hand at end of turn
	# Grants money on kills
	var card_attack_money_on_lethal: CardData = CardData.new("card_attack_money_on_lethal")
	card_attack_money_on_lethal.card_name = "数据币攻击"
	card_attack_money_on_lethal.card_color_id = "color_red"
	card_attack_money_on_lethal.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_money_on_lethal.card_description = "造成 [damage] 点伤害。击杀时获得 [money_amount] 数据币。"
	card_attack_money_on_lethal.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_money_on_lethal.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_attack_money_on_lethal.card_energy_cost = 2
	card_attack_money_on_lethal.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_attack_money_on_lethal.card_values = {"damage": 15, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default", "money_amount": 25}
	card_attack_money_on_lethal.card_upgrade_value_improvements = {"damage": 5, "money_amount": 5}
	card_attack_money_on_lethal.card_play_actions = [
	{
	Scripts.ACTION_ATTACK_GENERATOR: 
		{
		
		"time_delay": 0.0,
		"actions_on_lethal": 
			[
				{
				Scripts.ACTION_ADD_MONEY: {}
				}
			]
		}
	}
	]
	
	Global.register_rod(card_attack_money_on_lethal)
	
	# Attack that heals for unblocked damage
	# demonstrates storing values into CardPlayRequest for use by other actions
	var card_attack_heal_unblocked_damage: CardData = CardData.new("card_attack_heal_unblocked_damage")
	card_attack_heal_unblocked_damage.card_name = "吸血攻击"
	card_attack_heal_unblocked_damage.card_color_id = "color_blue"
	card_attack_heal_unblocked_damage.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_attack_heal_unblocked_damage.card_description = "对所有敌人造成 [damage] 点伤害，并回复等量未防火墙伤害的完整度"
	card_attack_heal_unblocked_damage.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_heal_unblocked_damage.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_attack_heal_unblocked_damage.card_requires_target = false
	card_attack_heal_unblocked_damage.card_play_destination = HandManager.EXHAUST_PILE
	card_attack_heal_unblocked_damage.card_values = {"damage": 4, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_attack_heal_unblocked_damage.card_upgrade_value_improvements = {"damage": 3}
	card_attack_heal_unblocked_damage.card_play_actions = [
	{
	Scripts.ACTION_ADD_HEALTH: 
		{
		"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
		# aliases unblocked damage into health value, capping it damage done to 0 hp
		"custom_key_names":{"health_amount": "unblocked_damage_capped"}
		}
	},
	{
	Scripts.ACTION_ATTACK_GENERATOR: 
		{
		"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
		"time_delay": 0.3,
		}
	}
	]
	
	Global.register_rod(card_attack_heal_unblocked_damage)
	
	# Attack that gets permanently stronger if it kills something
	var card_attack_improve_on_lethal: CardData = CardData.new("card_attack_improve_on_lethal")
	card_attack_improve_on_lethal.card_name = "成长攻击"
	card_attack_improve_on_lethal.card_color_id = "color_blue"
	card_attack_improve_on_lethal.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_attack_improve_on_lethal.card_description = "获得 [block] 点防火墙，造成 [damage] 点伤害。击杀时永久提升 2 点伤害和防火墙"
	card_attack_improve_on_lethal.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_improve_on_lethal.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_attack_improve_on_lethal.card_energy_cost = 2
	card_attack_improve_on_lethal.card_values = {"block": 5, "damage": 5, "number_of_attacks": 1,  "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_attack_improve_on_lethal.card_play_actions = [
	{
	Scripts.ACTION_ATTACK_GENERATOR: 
	{
		"time_delay": 0.0,
		"actions_on_lethal": 
			[
				{
				Scripts.ACTION_IMPROVE_CARD_VALUES: 
					{
					"time_delay": 0.1,
					"pick_played_card": true,
					"modify_parent_card": true,
					"card_value_improvements":
						{
						"block": 2,
						"damage": 2,
						}
					}
				}
			]
		}
	}
	
	]
	
	Global.register_rod(card_attack_improve_on_lethal)
	
	# Block that improves temporarily when retained
	var card_improving_retain_block: CardData = CardData.new("card_improving_retain_block")
	card_improving_retain_block.card_name = "保留防火墙"
	card_improving_retain_block.card_color_id = "color_orange"
	card_improving_retain_block.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_improving_retain_block.card_description = "获得 [block] 点防火墙。保留时提升 3 点防火墙"
	card_improving_retain_block.card_energy_cost = 1
	card_improving_retain_block.card_type = CardData.CARD_TYPES.SKILL
	card_improving_retain_block.card_rarity = CardData.CARD_RARITIES.COMMON
	card_improving_retain_block.card_requires_target = false
	card_improving_retain_block.card_is_retained = true
	card_improving_retain_block.card_keyword_object_ids = ["keyword_block"]
	card_improving_retain_block.card_values = {"block": 5}
	card_improving_retain_block.card_play_actions = [
		{
		Scripts.ACTION_BLOCK: {
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
			}
		}
	]
	card_improving_retain_block.card_retain_actions = [
		{
		Scripts.ACTION_IMPROVE_CARD_VALUES: {
			"time_delay": 0.1,
			"pick_played_card": true,
			"modify_parent_card": false,
			"card_value_improvements":
				{
				"block": 3
				}
			}
		}
	]
	
	Global.register_rod(card_improving_retain_block)
	
	# Attack that attaches itself to random enemy at the start of combat
	var card_self_attaching_attack: CardData = CardData.new("card_self_attaching_attack")
	card_self_attaching_attack.card_name = "自附着攻击"
	card_self_attaching_attack.card_color_id = "color_blue"
	card_self_attaching_attack.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_self_attaching_attack.card_description = "战斗开始时附着到一个随机敌人身上\n造成 [damage] 点伤害"
	card_self_attaching_attack.card_type = CardData.CARD_TYPES.ATTACK
	card_self_attaching_attack.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_self_attaching_attack.card_energy_cost = 0
	card_self_attaching_attack.card_values = {"damage": 20, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_self_attaching_attack.card_play_actions = [
	{
	Scripts.ACTION_ATTACK_GENERATOR: 
		{
		"time_delay": 0.0,
		}
	}
	]
	card_self_attaching_attack.card_initial_combat_actions = [
	{
	Scripts.ACTION_ATTACH_CARDS_ONTO_ENEMY: 
		{
		"time_delay": 0.0,
		"target_override": BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY,
		"pick_played_card": true
		}
	}
	]
	
	Global.register_rod(card_self_attaching_attack)
	
	# Attack that draws cards if played when 5 cards in hand
	var card_attack_with_conditional_draw: CardData = CardData.new("card_attack_with_conditional_draw")
	card_attack_with_conditional_draw.card_name = "加载脚本攻击"
	card_attack_with_conditional_draw.card_color_id = "color_red"
	card_attack_with_conditional_draw.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_with_conditional_draw.card_description = "造成 [damage] 点伤害。当前线程数为 5 时调用则读取 2 个脚本，否则读取 1 张"
	card_attack_with_conditional_draw.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_with_conditional_draw.card_rarity = CardData.CARD_RARITIES.RARE
	card_attack_with_conditional_draw.card_energy_cost = 1
	card_attack_with_conditional_draw.card_values = {"damage": 5, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_attack_with_conditional_draw.card_upgrade_value_improvements = {"damage": 5}
	card_attack_with_conditional_draw.card_play_actions = [
	{
	Scripts.ACTION_ATTACK_GENERATOR: {
		"time_delay": 0.0,
		"actions_on_lethal": []
		}
	},
	{
	Scripts.ACTION_VALIDATOR: {
		"validator_data":
		[
			{
			Scripts.VALIDATOR_CARD_TYPE_IN_HAND: 
				{
				"card_type_minimum": 5,
				"card_type_maximum": 5,
				"card_types": CardData.CARD_TYPES.values(),	# any card
				"invert_validation": false,
				}
			}
		],
		"passed_action_data": 
		[
			{
			Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 2},
			}
		],
		"failed_action_data": 
		[
			{
			Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1},
			}
		],
		"time_delay": 0.0,
		}
	}
	]

	Global.register_rod(card_attack_with_conditional_draw)
	
	# Attack that blocks if targeted enemy is attacking
	var card_attack_with_conditional_block: CardData = CardData.new("card_attack_with_conditional_block")
	card_attack_with_conditional_block.card_name = "攻击防火墙"
	card_attack_with_conditional_block.card_color_id = "color_red"
	card_attack_with_conditional_block.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_with_conditional_block.card_description = "造成 [damage] 点伤害。如果目标敌人正在攻击，获得 [block] 点防火墙"
	card_attack_with_conditional_block.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_with_conditional_block.card_rarity = CardData.CARD_RARITIES.COMMON
	card_attack_with_conditional_block.card_energy_cost = 1
	card_attack_with_conditional_block.card_values = {"damage": 10, "block": 5, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_attack_with_conditional_block.card_upgrade_value_improvements = {"damage": 3, "block": 3}
	card_attack_with_conditional_block.card_glow_validators = [
		{Scripts.VALIDATOR_ENEMY_ATTACKING: {}}
	]
	card_attack_with_conditional_block.card_play_actions = [
	{
	Scripts.ACTION_ATTACK_GENERATOR: {
		"time_delay": 0.0,
		"actions_on_lethal": []
		}
	},
	{
	Scripts.ACTION_VALIDATOR: {
		"validator_data":
		[
			{Scripts.VALIDATOR_CARD_PLAY_ENEMY_ATTACKING: {}}
		],
		"passed_action_data": 
		[
			{
			Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT},
			}
		],
		"time_delay": 0.0,
		}
	}
	]

	Global.register_rod(card_attack_with_conditional_block)
	
	# Variable cost attack
	# Capped at 5 energy
	var card_attack_variable_cost: CardData = CardData.new("card_attack_variable_cost")
	card_attack_variable_cost.card_name = "变数攻击"
	card_attack_variable_cost.card_color_id = "color_orange"
	card_attack_variable_cost.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_attack_variable_cost.card_description = "物理删除 [variable_energy_icons]，造成 [damage] 点伤害"
	card_attack_variable_cost.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_variable_cost.card_rarity = CardData.CARD_RARITIES.RARE
	card_attack_variable_cost.card_energy_cost = 0
	card_attack_variable_cost.card_energy_cost_is_variable = true
	card_attack_variable_cost.card_energy_cost_variable_upper_bound = 5
	card_attack_variable_cost.card_values = {"damage": 1, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_attack_variable_cost.card_upgrade_value_improvements = {"damage": 1, "multiplier_offset": 1}
	card_attack_variable_cost.card_first_upgrade_property_changes = {"card_description": "物理删除 [variable_energy_icons]，造成 [damage] 点伤害"}	# updates description
	card_attack_variable_cost.card_play_actions = [
	{
	Scripts.ACTION_VARIABLE_COST_MODIFIER: {
		"action_data":
		[
			{
			Scripts.ACTION_ATTACK_GENERATOR: {
				"time_delay": 0.0,
				"merge_attacks": true,
				"actions_on_lethal": []
				}
			}
		],
		"multiplier_offset": 0,
		"multiplied_values": [
			"number_of_attacks"
		],
		"time_delay": 0.0,
		}
	}
	]

	Global.register_rod(card_attack_variable_cost)
	
	# Attack based on number of cards played in combat
	var card_attack_number_of_cards_played: CardData = CardData.new("card_attack_number_of_cards_played")
	card_attack_number_of_cards_played.card_name = "并发攻击"
	card_attack_number_of_cards_played.card_color_id = "color_red"
	card_attack_number_of_cards_played.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_number_of_cards_played.card_description = "造成 [damage] 点伤害，本场战斗中每调用一个脚本增加 2 点伤害"
	card_attack_number_of_cards_played.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_number_of_cards_played.card_rarity = CardData.CARD_RARITIES.RARE
	card_attack_number_of_cards_played.card_energy_cost = 2
	card_attack_number_of_cards_played.card_values = {"damage": 1, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_attack_number_of_cards_played.card_upgrade_value_improvements = {"damage": 1}
	card_attack_number_of_cards_played.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_attack_number_of_cards_played.card_play_actions = [
		{
		Scripts.ACTION_ATTACK_GENERATOR: {
			"time_delay": 0.0,
			"merge_attacks": true,
			"actions_on_lethal": []
			}
		}
	]
	card_attack_number_of_cards_played.add_card_decorator("card_decorator_dynamic_value_modifier",
		{
		"stat_enum": CombatStatsData.STATS.CARDS_PLAYED,
		"is_turn_stat": false,
		"multiplied_values": ["damage"],
		"multiplied_values_bases": {"damage": 0},
		"multiplied_values_per_stat": {"damage": 2},
		})
	
	Global.register_rod(card_attack_number_of_cards_played)
	
	# Example of card using start of combat actions
	var card_initial_combat_block: CardData = CardData.new("card_block_initial")
	card_initial_combat_block.card_name = "防火墙"
	card_initial_combat_block.card_color_id = "color_white"
	card_initial_combat_block.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_initial_combat_block.card_description = "获得 [block] 点防火墙。战斗开始时获得 [block] 点防火墙"
	card_initial_combat_block.card_type = CardData.CARD_TYPES.SKILL
	card_initial_combat_block.card_rarity = CardData.CARD_RARITIES.COMMON
	card_initial_combat_block.card_requires_target = false
	card_initial_combat_block.card_keyword_object_ids = ["keyword_block"]
	card_initial_combat_block.card_values = {"block": 5}
	card_initial_combat_block.card_upgrade_value_improvements = {"block": 3}
	card_initial_combat_block.card_play_actions = [{
	Scripts.ACTION_BLOCK: 
		{
			"block": 5,
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	}]
	card_initial_combat_block.card_initial_combat_actions = [{
	Scripts.ACTION_BLOCK: 
		{
			"block": 5,
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	}]
	
	Global.register_rod(card_initial_combat_block)
	
	
	# Block using 2 custom values
	var card_custom_block: CardData = CardData.new("card_custom_block")
	card_custom_block.card_name = "自定义防火墙"
	card_custom_block.card_color_id = "color_white"
	card_custom_block.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_custom_block.card_description = "防火墙两次。获得 [custom_block_1] 点防火墙。获得 [custom_block_2] 点防火墙。"
	card_custom_block.card_type = CardData.CARD_TYPES.SKILL
	card_custom_block.card_rarity = CardData.CARD_RARITIES.COMMON
	card_custom_block.card_requires_target = false
	card_custom_block.card_keyword_object_ids = ["keyword_block"]
	card_custom_block.card_values = {"custom_block_1": 3, "custom_block_2": 4}
	card_custom_block.card_upgrade_value_improvements = {"custom_block_1": 5, "custom_block_2": 5}
	card_custom_block.card_play_actions = [
	{
	Scripts.ACTION_BLOCK: 
		{
		"custom_key_names": {"block": "custom_block_1"},
		"time_delay": 0.5,
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	},
	{
	Scripts.ACTION_BLOCK: 
		{
		"custom_key_names": {"block": "custom_block_2"},
		"time_delay": 0.5,
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	},
	]
	
	Global.register_rod(card_custom_block)
	
	# Block that ends turn
	# Adjust the immediacy value to affect when the turn is ended
	# Blocks before and after an end turn requesst to demonstrate turn ending differences
	var card_end_turn: CardData = CardData.new("card_end_turn")
	card_end_turn.card_name = "结束时钟周期"
	card_end_turn.card_color_id = "color_white"
	card_end_turn.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_end_turn.card_description = "获得 [block] 点防火墙。结束时钟周期。获得 [block] 点防火墙"
	card_end_turn.card_type = CardData.CARD_TYPES.SKILL
	card_end_turn.card_rarity = CardData.CARD_RARITIES.RARE
	card_end_turn.card_requires_target = false
	card_end_turn.card_keyword_object_ids = ["keyword_block"]
	card_end_turn.card_values = {"block": 5, "end_turn_immediacy_level": CombatEndTurn.END_TURN_QUEUE_IMMEDIACY.IMMEDIATE}
	card_end_turn.card_upgrade_value_improvements = {"block": 5}
	card_end_turn.card_play_actions = [
	{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	{Scripts.ACTION_END_TURN: {"time_delay": 0.05}},
	{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	
	Global.register_rod(card_end_turn)
	
	# Block that exhausts on use
	# Drawn first
	var card_big_block: CardData = CardData.new("card_block_big")
	card_big_block.card_name = "物理删除防火墙"
	card_big_block.card_color_id = "color_orange"
	card_big_block.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_big_block.card_description = "获得 [block] 点防火墙"
	card_big_block.card_type = CardData.CARD_TYPES.SKILL
	card_big_block.card_rarity = CardData.CARD_RARITIES.COMMON
	card_big_block.card_requires_target = false
	card_big_block.card_play_destination = HandManager.EXHAUST_PILE
	card_big_block.card_first_shuffle_priority = 1	# card will be top of deck on combat start
	card_big_block.card_keyword_object_ids = ["keyword_block"]
	card_big_block.card_values = {"block": 15}
	card_big_block.card_upgrade_value_improvements = {"block": 5}
	card_big_block.card_play_actions = [{
	Scripts.ACTION_BLOCK: {
		"time_delay": 0.5,
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	}]
	
	Global.register_rod(card_big_block)
	
	# Block that improves each time in combat
	var card_improving_block: CardData = CardData.new("card_improving_block")
	card_improving_block.card_name = "成长防火墙"
	card_improving_block.card_color_id = "color_green"
	card_improving_block.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_improving_block.card_description = "获得 [block] 点防火墙。本场战斗中提升 1 点防火墙值"
	card_improving_block.card_type = CardData.CARD_TYPES.SKILL
	card_improving_block.card_rarity = CardData.CARD_RARITIES.RARE
	card_improving_block.card_requires_target = false
	card_improving_block.card_first_shuffle_priority = 1	# card will be top of deck on combat start
	card_improving_block.card_keyword_object_ids = ["keyword_block"]
	card_improving_block.card_values = {"block": 5}
	card_improving_block.card_play_actions = [
	{
	Scripts.ACTION_BLOCK: {
		"time_delay": 0.5,
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT
		}
	},
	{
	Scripts.ACTION_IMPROVE_CARD_VALUES: {
		"time_delay": 0.1,
		"pick_played_card": true,
		"modify_parent_card": false,
		"card_value_improvements":
			{
			"block": 1
			}
		}
	},
	]
	
	Global.register_rod(card_improving_block)
	
	# Attack card that improves all cards of the same id when played
	var card_law: CardData = CardData.new("card_law")
	card_law.card_name = "法则"
	card_law.card_color_id = "color_red"
	card_law.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_law.card_description = "造成 [damage] 点伤害。本场战斗中所有核心权限脚本提升 3 点伤害。"
	card_law.card_type = CardData.CARD_TYPES.ATTACK
	card_law.card_rarity = CardData.CARD_RARITIES.COMMON
	card_law.card_requires_target = true
	card_law.card_energy_cost = 0
	card_law.card_keyword_object_ids = []
	card_law.card_values = {"damage": 5, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default",}
	card_law.card_upgrade_value_improvements = {"damage": 3}
	card_law.card_play_actions = [
	# improve self
	{
	Scripts.ACTION_IMPROVE_CARD_VALUES: {
		"pick_played_card": true,
		"modify_parent_card": false,
		"time_delay": 0.0,
		"card_value_improvements":
			{
			"damage": 3
			}
		}
	},
	# improve all other Laws (self not included because card in limbo)
	{
	Scripts.ACTION_PICK_CARDS: {
		"max_card_amount": 999,
		"min_card_amount": 999,
		"min_cards_are_required_for_action": false,
		"random_selection": false,
		"card_pick_type": HandManager.COMBAT_DECK,
		"card_pick_text": "",
		# limit to only other Law cards
		"validator_data": [
			{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": [card_law.object_id]}}
		],
		"action_data": [
				{
				Scripts.ACTION_IMPROVE_CARD_VALUES: {
					"pick_played_card": false,
					"modify_parent_card": false,
					"card_value_improvements":
						{
						"damage": 3,
						}
				}},
			]
		}
	},
	# attack. Happens before improvements
	{Scripts.ACTION_ATTACK_GENERATOR: {}}
	]
	
	Global.register_rod(card_law)
	
	# Discard up to 3 cards and block for each
	# example of cardset modifiers
	var card_discard_and_block: CardData = CardData.new("card_discard_block")
	card_discard_and_block.card_name = "回收站防火墙"
	card_discard_and_block.card_color_id = "color_red"
	card_discard_and_block.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_discard_and_block.card_description = "弃置最多 [max_card_amount] 个脚本，每个获得 [block] 点防火墙"
	card_discard_and_block.card_type = CardData.CARD_TYPES.SKILL
	card_discard_and_block.card_rarity = CardData.CARD_RARITIES.COMMON
	card_discard_and_block.card_requires_target = false
	card_discard_and_block.card_keyword_object_ids = ["keyword_block"]
	card_discard_and_block.card_values = {"block": 5,  "max_card_amount": 3}
	card_discard_and_block.card_upgrade_value_improvements = {"block": 3, "max_card_amount": 1}
	card_discard_and_block.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 0,
		"card_pick_type": HandManager.HAND_PILE,
		"card_pick_text": "选择最多 {0} 个脚本弃置。已选 {1} 个",
		"action_data": [
			{Scripts.ACTION_VARIABLE_CARDSET_MODIFIER: {
				"multiplied_values": ["block"],
				"action_data": [{Scripts.ACTION_BLOCK: {
					"time_delay": 0.5,
					"target_override": BaseAction.TARGET_OVERRIDES.PARENT
					}}]
			}},
			{Scripts.ACTION_DISCARD_CARDS: {}},
			]
		}
	},
	]
	
	Global.register_rod(card_discard_and_block)
	
	# Discard up to 3 attack cards and damage all enemies for each one
	# exmaple of validators in card picking, and variable cardsets
	var card_banish_attack: CardData = CardData.new("card_banish_attack")
	card_banish_attack.card_name = "放逐攻击"
	card_banish_attack.card_color_id = "color_red"
	card_banish_attack.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_banish_attack.card_description = "彻底删除最多 [max_card_amount] 个攻击脚本，每个对所有敌人造成 [damage] 点伤害"
	card_banish_attack.card_type = CardData.CARD_TYPES.ATTACK
	card_banish_attack.card_rarity = CardData.CARD_RARITIES.COMMON
	card_banish_attack.card_requires_target = false
	card_banish_attack.card_keyword_object_ids = ["keyword_banish"]
	card_banish_attack.card_values = {"damage": 8,  "max_card_amount": 3}
	card_banish_attack.card_upgrade_value_improvements = {"damage": 2, "max_card_amount": 1}
	card_banish_attack.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 0,
		"card_pick_type": HandManager.HAND_PILE,
		"card_pick_text": "选择最多 {0} 个脚本放逐。已选 {1} 个",
		# only attack cards allowed
		"validator_data": [
			{Scripts.VALIDATOR_CARD_TYPE: {"card_types": [CardData.CARD_TYPES.ATTACK]}}
		],
		# banishes the cards and updates attack generator based on number of cards
		"action_data": [
			{Scripts.ACTION_VARIABLE_CARDSET_MODIFIER: {
				"multiplied_values": ["number_of_attacks"],
				"action_data": [{Scripts.ACTION_ATTACK_GENERATOR: {
					"number_of_attacks": 1,
					"impact_vfx_animation_id": "animation_vfx_impact_default",
					"time_delay": 0.5,
					"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES
					}}]
			}},
			{Scripts.ACTION_BANISH_CARDS: {}},
			]
		}
	},
	]
	
	Global.register_rod(card_banish_attack)
	
	# Discard up to 2 cards and emit a custom signal that's bound to a custom stat
	# using custom signals with variable outputs
	var card_special_discard: CardData = CardData.new("card_special_discard")
	card_special_discard.card_name = "特殊丢弃"
	card_special_discard.card_color_id = "color_orange"
	card_special_discard.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_special_discard.card_description = "弃置最多 [max_card_amount] 个脚本，每个发出一个自定义信号"
	card_special_discard.card_type = CardData.CARD_TYPES.SKILL
	card_special_discard.card_rarity = CardData.CARD_RARITIES.COMMON
	card_special_discard.card_requires_target = false
	card_special_discard.card_keyword_object_ids = ["keyword_discard"]
	card_special_discard.card_values = {"max_card_amount": 3}
	card_special_discard.card_upgrade_value_improvements = {"max_card_amount": 4}
	card_special_discard.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 0,
		"card_pick_type": HandManager.HAND_PILE,
		"card_pick_text": "选择最多 {0} 个脚本弃置。已选 {1} 个",
		"validator_data": [],
		# discard the cards and emit a custom signal of value the number of cards
		"action_data": [
			{Scripts.ACTION_VARIABLE_CARDSET_MODIFIER: {
				"multiplied_values": ["custom_signal_value"],
				"action_data": [{Scripts.ACTION_EMIT_CUSTOM_SIGNAL: {
					"custom_signal_object_id": "custom_signal_special_discard",
					"custom_signal_value": 1,
					"time_delay": 0.0,
					}}]
			}},
			{Scripts.ACTION_DISCARD_CARDS: {}},
			]
		}
	},
	]
	
	Global.register_rod(card_special_discard)
	
	# Pick up to 2 cards from draw pile and add to hand
	var card_pick_from_discard: CardData = CardData.new("card_pick_from_discard")
	card_pick_from_discard.card_name = "回收站拾取"
	card_pick_from_discard.card_color_id = "color_blue"
	card_pick_from_discard.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_pick_from_discard.card_description = "从回收站选择 2 个脚本加入当前线程"
	card_pick_from_discard.card_type = CardData.CARD_TYPES.SKILL
	card_pick_from_discard.card_rarity = CardData.CARD_RARITIES.RARE
	card_pick_from_discard.card_requires_target = false
	card_pick_from_discard.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 0,
		"max_card_amount": 2,
		"min_cards_are_required_for_action": false,
		"random_selection": false,
		"card_pick_text": "选择 {0} 个脚本加入当前线程。已选 {1} 个",
		"card_pick_type": HandManager.DISCARD_PILE,
		"action_data": [{Scripts.ACTION_ADD_CARDS_TO_HAND: {}}]
		}
	},
	]
	
	Global.register_rod(card_pick_from_discard)
	
	# Pick 2 card from discard pile and randomly add to draw pile
	var card_add_to_draw_from_discard: CardData = CardData.new("card_add_to_draw_from_discard")
	card_add_to_draw_from_discard.card_name = "回收站拾取"
	card_add_to_draw_from_discard.card_color_id = "color_blue"
	card_add_to_draw_from_discard.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_add_to_draw_from_discard.card_description = "从回收站选择 2 个脚本随机插入内存队列"
	card_add_to_draw_from_discard.card_type = CardData.CARD_TYPES.SKILL
	card_add_to_draw_from_discard.card_rarity = CardData.CARD_RARITIES.RARE
	card_add_to_draw_from_discard.card_requires_target = false
	card_add_to_draw_from_discard.card_values = {"card_destination_strategy": HandManager.PILE_INSERTION_STRATEGIES.TOP}
	card_add_to_draw_from_discard.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 1,
		"max_card_amount": 2,
		"min_cards_are_required_for_action": false,
		"random_selection": false,
		"card_pick_text": "选择 {0} 个脚本加入内存队列。已选 {1} 个",
		"card_pick_type": HandManager.DISCARD_PILE,
		"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {}}]
		}
	},
	]
	
	Global.register_rod(card_add_to_draw_from_discard)
	
	# Sets all cards in hand to be zero cost until end of turn
	var card_set_hand_energy: CardData = CardData.new("card_set_hand_energy")
	card_set_hand_energy.card_name = "设置当前线程算力"
	card_set_hand_energy.card_color_id = "color_red"
	card_set_hand_energy.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_set_hand_energy.card_description = "当前线程中所有脚本耗能变为 0，持续到时钟周期结束"
	card_set_hand_energy.card_type = CardData.CARD_TYPES.SKILL
	card_set_hand_energy.card_rarity = CardData.CARD_RARITIES.RARE
	card_set_hand_energy.card_requires_target = false
	card_set_hand_energy.card_values = {"card_energy_cost": -1, "card_energy_cost_until_played": -1, "card_energy_cost_until_turn": 0}
	card_set_hand_energy.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 10,
		"max_card_amount": 10,
		"min_cards_are_required_for_action": false,
		"random_selection": false,
		"card_pick_text": "选择 {0} 个脚本加入当前线程。已选 {1} 个",
		"card_pick_type": HandManager.HAND_PILE,
		"action_data": [{Scripts.ACTION_CHANGE_CARD_ENERGIES: {}}]
		}
	},
	]
	
	Global.register_rod(card_set_hand_energy)
	
	# transforms all other cards in hand during combat
	var card_transform_hand: CardData = CardData.new("card_transform_hand")
	card_transform_hand.card_name = "变形当前线程"
	card_transform_hand.card_color_id = "color_red"
	card_transform_hand.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_transform_hand.card_description = "格式化当前线程中的脚本"
	card_transform_hand.card_type = CardData.CARD_TYPES.SKILL
	card_transform_hand.card_rarity = CardData.CARD_RARITIES.RARE
	card_transform_hand.card_requires_target = false
	card_transform_hand.card_values = {
		"transform_parent_card": false,
		"keep_rarity": false,
		"keep_color": false,
		"keep_type": false,
		}
	card_transform_hand.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 10,
		"max_card_amount": 10,
		"min_cards_are_required_for_action": false,
		"random_selection": false,
		"card_pick_text": "选择 {0} 个脚本加入当前线程。已选 {1} 个",
		"card_pick_type": HandManager.HAND_PILE,
		"action_data": [{Scripts.ACTION_TRANSFORM_CARDS: {}}]
		}
	},
	]
	
	Global.register_rod(card_transform_hand)
	
	# Card that transforms into a B variant when right clicked
	var card_right_click_transform_mode_a: CardData = CardData.new("card_right_click_transform_mode_a")
	card_right_click_transform_mode_a.card_name = "模式 A"
	card_right_click_transform_mode_a.card_color_id = "color_red"
	card_right_click_transform_mode_a.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_right_click_transform_mode_a.card_description = "造成 [damage] 点伤害\n右键点击转换为 B 形态"
	card_right_click_transform_mode_a.card_type = CardData.CARD_TYPES.ATTACK
	card_right_click_transform_mode_a.card_rarity = CardData.CARD_RARITIES.COMMON
	card_right_click_transform_mode_a.card_color_id = "color_red"
	card_right_click_transform_mode_a.card_requires_target = true
	card_right_click_transform_mode_a.card_values = {
		"damage": 7,
		"number_of_attacks": 1,
		"impact_vfx_animation_id": "animation_vfx_impact_default",
		"transform_parent_card": false,
		"keep_upgrade_level": true,
		"pick_played_card": true,
		"transform_into_card_object_id": "card_right_click_transform_mode_b",
		}
	card_right_click_transform_mode_a.card_upgrade_value_improvements = {"damage": 4}
	card_right_click_transform_mode_a.card_play_actions = [{Scripts.ACTION_ATTACK_GENERATOR: {}}]
	card_right_click_transform_mode_a.card_right_click_actions = [{Scripts.ACTION_TRANSFORM_CARDS: {}}]
	
	Global.register_rod(card_right_click_transform_mode_a)
	
	# Card that transforms into a A variant when right clicked
	# this card cannot appear in card packs and thus not draftable
	var card_right_click_transform_mode_b: CardData = CardData.new("card_right_click_transform_mode_b")
	card_right_click_transform_mode_b.card_name = "模式 B"
	card_right_click_transform_mode_b.card_color_id = "color_red"
	card_right_click_transform_mode_b.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_right_click_transform_mode_b.card_description = "获得 [block] 点防火墙\n右键点击转换为 A 形态"
	card_right_click_transform_mode_b.card_type = CardData.CARD_TYPES.SKILL
	card_right_click_transform_mode_b.card_rarity = CardData.CARD_RARITIES.COMMON
	card_right_click_transform_mode_b.card_appears_in_card_packs = false
	card_right_click_transform_mode_b.card_color_id = "color_red"
	card_right_click_transform_mode_b.card_requires_target = false
	card_right_click_transform_mode_b.card_values = {
		"block": 5,
		"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
		"transform_parent_card": false,
		"keep_upgrade_level": true,
		"pick_played_card": true,
		"transform_into_card_object_id": "card_right_click_transform_mode_a",
		}
	card_right_click_transform_mode_b.card_upgrade_value_improvements = {"block": 3}
	card_right_click_transform_mode_b.card_play_actions = [{Scripts.ACTION_BLOCK: {}}]
	card_right_click_transform_mode_b.card_right_click_actions = [{Scripts.ACTION_TRANSFORM_CARDS: {}}]
	
	Global.register_rod(card_right_click_transform_mode_b)
	
	# draw cards and randomize cost of cards in hand
	var card_randomize_hand_energy_costs: CardData = CardData.new("card_randomize_hand_energy_costs")
	card_randomize_hand_energy_costs.card_name = "随机脚本耗能"
	card_randomize_hand_energy_costs.card_color_id = "color_blue"
	card_randomize_hand_energy_costs.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_randomize_hand_energy_costs.card_description = "读取 [draw_count] 个脚本。本时钟周期随机化当前线程中所有脚本的耗能"
	card_randomize_hand_energy_costs.card_energy_cost = 0
	card_randomize_hand_energy_costs.card_type = CardData.CARD_TYPES.SKILL
	card_randomize_hand_energy_costs.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_randomize_hand_energy_costs.card_requires_target = false
	card_randomize_hand_energy_costs.card_values = {
		"draw_count": 2,
		"randomize_card_energy_cost_until_turn": true,
		}
	card_randomize_hand_energy_costs.card_upgrade_value_improvements = {"draw_count": 1}
	card_randomize_hand_energy_costs.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"min_card_amount": 10,
		"max_card_amount": 10,
		"min_cards_are_required_for_action": false,
		"random_selection": false,
		"card_pick_text": "选择 {0} 个脚本加入当前线程。已选 {1} 个",
		"card_pick_type": HandManager.HAND_PILE,
		"action_data": [{Scripts.ACTION_RANDOMIZE_CARD_ENERGIES: {}}]
		}
	},
	{
	Scripts.ACTION_DRAW_GENERATOR: {},
	},
	]
	
	Global.register_rod(card_randomize_hand_energy_costs)
	
	# Creates cards and adds them to hand
	var card_generate_shoves: CardData = CardData.new("card_generate_shoves")
	card_generate_shoves.card_name = "推击之舞"
	card_generate_shoves.card_color_id = "color_green"
	card_generate_shoves.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_generate_shoves.card_description = "生成 [number_of_cards] 张完全合规的推送脚本并加入当前线程"
	card_generate_shoves.card_type = CardData.CARD_TYPES.SKILL
	card_generate_shoves.card_rarity = CardData.CARD_RARITIES.COMMON
	card_generate_shoves.card_requires_target = false
	card_generate_shoves.card_keyword_object_ids = []
	card_generate_shoves.card_values = {"created_card_object_id": "card_shove",  "number_of_cards": 3}
	card_generate_shoves.card_upgrade_value_improvements = {"number_of_cards": 1}
	card_generate_shoves.card_play_actions = [
	{
	Scripts.ACTION_CREATE_CARDS: {
		"action_data": [{Scripts.ACTION_ADD_CARDS_TO_HAND: {}}]
		}
	},
	]
	
	Global.register_rod(card_generate_shoves)
	
	# Generated card
	var card_shove: CardData = CardData.new("card_shove")
	card_shove.card_name = "推击"
	card_shove.card_color_id = "color_white"
	card_shove.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_shove.card_description = "造成 [damage] 点伤害"
	card_shove.card_type = CardData.CARD_TYPES.ATTACK
	card_shove.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_shove.card_energy_cost = 0
	card_shove.card_play_destination = HandManager.EXHAUST_PILE
	card_shove.card_values = {"damage": 4, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_shove.card_upgrade_value_improvements = {"damage": 3}
	card_shove.card_play_actions = [{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
	}]
	
	Global.register_rod(card_shove)
	
	# Creates status cards and adds them to draw pile
	var card_generate_status_cards: CardData = CardData.new("card_generate_status_cards")
	card_generate_status_cards.card_name = "状态码生成器"
	card_generate_status_cards.card_color_id = "color_red"
	card_generate_status_cards.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_generate_status_cards.card_description = "生成 [number_of_cards] 张虚无脚本并放到内存队列顶部"
	card_generate_status_cards.card_type = CardData.CARD_TYPES.SKILL
	card_generate_status_cards.card_rarity = CardData.CARD_RARITIES.COMMON
	card_generate_status_cards.card_requires_target = false
	card_generate_status_cards.card_keyword_object_ids = []
	card_generate_status_cards.card_values = {"created_card_object_id": "card_ethereal_status",  "number_of_cards": 2}
	card_generate_status_cards.card_upgrade_value_improvements = {"number_of_cards": 1}
	card_generate_status_cards.card_play_actions = [
	{
	Scripts.ACTION_CREATE_CARDS: {
		"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {}}]
		}
	},
	]
	
	Global.register_rod(card_generate_status_cards)
	
	# Generated card
	var card_ethereal_status: CardData = CardData.new("card_ethereal_status")
	card_ethereal_status.card_name = "状态"
	card_ethereal_status.card_color_id = "color_white"
	card_ethereal_status.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_ethereal_status.card_description = "时钟周期结束时读取 [draw_count] 个脚本"
	card_ethereal_status.card_type = CardData.CARD_TYPES.STATUS
	card_ethereal_status.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_ethereal_status.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_ethereal_status.card_is_playable = false
	card_ethereal_status.card_values = {"draw_count": 1}
	card_ethereal_status.card_end_of_turn_actions = [
		{
		Scripts.ACTION_DRAW_GENERATOR: {},
		},
	]
	
	Global.register_rod(card_ethereal_status)
	
	# Energy on discard card
	var card_energy_on_discard: CardData = CardData.new("card_energy_on_discard")
	card_energy_on_discard.card_name = "算力回收"
	card_energy_on_discard.card_color_id = "color_green"
	card_energy_on_discard.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_energy_on_discard.card_description = "弃置时获得 [energy_amount_energy_icons]。"
	card_energy_on_discard.card_is_playable = false
	card_energy_on_discard.card_type = CardData.CARD_TYPES.SKILL
	card_energy_on_discard.card_rarity = CardData.CARD_RARITIES.COMMON
	card_energy_on_discard.card_requires_target = false
	card_energy_on_discard.card_values = {"energy_amount": 2}
	card_energy_on_discard.card_upgrade_value_improvements = {"energy_amount": 1}
	card_energy_on_discard.card_first_upgrade_property_changes = {"card_description": "弃置时获得 [energy_amount_energy_icons]。"}
	card_energy_on_discard.card_discard_actions = [
	{
	Scripts.ACTION_ADD_ENERGY: {}
	},
	]
	
	Global.register_rod(card_energy_on_discard)

	# Discard hand and draw 2 card
	var card_discard_hand: CardData = CardData.new("card_discard_hand")
	card_discard_hand.card_name = "丢弃当前线程"
	card_discard_hand.card_color_id = "color_blue"
	card_discard_hand.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_discard_hand.card_description = "弃置所有当前线程。读取 [draw_count] 个脚本。"
	card_discard_hand.card_type = CardData.CARD_TYPES.SKILL
	card_discard_hand.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_discard_hand.card_requires_target = false
	card_discard_hand.card_values = {"draw_count": 2}
	card_discard_hand.card_upgrade_value_improvements = {"draw_count": 1}
	card_discard_hand.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_discard_hand.card_play_actions = [
	{
	Scripts.ACTION_DRAW_GENERATOR: {},
	},
	{
	Scripts.ACTION_PICK_CARDS: {
		"max_card_amount": 10,
		"min_card_amount": 10,
		"min_cards_are_required_for_action": false,
		"random_selection": true,
		"card_pick_type": HandManager.HAND_PILE,
		"card_pick_text": "",
		"action_data": [{Scripts.ACTION_DISCARD_CARDS: {}}]
		}
	},
	]

	Global.register_rod(card_discard_hand)
	
	# Attack card that forces the target to cycle their intent
	var card_cycle_enemy_intent: CardData = CardData.new("card_cycle_enemy_intent")
	card_cycle_enemy_intent.card_name = "循环意图"
	card_cycle_enemy_intent.card_color_id = "color_green"
	card_cycle_enemy_intent.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_cycle_enemy_intent.card_description = "造成 [damage] 点伤害并强制敌人切换其意图。"
	card_cycle_enemy_intent.card_type = CardData.CARD_TYPES.ATTACK
	card_cycle_enemy_intent.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_cycle_enemy_intent.card_keyword_object_ids = []
	card_cycle_enemy_intent.card_values = {"damage": 5, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_cycle_enemy_intent.card_upgrade_value_improvements = {"damage": 3}
	card_cycle_enemy_intent.card_play_actions = [
		{
		Scripts.ACTION_CYCLE_ENEMY_INTENT: {"time_delay": 0.0}
		},
		{
		Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
		}
	]
	
	Global.register_rod(card_cycle_enemy_intent)
	
	# Block if no attacks in hand
	var card_block_without_attacks: CardData = CardData.new("card_block_without_attacks")
	card_block_without_attacks.card_name = "无攻击防火墙"
	card_block_without_attacks.card_color_id = "color_green"
	card_block_without_attacks.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_block_without_attacks.card_description = "获得 [block] 点防火墙。当前线程中有攻击脚本时无法调用。"
	card_block_without_attacks.card_type = CardData.CARD_TYPES.SKILL
	card_block_without_attacks.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_block_without_attacks.card_requires_target = false
	card_block_without_attacks.card_keyword_object_ids = ["keyword_block"]
	card_block_without_attacks.card_values = {"block": 15}
	card_block_without_attacks.card_upgrade_value_improvements = {"block": 5}
	card_block_without_attacks.card_play_actions = [
		{
		Scripts.ACTION_BLOCK: 
			{
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
			}
		}
	]
	card_block_without_attacks.card_play_validators = [
		{
		Scripts.VALIDATOR_CARD_TYPE_IN_HAND: 
			{
			"card_type_minimum": 0,
			"card_type_maximum": 0,
			"card_types": [
				CardData.CARD_TYPES.ATTACK
			],
			"invert_validation": false,
			}
		}
	]

	Global.register_rod(card_block_without_attacks)
	
	# Attack that costs less per each card discarded
	var card_attack_lower_cost_on_discard: CardData = CardData.new("card_attack_lower_cost_on_discard")
	card_attack_lower_cost_on_discard.card_name = "降能攻击"
	card_attack_lower_cost_on_discard.card_color_id = "color_red"
	card_attack_lower_cost_on_discard.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_lower_cost_on_discard.card_energy_cost = 7
	card_attack_lower_cost_on_discard.card_description = "造成 [damage] 点伤害。本时钟周期每弃置一个脚本费用降低。"
	card_attack_lower_cost_on_discard.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_lower_cost_on_discard.card_rarity = CardData.CARD_RARITIES.COMMON
	card_attack_lower_cost_on_discard.card_requires_target = true
	card_attack_lower_cost_on_discard.card_values = {"damage": 30, "number_of_attacks": 1,  "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_attack_lower_cost_on_discard.card_upgrade_value_improvements = {"damage": 10}
	card_attack_lower_cost_on_discard.card_play_actions = [
		{
		Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
		}
	]
	card_attack_lower_cost_on_discard.add_card_decorator("card_decorator_dynamic_cost_modifier", {
		"modifiy_card_energy_cost_until_combat": false,
		"modifiy_card_energy_cost_until_played": false,
		"modifiy_card_energy_cost_until_turn": true,
		"stat_enum": CombatStatsData.STATS.CARDS_DISCARDED,
		"is_turn_stat": true,
		"energy_per_stat": -2
		})

	Global.register_rod(card_attack_lower_cost_on_discard)
	
	# Attack that costs more per each time damage taken
	var card_attack_increase_cost_on_damage_taken: CardData = CardData.new("card_attack_increase_cost_on_damage_taken")
	card_attack_increase_cost_on_damage_taken.card_name = "增能攻击"
	card_attack_increase_cost_on_damage_taken.card_color_id = "color_green"
	card_attack_increase_cost_on_damage_taken.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_attack_increase_cost_on_damage_taken.card_energy_cost = 0
	card_attack_increase_cost_on_damage_taken.card_description = "造成 [damage] 点伤害。本场战斗中每受到一次伤害，费用增加 1 点 {0}".format([Card.ENERGY_ICON_KEYWORD])
	card_attack_increase_cost_on_damage_taken.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_increase_cost_on_damage_taken.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_attack_increase_cost_on_damage_taken.card_requires_target = true
	card_attack_increase_cost_on_damage_taken.card_values = {"damage": 10, "number_of_attacks": 1,  "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_attack_increase_cost_on_damage_taken.card_upgrade_value_improvements = {"damage": 10}
	card_attack_increase_cost_on_damage_taken.card_play_actions = [
		{
		Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
		}
	]
	card_attack_increase_cost_on_damage_taken.add_card_decorator("card_decorator_dynamic_cost_modifier", {
		"modifiy_card_energy_cost_until_combat": true,
		"modifiy_card_energy_cost_until_played": false,
		"modifiy_card_energy_cost_until_turn": false,
		"stat_enum": CombatStatsData.STATS.PLAYER_DAMAGED_COUNT,
		"is_turn_stat": false,
		"energy_per_stat": 1
		})

	Global.register_rod(card_attack_increase_cost_on_damage_taken)
	
	# Block if a card exhausted this turn
	var card_block_if_exhaust: CardData = CardData.new("card_block_if_exhaust")
	card_block_if_exhaust.card_name = "物理删除时防火墙"
	card_block_if_exhaust.card_color_id = "color_orange"
	card_block_if_exhaust.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_block_if_exhaust.card_description = "获得 [block] 点防火墙。本时钟周期没有物理删除过脚本时无法调用。"
	card_block_if_exhaust.card_type = CardData.CARD_TYPES.SKILL
	card_block_if_exhaust.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_block_if_exhaust.card_requires_target = false
	card_block_if_exhaust.card_energy_cost = 0
	card_block_if_exhaust.card_keyword_object_ids = ["keyword_block", "keyword_exhaust"]
	card_block_if_exhaust.card_values = {"block": 8}
	card_block_if_exhaust.card_upgrade_value_improvements = {"block": 4}
	card_block_if_exhaust.card_play_actions = [
		{
		Scripts.ACTION_BLOCK: 
			{
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
			}
		}
	]
	card_block_if_exhaust.card_play_validators = [
		{
		Scripts.VALIDATOR_COMBAT_STATS: 
			{
			"stat_enum": CombatStatsData.STATS.CARDS_EXHAUSTED,
			"is_total_stat": false,
			"operator": ">=",
			"comparison_value": 1,
			}
		}
	]
	
	Global.register_rod(card_block_if_exhaust)
	
	# Position based card
	var card_attack_in_center_of_hand: CardData = CardData.new("card_attack_in_center")
	card_attack_in_center_of_hand.card_name = "中心攻击"
	card_attack_in_center_of_hand.card_color_id = "color_red"
	card_attack_in_center_of_hand.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_attack_in_center_of_hand.card_description = "造成 [damage] 点伤害。只能在当前线程正中间时调用。"
	card_attack_in_center_of_hand.card_type = CardData.CARD_TYPES.ATTACK
	card_attack_in_center_of_hand.card_rarity = CardData.CARD_RARITIES.COMMON
	card_attack_in_center_of_hand.card_requires_target = true
	card_attack_in_center_of_hand.card_values = {"damage": 5, "number_of_attacks": 1,  "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_attack_in_center_of_hand.card_upgrade_value_improvements = {"damage": 5}
	card_attack_in_center_of_hand.card_play_actions = [
		{
		Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0, "actions_on_lethal": []}
		}
	]
	card_attack_in_center_of_hand.card_play_validators = [
		{
		Scripts.VALIDATOR_CARD_POSITION_IN_HAND:
			{
			"position_in_hand": "center",
			"invert_validation": false,
			}
		}
	]

	Global.register_rod(card_attack_in_center_of_hand)
	
	# Hand adjacency based card
	# Requires others next to it in order to work
	var card_requires_adjacency: CardData = CardData.new("card_requires_adjacency")
	card_requires_adjacency.card_name = "相邻攻击"
	card_requires_adjacency.card_color_id = "color_red"
	card_requires_adjacency.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_requires_adjacency.card_description = "造成 [damage] 点伤害。只有在至少一个攻击脚本相邻时才能调用。"
	card_requires_adjacency.card_type = CardData.CARD_TYPES.ATTACK
	card_requires_adjacency.card_rarity = CardData.CARD_RARITIES.COMMON
	card_requires_adjacency.card_requires_target = true
	card_requires_adjacency.card_values = {"damage": 10, "number_of_attacks": 1,  "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_requires_adjacency.card_upgrade_value_improvements = {"damage": 5}
	card_requires_adjacency.card_play_actions = [
		{
		Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0}
		}
	]
	card_requires_adjacency.card_play_validators = [
		{
		Scripts.VALIDATOR_CARD_TYPE_ADJACENT_IN_HAND:
			{
			"card_types": [CardData.CARD_TYPES.ATTACK],
			"requires_surrounded": false,
			"invert_validation": false,
			}
		}
	]

	Global.register_rod(card_requires_adjacency)
	
	# Discards adjacent cards in hand
	var card_discard_adjacent_cards: CardData = CardData.new("card_discard_adjacent_cards")
	card_discard_adjacent_cards.card_name = "丢弃相邻脚本"
	card_discard_adjacent_cards.card_color_id = "color_green"
	card_discard_adjacent_cards.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_discard_adjacent_cards.card_description = "弃置相邻的脚本。每弃置一个获得 [block] 点防火墙"
	card_discard_adjacent_cards.card_type = CardData.CARD_TYPES.SKILL
	card_discard_adjacent_cards.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_discard_adjacent_cards.card_requires_target = false
	card_discard_adjacent_cards.card_values = {"block": 5}
	card_discard_adjacent_cards.card_upgrade_value_improvements = {"block": 2}
	card_discard_adjacent_cards.card_play_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"max_card_amount": 0,
			"min_card_amount": 2,
			"min_cards_are_required_for_action": false,
			"random_selection": true,
			"card_pick_type": ActionBasePickCards.PICK_ADJACENT_CARDS,
			"card_pick_text": "",
			"action_data": [
				# improve effect for each discarded card
				{Scripts.ACTION_VARIABLE_CARDSET_MODIFIER: {
					"multiplied_values": ["block"],
					"action_data": [{Scripts.ACTION_BLOCK: {
						"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
						"time_delay": 0.1,
						}}]
				}},
				# discard the cards
				{Scripts.ACTION_DISCARD_CARDS: {}},
				]
			}
		},
	]
	
	Global.register_rod(card_discard_adjacent_cards)
	
	# Applies a decorate to adjacent cards in hand
	var card_decorate_adjacent_cards: CardData = CardData.new("card_decorate_adjacent_cards")
	card_decorate_adjacent_cards.card_name = "装饰相邻脚本"
	card_decorate_adjacent_cards.card_color_id = "color_green"
	card_decorate_adjacent_cards.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_decorate_adjacent_cards.card_description = "相邻的脚本调用时会额外获得 5 点防火墙。"
	card_decorate_adjacent_cards.card_type = CardData.CARD_TYPES.SKILL
	card_decorate_adjacent_cards.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_decorate_adjacent_cards.card_requires_target = false
	card_decorate_adjacent_cards.card_values = {"block": 5, "decorate_parent_card": false, "card_decorator_object_id": "card_decorator_block_on_play", "card_decorator_values": {}}
	card_decorate_adjacent_cards.card_upgrade_value_improvements = {"block": 2}
	card_decorate_adjacent_cards.card_play_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"max_card_amount": 0,
			"min_card_amount": 2,
			"min_cards_are_required_for_action": false,
			"random_selection": true,
			"card_pick_type": ActionBasePickCards.PICK_ADJACENT_CARDS,
			"card_pick_text": "选择 {0} 个脚本装饰。已选 {1} 个",
			"action_data": [
				{Scripts.ACTION_DECORATE_CARDS: {}},
				]
			}
		},
	]
	
	Global.register_rod(card_decorate_adjacent_cards)
	
	# Swap cards in hand
	var card_swap_hand_cards: CardData = CardData.new("card_swap_hand_cards")
	card_swap_hand_cards.card_name = "交换脚本"
	card_swap_hand_cards.card_color_id = "color_blue"
	card_swap_hand_cards.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_swap_hand_cards.card_description = "交换当前线程中 2 个脚本的位置"
	card_swap_hand_cards.card_type = CardData.CARD_TYPES.SKILL
	card_swap_hand_cards.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_swap_hand_cards.card_requires_target = false
	card_swap_hand_cards.card_play_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			# must be exactly 2 cards
			"max_card_amount": 2,
			"min_card_amount": 2,
			"min_cards_are_required_for_action": true,
			"random_selection": false,
			"quick_pick": true,
			"card_pick_type": HandManager.HAND_PILE,
			"card_pick_text": "选择 {0} 个脚本交换。已选 {1} 个",
			"action_data": [
				{Scripts.ACTION_SWAP_HAND_CARDS: {}},
				]
			}
		},
	]
	
	Global.register_rod(card_swap_hand_cards)
	
	# Block and play a card from discard pile
	var card_play_cards_from_discard: CardData = CardData.new("card_play_from_discard")
	card_play_cards_from_discard.card_name = "从回收站调用"
	card_play_cards_from_discard.card_color_id = "color_blue"
	card_play_cards_from_discard.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_play_cards_from_discard.card_description = "获得 [block] 点防火墙。从回收站中调用一个脚本。"
	card_play_cards_from_discard.card_type = CardData.CARD_TYPES.SKILL
	card_play_cards_from_discard.card_rarity = CardData.CARD_RARITIES.COMMON
	card_play_cards_from_discard.card_requires_target = false
	card_play_cards_from_discard.card_keyword_object_ids = ["keyword_block"]
	card_play_cards_from_discard.card_values = {"block": 3}
	card_play_cards_from_discard.card_upgrade_value_improvements = {"block": 2}
	card_play_cards_from_discard.card_play_actions = [
		{
		Scripts.ACTION_BLOCK: 
			{
			"time_delay": 0.5,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT
			}
		},
		{
		Scripts.ACTION_PICK_CARDS: {
			"max_card_amount": 1,
			"min_card_amount": 1,
			"min_cards_are_required_for_action": true,
			"random_selection": false,
			"card_pick_type": HandManager.DISCARD_PILE,
			"card_pick_text": "选择 {0} 个脚本调用。已选 {1} 个",
			"action_data": [{Scripts.ACTION_PLAY_CARDS: {}}]
			}
		},
	]

	Global.register_rod(card_play_cards_from_discard)
	
	# Discard up to the top 3 attacks from draw pile
	var card_discard_attacks_from_draw: CardData = CardData.new("card_discard_attacks_from_draw")
	card_discard_attacks_from_draw.card_name = "丢弃脚本库攻击脚本"
	card_discard_attacks_from_draw.card_color_id = "color_blue"
	card_discard_attacks_from_draw.card_texture_path = "external/sprites/cards/blue/card_blue.png"
	card_discard_attacks_from_draw.card_description = "弃置内存队列顶部最多 [pickable_cards_max_amount] 个攻击脚本。"
	card_discard_attacks_from_draw.card_type = CardData.CARD_TYPES.SKILL
	card_discard_attacks_from_draw.card_rarity = CardData.CARD_RARITIES.COMMON
	card_discard_attacks_from_draw.card_first_shuffle_priority = 1
	card_discard_attacks_from_draw.card_requires_target = false
	card_discard_attacks_from_draw.card_keyword_object_ids = ["keyword_block"]
	card_discard_attacks_from_draw.card_values = {"pickable_cards_max_amount": 3}
	card_discard_attacks_from_draw.card_upgrade_value_improvements = {"pickable_cards_max_amount": 1}
	card_discard_attacks_from_draw.card_play_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"max_card_amount": 999,
			"min_card_amount": 0,
			"min_cards_are_required_for_action": true,
			"random_selection": false,
			"card_pick_type": HandManager.DRAW_PILE,
			"card_pick_text": "选择 {3} 个攻击脚本弃置。已选 {1} 个",
			"action_data": [{Scripts.ACTION_DISCARD_CARDS: {}}],
			# only attack cards allowed
			"validator_data": [
			{Scripts.VALIDATOR_CARD_TYPE: {"card_types": [CardData.CARD_TYPES.ATTACK]}},
			],
			}
		},
	]

	Global.register_rod(card_discard_attacks_from_draw)
	
	# Play 2 random cards from hand
	var card_play_random_cards_from_hand: CardData = CardData.new("card_play_random_cards_from_hand")
	card_play_random_cards_from_hand.card_name = "调用随机当前线程"
	card_play_random_cards_from_hand.card_color_id = "color_red"
	card_play_random_cards_from_hand.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_play_random_cards_from_hand.card_description = "从当前线程中随机调用 2 个脚本。"
	card_play_random_cards_from_hand.card_type = CardData.CARD_TYPES.SKILL
	card_play_random_cards_from_hand.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_play_random_cards_from_hand.card_requires_target = false
	card_play_random_cards_from_hand.card_play_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"max_card_amount": 2,
			"min_card_amount": 2,
			"min_cards_are_required_for_action": false,
			"random_selection": true,
			"card_pick_type": HandManager.HAND_PILE,
			"card_pick_text": "选择 {0} 个脚本调用。已选 {1} 个",
			"action_data": [{Scripts.ACTION_PLAY_CARDS: {}}]
			}
		},
	]

	Global.register_rod(card_play_random_cards_from_hand)
	
	# Select cards to retain
	var card_retain_hand: CardData = CardData.new("card_retain_hand")
	card_retain_hand.card_name = "保留脚本"
	card_retain_hand.card_color_id = "color_orange"
	card_retain_hand.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_retain_hand.card_description = "选择 [min_card_amount] 个脚本在时钟周期结束时保留。"
	card_retain_hand.card_type = CardData.CARD_TYPES.SKILL
	card_retain_hand.card_rarity = CardData.CARD_RARITIES.COMMON
	card_retain_hand.card_requires_target = false
	card_retain_hand.card_keyword_object_ids = ["keyword_retain"]
	card_retain_hand.card_values = {"min_card_amount": 2, "max_card_amount": 2,}
	card_retain_hand.card_upgrade_value_improvements = {"min_card_amount": 1, "max_card_amount": 1,}
	card_retain_hand.card_play_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"min_cards_are_required_for_action": false,
			"random_selection": false,
			"card_pick_type": HandManager.HAND_PILE,
			"card_pick_text": "选择 {0} 个脚本保留。已选 {1} 个",
			"action_data": [{Scripts.ACTION_RETAIN_CARDS: {}}]
			}
		},
	]

	Global.register_rod(card_retain_hand)
	
	# Select cards to exhaust in hand
	var card_exhaust_card_in_hand: CardData = CardData.new("card_exhaust_card_in_hand")
	card_exhaust_card_in_hand.card_name = "物理删除脚本"
	card_exhaust_card_in_hand.card_color_id = "color_orange"
	card_exhaust_card_in_hand.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_exhaust_card_in_hand.card_description = "选择 [min_card_amount] 个脚本物理删除。"
	card_exhaust_card_in_hand.card_type = CardData.CARD_TYPES.SKILL
	card_exhaust_card_in_hand.card_rarity = CardData.CARD_RARITIES.COMMON
	card_exhaust_card_in_hand.card_requires_target = false
	card_exhaust_card_in_hand.card_keyword_object_ids = ["keyword_exhaust"]
	card_exhaust_card_in_hand.card_values = {"min_card_amount": 1, "max_card_amount": 1,}
	card_exhaust_card_in_hand.card_play_actions = [
		{
		Scripts.ACTION_PICK_CARDS: {
			"min_cards_are_required_for_action": true,
			"random_selection": false,
			"card_pick_type": HandManager.HAND_PILE,
			"card_pick_text": "选择 {0} 个脚本物理删除。已选 {1} 个",
			"action_data": [{Scripts.ACTION_EXHAUST_CARDS: {}}]
			}
		},
	]

	Global.register_rod(card_exhaust_card_in_hand)
	
	# Select cards to upgrade permanently
	var card_upgrade_card: CardData = CardData.new("card_upgrade_card")
	card_upgrade_card.card_name = "升级脚本"
	card_upgrade_card.card_color_id = "color_green"
	card_upgrade_card.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_upgrade_card.card_description = "选择一个脚本永久升级。"
	card_upgrade_card.card_type = CardData.CARD_TYPES.SKILL
	card_upgrade_card.card_rarity = CardData.CARD_RARITIES.RARE
	card_upgrade_card.card_requires_target = false
	card_upgrade_card.card_values = {"upgrade_parent_card": false}
	card_upgrade_card.card_play_actions = [
		{
		Scripts.ACTION_PICK_UPGRADE_CARDS: {
			"max_card_amount": 1,
			"min_card_amount": 1,
			"min_cards_are_required_for_action": true,
			"random_selection": false,
			"card_pick_type": HandManager.DECK,
			"card_pick_text": "选择一个脚本升级。"
			}
		},
	]

	Global.register_rod(card_upgrade_card)
	
	# Upgrade all cards in combat deck card
	var card_upgrade_entire_deck: CardData = CardData.new("card_upgrade_entire_deck")
	card_upgrade_entire_deck.card_name = "升级战斗脚本库"
	card_upgrade_entire_deck.card_color_id = "color_white"
	card_upgrade_entire_deck.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_upgrade_entire_deck.card_description = "本场战斗中升级脚本库中的所有脚本。"
	card_upgrade_entire_deck.card_type = CardData.CARD_TYPES.SKILL
	card_upgrade_entire_deck.card_rarity = CardData.CARD_RARITIES.RARE
	card_upgrade_entire_deck.card_requires_target = false
	card_upgrade_entire_deck.card_play_destination = HandManager.EXHAUST_PILE
	card_upgrade_entire_deck.card_energy_cost = 3
	card_upgrade_entire_deck.card_values = {"upgrade_parent_card": false}
	card_upgrade_entire_deck.card_play_actions = [
		{
		Scripts.ACTION_PICK_UPGRADE_CARDS: {
			"max_card_amount": 999,
			"min_card_amount": 999,
			"min_cards_are_required_for_action": false,
			"random_selection": false,
			"card_pick_type": HandManager.COMBAT_DECK,
			"card_pick_text": "选择 {0} 个脚本升级。已选 {1} 个"
			}
		},
	]

	Global.register_rod(card_upgrade_entire_deck)
	
	# Pick one of 3 random attacks and add to hand
	var card_draft_random_attack: CardData = CardData.new("card_draft_random_attack")
	card_draft_random_attack.card_name = "加载取攻击脚本"
	card_draft_random_attack.card_color_id = "color_green"
	card_draft_random_attack.card_texture_path = "external/sprites/cards/green/card_green.png"
	card_draft_random_attack.card_description = "从 3 个攻击脚本中选择一个加入当前线程。\n本场战斗中其费用为 0"
	card_draft_random_attack.card_type = CardData.CARD_TYPES.SKILL
	card_draft_random_attack.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_draft_random_attack.card_requires_target = false
	card_draft_random_attack.card_play_destination = HandManager.EXHAUST_PILE
	card_draft_random_attack.card_values = {}
	card_draft_random_attack.card_upgrade_value_improvements = {}
	card_draft_random_attack.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_draft_random_attack.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"max_card_amount": 1,
		"min_card_amount": 1,
		"draft_max_card_amount": 3,
		"min_cards_are_required_for_action": true,
		"draft_from_card_pool": true,
		"random_selection": false,
		"quick_pick": true,
		"card_pick_type": ActionBasePickCards.PICK_DRAFT,
		"card_pick_text": "选择一个攻击脚本",
		"action_data": [
			{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
			{Scripts.ACTION_CHANGE_CARD_ENERGIES: {"card_energy_cost_until_combat": 0}}
			],
		# only non-generated attack cards allowed
		"validator_data": [
			{Scripts.VALIDATOR_CARD_TYPE: {"card_types": [CardData.CARD_TYPES.ATTACK]}},
			{Scripts.VALIDATOR_CARD_RARITY: {"card_rarities_exclude": [CardData.CARD_RARITIES.GENERATED]}},
		],
		}
	},
	]

	Global.register_rod(card_draft_random_attack)
	
	# Pick a red card and add it to hand
	var card_draft_red_card: CardData = CardData.new("card_draft_red_card")
	card_draft_red_card.card_name = "加载猩红脚本"
	card_draft_red_card.card_color_id = "color_red"
	card_draft_red_card.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_draft_red_card.card_description = "从 5 个猩红脚本中选择一个加入当前线程。\n本场战斗中其费用为 0"
	card_draft_red_card.card_type = CardData.CARD_TYPES.SKILL
	card_draft_red_card.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_draft_red_card.card_requires_target = false
	card_draft_red_card.card_play_destination = HandManager.EXHAUST_PILE
	card_draft_red_card.card_values = {}
	card_draft_red_card.card_upgrade_value_improvements = {}
	card_draft_red_card.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_draft_red_card.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"max_card_amount": 1,
		"min_card_amount": 1,
		"draft_max_card_amount": 5,
		"min_cards_are_required_for_action": true,
		"draft_from_card_pool": true,
		"random_selection": false,
		"quick_pick": true,
		"card_pick_type": ActionBasePickCards.PICK_DRAFT,
		"card_pick_text": "选择一个红色脚本",
		"action_data": [
			{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
			{Scripts.ACTION_CHANGE_CARD_ENERGIES: {"card_energy_cost_until_combat": 0}}
			],
		# get red cards
		"draft_card_pack_id": "card_pack_red"
		}
	},
	]

	Global.register_rod(card_draft_red_card)
	
	# Adds a random card from the player's available card pool
	var card_draft_random_player_pool: CardData = CardData.new("card_draft_random_player_pool")
	card_draft_random_player_pool.card_name = "随机加载"
	card_draft_random_player_pool.card_color_id = "color_white"
	card_draft_random_player_pool.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_draft_random_player_pool.card_description = "从玩家的脚本库中随机添加一个脚本到当前线程。其费用为 0"
	card_draft_random_player_pool.card_type = CardData.CARD_TYPES.SKILL
	card_draft_random_player_pool.card_rarity = CardData.CARD_RARITIES.RARE
	card_draft_random_player_pool.card_requires_target = false
	card_draft_random_player_pool.card_play_destination = HandManager.EXHAUST_PILE
	card_draft_random_player_pool.card_values = {"draw_count": 2}
	card_draft_random_player_pool.card_upgrade_value_improvements = {}
	card_draft_random_player_pool.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_draft_random_player_pool.card_play_actions = [
	{
	Scripts.ACTION_PICK_CARDS: {
		"max_card_amount": 1,
		"min_card_amount": 1,
		"draft_max_card_amount": 1,
		"min_cards_are_required_for_action": true,
		"draft_from_card_pool": true,
		"random_selection": true,
		"quick_pick": true,
		"card_pick_type": ActionBasePickCards.PICK_DRAFT,
		"card_pick_text": "选择一个脚本",
		"action_data": [
			{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
			{Scripts.ACTION_CHANGE_CARD_ENERGIES: {"card_energy_cost_until_combat": 0}}
			],
		# non weighted draft from player draft pool
		"draft_use_player_draft": true,
		"draft_is_weighted": false,
		"draft_use_pity_system": false,
		}
	},
	]

	Global.register_rod(card_draft_random_player_pool)
	
	# Energy on play card
	# demonstrates [energy_icon] keyword
	var card_grant_energy: CardData = CardData.new("card_grant_energy")
	card_grant_energy.card_name = "算力脚本"
	card_grant_energy.card_color_id = "color_red"
	card_grant_energy.card_texture_path = "external/sprites/cards/red/card_red.png"
	card_grant_energy.card_description = "调用时获得 [energy_amount_energy_icons]。"
	card_grant_energy.card_is_playable = true
	card_grant_energy.card_energy_cost = 0
	card_grant_energy.card_type = CardData.CARD_TYPES.SKILL
	card_grant_energy.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_grant_energy.card_requires_target = false
	card_grant_energy.card_values = {"energy_amount": 2}
	card_grant_energy.card_upgrade_value_improvements = {"energy_amount": 1}
	card_grant_energy.card_first_upgrade_property_changes = {"card_description": "调用时获得 [energy_amount_energy_icons]。"}
	card_grant_energy.card_play_actions = [
	{
	Scripts.ACTION_ADD_ENERGY: {}
	}
	]
	
	Global.register_rod(card_grant_energy)
	
	# Energy on draw card
	var card_energy_on_draw: CardData = CardData.new("card_energy_on_draw")
	card_energy_on_draw.card_name = "算力加载脚本"
	card_energy_on_draw.card_color_id = "color_orange"
	card_energy_on_draw.card_texture_path = "external/sprites/cards/orange/card_orange.png"
	card_energy_on_draw.card_description = "被加载时获得 [energy_amount_energy_icons]。"
	card_energy_on_draw.card_is_playable = false
	card_energy_on_draw.card_type = CardData.CARD_TYPES.SKILL
	card_energy_on_draw.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_energy_on_draw.card_requires_target = false
	card_energy_on_draw.card_values = {"energy_amount": 2}
	card_energy_on_draw.card_upgrade_value_improvements = {"energy_amount": 1}
	card_energy_on_draw.card_first_upgrade_property_changes = {"card_description": "被加载时获得 [energy_amount_energy_icons]。"}
	card_energy_on_draw.card_draw_actions = [
	{
	Scripts.ACTION_ADD_ENERGY: {}
	}
	]
	
	Global.register_rod(card_energy_on_draw)
	
	# Health
	var card_add_health: CardData = CardData.new("card_add_health")
	card_add_health.card_name = "恢复完整度"
	card_add_health.card_color_id = "color_white"
	card_add_health.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_add_health.card_description = "获得 [health_amount] 点完整度和 [health_max_amount] 点最大完整度"
	card_add_health.card_type = CardData.CARD_TYPES.SKILL
	card_add_health.card_rarity = CardData.CARD_RARITIES.RARE
	card_add_health.card_requires_target = false
	card_add_health.card_play_destination = HandManager.EXHAUST_PILE
	card_add_health.card_values = {"health_amount": 3, "health_max_amount": 3}
	card_add_health.card_upgrade_value_improvements = {"health_amount": 1, "health_max_amount": 1}
	card_add_health.card_play_actions = [
	{
	Scripts.ACTION_ADD_HEALTH: {
		"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
	}
	}
	]
	
	Global.register_rod(card_add_health)
	
	# Quest card
	# adds a rest action to transform it when added to deck
	var card_quest: CardData = CardData.new("card_quest")
	card_quest.card_name = "后台任务脚本"
	card_quest.card_color_id = "color_white"
	card_quest.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_quest.card_description = "在待机节点可将其转化为奖励"
	card_quest.card_type = CardData.CARD_TYPES.CURSE
	card_quest.card_rarity = CardData.CARD_RARITIES.COMMON
	card_quest.card_appears_in_card_packs = false # cannot appear in packs
	card_quest.card_is_playable = false
	card_quest.card_add_to_deck_actions = [
		{Scripts.ACTION_UPDATE_REST_ACTIONS: {"add_rest_action_object_ids": ["rest_action_transform_quest_card"]}}
	]
	Global.register_rod(card_quest)
	
	# Quest reward
	var card_quest_reward: CardData = CardData.new("card_quest_reward")
	card_quest_reward.card_name = "任务奖励攻击"
	card_quest_reward.card_color_id = "color_white"
	card_quest_reward.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_quest_reward.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害"
	card_quest_reward.card_type = CardData.CARD_TYPES.ATTACK
	card_quest_reward.card_rarity = CardData.CARD_RARITIES.RARE
	card_quest_reward.card_appears_in_card_packs = false # cannot appear in packs
	card_quest_reward.card_keyword_object_ids = []
	card_quest_reward.card_values = {"damage": 20, "number_of_attacks": 1,  "impact_vfx_animation_id": "animation_vfx_impact_default"}
	card_quest_reward.card_upgrade_value_improvements = {"damage": 5}
	card_quest_reward.card_play_actions = [{
	Scripts.ACTION_ATTACK_GENERATOR: {"time_delay": 0.0}
	}]
	Global.register_rod(card_quest_reward)
	
	# Restart Combat Card
	# Mainly there for technical demonstration
	var card_restart_combat: CardData = CardData.new("card_restart_combat")
	card_restart_combat.card_name = "重置战斗"
	card_restart_combat.card_color_id = "color_white"
	card_restart_combat.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_restart_combat.card_description = "重新开始战斗"
	card_restart_combat.card_type = CardData.CARD_TYPES.SKILL
	card_restart_combat.card_rarity = CardData.CARD_RARITIES.RARE
	card_restart_combat.card_requires_target = false
	card_restart_combat.card_play_destination = HandManager.EXHAUST_PILE
	card_restart_combat.card_appears_in_card_packs = false # debug cards aren't draftable
	card_restart_combat.card_values = {}
	card_restart_combat.card_upgrade_value_improvements = {}
	card_restart_combat.card_play_actions = [
	{
	Scripts.ACTION_START_COMBAT: {}
	}
	]
	
	Global.register_rod(card_restart_combat)
	
	# Displays text messages in combat
	# debug card
	var card_talk: CardData = CardData.new("card_talk")
	card_talk.card_name = "发送消息"
	card_talk.card_color_id = "color_white"
	card_talk.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_talk.card_description = "让你说出 [message_bbcode]"
	card_talk.card_type = CardData.CARD_TYPES.SKILL
	card_talk.card_rarity = CardData.CARD_RARITIES.RARE
	card_talk.card_requires_target = false
	card_talk.card_play_destination = HandManager.DISCARD_PILE
	card_talk.card_appears_in_card_packs = false # debug cards aren't draftable
	card_talk.card_values = {"message_bbcode": "收到", "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}
	card_talk.card_upgrade_value_improvements = {}
	card_talk.card_first_upgrade_property_changes = {
		"card_description": "让所有战斗参与者说出 [message_bbcode]"
	}
	card_talk.card_first_upgrade_value_changes = {
		"target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS
	}
	card_talk.card_play_actions = [
		{
		Scripts.ACTION_TALK: {"time_delay": 0.75}
		},
	]
	
	Global.register_rod(card_talk)
	
	# Card that logs to console
	# debug card
	var card_debug_log: CardData = CardData.new("card_debug_log")
	card_debug_log.card_name = "记录到控制台"
	card_debug_log.card_color_id = "color_white"
	card_debug_log.card_texture_path = "external/sprites/cards/white/card_white.png"
	card_debug_log.card_description = "在控制台输出 [log_message]"
	card_debug_log.card_type = CardData.CARD_TYPES.SKILL
	card_debug_log.card_rarity = CardData.CARD_RARITIES.RARE
	card_debug_log.card_requires_target = false
	card_debug_log.card_appears_in_card_packs = false # debug cards aren't draftable
	card_debug_log.card_keyword_object_ids = []
	card_debug_log.card_values = {"log_message": "Hello World", "log_message_color_html": Color.SEA_GREEN.to_html(true)}
	card_debug_log.card_play_actions = [{
	Scripts.ACTION_DEBUG_LOG: {}
	}]
	
	Global.register_rod(card_debug_log)

#region Card Packs

func add_test_card_packs() -> void:
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
func add_test_artifact_packs() -> void:
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
func add_test_consumable_packs() -> void:
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
