## 蓝色卡牌 — 渗透专家 / 白帽黑客主题
## 主题A：情报渗透 — 抽牌/手牌操控/牌库回收，以信息优势碾压对手
## 主题B：漏洞利用 — "漏洞暴露" debuff 联动，叠加 → 爆发
class_name GlobalProdDataGeneratorBlueCards
extends RefCounted

static func add_cards_blue() -> void:
	var color: String = "blue"

	#region 流派A：情报渗透

	# 1. 端口扫描 — 基础抽牌
	var card_port_scan: CardData = CardData.new("card_port_scan")
	card_port_scan.card_name = "端口扫描"
	card_port_scan.card_color_id = "color_{0}".format([color])
	card_port_scan.card_texture_path = "sprites/card/blue/card_port_scan.png"
	card_port_scan.card_description = "读取 [draw_count] 个脚本。"
	card_port_scan.card_hint = "摸 [draw_count] 张牌。"
	card_port_scan.card_type = CardData.CARD_TYPES.SKILL
	card_port_scan.card_rarity = CardData.CARD_RARITIES.COMMON
	card_port_scan.card_requires_target = false
	card_port_scan.card_energy_cost = 1
	card_port_scan.card_values = {"draw_count": 2}
	card_port_scan.card_upgrade_value_improvements = {"draw_count": 1}
	card_port_scan.card_play_actions = [
		{Scripts.ACTION_DRAW_GENERATOR: {}},
	]

	Global.register_rod(card_port_scan)

	# 2. 数据嗅探 — 攻击附带过牌
	var card_data_sniff: CardData = CardData.new("card_data_sniff")
	card_data_sniff.card_name = "数据嗅探"
	card_data_sniff.card_color_id = "color_{0}".format([color])
	card_data_sniff.card_texture_path = "sprites/card/blue/card_data_sniff.png"
	card_data_sniff.card_description = "造成 [damage] 点伤害。读取 [draw_count] 个脚本。"
	card_data_sniff.card_hint = "攻击，并摸 [draw_count] 张牌。"
	card_data_sniff.card_type = CardData.CARD_TYPES.ATTACK
	card_data_sniff.card_rarity = CardData.CARD_RARITIES.COMMON
	card_data_sniff.card_requires_target = true
	card_data_sniff.card_energy_cost = 1
	card_data_sniff.card_values = {"damage": 7, "number_of_attacks": 1, "draw_count": 1, "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_data_sniff.card_upgrade_value_improvements = {"damage": 2}
	card_data_sniff.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }},
		{Scripts.ACTION_DRAW_GENERATOR: {}},
	]

	Global.register_rod(card_data_sniff)

	# 3. 缓存预热 — 护盾 + 打出后回抽牌堆顶
	var card_cache_warmup: CardData = CardData.new("card_cache_warmup")
	card_cache_warmup.card_name = "缓存预热"
	card_cache_warmup.card_color_id = "color_{0}".format([color])
	card_cache_warmup.card_texture_path = "sprites/card/blue/card_cache_warmup.png"
	card_cache_warmup.card_description = "获得 [block] 点防火墙。打出后置于内存队列顶部。"
	card_cache_warmup.card_hint = "获得护盾（防火墙）；打出后它回到牌库顶，下次摸牌会最先摸到它。"
	card_cache_warmup.card_type = CardData.CARD_TYPES.SKILL
	card_cache_warmup.card_rarity = CardData.CARD_RARITIES.COMMON
	card_cache_warmup.card_requires_target = false
	card_cache_warmup.card_energy_cost = 1
	card_cache_warmup.card_play_destination = HandManager.DRAW_PILE
	card_cache_warmup.card_play_destination_strategy = HandManager.PILE_INSERTION_STRATEGIES.TOP
	card_cache_warmup.card_values = {"block": 7}
	card_cache_warmup.card_upgrade_value_improvements = {"block": 4}
	card_cache_warmup.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
	]

	Global.register_rod(card_cache_warmup)

	# 4. 流量分析 — 手牌数 → 护盾
	var card_traffic_analysis: CardData = CardData.new("card_traffic_analysis")
	card_traffic_analysis.card_name = "流量分析"
	card_traffic_analysis.card_color_id = "color_{0}".format([color])
	card_traffic_analysis.card_texture_path = "sprites/card/blue/card_traffic_analysis.png"
	card_traffic_analysis.card_description = "当前线程中每有一个脚本，获得 [block_per_card] 点防火墙。"
	card_traffic_analysis.card_hint = "获得护盾 = 手牌数 * [block_per_card]"
	card_traffic_analysis.card_type = CardData.CARD_TYPES.SKILL
	card_traffic_analysis.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_traffic_analysis.card_requires_target = false
	card_traffic_analysis.card_energy_cost = 0
	card_traffic_analysis.card_values = {"block": 2, "block_per_card": 2}
	card_traffic_analysis.card_upgrade_value_improvements = {"block": 1, "block_per_card": 1}
	card_traffic_analysis.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "cards_in_hand",
				"multiplied_values": ["block"],
				"multiplied_values_bases": {"block": 0},
				"time_delay": 0.0,
				"action_data": [
					{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
				],
			},
		},
	]

	Global.register_rod(card_traffic_analysis)

	# 5. 栈追踪 — 从弃牌堆回收一张牌，该牌本回合免费
	var card_stack_trace: CardData = CardData.new("card_stack_trace")
	card_stack_trace.card_name = "栈追踪"
	card_stack_trace.card_color_id = "color_{0}".format([color])
	card_stack_trace.card_texture_path = "sprites/card/blue/card_stack_trace.png"
	card_stack_trace.card_description = "选择回收站中一张脚本放回当前线程，本时钟周期耗能变为 0。"
	card_stack_trace.card_hint = "从弃牌堆（回收站）里选一张已打出的牌拿回手牌，且本回合打出它不花费用；此牌打出后本场战斗不再出现。"
	card_stack_trace.card_type = CardData.CARD_TYPES.SKILL
	card_stack_trace.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_stack_trace.card_requires_target = false
	card_stack_trace.card_energy_cost = 1
	card_stack_trace.card_play_destination = HandManager.EXHAUST_PILE
	card_stack_trace.card_values = {"energy_cost_zero": 0}
	card_stack_trace.card_first_upgrade_property_changes = {
		"card_play_destination": HandManager.DISCARD_PILE,
		"card_hint": "从弃牌堆（回收站）里选一张已打出的牌拿回手牌，且本回合打出它不花费用。"
	}
	card_stack_trace.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.DISCARD_PILE,
				"min_card_amount": 1,
				"max_card_amount": 1,
				"min_cards_are_required_for_action": false,
				"random_selection": false,
				"card_pick_text": "选择一张脚本，本回合耗能变为 0",
				"action_data": [
					{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
					{
						Scripts.ACTION_CHANGE_CARD_ENERGIES: {
							"custom_key_names": {"card_energy_cost_until_turn": "energy_cost_zero"},
						},
					},
				],
			},
		},
	]

	Global.register_rod(card_stack_trace)


	# 7. 数据挖掘 — 能力：每回合额外抽牌
	var card_data_mining: CardData = CardData.new("card_data_mining")
	card_data_mining.card_name = "数据挖掘"
	card_data_mining.card_color_id = "color_{0}".format([color])
	card_data_mining.card_texture_path = "sprites/card/blue/card_data_mining.png"
	card_data_mining.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_increase_turn_draw]。"
	card_data_mining.card_hint = "打出后，本场战斗每个回合开始时都会多摸 [status_charge_amount] 张牌，效果永久持续。"
	card_data_mining.card_type = CardData.CARD_TYPES.POWER
	card_data_mining.card_rarity = CardData.CARD_RARITIES.RARE
	card_data_mining.card_requires_target = false
	card_data_mining.card_energy_cost = 2
	card_data_mining.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_increase_turn_draw"}
	card_data_mining.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_data_mining.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_increase_turn_draw",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]

	Global.register_rod(card_data_mining)

	#endregion

	#region 流派B：漏洞利用

	# 8. 注入攻击 — 攻击 + 漏洞暴露
	var card_inject_attack: CardData = CardData.new("card_inject_attack")
	card_inject_attack.card_name = "注入攻击"
	card_inject_attack.card_color_id = "color_{0}".format([color])
	card_inject_attack.card_texture_path = "sprites/card/blue/card_inject_attack.png"
	card_inject_attack.card_description = "造成 [damage] 点伤害，并施加 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]。若目标有 [status_icon:status_effect_vulnerable]，额外造成 [bonus_damage] 点伤害。"
	card_inject_attack.card_hint = "攻击并施加 [status_icon:status_effect_vulnerable]（使目标受到的攻击伤害提高50%）；若目标已有该状态，则额外造成伤害。"
	card_inject_attack.card_type = CardData.CARD_TYPES.ATTACK
	card_inject_attack.card_rarity = CardData.CARD_RARITIES.COMMON
	card_inject_attack.card_requires_target = true
	card_inject_attack.card_energy_cost = 1
	card_inject_attack.card_values = {"damage": 5, "bonus_damage": 3, "number_of_attacks": 1, "status_charge_amount": 1, "status_effect_object_id": "status_effect_vulnerable", "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_inject_attack.card_upgrade_value_improvements = {"damage": 2, "bonus_damage": 2, "status_charge_amount": 1}
	card_inject_attack.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
			},
		},
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_TARGET_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_vulnerable",
						"operator": ">=",
						"status_effect_charge_comparison_value": 1,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, 
						"custom_key_names": {"additional_damage": "bonus_damage"}
					}}
				],
				"failed_action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }}
				]
			}
		}
	]

	Global.register_rod(card_inject_attack)

	# 9. 木马植入 — 纯 debuff 叠加
	var card_trojan_plant: CardData = CardData.new("card_trojan_plant")
	card_trojan_plant.card_name = "木马植入"
	card_trojan_plant.card_color_id = "color_{0}".format([color])
	card_trojan_plant.card_texture_path = "sprites/card/blue/card_trojan_plant.png"
	card_trojan_plant.card_description = "施加 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]。"
	card_trojan_plant.card_hint = "对目标施加 [status_icon:status_effect_vulnerable]，使其之后受到的攻击伤害提高50%。"
	card_trojan_plant.card_type = CardData.CARD_TYPES.SKILL
	card_trojan_plant.card_rarity = CardData.CARD_RARITIES.COMMON
	card_trojan_plant.card_requires_target = true
	card_trojan_plant.card_energy_cost = 1
	card_trojan_plant.card_values = {"status_charge_amount": 3, "status_effect_object_id": "status_effect_vulnerable"}
	card_trojan_plant.card_upgrade_value_improvements = {"status_charge_amount": 2}
	card_trojan_plant.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
			},
		},
	]

	Global.register_rod(card_trojan_plant)

	# 10. 渗透测试 — 施加漏洞暴露，然后造成等于层数的伤害
	var card_penetration_test: CardData = CardData.new("card_penetration_test")
	card_penetration_test.card_name = "渗透测试"
	card_penetration_test.card_color_id = "color_{0}".format([color])
	card_penetration_test.card_texture_path = "sprites/card/blue/card_penetration_test.png"
	card_penetration_test.card_description = "施加 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]，然后造成等同于 [status_icon:status_effect_vulnerable] 层数的伤害。"
	card_penetration_test.card_hint = "先叠加 [status_icon:status_effect_vulnerable]，再造成与目标当前 [status_icon:status_effect_vulnerable] 层数相等的伤害。"
	card_penetration_test.card_type = CardData.CARD_TYPES.ATTACK
	card_penetration_test.card_rarity = CardData.CARD_RARITIES.COMMON
	card_penetration_test.card_requires_target = true
	card_penetration_test.card_energy_cost = 1
	card_penetration_test.card_values = {"damage": 1, "number_of_attacks": 1, "status_charge_amount": 1, "status_effect_object_id": "status_effect_vulnerable", "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_penetration_test.card_upgrade_value_improvements = {"status_charge_amount": 1}
	card_penetration_test.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "target_status_effect_charges",
				"multiplied_values": ["damage"],
				"multiplied_values_bases": {"damage": 0},
				"stat_variable_name": "status_effect_vulnerable",
				"time_delay": 0.0,
				"action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }},
				],
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
			},
		},
	]

	Global.register_rod(card_penetration_test)

	# 11. SQL注入 — 多段攻击，有漏洞暴露时多打一段
	var card_sql_injection: CardData = CardData.new("card_sql_injection")
	card_sql_injection.card_name = "SQL注入"
	card_sql_injection.card_color_id = "color_{0}".format([color])
	card_sql_injection.card_texture_path = "sprites/card/blue/card_sql_injection.png"
	card_sql_injection.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害。若目标有 [status_icon:status_effect_vulnerable]，额外造成一次伤害。"
	card_sql_injection.card_hint = "多段攻击；若目标处于 [status_icon:status_effect_vulnerable] 状态，则额外多攻击一段。"
	card_sql_injection.card_type = CardData.CARD_TYPES.ATTACK
	card_sql_injection.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_sql_injection.card_requires_target = true
	card_sql_injection.card_energy_cost = 2
	card_sql_injection.card_values = {"damage": 6, "number_of_attacks": 2, "bonus_attacks": 3, "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_sql_injection.card_upgrade_value_improvements = {"damage": 2, "bonus_attacks": 0}
	card_sql_injection.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_TARGET_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_vulnerable",
						"operator": ">=",
						"status_effect_charge_comparison_value": 1,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, 
						"custom_key_names": {"number_of_attacks": "bonus_attacks"}
					}}
				],
				"failed_action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }}
				]
			}
		}
	]

	Global.register_rod(card_sql_injection)

	# 12. 拒绝服务 — 双 debuff 控场
	var card_denial_of_service: CardData = CardData.new("card_denial_of_service")
	card_denial_of_service.card_name = "拒绝服务"
	card_denial_of_service.card_color_id = "color_{0}".format([color])
	card_denial_of_service.card_texture_path = "sprites/card/blue/card_denial_of_service.png"
	card_denial_of_service.card_description = "施加 [vulnerable_amount] 层 [status_icon:status_effect_vulnerable] 和 [weaken_amount] 层 [status_icon:status_effect_weaken]。"
	card_denial_of_service.card_hint = "给目标叠加 [status_icon:status_effect_vulnerable]（受到伤害提高）和 [status_icon:status_effect_weaken]（其攻击伤害降低）两种减益。"
	card_denial_of_service.card_type = CardData.CARD_TYPES.SKILL
	card_denial_of_service.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_denial_of_service.card_requires_target = true
	card_denial_of_service.card_energy_cost = 2
	card_denial_of_service.card_values = {"vulnerable_amount": 2, "weaken_amount": 2}
	card_denial_of_service.card_upgrade_value_improvements = {"vulnerable_amount": 1, "weaken_amount": 1}
	card_denial_of_service.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"custom_key_names": {"status_charge_amount": "vulnerable_amount"},
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_weaken",
				"custom_key_names": {"status_charge_amount": "weaken_amount"},
			},
		},
	]

	Global.register_rod(card_denial_of_service)

	# 13. 后门植入 — 生成 token 卡到手牌
	var card_backdoor_inject: CardData = CardData.new("card_backdoor_inject")
	card_backdoor_inject.card_name = "后门植入"
	card_backdoor_inject.card_color_id = "color_{0}".format([color])
	card_backdoor_inject.card_texture_path = "sprites/card/blue/card_backdoor_inject.png"
	card_backdoor_inject.card_description = "将一张[card_name:card_exploit_token]加入当前线程。"
	card_backdoor_inject.card_hint = "生成一张 0 费的[card_name:card_exploit_token]到手牌，可用来给敌人叠加 [status_icon:status_effect_vulnerable]；此牌打出后本场战斗不再出现。"
	card_backdoor_inject.card_type = CardData.CARD_TYPES.SKILL
	card_backdoor_inject.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_backdoor_inject.card_requires_target = false
	card_backdoor_inject.card_energy_cost = 1
	card_backdoor_inject.card_play_destination = HandManager.EXHAUST_PILE
	card_backdoor_inject.card_values = {}
	card_backdoor_inject.card_first_upgrade_property_changes = {
		"card_description": "将两张[card_name:card_exploit_token]加入当前线程。",
		"card_play_actions": [
			{Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_exploit_token",
				"number_of_cards": 2,
				"action_data": [
					{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
				],
			}},
		],
	}
	card_backdoor_inject.card_play_actions = [
		{Scripts.ACTION_CREATE_CARDS: {
			"created_card_object_id": "card_exploit_token",
			"number_of_cards": 1,
			"action_data": [
				{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
			],
		}},
	]

	Global.register_rod(card_backdoor_inject)

	# Token: 漏洞注入 — 由后门植入生成
	var card_exploit_token: CardData = CardData.new("card_exploit_token")
	card_exploit_token.card_name = "漏洞注入"
	card_exploit_token.card_color_id = "color_{0}".format([color])
	card_exploit_token.card_texture_path = "sprites/card/blue/card_exploit_token.png"
	card_exploit_token.card_description = "施加 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]。"
	card_exploit_token.card_hint = "打出后对目标施加 [status_icon:status_effect_vulnerable]（使其受到的攻击伤害提高50%）；此牌打出后本场战斗不再出现。"
	card_exploit_token.card_type = CardData.CARD_TYPES.SKILL
	card_exploit_token.card_rarity = CardData.CARD_RARITIES.GENERATED
	card_exploit_token.card_requires_target = true
	card_exploit_token.card_energy_cost = 0
	card_exploit_token.card_play_destination = HandManager.EXHAUST_PILE
	card_exploit_token.card_values = {"status_charge_amount": 2, "status_effect_object_id": "status_effect_vulnerable"}
	card_exploit_token.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
			},
		},
	]

	Global.register_rod(card_exploit_token)

	# 14. 蠕虫病毒 — 能力：战斗开始时对所有敌人施加漏洞暴露
	var card_worm_virus: CardData = CardData.new("card_worm_virus")
	card_worm_virus.card_name = "蠕虫病毒"
	card_worm_virus.card_color_id = "color_{0}".format([color])
	card_worm_virus.card_texture_path = "sprites/card/blue/card_worm_virus.png"
	card_worm_virus.card_description = "战斗开始时，对所有敌人施加 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]。"
	card_worm_virus.card_hint = "只要它在你的牌库中，每场战斗开始时就自动对所有敌人施加 [status_icon:status_effect_vulnerable]，无需打出或摸到。"
	card_worm_virus.card_type = CardData.CARD_TYPES.POWER
	card_worm_virus.card_rarity = CardData.CARD_RARITIES.RARE
	card_worm_virus.card_requires_target = false
	card_worm_virus.card_energy_cost = 2
	card_worm_virus.card_first_shuffle_priority = 1
	card_worm_virus.card_values = {"status_charge_amount": 1}
	card_worm_virus.card_first_upgrade_property_changes = {"card_energy_cost": 1}
	card_worm_virus.card_initial_combat_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]

	Global.register_rod(card_worm_virus)

	# 15. 零日漏洞 — 高爆发终结技，有漏洞暴露时伤害翻倍
	var card_zero_day: CardData = CardData.new("card_zero_day")
	card_zero_day.card_name = "零日漏洞"
	card_zero_day.card_color_id = "color_{0}".format([color])
	card_zero_day.card_texture_path = "sprites/card/blue/card_zero_day.png"
	card_zero_day.card_description = "造成 [damage] 点伤害。若目标有 [status_icon:status_effect_vulnerable]，伤害翻倍。"
	card_zero_day.card_hint = "若敌人有[status_icon:status_effect_vulnerable]，则伤害翻倍"
	card_zero_day.card_type = CardData.CARD_TYPES.ATTACK
	card_zero_day.card_rarity = CardData.CARD_RARITIES.RARE
	card_zero_day.card_requires_target = true
	card_zero_day.card_energy_cost = 2
	card_zero_day.card_values = {"damage": 18, "bonus_damage": 18, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_zero_day.card_upgrade_value_improvements = {"damage": 5, "bonus_damage": 5}
	card_zero_day.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_TARGET_STATUS_EFFECT_CHARGES: {
						"status_effect_object_id": "status_effect_vulnerable",
						"operator": ">=",
						"status_effect_charge_comparison_value": 1,
					}},
				],
				"passed_action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, 
						"custom_key_names": {"additional_damage": "bonus_damage"}
					}}
				],
				"failed_action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }}
				]
			}
		}
	]

	Global.register_rod(card_zero_day)

	#endregion

	#region 通用 / 混合

	# 16. 代理转发 — 护盾 + 手牌攻击牌加成
	var card_proxy_forward: CardData = CardData.new("card_proxy_forward")
	card_proxy_forward.card_name = "代理转发"
	card_proxy_forward.card_color_id = "color_{0}".format([color])
	card_proxy_forward.card_texture_path = "sprites/card/blue/card_proxy_forward.png"
	card_proxy_forward.card_description = "获得 [block] 点防火墙。当前线程中每有一张攻击脚本，额外获得 [block_per_attack] 点。"
	card_proxy_forward.card_hint = "获得护盾（防火墙）；手牌里每有一张攻击牌，再额外获得一些护盾（防火墙）。"
	card_proxy_forward.card_type = CardData.CARD_TYPES.SKILL
	card_proxy_forward.card_rarity = CardData.CARD_RARITIES.COMMON
	card_proxy_forward.card_requires_target = false
	card_proxy_forward.card_energy_cost = 1
	card_proxy_forward.card_values = {"block": 6, "block_per_attack": 2}
	card_proxy_forward.card_upgrade_value_improvements = {"block": 3}
	card_proxy_forward.card_play_actions = [
		{Scripts.ACTION_BLOCK: {"target_override": BaseAction.TARGET_OVERRIDES.PARENT, "audio_path": AudioConstants.SFX_GROUP_SHIELD_UP}},
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "attack_cards_in_hand",
				"multiplied_values": ["block_per_attack"],
				"multiplied_values_bases": {"block_per_attack": 0},
				"time_delay": 0.0,
				"action_data": [
					{Scripts.ACTION_BLOCK: {
						"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
						"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
						"custom_key_names": {"block": "block_per_attack"},
					}},
				],
			},
		},
	]

	Global.register_rod(card_proxy_forward)

	# 17. 缓冲区溢出 — 标准 2 费直伤
	var card_buffer_overflow: CardData = CardData.new("card_buffer_overflow_blue")
	card_buffer_overflow.card_name = "缓冲区溢出"
	card_buffer_overflow.card_color_id = "color_{0}".format([color])
	card_buffer_overflow.card_texture_path = "sprites/card/blue/card_buffer_overflow_blue.png"
	card_buffer_overflow.card_description = "造成 [damage] 点伤害。"
	card_buffer_overflow.card_hint = "一张单纯的高伤害攻击牌。"
	card_buffer_overflow.card_type = CardData.CARD_TYPES.ATTACK
	card_buffer_overflow.card_rarity = CardData.CARD_RARITIES.COMMON
	card_buffer_overflow.card_requires_target = true
	card_buffer_overflow.card_energy_cost = 2
	card_buffer_overflow.card_values = {"damage": 16, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_buffer_overflow.card_upgrade_value_improvements = {"damage": 6}
	card_buffer_overflow.card_play_actions = [
		{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }},
	]

	Global.register_rod(card_buffer_overflow)

	# 18. 逻辑炸弹 — 攻击 + 炸弹 debuff
	var card_logic_bomb: CardData = CardData.new("card_logic_bomb")
	card_logic_bomb.card_name = "逻辑炸弹"
	card_logic_bomb.card_color_id = "color_{0}".format([color])
	card_logic_bomb.card_texture_path = "sprites/card/blue/card_logic_bomb.png"
	card_logic_bomb.card_description = "造成 [damage] 点伤害。给自己施加 [bomb_amount] 层（副层数为 [bomb_damage] ） [status_icon:status_effect_bomb]。"
	card_logic_bomb.card_hint = "造成伤害并给自己装上 [status_icon:status_effect_bomb]，倒计时结束后引爆、对所有敌人造成 [bomb_damage] 点伤害。此牌打出后本场战斗不再出现。"
	card_logic_bomb.card_type = CardData.CARD_TYPES.ATTACK
	card_logic_bomb.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_logic_bomb.card_requires_target = true
	card_logic_bomb.card_energy_cost = 2
	card_logic_bomb.card_play_destination = HandManager.EXHAUST_PILE
	card_logic_bomb.card_values = {"damage": 8, "number_of_attacks": 1, "bomb_amount": 3, "bomb_damage": 15, "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_logic_bomb.card_upgrade_value_improvements = {"damage": 4, "bomb_damage": 5}
	card_logic_bomb.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_bomb",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"custom_key_names": {"status_charge_amount": "bomb_amount", "status_secondary_charge_amount": "bomb_damage"},
			},
		},
		{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }},
	]

	Global.register_rod(card_logic_bomb)

	# 19. 暗网协议 — X 费：消耗所有算力，获得等量算力增幅
	var card_darknet_protocol: CardData = CardData.new("card_darknet_protocol")
	card_darknet_protocol.card_name = "暗网协议"
	card_darknet_protocol.card_color_id = "color_{0}".format([color])
	card_darknet_protocol.card_texture_path = "sprites/card/blue/card_darknet_protocol.png"
	card_darknet_protocol.card_description = "获得 X 层 [status_icon:status_effect_damage_increase]。"
	card_darknet_protocol.card_hint = "使用你当前全部能量（算力），按使用的点数获得等量 [status_icon:status_effect_damage_increase]（攻击伤害提高）；此牌打出后本场战斗不再出现。"
	card_darknet_protocol.card_type = CardData.CARD_TYPES.SKILL
	card_darknet_protocol.card_rarity = CardData.CARD_RARITIES.RARE
	card_darknet_protocol.card_requires_target = false
	card_darknet_protocol.card_energy_cost = 0
	card_darknet_protocol.card_energy_cost_is_variable = true
	card_darknet_protocol.card_energy_cost_variable_upper_bound = -1
	card_darknet_protocol.card_play_destination = HandManager.EXHAUST_PILE
	card_darknet_protocol.card_end_of_turn_destination = HandManager.EXHAUST_PILE
	card_darknet_protocol.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_damage_increase", "multiplier_offset": 0}
	card_darknet_protocol.card_upgrade_value_improvements = {"multiplier_offset": 1}
	card_darknet_protocol.card_first_upgrade_property_changes = {
		"card_end_of_turn_destination": HandManager.DISCARD_PILE,
		"card_description": "获得 X+1 层 [status_icon:status_effect_damage_increase]。",
	}
	card_darknet_protocol.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COST_MODIFIER: {
				"action_data": [
					{
						Scripts.ACTION_APPLY_STATUS: {
							"status_effect_object_id": "status_effect_damage_increase",
							"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
						},
					},
				],
				"multiplied_values": ["status_charge_amount"],
				"time_delay": 0.0,
			},
		},
	]

	Global.register_rod(card_darknet_protocol)

	# 20. 安全审计 — 手牌数 → 漏洞暴露
	var card_security_audit: CardData = CardData.new("card_security_audit")
	card_security_audit.card_name = "安全审计"
	card_security_audit.card_color_id = "color_{0}".format([color])
	card_security_audit.card_texture_path = "sprites/card/blue/card_security_audit.png"
	card_security_audit.card_description = "施加等同于当前线程中脚本数量的 [status_icon:status_effect_vulnerable] 层数。"
	card_security_audit.card_hint = "按你当前手牌数量，给目标叠加等量的 [status_icon:status_effect_vulnerable]；此牌打出后本场战斗不再出现。"
	card_security_audit.card_type = CardData.CARD_TYPES.SKILL
	card_security_audit.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_security_audit.card_requires_target = true
	card_security_audit.card_energy_cost = 1
	card_security_audit.card_play_destination = HandManager.EXHAUST_PILE
	card_security_audit.card_values = {"status_charge_amount": 1, "status_effect_object_id": "status_effect_vulnerable"}
	card_security_audit.card_first_upgrade_property_changes = {
		"card_play_destination": HandManager.DISCARD_PILE,
		"card_hint": "按你当前手牌数量，给目标叠加等量的 [status_icon:status_effect_vulnerable]。"
	}
	card_security_audit.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "cards_in_hand",
				"multiplied_values": ["status_charge_amount"],
				"multiplied_values_bases": {"status_charge_amount": 0},
				"time_delay": 0.0,
				"action_data": [
					{
						Scripts.ACTION_APPLY_STATUS: {
							"status_effect_object_id": "status_effect_vulnerable",
						},
					},
				],
			},
		},
	]

	Global.register_rod(card_security_audit)

	#endregion

	#region 生存与AOE

	# 20. 广播风暴 — AOE 攻击
	var card_broadcast_storm: CardData = CardData.new("card_broadcast_storm")
	card_broadcast_storm.card_name = "广播风暴"
	card_broadcast_storm.card_color_id = "color_{0}".format([color])
	card_broadcast_storm.card_texture_path = "sprites/card/blue/card_broadcast_storm.png"
	card_broadcast_storm.card_description = "对所有敌人造成 [damage] 点伤害。施加 [status_charge_amount] 层 [status_icon:status_effect_vulnerable]。"
	card_broadcast_storm.card_hint = "对所有敌人造成伤害，并施加 [status_icon:status_effect_vulnerable]（使其受到的攻击伤害提高）。"
	card_broadcast_storm.card_type = CardData.CARD_TYPES.ATTACK
	card_broadcast_storm.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_broadcast_storm.card_requires_target = false
	card_broadcast_storm.card_energy_cost = 2
	card_broadcast_storm.card_values = {"damage": 8, "number_of_attacks": 1, "status_charge_amount": 1, "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_broadcast_storm.card_upgrade_value_improvements = {"damage": 3, "status_charge_amount": 1}
	card_broadcast_storm.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, 
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]

	Global.register_rod(card_broadcast_storm)

	# 21. 数据备份 — 回血
	var card_data_backup: CardData = CardData.new("card_data_backup")
	card_data_backup.card_name = "数据备份"
	card_data_backup.card_color_id = "color_{0}".format([color])
	card_data_backup.card_texture_path = "sprites/card/blue/card_data_backup.png"
	card_data_backup.card_description = "恢复 [health_amount] 点完整度。"
	card_data_backup.card_hint = "恢复生命（完整度）；此牌打出后本场战斗不再出现。"
	card_data_backup.card_type = CardData.CARD_TYPES.SKILL
	card_data_backup.card_rarity = CardData.CARD_RARITIES.COMMON
	card_data_backup.card_requires_target = false
	card_data_backup.card_energy_cost = 1
	card_data_backup.card_play_destination = HandManager.EXHAUST_PILE
	card_data_backup.card_values = {"health_amount": 6}
	card_data_backup.card_upgrade_value_improvements = {"health_amount": 3}
	card_data_backup.card_play_actions = [
		{
			Scripts.ACTION_ADD_HEALTH: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]

	Global.register_rod(card_data_backup)

	# 22. 蜜罐陷阱 — 全体输出降级
	var card_honeypot: CardData = CardData.new("card_honeypot")
	card_honeypot.card_name = "蜜罐陷阱"
	card_honeypot.card_color_id = "color_{0}".format([color])
	card_honeypot.card_texture_path = "sprites/card/blue/card_honeypot.png"
	card_honeypot.card_description = "获得 [block] 点防火墙。对所有敌人施加 [status_charge_amount] 层 [status_icon:status_effect_weaken]。"
	card_honeypot.card_hint = "获得护盾（防火墙），并让所有敌人获得 [status_icon:status_effect_weaken]（其攻击伤害降低）。"
	card_honeypot.card_type = CardData.CARD_TYPES.SKILL
	card_honeypot.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_honeypot.card_requires_target = false
	card_honeypot.card_energy_cost = 2
	card_honeypot.card_values = {"block": 7, "status_charge_amount": 1}
	card_honeypot.card_upgrade_value_improvements = {"block": 3, "status_charge_amount": 1}
	card_honeypot.card_play_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_weaken",
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]

	Global.register_rod(card_honeypot)

	# 23. 载荷投递 — 攻击+漏洞+过牌
	var card_payload_delivery: CardData = CardData.new("card_payload_delivery")
	card_payload_delivery.card_name = "载荷投递"
	card_payload_delivery.card_color_id = "color_{0}".format([color])
	card_payload_delivery.card_texture_path = "sprites/card/blue/card_payload_delivery.png"
	card_payload_delivery.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害。目标每有 1 层 [status_icon:status_effect_vulnerable]，次数加 1。读取 [draw_count] 个脚本。"
	card_payload_delivery.card_hint = "多段攻击，目标每有 1 层 [status_icon:status_effect_vulnerable] 就多攻击 1 段，随后摸 [draw_count] 张牌。"
	card_payload_delivery.card_type = CardData.CARD_TYPES.ATTACK
	card_payload_delivery.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_payload_delivery.card_requires_target = true
	card_payload_delivery.card_energy_cost = 2
	card_payload_delivery.card_values = {"damage": 4, "number_of_attacks": 1, "draw_count": 1, "status_effect_object_id": "status_effect_vulnerable", "impact_vfx_animation_id": "animation_vfx_magic_blue"}
	card_payload_delivery.card_upgrade_value_improvements = {"damage": 2}
	card_payload_delivery.card_play_actions = [
		{
			Scripts.ACTION_VARIABLE_COMBAT_STATS_MODIFIER: {
				"combat_stat_name": "target_status_effect_charges",
				"stat_variable_name": "status_effect_vulnerable",
				"multiplied_values": ["number_of_attacks"],
				"multiplied_values_bases": {"number_of_attacks": 1},
				"action_data": [
					{Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST, }},
				]
			},
		},
		{Scripts.ACTION_DRAW_GENERATOR: {}},
	]

	Global.register_rod(card_payload_delivery)

	# 24. 权限提升 — 永久最大算力成长
	var card_privilege_escalation: CardData = CardData.new("card_privilege_escalation")
	card_privilege_escalation.card_name = "权限提升"
	card_privilege_escalation.card_color_id = "color_{0}".format([color])
	card_privilege_escalation.card_texture_path = "sprites/card/blue/card_privilege_escalation.png"
	card_privilege_escalation.card_description = "获得 [status_charge_amount] 层 [status_icon:status_effect_bonus_energy_per_turn]。"
	card_privilege_escalation.card_hint = "在本场战斗接下来的每个回合，额外获得等同于层数的算力；此牌打出后本场战斗不再出现。"
	card_privilege_escalation.card_type = CardData.CARD_TYPES.POWER
	card_privilege_escalation.card_rarity = CardData.CARD_RARITIES.RARE
	card_privilege_escalation.card_requires_target = false
	card_privilege_escalation.card_energy_cost = 1
	card_privilege_escalation.card_play_destination = HandManager.EXHAUST_PILE
	card_privilege_escalation.card_values = {"status_charge_amount": 1}
	card_privilege_escalation.card_upgrade_value_improvements = {}
	card_privilege_escalation.card_first_upgrade_property_changes = {"card_energy_cost": 0}
	card_privilege_escalation.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"status_effect_object_id": "status_effect_bonus_energy_per_turn",
			},
		},
	]

	Global.register_rod(card_privilege_escalation)

	# 25. 僵尸网络打击 - Finisher scaling with cards played
	var card_botnet_strike: CardData = CardData.new("card_botnet_strike")
	card_botnet_strike.card_name = "僵尸网络打击"
	card_botnet_strike.card_color_id = "color_{0}".format([color])
	card_botnet_strike.card_texture_path = "sprites/card/blue/card_botnet_strike.png"
	card_botnet_strike.card_description = "造成 [number_of_attacks] 次 [damage] 点伤害（在本时钟周期每打出过 1 个脚本，次数加 [number_of_attacks_modifier]）"
	card_botnet_strike.card_hint = "本回合你每打出过一张牌，这次攻击就多攻击一段，越晚打出越强。"
	card_botnet_strike.card_type = CardData.CARD_TYPES.ATTACK
	card_botnet_strike.card_rarity = CardData.CARD_RARITIES.RARE
	card_botnet_strike.card_requires_target = true
	card_botnet_strike.card_energy_cost = 2
	card_botnet_strike.card_values = { "damage": 5, "number_of_attacks": 1, "number_of_attacks_modifier": 1, "impact_vfx_animation_id": "animation_vfx_magic_blue" }
	card_botnet_strike.card_upgrade_value_improvements = { "damage": 2 }
	var decorator_botnet_strike: CardDecoratorData = CardDecoratorData.new("decorator_botnet_strike")
	decorator_botnet_strike.card_decorator_script_path = Scripts.DECORATOR_DYNAMIC_VALUE_MODIFIER
	Global.register_rod(decorator_botnet_strike)
	
	card_botnet_strike.card_decorators = {
		decorator_botnet_strike.object_id: {
			"stat_enum": CombatStatsData.STATS.CARDS_PLAYED,
			"turn_stat_type": 0,
			"multiplied_values": ["number_of_attacks"],
			"multiplied_values_bases": {"number_of_attacks": 1},
			"multiplied_values_per_stat": {"number_of_attacks": 1}
		}
	}

	card_botnet_strike.card_play_actions = [
		{
			Scripts.ACTION_ATTACK_GENERATOR: { "audio_path": AudioConstants.SFX_GROUP_ENERGY_BURST,  },
		},
	]

	Global.register_rod(card_botnet_strike)
	
	# 蓝卡：多路复用
	var card_multiplexing: CardData = CardData.new("card_multiplexing")
	card_multiplexing.card_name = "多路复用"
	card_multiplexing.card_color_id = "color_{0}".format([color])
	card_multiplexing.card_values = {"attack_threshold": 3, "attack_gain": 1, "skill_threshold": 3, "skill_gain": 2, "power_threshold": 2, "power_gain": 1}
	card_multiplexing.card_description = "选择 1 项协议挂载为常驻监听进程：「每打出 [attack_threshold] 张攻击脚本，获得 [attack_gain] 层[status_icon:status_effect_damage_increase]」「每打出 [skill_threshold] 张辅助脚本，获得 [skill_gain] 层[status_icon:status_effect_block_on_turn_end]」「每打出 [power_threshold] 张守护进程，获得 [power_gain] 层[status_icon:status_effect_bonus_energy_per_turn]」"
	card_multiplexing.card_hint = "三选一永久增益：攻击流获得力量、辅助流获得回合末防火墙、守护进程流获得额外算力。"
	card_multiplexing.card_texture_path = "sprites/card/blue/card_multiplexing.png"
	card_multiplexing.card_type = CardData.CARD_TYPES.POWER
	card_multiplexing.card_rarity = CardData.CARD_RARITIES.RARE
	card_multiplexing.card_requires_target = false
	card_multiplexing.card_energy_cost = 3
	card_multiplexing.card_upgrade_amount_max = 0
	card_multiplexing.card_play_actions = [
		{
			Scripts.ACTION_PICK_OPTIONS: {
				"options": [
					{
						"option_name": "攻击协议",
						"option_description": "打出 [attack_threshold] 张[color=red]攻击脚本[/color]时，获得 [attack_gain] 层[status_icon:status_effect_damage_increase]。",
						"option_sub_actions": [
							{
								Scripts.ACTION_APPLY_STATUS: {
									"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
									"status_effect_object_id": "status_effect_curiosity2",
									"status_charge_amount": 1,
									"status_force_apply_new_effect": true,
									"status_custom_values": {
										"curiosity_trigger_card_types": [CardData.CARD_TYPES.ATTACK],
										"curiosity_trigger_threshold": 3,
										"curiosity_reaction_status_id": "status_effect_damage_increase",
										"curiosity_reaction_amount": 1,
										"curiosity_current_counter": 0
									}
								}
							}
						]
					},
					{
						"option_name": "防御协议",
						"option_description": "打出 [skill_threshold] 张[color=green]辅助脚本[/color]时，获得 [skill_gain] 层[status_icon:status_effect_block_on_turn_end]。",
						"option_sub_actions": [
							{
								Scripts.ACTION_APPLY_STATUS: {
									"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
									"status_effect_object_id": "status_effect_curiosity2",
									"status_charge_amount": 1,
									"status_force_apply_new_effect": true,
									"status_custom_values": {
										"curiosity_trigger_card_types": [CardData.CARD_TYPES.SKILL],
										"curiosity_trigger_threshold": 3,
										"curiosity_reaction_status_id": "status_effect_block_on_turn_end",
										"curiosity_reaction_amount": 2,
										"curiosity_current_counter": 0
									}
								}
							}
						]
					},
					{
						"option_name": "资源协议",
						"option_description": "打出 [power_threshold] 张[color=blue]守护进程[/color]时，获得 [power_gain] 层[status_icon:status_effect_bonus_energy_per_turn]。",
						"option_sub_actions": [
							{
								Scripts.ACTION_APPLY_STATUS: {
									"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
									"status_effect_object_id": "status_effect_curiosity2",
									"status_charge_amount": 1,
									"status_force_apply_new_effect": true,
									"status_custom_values": {
										"curiosity_trigger_card_types": [CardData.CARD_TYPES.POWER],
										"curiosity_trigger_threshold": 2,
										"curiosity_reaction_status_id": "status_effect_bonus_energy_per_turn",
										"curiosity_reaction_amount": 1,
										"curiosity_current_counter": 0
									}
								}
							}
						]
					}
				]
			}
		}
	]
	Global.register_rod(card_multiplexing)
	# 自产生程序
	var card_quine: CardData = CardData.new("card_quine")
	card_quine.card_name = "自产生程序"
	card_quine.card_color_id = "color_blue"
	card_quine.card_type = CardData.CARD_TYPES.ATTACK
	card_quine.card_energy_cost = 1
	card_quine.card_rarity = CardData.CARD_RARITIES.UNCOMMON
	card_quine.card_values = {"damage": 4, "number_of_cards": 2, "damage_increase": 1}
	card_quine.card_first_upgrade_value_changes = {"damage": 6}
	card_quine.card_description = "造成 [damage] 点伤害。将 [number_of_cards] 张[card_name:card_quine]洗入待加载区。本场战斗中所有[card_name:card_quine]的伤害永久 +[damage_increase]。"
	card_quine.card_hint = "每次打出都会复制自己并全体加伤害，越到后期牌组中的自产生程序越多、越强。"
	card_quine.card_texture_path = "sprites/card/blue/card_quine.png"
	card_quine.card_play_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": HandManager.COMBAT_DECK,
				"min_card_amount": 999,
				"max_card_amount": 999,
				"random_selection": true,
				"validator_data": [
					{Scripts.VALIDATOR_CARD_ID: {"card_object_ids": ["card_quine"]}}
				],
				"action_data": [
					{
						Scripts.ACTION_IMPROVE_CARD_VALUES: {
							"card_value_improvements": {"damage": 1},
							"modify_parent_card": false
						}
					}
				]
			}
		},
		{
			Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_quine",
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_DRAW: {
							"card_destination_strategy": HandManager.PILE_INSERTION_STRATEGIES.RANDOM
						}
					}
				]
			}
		},
		{
			Scripts.ACTION_ATTACK_GENERATOR: {}
		}
	]
	Global.register_rod(card_quine)

	# 内存地址越界
	var card_memory_out_of_bounds: CardData = CardData.new("card_memory_out_of_bounds")
	card_memory_out_of_bounds.card_name = "内存地址越界"
	card_memory_out_of_bounds.card_color_id = "color_blue"
	card_memory_out_of_bounds.card_type = CardData.CARD_TYPES.ATTACK
	card_memory_out_of_bounds.card_energy_cost = 1
	card_memory_out_of_bounds.card_rarity = CardData.CARD_RARITIES.COMMON
	card_memory_out_of_bounds.card_values = {"damage": 6, "overflow_damage": 20}
	card_memory_out_of_bounds.card_first_upgrade_value_changes = {"damage": 9, "overflow_damage": 28}
	card_memory_out_of_bounds.card_description = "造成 [damage] 点伤害。若此脚本位于当前线程的最右端，改为造成 [overflow_damage] 点伤害。"
	card_memory_out_of_bounds.card_hint = "位于手牌最右侧时伤害大幅提升，注意出牌顺序。"
	card_memory_out_of_bounds.card_texture_path = "sprites/card/blue/card_buffer_overflow.png"
	card_memory_out_of_bounds.card_play_actions = [
		{
			Scripts.ACTION_VALIDATOR: {
				"validator_data": [
					{Scripts.VALIDATOR_CARD_POSITION_IN_HAND: {"position_in_hand": "right"}}
				],
				"passed_action_data": [
					{
						Scripts.ACTION_ATTACK_GENERATOR: {
							"custom_key_names": {"damage": "overflow_damage"}
						}
					}
				],
				"failed_action_data": [
					{
						Scripts.ACTION_ATTACK_GENERATOR: {}
					}
				]
			}
		}
	]
	Global.register_rod(card_memory_out_of_bounds)

	# 时间戳伪造
	var card_timestamp_spoofing: CardData = CardData.new("card_timestamp_spoofing")
	card_timestamp_spoofing.card_name = "时间戳伪造"
	card_timestamp_spoofing.card_color_id = "color_blue"
	card_timestamp_spoofing.card_type = CardData.CARD_TYPES.SKILL
	card_timestamp_spoofing.card_requires_target = false
	card_timestamp_spoofing.card_energy_cost = 2
	card_timestamp_spoofing.card_rarity = CardData.CARD_RARITIES.RARE
	card_timestamp_spoofing.card_upgrade_amount_max = 0
	card_timestamp_spoofing.card_values = {"status_charge_amount": 1, "duration": 5}
	card_timestamp_spoofing.card_description = "获得 [duration] 秒限时窗口，期间所有脚本费用变为 0。窗口结束后强制结束当前时钟周期。"
	card_timestamp_spoofing.card_hint = "打出后有 [duration] 秒真实时间让你免费出牌，时间到自动结束回合。手速越快收益越高。"
	card_timestamp_spoofing.card_texture_path = "sprites/card/blue/card_timestamp_spoofing.png"
	card_timestamp_spoofing.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_timestamp_spoofing",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT
			}
		}
	]
	Global.register_rod(card_timestamp_spoofing)

	# 系统死锁
	var card_dead_lock: CardData = CardData.new("card_dead_lock")
	card_dead_lock.card_name = "系统死锁"
	card_dead_lock.card_color_id = "color_blue"
	card_dead_lock.card_type = CardData.CARD_TYPES.SKILL
	card_dead_lock.card_energy_cost = 3
	card_dead_lock.card_rarity = CardData.CARD_RARITIES.RARE
	card_dead_lock.card_requires_target = false
	card_dead_lock.card_upgrade_amount_max = 0
	card_dead_lock.card_values = {"overshield_amount": 50, "status_charge_amount": 2}
	card_dead_lock.card_description = "获得 [overshield_amount] 层 [status_icon:status_effect_overshield]。施加 [status_charge_amount] 层 [status_icon:status_effect_deadlock]，下个时钟周期无法打出任何脚本。"
	card_dead_lock.card_hint = "一次性获得大量过载防火墙（跨回合保留），代价是下回合完全无法出牌。适合在关键回合抵挡致命攻击。"
	card_dead_lock.card_texture_path = "sprites/card/blue/card_dead_lock.png"
	card_dead_lock.card_play_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"custom_key_names": {"status_charge_amount": "overshield_amount"}
			}
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_deadlock",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT
			}
		}
	]
	Global.register_rod(card_dead_lock)

	#endregion
