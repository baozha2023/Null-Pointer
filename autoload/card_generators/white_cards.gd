## 通用白色卡牌 — 尚未归入特定色系的中立卡
class_name GlobalProdDataGeneratorWhiteCards
extends RefCounted

static func add_cards_white() -> void:
	var color: String = "white"

	# 算力注入 — 初始牌组的一次性算力补充
	var card_energy_injection: CardData = CardData.new("card_energy_injection")
	card_energy_injection.card_name = "算力注入"
	card_energy_injection.card_color_id = "color_{0}".format([color])
	card_energy_injection.card_texture_path = "sprites/card/white/card_energy_injection.png"
	card_energy_injection.card_description = "获得 [energy_amount_energy_icons]。"
	card_energy_injection.card_hint = "立即补充算力；打出后从牌组永久移除。"
	card_energy_injection.card_type = CardData.CARD_TYPES.SKILL
	card_energy_injection.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_energy_injection.card_requires_target = false
	card_energy_injection.card_energy_cost = 0
	card_energy_injection.card_play_destination = HandManager.BANISH_PILE
	card_energy_injection.card_values = { "energy_amount": 2 }
	card_energy_injection.card_upgrade_value_improvements = { "energy_amount": 1 }
	card_energy_injection.card_play_actions = [
		{
			Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {
				"pick_played_card": true,
			},
		},
		{Scripts.ACTION_ADD_ENERGY: {}},
	]
	Global.register_rod(card_energy_injection)

	# 下时钟周期算力 — 算力预分配
	var card_energy_next_turn: CardData = CardData.new("card_energy_next_turn")
	card_energy_next_turn.card_name = "下时钟周期算力"
	card_energy_next_turn.card_color_id = "color_{0}".format([color])
	card_energy_next_turn.card_texture_path = "sprites/card/white/card_energy_next_turn.png"
	card_energy_next_turn.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_energy_next_turn]。"
	card_energy_next_turn.card_hint = "为下个周期预留算力，适合为消耗大的强力脚本做铺垫。"
	card_energy_next_turn.card_type = CardData.CARD_TYPES.SKILL
	card_energy_next_turn.card_rarity = CardData.CARD_RARITIES.COMMON
	card_energy_next_turn.card_requires_target = false
	card_energy_next_turn.card_values = { "status_charge_amount": 2 }
	card_energy_next_turn.card_upgrade_value_improvements = { "status_charge_amount": 1 }
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
	card_traffic_sniff.card_description = "读取 [draw_count] 个脚本。"
	card_traffic_sniff.card_hint = "一次性大量抽牌；打出后在本场战斗中物理删除。"
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
	card_firewall_patch.card_description = "获得 [block] 点防火墙。"
	card_firewall_patch.card_hint = "提供一次性高额防火墙；打出后在本场战斗中物理删除。"
	card_firewall_patch.card_type = CardData.CARD_TYPES.SKILL
	card_firewall_patch.card_rarity = CardData.CARD_RARITIES.COMMON
	card_firewall_patch.card_requires_target = false
	card_firewall_patch.card_energy_cost = 1
	card_firewall_patch.card_play_destination = HandManager.EXHAUST_PILE
	card_firewall_patch.card_values = { "block": 12 }
	card_firewall_patch.card_upgrade_value_improvements = { "block": 4 }
	card_firewall_patch.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
	]
	Global.register_rod(card_firewall_patch)

	# 3. 内存快照 — 复制手牌
	var card_memory_snapshot: CardData = CardData.new("card_memory_snapshot")
	card_memory_snapshot.card_name = "内存快照"
	card_memory_snapshot.card_color_id = "color_{0}".format([color])
	card_memory_snapshot.card_texture_path = "sprites/card/white/card_memory_snapshot.png"
	card_memory_snapshot.card_description = "选择复制当前线程中最多 [card_amount] 个脚本。"
	card_memory_snapshot.card_hint = "在战斗中复制一个核心脚本；打出后在本场战斗中物理删除。"
	card_memory_snapshot.card_type = CardData.CARD_TYPES.SKILL
	card_memory_snapshot.card_rarity = CardData.CARD_RARITIES.RARE
	card_memory_snapshot.card_requires_target = false
	card_memory_snapshot.card_energy_cost = 1
	card_memory_snapshot.card_play_destination = HandManager.EXHAUST_PILE
	card_memory_snapshot.card_values = { "card_amount": 1 }
	card_memory_snapshot.card_first_upgrade_property_changes = { "card_energy_cost": 0 }
	card_memory_snapshot.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.HAND_PILE],
				"exclude_validated_card": true,
				"comparison_value": 1,
			}
		},
	]
	card_memory_snapshot.card_play_actions = [
		{
			Scripts.ACTION_PICK_DUPLICATE_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount"},
				"min_card_amount": 1,
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
	card_log_cleanup.card_description = "选择回收站中最多 [number_of_cards] 个脚本物理删除。"
	card_log_cleanup.card_hint = "清理弃牌堆中的垃圾牌，精简牌库；若本回合不打出，回合结束也会被永久移除。"
	card_log_cleanup.card_type = CardData.CARD_TYPES.SKILL
	card_log_cleanup.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_log_cleanup.card_requires_target = false
	card_log_cleanup.card_energy_cost = 0
	card_log_cleanup.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_log_cleanup.card_values = { "number_of_cards": 2 }
	card_log_cleanup.card_upgrade_value_improvements = { "number_of_cards": 1 }
	card_log_cleanup.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.DISCARD_PILE],
				"comparison_value": 1,
			}
		},
	]
	card_log_cleanup.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "number_of_cards"},
				"min_card_amount": 1,
				"min_cards_are_required_for_action": true,
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
	card_kernel_reconstruct.card_description = "选择脚本库中最多 [number_of_cards] 个脚本永久升级。"
	card_kernel_reconstruct.card_hint = "极其珍贵的永久强化手段；用后从牌组永久移除。"
	card_kernel_reconstruct.card_type = CardData.CARD_TYPES.POWER
	card_kernel_reconstruct.card_rarity = CardData.CARD_RARITIES.RARE
	card_kernel_reconstruct.card_requires_target = false
	card_kernel_reconstruct.card_energy_cost = 2
	card_kernel_reconstruct.card_play_destination = HandManager.BANISH_PILE
	card_kernel_reconstruct.card_values = { "number_of_cards": 1 }
	card_kernel_reconstruct.card_upgrade_value_improvements = { "number_of_cards": 1 }
	var kernel_reconstruct_target_validators: Array[Dictionary] = [
		{Scripts.VALIDATOR_CARD_UPGRADEABLE: {}},
	]
	card_kernel_reconstruct.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.UPGRADE_DECK],
				"validator_data": kernel_reconstruct_target_validators,
				"comparison_value": 1,
			}
		},
	]
	card_kernel_reconstruct.card_play_actions = [
		{
			Scripts.ACTION_REMOVE_CARDS_FROM_DECK: {
				"pick_played_card": true,
			},
		},
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "number_of_cards"},
				"min_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"random_selection": false,
				"can_back_out": true,
				"quick_pick": false,
				"card_pick_type": HandManager.UPGRADE_DECK,
				"card_pick_text": "选择最多 {0} 个脚本永久升级。已选 {1} 个",
				"validator_data": kernel_reconstruct_target_validators,
				"action_data": [
					{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": true } },
				],
			},
		},
	]
	Global.register_rod(card_kernel_reconstruct)

	# 校验和打击 — 稳定的中立攻击
	var card_checksum_strike: CardData = CardData.new("card_checksum_strike")
	card_checksum_strike.card_name = "校验和打击"
	card_checksum_strike.card_color_id = "color_{0}".format([color])
	card_checksum_strike.card_texture_path = "sprites/card/white/card_checksum_strike.png"
	card_checksum_strike.card_description = "造成 [damage] 点伤害。"
	card_checksum_strike.card_hint = "稳定且无附加条件的通用攻击脚本。"
	card_checksum_strike.card_type = CardData.CARD_TYPES.ATTACK
	card_checksum_strike.card_rarity = CardData.CARD_RARITIES.COMMON
	card_checksum_strike.card_requires_target = true
	card_checksum_strike.card_energy_cost = 1
	card_checksum_strike.card_values = {
		"damage": 8,
		"number_of_attacks": 1,
	}
	card_checksum_strike.card_upgrade_value_improvements = {"damage": 3}
	card_checksum_strike.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: {"audio_path": AudioConstants.SFX_GROUP_BLUNT_SMASH}},
	]
	Global.register_rod(card_checksum_strike)

	# 回滚协议 — 从回收站恢复一个脚本
	var card_rollback_protocol: CardData = CardData.new("card_rollback_protocol")
	card_rollback_protocol.card_name = "回滚协议"
	card_rollback_protocol.card_color_id = "color_{0}".format([color])
	card_rollback_protocol.card_texture_path = "sprites/card/white/card_rollback_protocol.png"
	card_rollback_protocol.card_description = "从回收站中选择 [card_amount] 个脚本加入当前线程。"
	card_rollback_protocol.card_hint = "精确找回本场战斗中已经打出或丢弃的一个脚本。"
	card_rollback_protocol.card_type = CardData.CARD_TYPES.SKILL
	card_rollback_protocol.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_rollback_protocol.card_requires_target = false
	card_rollback_protocol.card_energy_cost = 1
	card_rollback_protocol.card_play_destination = HandManager.EXHAUST_PILE
	card_rollback_protocol.card_values = {"card_amount": 1}
	card_rollback_protocol.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_rollback_protocol.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.DISCARD_PILE],
				"comparison_value": 1,
			},
		},
	]
	card_rollback_protocol.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount"},
				"min_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"card_pick_type": HandManager.DISCARD_PILE,
				"card_pick_text": "选择要回滚至当前线程的脚本",
				"random_selection": false,
				"action_data": [{Scripts.ACTION_ADD_CARDS_TO_HAND: {}}],
			},
		},
	]
	Global.register_rod(card_rollback_protocol)

	# 热插拔 — 临时免除一个手牌脚本的耗能
	var card_hot_swap: CardData = CardData.new("card_hot_swap")
	card_hot_swap.card_name = "热插拔"
	card_hot_swap.card_color_id = "color_{0}".format([color])
	card_hot_swap.card_texture_path = "sprites/card/white/card_hot_swap.png"
	card_hot_swap.card_description = "选择当前线程中 [card_amount] 个其他脚本，使其本时钟周期耗能变为 0。"
	card_hot_swap.card_hint = "用一个脚本位换取本回合高费核心脚本的免费执行。"
	card_hot_swap.card_type = CardData.CARD_TYPES.SKILL
	card_hot_swap.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_hot_swap.card_requires_target = false
	card_hot_swap.card_energy_cost = 1
	card_hot_swap.card_play_destination = HandManager.EXHAUST_PILE
	card_hot_swap.card_values = {"card_amount": 1}
	card_hot_swap.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_hot_swap.card_play_validators = [
		{
			Scripts.VALIDATOR_COMBAT_PILES_HAVE_VALIDATED_CARDS: {
				"source_zones": [HandManager.HAND_PILE],
				"exclude_validated_card": true,
				"comparison_value": 1,
			},
		},
	]
	card_hot_swap.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"custom_key_names": {"max_card_amount": "card_amount"},
				"min_card_amount": 1,
				"min_cards_are_required_for_action": true,
				"card_pick_type": HandManager.HAND_PILE,
				"card_pick_text": "选择要热插拔的其他脚本",
				"random_selection": false,
				"action_data": [{Scripts.ACTION_CHANGE_CARD_ENERGIES: {"card_energy_cost_until_turn": 0}}],
			},
		},
	]
	Global.register_rod(card_hot_swap)

	# 沙箱隔离 — 防火墙与一次异常阻断
	var card_sandbox_isolation: CardData = CardData.new("card_sandbox_isolation")
	card_sandbox_isolation.card_name = "沙箱隔离"
	card_sandbox_isolation.card_color_id = "color_{0}".format([color])
	card_sandbox_isolation.card_texture_path = "sprites/card/white/card_sandbox_isolation.png"
	card_sandbox_isolation.card_description = "获得 [block] 点防火墙与 [status_charge_amount] 层 [status_icon:status_effect_negate_debuff]。"
	card_sandbox_isolation.card_hint = "同时抵挡常规伤害，并阻断下一次施加给你的减益。"
	card_sandbox_isolation.card_type = CardData.CARD_TYPES.SKILL
	card_sandbox_isolation.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_sandbox_isolation.card_requires_target = false
	card_sandbox_isolation.card_energy_cost = 1
	card_sandbox_isolation.card_values = {"block": 6, "status_charge_amount": 1}
	card_sandbox_isolation.card_upgrade_value_improvements = {"block": 4}
	card_sandbox_isolation.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_negate_debuff",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(card_sandbox_isolation)

	# 广播中继 — 群体削弱
	var card_broadcast_relay: CardData = CardData.new("card_broadcast_relay")
	card_broadcast_relay.card_name = "广播中继"
	card_broadcast_relay.card_color_id = "color_{0}".format([color])
	card_broadcast_relay.card_texture_path = "sprites/card/white/card_broadcast_relay.png"
	card_broadcast_relay.card_description = "对所有敌人施加 [status_charge_amount] 层 [status_icon:status_effect_weaken]。"
	card_broadcast_relay.card_hint = "压制全部敌人的输出，敌人越多收益越高。"
	card_broadcast_relay.card_type = CardData.CARD_TYPES.SKILL
	card_broadcast_relay.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_broadcast_relay.card_requires_target = false
	card_broadcast_relay.card_energy_cost = 1
	card_broadcast_relay.card_values = {"status_charge_amount": 1}
	card_broadcast_relay.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_broadcast_relay.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_weaken",
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]
	Global.register_rod(card_broadcast_relay)

	# 熔断保护 — 立即获得高额防御，但向脚本库写入过载发热
	var card_overload_fuse: CardData = CardData.new("card_overload_fuse")
	card_overload_fuse.card_name = "熔断保护"
	card_overload_fuse.card_color_id = "color_{0}".format([color])
	card_overload_fuse.card_texture_path = "sprites/card/white/card_overload_fuse.png"
	card_overload_fuse.card_description = "获得 [block] 点防火墙。将一张[card_name:card_status_burn]置于脚本库顶部。"
	card_overload_fuse.card_hint = "无需算力即可紧急防御，但下一次读取会得到一张危险状态码。"
	card_overload_fuse.card_type = CardData.CARD_TYPES.SKILL
	card_overload_fuse.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_overload_fuse.card_requires_target = false
	card_overload_fuse.card_energy_cost = 0
	card_overload_fuse.card_play_destination = HandManager.EXHAUST_PILE
	card_overload_fuse.card_values = {"block": 12}
	card_overload_fuse.card_upgrade_value_improvements = {"block": 4}
	card_overload_fuse.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
		{
			Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_status_burn",
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_DRAW: {
							"card_destination_strategy": HandManager.PILE_INSERTION_STRATEGIES.TOP,
						},
					},
				],
			},
		},
	]
	Global.register_rod(card_overload_fuse)

	# 零信任架构 — 同时阻断下一次伤害与减益
	var card_zero_trust_architecture: CardData = CardData.new("card_zero_trust_architecture")
	card_zero_trust_architecture.card_name = "零信任架构"
	card_zero_trust_architecture.card_color_id = "color_{0}".format([color])
	card_zero_trust_architecture.card_texture_path = "sprites/card/white/card_zero_trust_architecture.png"
	card_zero_trust_architecture.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_negate_damage] 与 [status_charge_amount] 层 [status_icon:status_effect_negate_debuff]。"
	card_zero_trust_architecture.card_hint = "分别完全阻断下一次伤害和下一次减益，适合应对高威胁回合。"
	card_zero_trust_architecture.card_type = CardData.CARD_TYPES.POWER
	card_zero_trust_architecture.card_rarity = CardData.CARD_RARITIES.RARE
	card_zero_trust_architecture.card_requires_target = false
	card_zero_trust_architecture.card_energy_cost = 2
	card_zero_trust_architecture.card_play_destination = HandManager.EXHAUST_PILE
	card_zero_trust_architecture.card_values = {"status_charge_amount": 1}
	card_zero_trust_architecture.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_zero_trust_architecture.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_negate_damage",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_negate_debuff",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(card_zero_trust_architecture)

	# 异常脚本（诅咒卡牌）
	var card_curse_exception: CardData = CardData.new("card_curse_exception")
	card_curse_exception.card_name = "异常报错"
	card_curse_exception.card_color_id = "color_white"
	card_curse_exception.card_texture_path = "sprites/card/white/card_curse_exception.png"
	card_curse_exception.card_values = {"damage": 1}
	card_curse_exception.card_description = "无法被打出。 [color=#ff6b6b]抽到此牌时，受到 [damage] 点伤害。[/color]"
	card_curse_exception.card_hint = "这是一张诅咒卡牌。不仅会污染卡池，某些情况下还会造成负面效果。"
	card_curse_exception.card_type = CardData.CARD_TYPES.CURSE
	card_curse_exception.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_curse_exception.card_is_playable = false
	card_curse_exception.card_draw_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
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
	card_status_dazed.card_texture_path = "sprites/card/white/card_status_dazed.png"
	card_status_dazed.card_description = ""
	card_status_dazed.card_hint = "状态牌。卡在手里占用抽牌空间，回合结束后自动消失。"
	card_status_dazed.card_type = CardData.CARD_TYPES.STATUS
	card_status_dazed.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_status_dazed.card_is_playable = false
	card_status_dazed.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	Global.register_rod(card_status_dazed)

	# Burn (过载发热) - Unplayable, deals 2 damage to player at end of turn
	var card_status_burn: CardData = CardData.new("card_status_burn")
	card_status_burn.card_name = "过载发热"
	card_status_burn.card_color_id = "color_white"
	card_status_burn.card_texture_path = "sprites/card/white/card_status_burn.png"
	card_status_burn.card_description = "无法被打出。 [color=#ff6b6b]在你的回合结束时，受到 [damage] 点伤害。[/color]"
	card_status_burn.card_hint = "状态牌。不仅卡手，回合结束时还会对你造成真实伤害！"
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
	
	# 融合（占位符，用于图鉴显示）
	var card_forge_fusion: CardData = CardData.new("card_forge_fusion")
	card_forge_fusion.card_name = "融合"
	card_forge_fusion.card_color_id = "color_white"
	card_forge_fusion.card_texture_path = "sprites/card/white/card_forge_compile.png"
	card_forge_fusion.card_description = "释放锻造台中的指定代码，并按顺序依次执行这些指令。 [color=gray]此卡牌仅在战斗中通过特定的锻造机制动态生成。[/color]"
	card_forge_fusion.card_hint = "融合卡是代码锻炉的核心产物，能够完美继承并连续执行所有被置入锻造台的卡牌的核心指令。合理规划锻造顺序，可以打出极具破坏力的组合效果！"
	card_forge_fusion.card_type = CardData.CARD_TYPES.SKILL
	card_forge_fusion.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_forge_fusion.card_requires_target = false
	card_forge_fusion.card_play_destination = HandManager.BANISH_PILE
	card_forge_fusion.card_end_of_turn_destination = HandManager.BANISH_PILE
	card_forge_fusion.card_energy_cost = 0
	card_forge_fusion.card_play_actions = []
	Global.register_rod(card_forge_fusion)

	# 10. 精准打击 (Time Strike)
	var card_time_strike: CardData = CardData.new("card_time_strike")
	card_time_strike.card_name = "精准打击"
	card_time_strike.card_color_id = "color_{0}".format([color])
	card_time_strike.card_description = "造成当前游戏时间（秒）个位数 x [time_multiplier] 的伤害。"
	card_time_strike.card_hint = "打出该牌时，会取当前时间秒数的个位数并乘以 [time_multiplier] 结算伤害。"
	card_time_strike.card_type = CardData.CARD_TYPES.ATTACK
	card_time_strike.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_time_strike.card_requires_target = true
	card_time_strike.card_energy_cost = 1
	card_time_strike.card_requires_time_snapshot = true
	card_time_strike.card_texture_path = "sprites/card/white/card_time_strike.png"
	card_time_strike.card_values = {"time_multiplier": 2, "number_of_attacks": 1}
	card_time_strike.card_upgrade_value_improvements = {"time_multiplier": 1}
	card_time_strike.card_play_actions = [
		{
			Scripts.ACTION_TIME_ATTACK_GENERATOR: {
				"time_extraction_mode": ActionTimeAttackGenerator.TIME_EXTRACTION_MODES.ONES_DIGIT,
				"audio_path": AudioConstants.SFX_GROUP_BLUNT_SMASH,
				"time_delay": 0.0,
			},
		},
	]
	Global.register_rod(card_time_strike)
