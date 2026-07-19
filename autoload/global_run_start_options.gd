class_name GlobalRunStartOptionsGenerator
extends RefCounted

static func add_run_start_options() -> void:
	_add_tradeoff_options()
	_add_positive_options()

static func _register_option(object_id: String, option_type: int, bbcode: String, actions: Array[Dictionary]) -> void:
	var option: RunStartOptionData = RunStartOptionData.new(object_id)
	option.run_start_option_type = option_type
	option.run_start_option_bb_code = bbcode
	option.run_start_option_actions = actions
	Global.register_rod(option)

static func _add_tradeoff_options() -> void:
	_register_option(
		"run_start_tradeoff_money_50_health_5",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[money_amount]数据币[/color]，[color=red]失去[health_amount]点完整度[/color]",
		[
			{Scripts.ACTION_ADD_MONEY: {"money_amount": 50}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -5}},
		],
	)

	_register_option(
		"run_start_tradeoff_max_health_10_money_100",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[health_max_amount]点最大完整度[/color]，[color=red]失去[money_amount]数据币[/color]",
		[
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 10, "health_max_amount": 10}},
			{Scripts.ACTION_ADD_MONEY: {"money_amount": -100}},
		],
	)

	_register_option(
		"run_start_tradeoff_max_health_percent_health_15",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[percent:health_max_percent]最大完整度[/color]，[color=red]失去[health_amount]点完整度[/color]",
		[
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_percent": 0.1}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -15}},
		],
	)

	_register_option(
		"run_start_tradeoff_draft_card_health_5",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]选择[max_card_amount]张脚本[/color]，[color=red]失去[health_amount]点完整度[/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
				"rng_name": "rng_card_drafting",
				"validator_data": [],
				"draft_use_player_draft": true,
				"draft_is_weighted": false,
				"draft_use_pity_system": false,
			}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -5}},
		],
	)

	_register_option(
		"run_start_tradeoff_draft_common_money_100",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]选择[max_card_amount]张[card_rarities]脚本[/color]，[color=red]失去[money_amount]数据币[/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
				"validator_data": [
					{Scripts.VALIDATOR_CARD_RARITY: {"card_rarities": [CardData.CARD_RARITIES.COMMON]}},
					{Scripts.VALIDATOR_CARD_DRAFTABLE: {}},
				],
				"rng_name": "rng_card_drafting",
				"draft_use_player_draft": false,
				"draft_is_weighted": false,
				"draft_use_pity_system": false,
			}},
			{Scripts.ACTION_ADD_MONEY: {"money_amount": -100}},
		],
	)

	_register_option(
		"run_start_tradeoff_common_artifact_max_health_10",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[artifact_count]个随机[artifact_rarities]外设[/color]，[color=red]失去[health_max_amount]点最大完整度[/color]",
		[
			{Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON]}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -10}},
		],
	)

	_register_option(
		"run_start_tradeoff_white_card_curse",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]选择[max_card_amount]张纯白脚本[/color]，[color=red]获得[number_of_cards]张[card_name:created_card_object_id]脚本[/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}],
				"validator_data": [],
				"rng_name": "rng_card_drafting",
				"draft_card_pack_id": "card_pack_white",
			}},
			{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": "card_curse_exception", "number_of_cards": 1, "action_data": [{Scripts.ACTION_ADD_CARDS_TO_DECK: {}}]}},
		],
	)

	_register_option(
		"run_start_tradeoff_upgrade_card_health_15",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]升级[max_card_amount]张脚本[/color]，[color=red]失去[health_amount]点完整度[/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.UPGRADE_DECK,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": false,
				"quick_pick": false,
				"random_selection": false,
				"card_pick_text": "选择升级",
				"validator_data": [{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}}],
				"action_data": [{Scripts.ACTION_UPGRADE_CARDS: {"upgrade_parent_card": false}}],
			}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -15}},
		],
	)

	_register_option(
		"run_start_tradeoff_remove_card_max_health_percent",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]移除[max_card_amount]张脚本[/color]，[color=red]失去[percent:health_max_percent]最大完整度[/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": false,
				"quick_pick": false,
				"can_back_out": false,
				"random_selection": false,
				"card_pick_text": "选择移除",
				"card_pick_type": HandManager.DECK,
				"action_data": [{Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {}}],
			}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_percent": -0.15}},
		],
	)

	_register_option(
		"run_start_tradeoff_money_100_inflation",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[money_amount]数据币[/color]，[color=red]获得[artifact_name:artifact_id][/color]",
		[
			{Scripts.ACTION_ADD_MONEY: {"money_amount": 100}},
			{Scripts.ACTION_ADD_ARTIFACT: {"artifact_id": "artifact_inflation"}},
		],
	)

	_register_option(
		"run_start_tradeoff_transform_card_health_10",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]转换[max_card_amount]张脚本[/color]，[color=red]失去[health_amount]点完整度[/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": false,
				"quick_pick": false,
				"can_back_out": false,
				"random_selection": false,
				"card_pick_text": "选择转换",
				"card_pick_type": HandManager.DECK,
				"action_data": [{Scripts.ACTION_TRANSFORM_CARDS: {"transform_parent_card": false, "transform_rarities": [CardData.CARD_RARITIES.COMMON, CardData.CARD_RARITIES.UNCOMMON, CardData.CARD_RARITIES.RARE]}}],
			}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -10}},
		],
	)

	_register_option(
		"run_start_tradeoff_uncommon_artifact_max_health_15",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[artifact_count]个随机[artifact_rarities]外设[/color]，[color=red]失去[health_max_amount]点最大完整度[/color]",
		[
			{Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.UNCOMMON]}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -15}},
		],
	)

	_register_option(
		"run_start_tradeoff_money_250_data_scarcity",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[money_amount]数据币[/color]，[color=red]获得[artifact_name:artifact_id][/color]",
		[
			{Scripts.ACTION_ADD_MONEY: {"money_amount": 250}},
			{Scripts.ACTION_ADD_ARTIFACT: {"artifact_id": "artifact_data_scarcity"}},
		],
	)

	_register_option(
		"run_start_tradeoff_upgrade_two_memory_leak",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]升级[max_card_amount]张脚本[/color]，[color=red]获得[artifact_name:artifact_id][/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.UPGRADE_DECK,
				"min_card_amount": 2,
				"max_card_amount": 2,
				"min_cards_are_required_for_action": false,
				"quick_pick": false,
				"random_selection": false,
				"card_pick_text": "选择升级",
				"validator_data": [{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}}],
				"action_data": [{Scripts.ACTION_UPGRADE_CARDS: {"upgrade_parent_card": false}}],
			}},
			{Scripts.ACTION_ADD_ARTIFACT: {"artifact_id": "artifact_memory_leak"}},
		],
	)

	_register_option(
		"run_start_tradeoff_consumable_health_5",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[slot_count]个随机消耗品[/color]，[color=red]失去[health_amount]点完整度[/color]",
		[
			{Scripts.ACTION_ADD_CONSUMABLE: {"random_consumable": true, "slot_count": 1}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -5}},
		],
	)

	_register_option(
		"run_start_tradeoff_max_health_15_high_latency",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]获得[health_max_amount]点最大完整度[/color]，[color=red]获得[artifact_name:artifact_id][/color]",
		[
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 15, "health_max_amount": 15}},
			{Scripts.ACTION_ADD_ARTIFACT: {"artifact_id": "artifact_high_latency"}},
		],
	)

	_register_option(
		"run_start_tradeoff_enchant_card_health_percent",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=green]免费附魔[max_card_amount]张脚本[/color]，[color=red]失去等同于[percent:percentage_heal_amount]最大值的完整度[/color]",
		[
			{Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.ENCHANT_DECK,
				"enchant_free": true,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": false,
				"quick_pick": false,
				"can_back_out": false,
				"validator_data": [{Scripts.VALIDATOR_CARD_IS_DECORATABLE: {"card_decorator_ids": GlobalProdDecoratorsGenerator.REST_SITE_ENCHANT_POOL}}],
				"action_data": [],
			}},
			{Scripts.ACTION_HEAL_PERCENT: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": -0.2}},
		],
	)

	_register_option(
		"run_start_tradeoff_boss_artifact_swap",
		RunStartOptionData.RUN_START_OPTION_TYPES.TRADEOFF,
		"[color=red]失去初始外设[/color]，[color=green]获得[artifact_count]个随机动态生成外设[/color]",
		[{Scripts.ACTION_SWAP_BOSS_ARTIFACT: {"artifact_count": 1}}],
	)

static func _add_positive_options() -> void:
	_register_option(
		"run_start_positive_easy_mode",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]获得[artifact_counter]层的[artifact_name:artifact_id][/color]",
		[{Scripts.ACTION_ADD_ARTIFACT: {"artifact_id": "artifact_easy_mode", "custom_values": {"artifact_counter": 3, "artifact_counter_max": 3}}}],
	)

	_register_option(
		"run_start_positive_two_common_artifacts",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]获得[artifact_count]个随机[artifact_rarities]外设[/color]",
		[{Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 2, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON]}}],
	)

	_register_option(
		"run_start_positive_max_health_full_heal",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]提升[health_max_amount]点最大完整度，并恢复至满完整度[/color]",
		[
			{Scripts.ACTION_HEAL_PERCENT: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": 1.0}},
			{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 0, "health_max_amount": 15}},
		],
	)

	_register_option(
		"run_start_positive_money_100",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]获得[money_amount]数据币[/color]",
		[{Scripts.ACTION_ADD_MONEY: {"money_amount": 100}}],
	)

	_register_option(
		"run_start_positive_common_artifact",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]获得[artifact_count]个随机[artifact_rarities]外设[/color]",
		[{Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON]}}],
	)

	_register_option(
		"run_start_positive_remove_card",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]移除[max_card_amount]张脚本[/color]",
		[{Scripts.ACTION_PICK_CARDS: {
			"use_parent_card": false,
			"min_card_amount": 1,
			"max_card_amount": 1,
			"min_cards_are_required_for_action": false,
			"quick_pick": false,
			"can_back_out": false,
			"random_selection": false,
			"card_pick_text": "选择移除",
			"card_pick_type": HandManager.DECK,
			"action_data": [{Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {}}],
		}}],
	)

	_register_option(
		"run_start_positive_upgrade_card",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]升级[max_card_amount]张脚本[/color]",
		[{Scripts.ACTION_PICK_CARDS: {
			"use_parent_card": false,
			"min_card_amount": 1,
			"max_card_amount": 1,
			"min_cards_are_required_for_action": false,
			"quick_pick": false,
			"can_back_out": false,
			"random_selection": false,
			"card_pick_text": "选择升级",
			"card_pick_type": HandManager.UPGRADE_DECK,
			"validator_data": [{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}}],
			"action_data": [{Scripts.ACTION_UPGRADE_CARDS: {}}],
		}}],
	)

	_register_option(
		"run_start_positive_transform_card",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]转换[max_card_amount]张脚本[/color]",
		[{Scripts.ACTION_PICK_CARDS: {
			"use_parent_card": false,
			"min_card_amount": 1,
			"max_card_amount": 1,
			"min_cards_are_required_for_action": false,
			"quick_pick": false,
			"can_back_out": false,
			"random_selection": false,
			"card_pick_text": "选择转换",
			"card_pick_type": HandManager.DECK,
			"action_data": [{Scripts.ACTION_TRANSFORM_CARDS: {"transform_parent_card": false, "transform_rarities": [CardData.CARD_RARITIES.COMMON, CardData.CARD_RARITIES.UNCOMMON, CardData.CARD_RARITIES.RARE]}}],
		}}],
	)

	_register_option(
		"run_start_positive_enchant_card",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]免费附魔[max_card_amount]张脚本[/color]",
		[{Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": HandManager.ENCHANT_DECK,
			"enchant_free": true,
			"min_card_amount": 1,
			"max_card_amount": 1,
			"min_cards_are_required_for_action": false,
			"quick_pick": false,
			"can_back_out": false,
			"validator_data": [{Scripts.VALIDATOR_CARD_IS_DECORATABLE: {"card_decorator_ids": GlobalProdDecoratorsGenerator.REST_SITE_ENCHANT_POOL}}],
			"action_data": [],
		}}],
	)

	_register_option(
		"run_start_positive_max_health_percent",
		RunStartOptionData.RUN_START_OPTION_TYPES.POSITIVE_ONLY,
		"[color=green]提升[percent:health_max_percent]最大完整度[/color]",
		[{Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_percent": 0.1}}],
	)
