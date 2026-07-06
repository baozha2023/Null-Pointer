class_name GlobalRunStartOptionsGenerator
extends RefCounted

static func add_run_start_options() -> void:
	### Downsides (PARTIAL_DOWNSIDE) - Existing
	var run_start_option_reduce_max_hp: RunStartOptionData = RunStartOptionData.new("run_start_option_reduce_max_hp")
	run_start_option_reduce_max_hp.run_start_option_bb_code = "[color=red]失去10点最大完整度[/color]"
	run_start_option_reduce_max_hp.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_reduce_max_hp.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_max_amount": -10 } }]
	Global.register_rod(run_start_option_reduce_max_hp)

	var run_start_option_take_damage: RunStartOptionData = RunStartOptionData.new("run_start_option_take_damage")
	run_start_option_take_damage.run_start_option_bb_code = "[color=red]失去5点完整度[/color]"
	run_start_option_take_damage.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_take_damage.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_amount": -5 } }]
	Global.register_rod(run_start_option_take_damage)

	var run_start_option_lose_money: RunStartOptionData = RunStartOptionData.new("run_start_option_lose_money")
	run_start_option_lose_money.run_start_option_bb_code = "[color=red]失去200数据币[/color]"
	run_start_option_lose_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_lose_money.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": -200 } }]
	Global.register_rod(run_start_option_lose_money)




	### NEW Downsides
	var run_start_option_reduce_max_hp_15: RunStartOptionData = RunStartOptionData.new("run_start_option_reduce_max_hp_15")
	run_start_option_reduce_max_hp_15.run_start_option_bb_code = "[color=red]失去15点最大完整度[/color]"
	run_start_option_reduce_max_hp_15.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_reduce_max_hp_15.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -15 } }]
	Global.register_rod(run_start_option_reduce_max_hp_15)

	# 1. Lose 15% max health
	var run_start_option_reduce_max_hp_pct: RunStartOptionData = RunStartOptionData.new("run_start_option_reduce_max_hp_pct")
	run_start_option_reduce_max_hp_pct.run_start_option_bb_code = "[color=red]失去15%最大完整度[/color]"
	run_start_option_reduce_max_hp_pct.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_reduce_max_hp_pct.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_percent": -0.15 } }]
	Global.register_rod(run_start_option_reduce_max_hp_pct)

	# 2. Take more damage (20)
	var run_start_option_take_damage_more: RunStartOptionData = RunStartOptionData.new("run_start_option_take_damage_more")
	run_start_option_take_damage_more.run_start_option_bb_code = "[color=red]失去20点完整度[/color]"
	run_start_option_take_damage_more.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_take_damage_more.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_amount": -20 } }]
	Global.register_rod(run_start_option_take_damage_more)

	# 3. Remove 1 card (Downside representation for some options, wait, removing a card is upside in deck builders. 
	# I'll make it "Gain a negative artifact" to represent losing early power)
	var run_start_option_inflation: RunStartOptionData = RunStartOptionData.new("run_start_option_inflation")
	run_start_option_inflation.run_start_option_bb_code = "[color=red]获得通货膨胀插件[/color]"
	run_start_option_inflation.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_inflation.run_start_option_actions = [{ Scripts.ACTION_ADD_ARTIFACT: { "artifact_id": "artifact_inflation" } }]
	Global.register_rod(run_start_option_inflation)

	# 4. Lose 30 money
	var run_start_option_lose_some_money: RunStartOptionData = RunStartOptionData.new("run_start_option_lose_some_money")
	run_start_option_lose_some_money.run_start_option_bb_code = "[color=red]失去100数据币[/color]"
	run_start_option_lose_some_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_lose_some_money.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": -100 } }]
	Global.register_rod(run_start_option_lose_some_money)

	# 5. Gain data scarcity
	var run_start_option_data_scarcity: RunStartOptionData = RunStartOptionData.new("run_start_option_data_scarcity")
	run_start_option_data_scarcity.run_start_option_bb_code = "[color=red]获得数据贫瘠插件[/color]"
	run_start_option_data_scarcity.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_data_scarcity.run_start_option_actions = [{ Scripts.ACTION_ADD_ARTIFACT: { "artifact_id": "artifact_data_scarcity" } }]
	Global.register_rod(run_start_option_data_scarcity)

	# 6. Take 15 damage
	var run_start_option_take_damage_15: RunStartOptionData = RunStartOptionData.new("run_start_option_take_damage_15")
	run_start_option_take_damage_15.run_start_option_bb_code = "[color=red]失去15点完整度[/color]"
	run_start_option_take_damage_15.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_take_damage_15.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "health_amount": -15 } }]
	Global.register_rod(run_start_option_take_damage_15)

	# 7. Take 20% damage
	var run_start_option_take_damage_pct: RunStartOptionData = RunStartOptionData.new("run_start_option_take_damage_pct")
	run_start_option_take_damage_pct.run_start_option_bb_code = "[color=red]失去等同于 20% 最大值的完整度[/color]"
	run_start_option_take_damage_pct.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_take_damage_pct.run_start_option_actions = [{ Scripts.ACTION_HEAL_PERCENT: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": -0.2 } }]
	Global.register_rod(run_start_option_take_damage_pct)


	### Upsides (PARTIAL_UPSIDE) - Existing
	var run_start_option_add_money: RunStartOptionData = RunStartOptionData.new("run_start_option_add_money")
	run_start_option_add_money.run_start_option_bb_code = "[color=green]获得50数据币[/color]"
	run_start_option_add_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_add_money.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 50 } }]
	Global.register_rod(run_start_option_add_money)

	var run_start_option_gain_max_hp: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_max_hp")
	run_start_option_gain_max_hp.run_start_option_bb_code = "[color=green]获得10点最大完整度[/color]"
	run_start_option_gain_max_hp.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_max_hp.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 10, "health_max_amount": 10 } }]
	Global.register_rod(run_start_option_gain_max_hp)

	var run_start_option_gain_max_hp_pct: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_max_hp_pct")
	run_start_option_gain_max_hp_pct.run_start_option_bb_code = "[color=green]获得10%最大完整度[/color]"
	run_start_option_gain_max_hp_pct.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_max_hp_pct.run_start_option_actions = [
		{ Scripts.ACTION_HEAL_PERCENT: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": 0.1 } },
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_percent": 0.1 } }
	]
	Global.register_rod(run_start_option_gain_max_hp_pct)

	var run_start_option_heal_hp_pct: RunStartOptionData = RunStartOptionData.new("run_start_option_heal_hp_pct")
	run_start_option_heal_hp_pct.run_start_option_bb_code = "[color=green]恢复等同于 30% 最大值的完整度[/color]"
	run_start_option_heal_hp_pct.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_heal_hp_pct.run_start_option_actions = [{ Scripts.ACTION_HEAL_PERCENT: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": 0.3 } }]
	Global.register_rod(run_start_option_heal_hp_pct)

	var run_start_option_draft_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_card")
	run_start_option_draft_card.run_start_option_bb_code = "[color=green]选择一张脚本[/color]"
	run_start_option_draft_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_card.run_start_option_actions = [{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": ActionBasePickCards.PICK_DRAFT,
			"pick_draft_cards": false, "draft_from_card_pool": true,
			"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
			"rng_name": "rng_card_drafting", "validator_data": [],
			"draft_use_player_draft": true, "draft_is_weighted": false, "draft_use_pity_system": false
		}
	}]
	Global.register_rod(run_start_option_draft_card)

	var run_start_option_draft_common_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_common_card")
	run_start_option_draft_common_card.run_start_option_bb_code = "[color=green]选择一张开源脚本[/color]"
	run_start_option_draft_common_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_common_card.run_start_option_actions = [{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": ActionBasePickCards.PICK_DRAFT, "pick_draft_cards": false, "draft_from_card_pool": true,
			"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
			"validator_data": [{ Scripts.VALIDATOR_CARD_RARITY: { "card_rarities": [CardData.CARD_RARITIES.COMMON] } }, { Scripts.VALIDATOR_CARD_DRAFTABLE: { } }],
			"rng_name": "rng_card_drafting", "draft_use_player_draft": false, "draft_is_weighted": false, "draft_use_pity_system": false
		}
	}]
	Global.register_rod(run_start_option_draft_common_card)

	var run_start_option_gain_common_artifact: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_common_artifact")
	run_start_option_gain_common_artifact.run_start_option_bb_code = "[color=green]获得 1 个随机开源外设插件[/color]"
	run_start_option_gain_common_artifact.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_common_artifact.run_start_option_actions = [{
		Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON] }
	}]
	Global.register_rod(run_start_option_gain_common_artifact)

	var run_start_option_draft_colorless_card: RunStartOptionData = RunStartOptionData.new("run_start_option_draft_colorless_card")
	run_start_option_draft_colorless_card.run_start_option_bb_code = "[color=green]选择一张纯白脚本[/color]"
	run_start_option_draft_colorless_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_draft_colorless_card.run_start_option_actions = [{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": ActionBasePickCards.PICK_DRAFT, "pick_draft_cards": false, "draft_from_card_pool": true,
			"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }], "validator_data": [],
			"rng_name": "rng_card_drafting", "draft_card_pack_id": "card_pack_white"
		}
	}]
	Global.register_rod(run_start_option_draft_colorless_card)

	var run_start_option_upgrade_card: RunStartOptionData = RunStartOptionData.new("run_start_option_upgrade_card")
	run_start_option_upgrade_card.run_start_option_bb_code = "[color=green]升级一张脚本[/color]"
	run_start_option_upgrade_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_upgrade_card.run_start_option_actions = [{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": HandManager.UPGRADE_DECK, "max_card_amount": 1, "min_card_amount": 1,
			"min_cards_are_required_for_action": false, "quick_pick": false, "random_selection": false,
			"card_pick_text": "选择升级",
			"validator_data": [{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } }],
			"action_data": [{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": false } }]
		}
	}]
	Global.register_rod(run_start_option_upgrade_card)

	var run_start_option_remove_card: RunStartOptionData = RunStartOptionData.new("run_start_option_remove_card")
	run_start_option_remove_card.run_start_option_bb_code = "[color=green]移除一张脚本[/color]"
	run_start_option_remove_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_remove_card.run_start_option_actions = [{
		Scripts.ACTION_PICK_CARDS: {
			"use_parent_card": false, "min_card_amount": 1, "max_card_amount": 1,
			"min_cards_are_required_for_action": false, "quick_pick": false, "can_back_out": false,
			"random_selection": false, "card_pick_text": "选择移除", "card_pick_type": HandManager.DECK,
			"action_data": [{ Scripts.ACTION_REMOVE_CARDS_FROM_DECK: { } }]
		}
	}]
	Global.register_rod(run_start_option_remove_card)


	### NEW Upsides
	# 7. Gain 100 money
	var run_start_option_add_100_money: RunStartOptionData = RunStartOptionData.new("run_start_option_add_100_money")
	run_start_option_add_100_money.run_start_option_bb_code = "[color=green]获得100数据币[/color]"
	run_start_option_add_100_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_add_100_money.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 100 } }]
	Global.register_rod(run_start_option_add_100_money)

	# 8. Transform a card
	var run_start_option_transform_card: RunStartOptionData = RunStartOptionData.new("run_start_option_transform_card")
	run_start_option_transform_card.run_start_option_bb_code = "[color=green]转换一张脚本[/color]"
	run_start_option_transform_card.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_transform_card.run_start_option_actions = [{
		Scripts.ACTION_PICK_CARDS: {
			"use_parent_card": false, "min_card_amount": 1, "max_card_amount": 1,
			"min_cards_are_required_for_action": false, "quick_pick": false, "can_back_out": false,
			"random_selection": false, "card_pick_text": "选择转换", "card_pick_type": HandManager.DECK,
			"action_data": [
				{ Scripts.ACTION_TRANSFORM_CARDS: { "transform_parent_card": false, "transform_rarities": [CardData.CARD_RARITIES.COMMON, CardData.CARD_RARITIES.UNCOMMON, CardData.CARD_RARITIES.RARE] } }
			]
		}
	}]
	Global.register_rod(run_start_option_transform_card)

	# 9. Gain uncommon artifact
	var run_start_option_gain_uncommon_artifact: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_uncommon_artifact")
	run_start_option_gain_uncommon_artifact.run_start_option_bb_code = "[color=green]获得 1 个随机闭源外设插件[/color]"
	run_start_option_gain_uncommon_artifact.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_uncommon_artifact.run_start_option_actions = [{
		Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.UNCOMMON] }
	}]
	Global.register_rod(run_start_option_gain_uncommon_artifact)

	# 10. Gain 250 money
	var run_start_option_add_250_money: RunStartOptionData = RunStartOptionData.new("run_start_option_add_250_money")
	run_start_option_add_250_money.run_start_option_bb_code = "[color=green]获得250数据币[/color]"
	run_start_option_add_250_money.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_add_250_money.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 250 } }]
	Global.register_rod(run_start_option_add_250_money)

	# 11. Upgrade 2 cards
	var run_start_option_upgrade_2_cards: RunStartOptionData = RunStartOptionData.new("run_start_option_upgrade_2_cards")
	run_start_option_upgrade_2_cards.run_start_option_bb_code = "[color=green]升级2张脚本[/color]"
	run_start_option_upgrade_2_cards.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_upgrade_2_cards.run_start_option_actions = [{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": HandManager.UPGRADE_DECK, "max_card_amount": 2, "min_card_amount": 2,
			"min_cards_are_required_for_action": false, "quick_pick": false, "random_selection": false,
			"card_pick_text": "选择升级",
			"validator_data": [{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } }],
			"action_data": [{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": false } }]
		}
	}]
	Global.register_rod(run_start_option_upgrade_2_cards)

	# 12. Gain random consumable
	var run_start_option_gain_consumable: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_consumable")
	run_start_option_gain_consumable.run_start_option_bb_code = "[color=green]获得一个随机消耗品[/color]"
	run_start_option_gain_consumable.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_consumable.run_start_option_actions = [{ Scripts.ACTION_ADD_CONSUMABLE: { "random_consumable": true } }]
	Global.register_rod(run_start_option_gain_consumable)

	# 13. Gain 15 max HP
	var run_start_option_gain_15_max_hp: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_15_max_hp")
	run_start_option_gain_15_max_hp.run_start_option_bb_code = "[color=green]获得15点最大完整度[/color]"
	run_start_option_gain_15_max_hp.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE
	run_start_option_gain_15_max_hp.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 15, "health_max_amount": 15 } }]
	Global.register_rod(run_start_option_gain_15_max_hp)

	### NEW FULL OPTIONS (COMPLETE)
	# 14. Boss Relic Swap
	var run_start_option_boss_relic_swap: RunStartOptionData = RunStartOptionData.new("run_start_option_boss_relic_swap")
	run_start_option_boss_relic_swap.run_start_option_bb_code = "[color=red]失去初始外设插件[/color] [color=green]获得 1 个随机动态生成外设插件。[/color]"
	run_start_option_boss_relic_swap.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_boss_relic_swap.run_start_option_actions = [
		{ Scripts.ACTION_SWAP_BOSS_ARTIFACT: { } }
	]
	Global.register_rod(run_start_option_boss_relic_swap)

	# 15. Gain Easy Mode Artifact
	var run_start_option_easy_mode: RunStartOptionData = RunStartOptionData.new("run_start_option_easy_mode")
	run_start_option_easy_mode.run_start_option_bb_code = "[color=green]给三层的安全模式外设插件。[/color]"
	run_start_option_easy_mode.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_easy_mode.run_start_option_actions = [{ 
		Scripts.ACTION_ADD_ARTIFACT: { 
			"artifact_id": "artifact_easy_mode",
			"custom_values": {
				"artifact_counter": 3,
				"artifact_counter_max": 3
			}
		} 
	}]
	Global.register_rod(run_start_option_easy_mode)


	# 19. Gain 2 common artifacts
	var run_start_option_gain_2_artifacts: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_2_artifacts")
	run_start_option_gain_2_artifacts.run_start_option_bb_code = "[color=green]直接获得 2 个随机开源外设插件。[/color]"
	run_start_option_gain_2_artifacts.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_gain_2_artifacts.run_start_option_actions = [
		{ Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 2, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON] } }
	]
	Global.register_rod(run_start_option_gain_2_artifacts)

	# 20. Gain 15 max HP and full heal
	var run_start_option_gain_hp_full_heal: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_hp_full_heal")
	run_start_option_gain_hp_full_heal.run_start_option_bb_code = "[color=green]提升 15 点最大完整度，并恢复至满完整度。[/color]"
	run_start_option_gain_hp_full_heal.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_gain_hp_full_heal.run_start_option_actions = [
		{ Scripts.ACTION_HEAL_PERCENT: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": 1.0 } },
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 0, "health_max_amount": 15 } }
	]
	Global.register_rod(run_start_option_gain_hp_full_heal)

	### NEW CUSTOM OPTIONS ADDED FROM PLAN
	
	# Downside: Gain Curse
	var run_start_option_gain_curse: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_curse")
	run_start_option_gain_curse.run_start_option_bb_code = "[color=red]获得一张《异常报错》脚本[/color]"
	run_start_option_gain_curse.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_gain_curse.run_start_option_actions = [
		{ Scripts.ACTION_CREATE_CARDS: { "created_card_object_id": "card_curse_exception", "number_of_cards": 1, "action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: {} }] } }
	]
	Global.register_rod(run_start_option_gain_curse)

	# Downside: Memory Leak
	var run_start_option_memory_leak: RunStartOptionData = RunStartOptionData.new("run_start_option_memory_leak")
	run_start_option_memory_leak.run_start_option_bb_code = "[color=red]获得《内存泄漏》插件[/color]"
	run_start_option_memory_leak.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_memory_leak.run_start_option_actions = [{ Scripts.ACTION_ADD_ARTIFACT: { "artifact_id": "artifact_memory_leak" } }]
	Global.register_rod(run_start_option_memory_leak)

	# Downside: High Latency
	var run_start_option_high_latency: RunStartOptionData = RunStartOptionData.new("run_start_option_high_latency")
	run_start_option_high_latency.run_start_option_bb_code = "[color=red]获得《高延迟》插件[/color]"
	run_start_option_high_latency.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE
	run_start_option_high_latency.run_start_option_actions = [{ Scripts.ACTION_ADD_ARTIFACT: { "artifact_id": "artifact_high_latency" } }]
	Global.register_rod(run_start_option_high_latency)
	
	# Complete: Gain 100 money
	var run_start_option_gain_100_money_complete: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_100_money_complete")
	run_start_option_gain_100_money_complete.run_start_option_bb_code = "[color=green]获得 100 数据币。[/color]"
	run_start_option_gain_100_money_complete.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_gain_100_money_complete.run_start_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 100 } }]
	Global.register_rod(run_start_option_gain_100_money_complete)

	# Complete: Gain 1 common artifact
	var run_start_option_gain_1_common_artifact_complete: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_1_common_artifact_complete")
	run_start_option_gain_1_common_artifact_complete.run_start_option_bb_code = "[color=green]获得 1 个随机开源外设插件。[/color]"
	run_start_option_gain_1_common_artifact_complete.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_gain_1_common_artifact_complete.run_start_option_actions = [{ Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON] } }]
	Global.register_rod(run_start_option_gain_1_common_artifact_complete)

	# Complete: Remove 1 card
	var run_start_option_remove_1_card_complete: RunStartOptionData = RunStartOptionData.new("run_start_option_remove_1_card_complete")
	run_start_option_remove_1_card_complete.run_start_option_bb_code = "[color=green]移除 1 张脚本。[/color]"
	run_start_option_remove_1_card_complete.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_remove_1_card_complete.run_start_option_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false, "min_card_amount": 1, "max_card_amount": 1,
				"min_cards_are_required_for_action": false, "quick_pick": false, "can_back_out": false,
				"random_selection": false, "card_pick_text": "选择移除", "card_pick_type": HandManager.DECK,
				"action_data": [{ Scripts.ACTION_REMOVE_CARDS_FROM_DECK: { } }]
			}
		}
	]
	Global.register_rod(run_start_option_remove_1_card_complete)

	# Complete: Upgrade 1 card
	var run_start_option_upgrade_1_card_complete: RunStartOptionData = RunStartOptionData.new("run_start_option_upgrade_1_card_complete")
	run_start_option_upgrade_1_card_complete.run_start_option_bb_code = "[color=green]升级 1 张脚本。[/color]"
	run_start_option_upgrade_1_card_complete.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_upgrade_1_card_complete.run_start_option_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false, "min_card_amount": 1, "max_card_amount": 1,
				"min_cards_are_required_for_action": false, "quick_pick": false, "can_back_out": false,
				"random_selection": false, "card_pick_text": "选择升级", "card_pick_type": HandManager.UPGRADE_DECK,
				"validator_data": [{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } }],
				"action_data": [{ Scripts.ACTION_UPGRADE_CARDS: { } }]
			}
		}
	]
	Global.register_rod(run_start_option_upgrade_1_card_complete)

	# Complete: Transform 1 card
	var run_start_option_transform_1_card_complete: RunStartOptionData = RunStartOptionData.new("run_start_option_transform_1_card_complete")
	run_start_option_transform_1_card_complete.run_start_option_bb_code = "[color=green]转换 1 张脚本。[/color]"
	run_start_option_transform_1_card_complete.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_transform_1_card_complete.run_start_option_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false, "min_card_amount": 1, "max_card_amount": 1,
				"min_cards_are_required_for_action": false, "quick_pick": false, "can_back_out": false,
				"random_selection": false, "card_pick_text": "选择转换", "card_pick_type": HandManager.DECK,
				"action_data": [
					{ Scripts.ACTION_TRANSFORM_CARDS: { "transform_parent_card": false, "transform_rarities": [CardData.CARD_RARITIES.COMMON, CardData.CARD_RARITIES.UNCOMMON, CardData.CARD_RARITIES.RARE] } }
				]
			}
		}
	]
	Global.register_rod(run_start_option_transform_1_card_complete)

	# Complete: Gain 10% Max HP
	var run_start_option_gain_max_hp_10_complete: RunStartOptionData = RunStartOptionData.new("run_start_option_gain_max_hp_10_complete")
	run_start_option_gain_max_hp_10_complete.run_start_option_bb_code = "[color=green]提升 10% 的最大完整度。[/color]"
	run_start_option_gain_max_hp_10_complete.run_start_option_type = RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE
	run_start_option_gain_max_hp_10_complete.run_start_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_percent": 0.1 } }]
	Global.register_rod(run_start_option_gain_max_hp_10_complete)
