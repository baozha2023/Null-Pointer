class_name GlobalProdArtifactsGenerator
extends RefCounted

static func generate_artifacts() -> void:
	add_artifacts()
	add_artifact_packs()


#region Artifacts
static func add_artifacts() -> void:
	var artifact_add_money: ArtifactData = ArtifactData.new("artifact_add_money")
	artifact_add_money.artifact_name = "零号铸币盒"
	artifact_add_money.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_add_money.artifact_texture_path = "sprites/artifacts/artifact_add_money.png"
	artifact_add_money.artifact_description = "获得时增加 [color=green]200[/color] 数据币。"
	artifact_add_money.artifact_add_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 200 } }]

	Global.register_rod(artifact_add_money)

	var artifact_high_latency: ArtifactData = ArtifactData.new("artifact_high_latency")
	artifact_high_latency.artifact_name = "拨号猫"
	artifact_high_latency.artifact_color_id = ""
	artifact_high_latency.artifact_texture_path = "sprites/artifacts/artifact_high_latency.png"
	artifact_high_latency.artifact_description = "每回合开始时，少抽 [color=red][artifact_counter][/color] 张牌。"
	artifact_high_latency.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_high_latency.artifact_appears_in_artifact_packs = false
	artifact_high_latency.artifact_counter_max = 999
	artifact_high_latency.artifact_counter = 1
	artifact_high_latency.artifact_first_turn_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_effect_object_id": "status_effect_high_latency",
				"custom_key_names": {
					"status_charge_amount": "artifact_counter"
				}
			},
		},
	]
	Global.register_rod(artifact_high_latency)

	var artifact_memory_leak: ArtifactData = ArtifactData.new("artifact_memory_leak")
	artifact_memory_leak.artifact_name = "漏水内存条"
	artifact_memory_leak.artifact_color_id = ""
	artifact_memory_leak.artifact_texture_path = "sprites/artifacts/artifact_memory_leak.png"
	artifact_memory_leak.artifact_description = "每回合开始时，失去 [color=red][artifact_counter][/color] 点完整度。"
	artifact_memory_leak.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_memory_leak.artifact_appears_in_artifact_packs = false
	artifact_memory_leak.artifact_counter_max = 999
	artifact_memory_leak.artifact_counter = 1
	artifact_memory_leak.artifact_first_turn_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_effect_object_id": "status_effect_memory_leak",
				"custom_key_names": {
					"status_charge_amount": "artifact_counter"
				}
			},
		},
	]
	Global.register_rod(artifact_memory_leak)

	var artifact_negate_money_gain: ArtifactData = ArtifactData.new("artifact_negate_money_gain")
	artifact_negate_money_gain.artifact_name = "永动超频核"
	artifact_negate_money_gain.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_negate_money_gain.artifact_texture_path = "sprites/artifacts/artifact_negate_money_gain.png"
	artifact_negate_money_gain.artifact_description = "每时钟周期获得 [energy_icon]。无法再获得数据币"
	artifact_negate_money_gain.artifact_add_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"energy_amount_max": 1,
			},
		},
	]
	artifact_negate_money_gain.artifact_remove_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"energy_amount_max": -1,
			},
		},
	]
	artifact_negate_money_gain.artifact_interceptor_ids = ["interceptor_negate_add_money"]

	Global.register_rod(artifact_negate_money_gain)

	var artifact_heal_on_combat_ended: ArtifactData = ArtifactData.new("artifact_heal_on_combat_ended")
	artifact_heal_on_combat_ended.artifact_name = "战地修复臂"
	artifact_heal_on_combat_ended.artifact_texture_path = "sprites/artifacts/artifact_heal_on_combat_ended.png"
	artifact_heal_on_combat_ended.artifact_description = "战斗结束时恢复 [color=green]5[/color] 点完整度。"
	artifact_heal_on_combat_ended.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_heal_on_combat_ended.artifact_end_of_combat_actions = [
		{
			Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 5 },
		},
	]

	Global.register_rod(artifact_heal_on_combat_ended)

	var artifact_auto_restore: ArtifactData = ArtifactData.new("artifact_auto_restore")
	artifact_auto_restore.artifact_name = "忒修斯修复舱"
	artifact_auto_restore.artifact_color_id = ""
	artifact_auto_restore.artifact_texture_path = "sprites/artifacts/artifact_auto_restore.png"
	artifact_auto_restore.artifact_description = "每场战斗开始时，完整度上限变为 [color=green]999[/color]，并完全恢复。"
	artifact_auto_restore.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT

	artifact_auto_restore.artifact_script_path = "res://scripts/artifacts/ArtifactAutoRestore.gd"

	Global.register_rod(artifact_auto_restore)

	var artifact_full_heal: ArtifactData = ArtifactData.new("artifact_full_heal")
	artifact_full_heal.artifact_name = "冷启动镜像"
	artifact_full_heal.artifact_texture_path = "sprites/artifacts/artifact_full_heal.png"
	artifact_full_heal.artifact_description = "获得时完全恢复完整度。"
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
	artifact_draw_on_kill.artifact_name = "收割进程"
	artifact_draw_on_kill.artifact_texture_path = "sprites/artifacts/artifact_draw_on_kill.png"
	artifact_draw_on_kill.artifact_description = "击杀敌人时读取 [color=blue]1[/color] 个脚本。"
	artifact_draw_on_kill.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_draw_on_kill.artifact_script_path = "res://scripts/artifacts/ArtifactDrawOnKill.gd"
	Global.register_rod(artifact_draw_on_kill)

	var artifact_draw_on_combat_start: ArtifactData = ArtifactData.new("artifact_draw_on_combat_start")
	artifact_draw_on_combat_start.artifact_name = "预读缓存"
	artifact_draw_on_combat_start.artifact_description = "首时钟周期额外读取 [color=blue]2[/color] 个脚本。"
	artifact_draw_on_combat_start.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BASIC
	artifact_draw_on_combat_start.artifact_color_id = "color_green"
	artifact_draw_on_combat_start.artifact_texture_path = "sprites/artifacts/artifact_draw_on_combat_start.png"
	artifact_draw_on_combat_start.artifact_first_turn_actions = [{ Scripts.ACTION_DRAW_GENERATOR: { "draw_count": 2 } }]

	Global.register_rod(artifact_draw_on_combat_start)

	var artifact_energy_on_combat_start: ArtifactData = ArtifactData.new("artifact_energy_on_combat_start")
	artifact_energy_on_combat_start.artifact_name = "启动电容"
	artifact_energy_on_combat_start.artifact_description = "首时钟周期获得 [energy_icon]。"
	artifact_energy_on_combat_start.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_energy_on_combat_start.artifact_texture_path = "sprites/artifacts/artifact_energy_on_combat_start.png"
	artifact_energy_on_combat_start.artifact_first_turn_actions = [{ Scripts.ACTION_ADD_ENERGY: { "energy_amount": 1 } }]

	Global.register_rod(artifact_energy_on_combat_start)

	var artifact_easy_mode: ArtifactData = ArtifactData.new("artifact_easy_mode")
	artifact_easy_mode.artifact_name = "安全模式开关"
	artifact_easy_mode.artifact_color_id = ""
	artifact_easy_mode.artifact_texture_path = "sprites/artifacts/artifact_easy_mode.png"
	artifact_easy_mode.artifact_description = "将敌人完整度设为 [color=red]1[/color]。"
	artifact_easy_mode.artifact_counter = 999
	artifact_easy_mode.artifact_counter_max = 999
	artifact_easy_mode.artifact_counter_reset_on_combat_end = -1
	artifact_easy_mode.artifact_counter_reset_on_turn_start = -1
	artifact_easy_mode.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_easy_mode.artifact_script_path = "res://scripts/artifacts/ArtifactEasyMode.gd"

	Global.register_rod(artifact_easy_mode)

	var artifact_data_scarcity: ArtifactData = ArtifactData.new("artifact_data_scarcity")
	artifact_data_scarcity.artifact_name = "荒漠限流阀"
	artifact_data_scarcity.artifact_color_id = ""
	artifact_data_scarcity.artifact_description = "获得的数据币收益减少 [color=red]20%[/color]。"
	artifact_data_scarcity.artifact_texture_path = "sprites/artifacts/artifact_data_scarcity.png"
	artifact_data_scarcity.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_data_scarcity.artifact_appears_in_artifact_packs = false
	artifact_data_scarcity.artifact_interceptor_ids = ["interceptor_reduce_add_money"]
	Global.register_rod(artifact_data_scarcity)

	var artifact_inflation: ArtifactData = ArtifactData.new("artifact_inflation")
	artifact_inflation.artifact_name = "价格操纵芯片"
	artifact_inflation.artifact_color_id = ""
	artifact_inflation.artifact_description = "商店所有商品价格上涨 [color=red]25%[/color]。"
	artifact_inflation.artifact_texture_path = "sprites/artifacts/artifact_inflation.png"
	artifact_inflation.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_inflation.artifact_appears_in_artifact_packs = false
	artifact_inflation.artifact_interceptor_ids = ["interceptor_increase_shop_price"]
	Global.register_rod(artifact_inflation)

	var artifact_data_abundance: ArtifactData = ArtifactData.new("artifact_data_abundance")
	artifact_data_abundance.artifact_name = "丰饶挖矿机"
	artifact_data_abundance.artifact_texture_path = "sprites/artifacts/artifact_data_abundance.png"
	artifact_data_abundance.artifact_description = "所有数据币获取量增加 [color=green]20%[/color]。"
	artifact_data_abundance.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_data_abundance.artifact_appears_in_artifact_packs = true
	artifact_data_abundance.artifact_interceptor_ids = ["interceptor_increase_add_money"]
	Global.register_rod(artifact_data_abundance)

	var artifact_deflation: ArtifactData = ArtifactData.new("artifact_deflation")
	artifact_deflation.artifact_name = "通货紧缩"
	artifact_deflation.artifact_texture_path = "sprites/artifacts/artifact_deflation.png"
	artifact_deflation.artifact_description = "商店所有商品价格下降 [color=green]25%[/color]。"
	artifact_deflation.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_deflation.artifact_appears_in_artifact_packs = true
	artifact_deflation.artifact_interceptor_ids = ["interceptor_decrease_shop_price"]
	Global.register_rod(artifact_deflation)

	var artifact_block_on_attacks: ArtifactData = ArtifactData.new("artifact_block_on_attacks")
	artifact_block_on_attacks.artifact_name = "动能防火墙"
	artifact_block_on_attacks.artifact_description = "每 [color=blue]3[/color] 次攻击获得 [color=blue]5[/color] 点防火墙。当前：[color=blue][artifact_counter][/color]/3"
	artifact_block_on_attacks.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BASIC
	artifact_block_on_attacks.artifact_color_id = "color_red"
	artifact_block_on_attacks.artifact_texture_path = "sprites/artifacts/artifact_block_on_attacks.png"
	artifact_block_on_attacks.artifact_script_path = "res://scripts/artifacts/ArtifactBlockOnAttacks.gd"
	artifact_block_on_attacks.artifact_counter_max = 3
	artifact_block_on_attacks.artifact_counter_wraparound = true
	artifact_block_on_attacks.artifact_counter_reset_on_turn_start = 0
	artifact_block_on_attacks.artifact_counter_reset_on_combat_end = 0
	artifact_block_on_attacks.artifact_max_counter_actions = [
		{
			Scripts.ACTION_BLOCK: { "block": 5, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP },
		},
	]

	Global.register_rod(artifact_block_on_attacks)

	var artifact_retain_hand: ArtifactData = ArtifactData.new("artifact_retain_hand")
	artifact_retain_hand.artifact_name = "线程冷冻舱"
	artifact_retain_hand.artifact_texture_path = "sprites/artifacts/artifact_retain_hand.png"
	artifact_retain_hand.artifact_description = "时钟周期结束时，当前线程中的所有脚本不会被丢弃"
	artifact_retain_hand.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_retain_hand.artifact_script_path = "res://scripts/artifacts/ArtifactRetainHand.gd"

	Global.register_rod(artifact_retain_hand)

	# preserves energy between turns
	var artifact_preserve_energy: ArtifactData = ArtifactData.new("artifact_preserve_energy")
	artifact_preserve_energy.artifact_name = "余量电容"
	artifact_preserve_energy.artifact_color_id = "color_orange"
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
	artifact_increase_attack_on_rest.artifact_name = "碎片整理臂"
	artifact_increase_attack_on_rest.artifact_description = "在维护终端可进行碎片整理。每场战斗开始时获得 [color=green]1[/color] 层 [status_icon:status_effect_damage_increase] 算力增幅（最高提升 [color=green]3[/color] 次）。当前次数：[color=green][artifact_counter][/color]/3"
	artifact_increase_attack_on_rest.artifact_counter = 0
	artifact_increase_attack_on_rest.artifact_counter_max = 3
	artifact_increase_attack_on_rest.artifact_color_id = "color_red"
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
	artifact_see_top_of_draw_pile.artifact_name = "内存探针"
	artifact_see_top_of_draw_pile.artifact_description = "可以预见内存队列顶部的脚本。\n[color=gray]（支持右键/双击操作）[/color]"
	artifact_see_top_of_draw_pile.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BASIC
	artifact_see_top_of_draw_pile.artifact_color_id = "color_blue"
	artifact_see_top_of_draw_pile.artifact_texture_path = "sprites/artifacts/artifact_see_top_of_draw_pile.png"
	artifact_see_top_of_draw_pile.artifact_right_click_actions = [
		{
			Scripts.ACTION_EMIT_CUSTOM_SIGNAL: {
				"custom_signal_object_id": "custom_signal_open_see_top_ui",
				"custom_signal_value": 0
			}
		}
	]
	Global.register_rod(artifact_see_top_of_draw_pile)

	var artifact_forge: ArtifactData = ArtifactData.new("artifact_forge")
	artifact_forge.artifact_name = "代码锻炉"
	artifact_forge.artifact_description = "解锁锻造台，提供高级的代码编译和改造功能。\n[color=gray]（支持右键/双击操作）[/color]"
	artifact_forge.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BASIC
	artifact_forge.artifact_color_id = "color_orange"
	artifact_forge.artifact_script_path = "res://scripts/artifacts/ArtifactForge.gd"
	artifact_forge.artifact_counter_max = 999
	artifact_forge.artifact_texture_path = "sprites/artifacts/artifact_forge.png"
	artifact_forge.artifact_right_click_actions = [
		{
			Scripts.ACTION_EMIT_CUSTOM_SIGNAL: {
				"custom_signal_object_id": "custom_signal_open_forge_ui",
				"custom_signal_value": 0
			}
		}
	]
	artifact_forge.artifact_turn_start_actions = [
		{Scripts.ACTION_TAKE_FROM_FORGE: {
			"take_type": ActionTakeFromForge.TAKE_TYPES.ALL,
			"clear_after_take": true,
			"execute_directly": false
		}}
	]
	Global.register_rod(artifact_forge)


	# Makes an attack card top deck when obtained
	var artifact_top_deck_attack_card: ArtifactData = ArtifactData.new("artifact_top_deck_attack_card")
	artifact_top_deck_attack_card.artifact_name = "红线调度器"
	artifact_top_deck_attack_card.artifact_texture_path = "sprites/artifacts/artifact_top_deck_attack_card.png"
	artifact_top_deck_attack_card.artifact_description = "选择一个攻击脚本置于内存队列顶部。"
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
				"card_pick_text": "选择一个脚本置于内存队列顶",
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
	artifact_right_click_shuffle_deck.artifact_name = "熵流路由器"
	artifact_right_click_shuffle_deck.artifact_description = "将回收站的数据重新分配入内存队列。\n[color=gray]（支持右键/双击操作）[/color]"
	artifact_right_click_shuffle_deck.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_right_click_shuffle_deck.artifact_color_id = "color_green"
	artifact_right_click_shuffle_deck.artifact_texture_path = "sprites/artifacts/artifact_right_click_shuffle_deck.png"
	artifact_right_click_shuffle_deck.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_right_click_shuffle_deck.artifact_right_click_actions = [
		{ Scripts.ACTION_RESHUFFLE: { } },
	]

	Global.register_rod(artifact_right_click_shuffle_deck)

	# 垃圾回收器：物理删除脚本时恢复完整度
	var artifact_garbage_collector: ArtifactData = ArtifactData.new("artifact_garbage_collector")
	artifact_garbage_collector.artifact_name = "垃圾回收器"
	artifact_garbage_collector.artifact_color_id = "color_green"
	artifact_garbage_collector.artifact_description = "每当一个脚本被物理删除时，恢复 [color=green]2[/color] 点完整度。"
	artifact_garbage_collector.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_garbage_collector.artifact_texture_path = "sprites/artifacts/artifact_garbage_collector.png"
	artifact_garbage_collector.artifact_script_path = "res://scripts/artifacts/ArtifactGarbageCollector.gd"

	Global.register_rod(artifact_garbage_collector)

	# 镜像流量复制：手动丢弃脚本时抽牌
	var artifact_traffic_mirroring: ArtifactData = ArtifactData.new("artifact_traffic_mirroring")
	artifact_traffic_mirroring.artifact_name = "镜像流量复制"
	artifact_traffic_mirroring.artifact_description = "每当手动丢弃一个脚本时，读取 [color=blue]1[/color] 个脚本。"
	artifact_traffic_mirroring.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_traffic_mirroring.artifact_texture_path = "sprites/artifacts/artifact_traffic_mirroring.png"
	artifact_traffic_mirroring.artifact_script_path = "res://scripts/artifacts/ArtifactTrafficMirroring.gd"

	Global.register_rod(artifact_traffic_mirroring)

	# 零信任网关：首回合AOE减益 + 自防
	var artifact_zero_trust_gateway: ArtifactData = ArtifactData.new("artifact_zero_trust_gateway")
	artifact_zero_trust_gateway.artifact_name = "零信任网关"
	artifact_zero_trust_gateway.artifact_description = "首时钟周期对所有敌人施加 [color=green]2[/color] 层漏洞暴露，并获得 [color=blue]4[/color] 点防火墙。"
	artifact_zero_trust_gateway.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_zero_trust_gateway.artifact_texture_path = "sprites/artifacts/artifact_zero_trust_gateway.png"
	artifact_zero_trust_gateway.artifact_first_turn_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
				"status_effect_object_id": "status_effect_vulnerable",
				"status_charge_amount": 2,
			},
		},
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"block": 4,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
	]

	Global.register_rod(artifact_zero_trust_gateway)

	# 热修复补丁：攻击充能 → 抽牌 + 回能
	var artifact_hotfix_patch: ArtifactData = ArtifactData.new("artifact_hotfix_patch")
	artifact_hotfix_patch.artifact_name = "热修复补丁"
	artifact_hotfix_patch.artifact_description = "每打出 3 次攻击，读取 1 个脚本并获得 [energy_icon]。"
	artifact_hotfix_patch.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_hotfix_patch.artifact_texture_path = "sprites/artifacts/artifact_hotfix_patch.png"
	artifact_hotfix_patch.artifact_script_path = "res://scripts/artifacts/ArtifactHotfixPatch.gd"
	artifact_hotfix_patch.artifact_counter_max = 3
	artifact_hotfix_patch.artifact_counter_wraparound = true
	artifact_hotfix_patch.artifact_counter_reset_on_turn_start = 0
	artifact_hotfix_patch.artifact_counter_reset_on_combat_end = 0
	artifact_hotfix_patch.artifact_max_counter_actions = [
		{ Scripts.ACTION_DRAW_GENERATOR: { "draw_count": 1 } },
		{ Scripts.ACTION_ADD_ENERGY: { "energy_amount": 1 } },
	]

	Global.register_rod(artifact_hotfix_patch)

	# 进程看门狗：濒死救援，单次触发后自移除
	var artifact_watchdog: ArtifactData = ArtifactData.new("artifact_watchdog")
	artifact_watchdog.artifact_name = "进程看门狗"
	artifact_watchdog.artifact_description = "每场战斗中，当完整度首次低于 [color=red]50%[/color] 时，恢复 [color=green]30%[/color] 最大完整度。触发后此外设被永久移除。"
	artifact_watchdog.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_watchdog.artifact_texture_path = "sprites/artifacts/artifact_watchdog.png"
	artifact_watchdog.artifact_script_path = "res://scripts/artifacts/ArtifactWatchdog.gd"

	Global.register_rod(artifact_watchdog)

	### New Cyberpunk Peripheral Artifacts ###

	# 1. U盘杀手 (USB Killer)
	var artifact_usb_killer: ArtifactData = ArtifactData.new("artifact_usb_killer")
	artifact_usb_killer.artifact_name = "U盘杀手"
	artifact_usb_killer.artifact_description = "每当你洗牌（将回收站洗入内存队列）时，对所有敌人造成 [color=red][artifact_counter][/color] 点伤害。"
	artifact_usb_killer.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
	artifact_usb_killer.artifact_texture_path = "sprites/artifacts/artifact_usb_killer.png"
	artifact_usb_killer.artifact_script_path = "res://scripts/artifacts/ArtifactUSBKiller.gd"
	artifact_usb_killer.artifact_counter = 5
	Global.register_rod(artifact_usb_killer)

	# 2. Oday数据库 (Zero-Day Database)
	var artifact_0day_database: ArtifactData = ArtifactData.new("artifact_0day_database")
	artifact_0day_database.artifact_name = "Oday数据库"
	artifact_0day_database.artifact_color_id = "color_blue"
	artifact_0day_database.artifact_description = "每场战斗中，你第一次给予敌人 [status_icon:status_effect_vulnerable] 时，层数额外 +[color=green][artifact_counter][/color]。"
	artifact_0day_database.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_0day_database.artifact_texture_path = "sprites/artifacts/artifact_0day_database.png"
	artifact_0day_database.artifact_script_path = "res://scripts/artifacts/ArtifactZeroDayDB.gd"
	artifact_0day_database.artifact_counter = 2
	artifact_0day_database.artifact_interceptor_ids = ["interceptor_zero_day_db"]
	Global.register_rod(artifact_0day_database)

	# 3. 备用电源 UPS (Uninterruptible Power Supply)
	var artifact_ups_battery: ArtifactData = ArtifactData.new("artifact_ups_battery")
	artifact_ups_battery.artifact_name = "备用电源 UPS"
	artifact_ups_battery.artifact_description = "你的回合结束时，如果有未消耗的算力，每剩余 1 点算力，获得 [color=blue][artifact_counter][/color] 点防火墙。"
	artifact_ups_battery.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_ups_battery.artifact_texture_path = "sprites/artifacts/artifact_ups_battery.png"
	artifact_ups_battery.artifact_script_path = "res://scripts/artifacts/ArtifactUPS.gd"
	artifact_ups_battery.artifact_counter = 4
	Global.register_rod(artifact_ups_battery)

	# 4. 物理信号干扰器 (Hardware Jammer)
	var artifact_hardware_jammer: ArtifactData = ArtifactData.new("artifact_hardware_jammer")
	artifact_hardware_jammer.artifact_name = "物理信号干扰器"
	artifact_hardware_jammer.artifact_description = "战斗开始时，给予所有敌人 [color=green][artifact_counter][/color] 层 [status_icon:status_effect_weaken]。"
	artifact_hardware_jammer.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_hardware_jammer.artifact_texture_path = "sprites/artifacts/artifact_hardware_jammer.png"
	artifact_hardware_jammer.artifact_script_path = "res://scripts/artifacts/ArtifactHardwareJammer.gd"
	artifact_hardware_jammer.artifact_counter = 1
	Global.register_rod(artifact_hardware_jammer)

	# 5. 暴力破解机 (Brute-Force Rig)
	var artifact_brute_force_rig: ArtifactData = ArtifactData.new("artifact_brute_force_rig")
	artifact_brute_force_rig.artifact_name = "暴力破解机"
	artifact_brute_force_rig.artifact_color_id = "color_red"
	artifact_brute_force_rig.artifact_description = "你的所有攻击脚本固定额外增加 [color=red]2[/color] 点伤害。但每回合的抽牌数减少 [color=red]1[/color] 张。"
	artifact_brute_force_rig.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_brute_force_rig.artifact_texture_path = "sprites/artifacts/artifact_brute_force_rig.png"
	artifact_brute_force_rig.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_brute_force_rig.artifact_interceptor_ids = ["interceptor_brute_force_attack", "interceptor_brute_force_draw"]
	Global.register_rod(artifact_brute_force_rig)

	# 6. 量子协处理器 (Quantum Coprocessor)
	var artifact_quantum_coprocessor: ArtifactData = ArtifactData.new("artifact_quantum_coprocessor")
	artifact_quantum_coprocessor.artifact_name = "量子协处理器"
	artifact_quantum_coprocessor.artifact_description = "每场战斗中你打出的前 [color=green][artifact_counter][/color] 张脚本，会触发两次。"
	artifact_quantum_coprocessor.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_quantum_coprocessor.artifact_texture_path = "sprites/artifacts/artifact_quantum_coprocessor.png"
	artifact_quantum_coprocessor.artifact_script_path = "res://scripts/artifacts/ArtifactQuantumCoproc.gd"
	artifact_quantum_coprocessor.artifact_counter = 1
	Global.register_rod(artifact_quantum_coprocessor)

	# 7. 智能路由器 (Smart Router)
	var artifact_smart_router: ArtifactData = ArtifactData.new("artifact_smart_router")
	artifact_smart_router.artifact_name = "智能路由器"
	artifact_smart_router.artifact_color_id = "color_orange"
	artifact_smart_router.artifact_description = "每当你打出一张辅助脚本时，有 [color=green][artifact_counter][/color]% 的概率不消耗算力。"
	artifact_smart_router.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.UNCOMMON
	artifact_smart_router.artifact_texture_path = "sprites/artifacts/artifact_smart_router.png"
	artifact_smart_router.artifact_script_path = "res://scripts/artifacts/ArtifactSmartRouter.gd"
	artifact_smart_router.artifact_counter = 25
	Global.register_rod(artifact_smart_router)

	# 8. 溢出堆栈 (Overflow Stack)
	var artifact_overflow_stack: ArtifactData = ArtifactData.new("artifact_overflow_stack")
	artifact_overflow_stack.artifact_name = "溢出堆栈"
	artifact_overflow_stack.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BOSS
	artifact_overflow_stack.artifact_description = "每时钟周期获得 [energy_icon]。但任何施加给你的负面状态层数默认增加 [color=red]1[/color] 层。"
	artifact_overflow_stack.artifact_texture_path = "sprites/artifacts/artifact_overflow_stack.png"
	artifact_overflow_stack.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_overflow_stack.artifact_interceptor_ids = ["interceptor_overflow_stack"]
	artifact_overflow_stack.artifact_add_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"energy_amount_max": 1,
			},
		},
	]
	artifact_overflow_stack.artifact_remove_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"energy_amount_max": -1,
			},
		},
	]
	Global.register_rod(artifact_overflow_stack)

	# 9. 壳中幽灵 (Ghost in the Shell)
	var artifact_ghost_in_shell: ArtifactData = ArtifactData.new("artifact_ghost_in_shell")
	artifact_ghost_in_shell.artifact_name = "壳中幽灵"
	artifact_ghost_in_shell.artifact_description = "每场战斗开始时，获得 [color=green][artifact_counter][/color] 层 [status_icon:status_effect_negate_damage] 伤害阻断。"
	artifact_ghost_in_shell.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_ghost_in_shell.artifact_texture_path = "sprites/artifacts/artifact_ghost_in_shell.png"
	artifact_ghost_in_shell.artifact_script_path = "res://scripts/artifacts/ArtifactGhostShell.gd"
	artifact_ghost_in_shell.artifact_counter = 1
	Global.register_rod(artifact_ghost_in_shell)

	# 10. 抓包工具 (Packet Sniffer)
	var artifact_packet_sniffer: ArtifactData = ArtifactData.new("artifact_packet_sniffer")
	artifact_packet_sniffer.artifact_name = "深网嗅探器"
	artifact_packet_sniffer.artifact_description = "每当你对敌人施加负面状态时，有 [color=green]50%[/color] 的概率读取 [color=blue]1[/color] 个脚本。"
	artifact_packet_sniffer.artifact_color_id = "color_blue"
	artifact_packet_sniffer.artifact_texture_path = "sprites/artifacts/artifact_packet_sniffer.png"
	artifact_packet_sniffer.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_packet_sniffer.artifact_interceptor_ids = ["interceptor_packet_sniffer"]
	Global.register_rod(artifact_packet_sniffer)

	# Debug Card Picker
	var artifact_debug_card_picker: ArtifactData = ArtifactData.new("artifact_debug_card_picker")
	artifact_debug_card_picker.artifact_name = "万能调试仪"
	artifact_debug_card_picker.artifact_description = "双击或右键打开全卡池，选择任意一张卡牌加入手牌。"
	artifact_debug_card_picker.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_debug_card_picker.artifact_texture_path = "sprites/artifacts/artifact_debug_card_picker.png"
	artifact_debug_card_picker.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_debug_card_picker.artifact_right_click_actions = [
		{
			Scripts.ACTION_DEBUG_PICK_ANY_CARD: {
				"max_card_amount": 1,
				"min_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"random_selection": false,
				"quick_pick": true,
				"can_back_out": true,
				"is_filter_enabled": true,
				"card_pick_text": "选择一张卡牌加入手牌",
				"action_data": [
					{ Scripts.ACTION_ADD_CARDS_TO_HAND: { } }
				]
			}
		}
	]
	Global.register_rod(artifact_debug_card_picker)

	# Debug Energy Adder
	var artifact_debug_energy_adder: ArtifactData = ArtifactData.new("artifact_debug_energy_adder")
	artifact_debug_energy_adder.artifact_name = "算力调试仪"
	artifact_debug_energy_adder.artifact_description = "双击或右键获得 [energy_icon]。"
	artifact_debug_energy_adder.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.EVENT
	artifact_debug_energy_adder.artifact_texture_path = "sprites/artifacts/artifact_debug_energy_adder.png"
	artifact_debug_energy_adder.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_debug_energy_adder.artifact_right_click_actions = [
		{ Scripts.ACTION_ADD_ENERGY: { "energy_amount": 1 } }
	]
	Global.register_rod(artifact_debug_energy_adder)

	# Taskmgr.exe
	var artifact_taskmgr: ArtifactData = ArtifactData.new("artifact_taskmgr")
	artifact_taskmgr.artifact_name = "任务管理器"
	artifact_taskmgr.artifact_description = "[右键点击]强制物理删除（消耗）手中所有费用 ≥ 2 的脚本。每删除一张，恢复 3 点完整度。"
	artifact_taskmgr.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.RARE
	artifact_taskmgr.artifact_texture_path = "sprites/artifacts/artifact_taskmgr.png"
	artifact_taskmgr.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
	artifact_taskmgr.artifact_right_click_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.HAND_PILE,
				"min_card_amount": 999,
				"max_card_amount": 999,
				"random_selection": true,
				"validator_data": [
					{Scripts.VALIDATOR_CARD_ENERGY_COST: {"comparison_value": 2, "operator": ">="}}
				],
				"action_data": [
					{Scripts.ACTION_EXHAUST_CARDS: {}},
					{
						Scripts.ACTION_VARIABLE_CARDSET_MODIFIER: {
							"action_data": [
								{Scripts.ACTION_ADD_HEALTH: {
									"health_amount": 3,
									"target_override": BaseAction.TARGET_OVERRIDES.PARENT
								}}
							],
							"multiplied_values": ["health_amount"]
						}
					}
				]
			}
		}
	]
	Global.register_rod(artifact_taskmgr)

	var artifact_eden_root_core := ArtifactData.new("artifact_eden_root_core")
	artifact_eden_root_core.artifact_name = "伊甸根核"
	artifact_eden_root_core.artifact_description = "每场战斗召唤位于友方前排的 [color=green]伊甸母树[/color]。与大树联动的脚本会自动取得此外设。"
	artifact_eden_root_core.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.BASIC
	artifact_eden_root_core.artifact_color_id = "color_green"
	artifact_eden_root_core.artifact_appears_in_artifact_packs = false
	artifact_eden_root_core.artifact_texture_path = "sprites/artifacts/artifact_eden_root_core.png"
	artifact_eden_root_core.artifact_add_actions = [{
		Scripts.ACTION_SUMMON_FRIENDLIES: {
			"friendly_object_ids": ["friendly_eden_world_tree"],
			"spawn_slots": [2],
			"number_of_spawns": 1,
		}
	}]
	artifact_eden_root_core.artifact_first_turn_actions = [{
		Scripts.ACTION_SUMMON_FRIENDLIES: {
			"friendly_object_ids": ["friendly_eden_world_tree"],
			"spawn_slots": [2],
			"number_of_spawns": 1,
		}
	}]
	Global.register_rod(artifact_eden_root_core)

	### Filler Artifacts
	#endregion



static func add_artifact_packs() -> void:
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
