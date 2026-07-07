class_name GlobalProdDecoratorsGenerator
extends RefCounted

const REST_SITE_ENCHANT_POOL: Array[String] = [
	"card_decorator_block_on_play",
	"card_decorator_remove_exhaust",
	"card_decorator_extra_draw"
]

static func generate_decorators() -> void:
	add_card_decorators()
	add_enchant_rest_actions()

#region Card Decorators
static func add_card_decorators() -> void:
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
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
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

#region Rest Actions
static func add_enchant_rest_actions() -> void:
	# enchant a selected card from your deck
	# randomly chooses an enchant
	# must have at least one card that can be decorated and enough money
	# NOTE: To add more random enchants, you must update the random selection, the pick validator, and the rest action deck validator
	var rest_action_enchant_cards: RestActionData = RestActionData.new("rest_action_enchant_cards")
	rest_action_enchant_cards.rest_action_name = "附魔脚本"
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
				"card_pick_type": HandManager.ENCHANT_DECK,
				# only decoratable cards allowed, must be able to slot one of the provided decorators
				"validator_data": [
					{
						Scripts.VALIDATOR_CARD_IS_DECORATABLE: {
							"card_decorator_ids": REST_SITE_ENCHANT_POOL,
						},
					},
				],
				"action_data": [
					# finish rest action
					{ Scripts.ACTION_REST_ACTION_END: { "rest_action_id": "rest_action_enchant_cards" } },
				],
			},
		},
	]
	rest_action_enchant_cards.rest_action_validators = [
		{
			# must have at least one card that can slot a decorator
			Scripts.VALIDATOR_DECK_HAS_DECORATABLE_CARD: {
				"card_pick_type": HandManager.DECK,
				"card_decorator_ids": REST_SITE_ENCHANT_POOL,
				"card_types": CardData.CARD_TYPES.values(), # any card
				"invert_validation": false,
			},
		},
	]

	Global.register_rod(rest_action_enchant_cards)
#endregion
