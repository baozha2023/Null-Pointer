## 通用白色卡牌 — 尚未归入特定色系的中立卡
class_name GlobalProdDataGeneratorWhiteCards
extends RefCounted

static func add_cards_white() -> void:
	var color: String = "white"

	# 下时钟周期算力 — 算力预分配
	var card_energy_next_turn: CardData = CardData.new("card_energy_next_turn")
	card_energy_next_turn.card_name = "下时钟周期算力"
	card_energy_next_turn.card_color_id = "color_{0}".format([color])
	card_energy_next_turn.card_texture_path = "sprites/card/white/card_energy_next_turn.png"
	card_energy_next_turn.card_description = "获得 [status_charge_amount] 层算力预分配。"
	card_energy_next_turn.card_hint = "为下个周期预留算力，适合为消耗大的强力脚本做铺垫。"
	card_energy_next_turn.card_type = CardData.CARD_TYPES.SKILL
	card_energy_next_turn.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_energy_next_turn.card_requires_target = false
	card_energy_next_turn.card_values = { "status_charge_amount": 2 }
	card_energy_next_turn.card_first_upgrade_property_changes = { "card_energy_cost": 0 }
	card_energy_next_turn.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_energy_next_turn",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]

	Global.register_rod(card_energy_next_turn)

	# 1. 端口嗅探 — 抽牌
	var card_traffic_sniff: CardData = CardData.new("card_traffic_sniff")
	card_traffic_sniff.card_name = "端口嗅探"
	card_traffic_sniff.card_color_id = "color_{0}".format([color])
	card_traffic_sniff.card_texture_path = "sprites/card/white/card_traffic_sniff.png"
	card_traffic_sniff.card_description = "读取 [draw_count] 个脚本。消耗。"
	card_traffic_sniff.card_type = CardData.CARD_TYPES.SKILL
	card_traffic_sniff.card_rarity = CardData.CARD_RARITIES.COMMON
	card_traffic_sniff.card_requires_target = false
	card_traffic_sniff.card_energy_cost = 1
	card_traffic_sniff.card_play_destination = HandManager.EXHAUST_PILE
	card_traffic_sniff.card_values = { "draw_count": 3 }
	card_traffic_sniff.card_upgrade_value_improvements = { "draw_count": 1 }
	card_traffic_sniff.card_play_actions = [
		{
			Scripts.ACTION_DRAW_GENERATOR: {},
		},
	]
	Global.register_rod(card_traffic_sniff)

	# 2. 防火墙补丁 — 格挡
	var card_firewall_patch: CardData = CardData.new("card_firewall_patch")
	card_firewall_patch.card_name = "防火墙补丁"
	card_firewall_patch.card_color_id = "color_{0}".format([color])
	card_firewall_patch.card_texture_path = "sprites/card/white/card_firewall_patch.png"
	card_firewall_patch.card_description = "获得 [block] 点防火墙。消耗。"
	card_firewall_patch.card_type = CardData.CARD_TYPES.SKILL
	card_firewall_patch.card_rarity = CardData.CARD_RARITIES.COMMON
	card_firewall_patch.card_requires_target = false
	card_firewall_patch.card_energy_cost = 1
	card_firewall_patch.card_play_destination = HandManager.EXHAUST_PILE
	card_firewall_patch.card_values = { "block": 7 }
	card_firewall_patch.card_upgrade_value_improvements = { "block": 3 }
	card_firewall_patch.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(card_firewall_patch)

	# 3. 内存快照 — 复制手牌
	var card_memory_snapshot: CardData = CardData.new("card_memory_snapshot")
	card_memory_snapshot.card_name = "内存快照"
	card_memory_snapshot.card_color_id = "color_{0}".format([color])
	card_memory_snapshot.card_texture_path = "sprites/card/white/card_memory_snapshot.png"
	card_memory_snapshot.card_description = "选择复制当前线程中最多 [card_amount] 个脚本。消耗。"
	card_memory_snapshot.card_type = CardData.CARD_TYPES.SKILL
	card_memory_snapshot.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_memory_snapshot.card_requires_target = false
	card_memory_snapshot.card_energy_cost = 1
	card_memory_snapshot.card_play_destination = HandManager.EXHAUST_PILE
	card_memory_snapshot.card_values = { "card_amount": 1 }
	card_memory_snapshot.card_upgrade_value_improvements = { "card_amount": 1 }
	card_memory_snapshot.card_play_actions = [
		{
			Scripts.ACTION_PICK_DUPLICATE_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount", "min_card_amount": "card_amount"},
				"min_cards_are_required_for_action": true,
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择要复制的脚本",
				"random_selection": false,
			},
		},
	]
	Global.register_rod(card_memory_snapshot)

	# 4. 日志清理 — 从弃牌堆删除
	var card_log_cleanup: CardData = CardData.new("card_log_cleanup")
	card_log_cleanup.card_name = "日志清理"
	card_log_cleanup.card_color_id = "color_{0}".format([color])
	card_log_cleanup.card_texture_path = "sprites/card/white/card_log_cleanup.png"
	card_log_cleanup.card_description = "选择回收站中最多 [number_of_cards] 个脚本物理删除。虚无。"
	card_log_cleanup.card_type = CardData.CARD_TYPES.SKILL
	card_log_cleanup.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_log_cleanup.card_requires_target = false
	card_log_cleanup.card_energy_cost = 0
	card_log_cleanup.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_log_cleanup.card_values = { "number_of_cards": 3 }
	card_log_cleanup.card_upgrade_value_improvements = { "number_of_cards": 2 }
	card_log_cleanup.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "number_of_cards"},
				"min_card_amount": 0,
				"min_cards_are_required_for_action": false,
				"random_selection": false,
				"card_pick_type": HandManager.DISCARD_PILE,
				"card_pick_text": "选择 [number_of_cards] 个脚本物理删除。已选 {1} 个",
				"action_data": [{Scripts.ACTION_EXHAUST_CARDS: {}}],
			},
		},
	]
	Global.register_rod(card_log_cleanup)

	# 5. 内核重构 — 永久升级
	var card_kernel_reconstruct: CardData = CardData.new("card_kernel_reconstruct")
	card_kernel_reconstruct.card_name = "内核重构"
	card_kernel_reconstruct.card_color_id = "color_{0}".format([color])
	card_kernel_reconstruct.card_texture_path = "sprites/card/white/card_kernel_reconstruct.png"
	card_kernel_reconstruct.card_description = "选择脚本库中最多 [number_of_cards] 个脚本永久升级。消耗。"
	card_kernel_reconstruct.card_type = CardData.CARD_TYPES.POWER
	card_kernel_reconstruct.card_rarity = CardData.CARD_RARITIES.RARE
	card_kernel_reconstruct.card_requires_target = false
	card_kernel_reconstruct.card_energy_cost = 2
	card_kernel_reconstruct.card_play_destination = HandManager.EXHAUST_PILE
	card_kernel_reconstruct.card_values = { "number_of_cards": 1 }
	card_kernel_reconstruct.card_upgrade_value_improvements = { "number_of_cards": 1 }
	card_kernel_reconstruct.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "number_of_cards", "min_card_amount": "number_of_cards"},
				"min_cards_are_required_for_action": true,
				"random_selection": false,
				"can_back_out": true,
				"quick_pick": false,
				"card_pick_type": HandManager.UPGRADE_DECK,
				"card_pick_text": "选择最多 {0} 个脚本永久升级。已选 {1} 个",
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } },
				],
				"action_data": [
					{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": true } },
				],
			},
		},
	]
	Global.register_rod(card_kernel_reconstruct)

	# 异常脚本（诅咒卡牌）
	var card_curse_exception: CardData = CardData.new("card_curse_exception")
	card_curse_exception.card_name = "异常报错"
	card_curse_exception.card_color_id = "color_white"
	card_curse_exception.card_texture_path = "sprites/card/white/card_kernel_reconstruct.png"
	card_curse_exception.card_description = "无用。不可打出。\n[color=#ff6b6b]抽到此牌时，受到1点伤害。[/color]"
	card_curse_exception.card_hint = "这是一张诅咒卡牌。不仅会污染卡池，某些情况下还会造成负面效果。"
	card_curse_exception.card_type = CardData.CARD_TYPES.CURSE
	card_curse_exception.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_curse_exception.card_is_playable = false
	card_curse_exception.card_draw_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"damage": 1,
				"bypass_block": true
			}
		}
	]
	Global.register_rod(card_curse_exception)

	# --- Status Cards ---
	# Dazed (垃圾数据) - Unplayable, Ethereal, exhausts when drawn or at end of turn
	var card_status_dazed: CardData = CardData.new("card_status_dazed")
	card_status_dazed.card_name = "垃圾数据"
	card_status_dazed.card_color_id = "color_white"
	card_status_dazed.card_texture_path = "sprites/card/status/card_dazed.png"
	card_status_dazed.card_description = "无法被打出。回合结束时被消耗。"
	card_status_dazed.card_type = CardData.CARD_TYPES.STATUS
	card_status_dazed.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_status_dazed.card_is_playable = false
	card_status_dazed.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	Global.register_rod(card_status_dazed)

	# Burn (过载发热) - Unplayable, deals 2 damage to player at end of turn
	var card_status_burn: CardData = CardData.new("card_status_burn")
	card_status_burn.card_name = "过载发热"
	card_status_burn.card_color_id = "color_white"
	card_status_burn.card_texture_path = "sprites/card/status/card_burn.png"
	card_status_burn.card_description = "无法被打出。在你的回合结束时，受到 [damage] 点伤害。"
	card_status_burn.card_type = CardData.CARD_TYPES.STATUS
	card_status_burn.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_status_burn.card_is_playable = false
	card_status_burn.card_values = { "damage": 2 }
	
	# Action for end of turn burn damage
	card_status_burn.card_end_of_turn_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"damage": 2,
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
			}
		}
	]
	Global.register_rod(card_status_burn)
