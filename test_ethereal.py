"""
测试 card_is_ethereal 删除后的"虚无"功能正确性
验证项：
1. card_is_ethereal 属性已完全从 .gd 文件中移除
2. is_card_ethereal() 仅依赖 card_end_of_turn_destination
3. 所有原有"虚无"卡牌的 card_end_of_turn_destination 正确设置
4. KeywordContainer 关键词判断、CodexCardDetailPanel 详情页标记对齐
"""

import os
import re
import sys

ROOT = r"f:\Godot\games\Slay-The-Robot"
failed = 0
passed = 0

def fail(msg: str):
    global failed
    print(f"  FAIL: {msg}")
    failed += 1

def ok(msg: str):
    global passed
    print(f"  OK:   {msg}")
    passed += 1

def read_gd(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return f.read()

def find_gd(root: str) -> list:
    """递归收集 .gd 文件路径"""
    result = []
    for dirpath, _dirnames, filenames in os.walk(root):
        for fn in filenames:
            if fn.endswith(".gd"):
                result.append(os.path.join(dirpath, fn))
    return result

# ============================================================
# Test 1: card_is_ethereal 在所有 .gd 文件中无残留
# ============================================================
print("=" * 60)
print("Test 1: card_is_ethereal 零残留")
all_gd = find_gd(ROOT)
residual = []
for path in all_gd:
    content = read_gd(path)
    if "card_is_ethereal" in content:
        lines = content.split("\n")
        for i, line in enumerate(lines, 1):
            if "card_is_ethereal" in line:
                # 排除纯注释行
                stripped = line.strip()
                if stripped.startswith("#"):
                    residual.append(f"{path}:{i} (注释) {stripped}")
                else:
                    residual.append(f"{path}:{i} {stripped}")
if residual:
    for r in residual:
        fail(r)
else:
    ok("无任何 card_is_ethereal 残留（含注释）")

# ============================================================
# Test 2: is_card_ethereal() 仅依赖 card_end_of_turn_destination
# ============================================================
print("=" * 60)
print("Test 2: is_card_ethereal() 逻辑简化")

carddata_path = os.path.join(ROOT, "data", "prototype", "CardData.gd")
carddata_content = read_gd(carddata_path)

# 提取 is_card_ethereal 方法体
m = re.search(r"func is_card_ethereal\(\)\s*->\s*bool\s*:\s*\n(\s+return\s+.+)", carddata_content)
if not m:
    fail("is_card_ethereal() 未找到")
else:
    body = m.group(1).strip()
    if "card_end_of_turn_destination" in body and "card_is_ethereal" not in body:
        ok(f"is_card_ethereal() 仅依赖 destination: {body}")
    else:
        fail(f"is_card_ethereal() 仍有冗余引用: {body}")

# ============================================================
# Test 3: 所有原"虚无"卡牌的 destination 正确
# ============================================================
print("=" * 60)
print("Test 3: 虚无卡牌 destination 验证")

# 被修改的卡牌及其期望状态
ethereal_cards = {
    "card_darknet_protocol": {
        "file": os.path.join(ROOT, "autoload", "card_generators", "blue_cards.gd"),
        "expect_destination": "EXHAUST_PILE",
    },
    "card_hotfix": {
        "file": os.path.join(ROOT, "autoload", "card_generators", "red_cards.gd"),
        "expect_destination": "EXHAUST_PILE",
    },
    "card_attack_block_end_of_turn": {
        "file": os.path.join(ROOT, "autoload", "GlobalTestDataGenerator.gd"),
        "expect_destination": "EXHAUST_PILE",
    },
    "card_ethereal_status": {
        "file": os.path.join(ROOT, "autoload", "GlobalTestDataGenerator.gd"),
        "expect_destination": "EXHAUST_PILE",
    },
    "card_chloroplast": {
        "file": os.path.join(ROOT, "autoload", "card_generators", "green_cards.gd"),
        "expect_destination": "EXHAUST_PILE",
    },
}

# 动态获取 HandManager EXHAUST_PILE 的实际值
handmanager_path = os.path.join(ROOT, "autoload", "HandManager.gd")
hm_content = read_gd(handmanager_path)
hm_exhaust = re.search(r'const EXHAUST_PILE:\s*String\s*=\s*"([^"]*)"', hm_content)
HM_EXHAUST_VALUE = hm_exhaust.group(1) if hm_exhaust else "EXHAUST"

for card_id, info in ethereal_cards.items():
    content = read_gd(info["file"])
    # 找到该卡牌的 card_end_of_turn_destination 赋值
    # 策略：从 var card_xxx = CardData.new(...) 开始，到下一个 var 或注册为止
    pattern = rf"var {re.escape(card_id)}:\s*CardData.*?Global\.register_rod"
    block = re.search(pattern, content, re.DOTALL)
    if not block:
        fail(f"{card_id}: 卡牌定义块未找到")
        continue
    
    # 找 card_end_of_turn_destination
    dest_match = re.search(
        r"card_end_of_turn_destination\s*=\s*HandManager\.(\w+)",
        block.group(0)
    )
    if not dest_match:
        fail(f"{card_id}: 未设置 card_end_of_turn_destination")
        continue
    
    actual_dest = dest_match.group(1)
    if actual_dest == info["expect_destination"]:
        ok(f"{card_id} → card_end_of_turn_destination = {actual_dest}")
    else:
        fail(f"{card_id}: 期望 {info['expect_destination']}，实际 {actual_dest}")

# ============================================================
# Test 4: 暗网协议升级后失去虚无 = destination 改为 DISCARD_PILE
# ============================================================
print("=" * 60)
print("Test 4: 暗网协议升级 property_changes")

blue_path = os.path.join(ROOT, "autoload", "card_generators", "blue_cards.gd")
blue_content = read_gd(blue_path)
protocol_block = re.search(
    r"var card_darknet_protocol:.*?card_first_upgrade_property_changes\s*=\s*\{(.*?)\}",
    blue_content, re.DOTALL
)
if not protocol_block:
    fail("暗网协议升级块未找到")
else:
    changes = protocol_block.group(1)
    if "card_is_ethereal" in changes:
        fail("升级中仍有 card_is_ethereal 引用")
    elif "card_end_of_turn_destination" in changes and "DISCARD_PILE" in changes:
        ok("升级改为 card_end_of_turn_destination: DISCARD_PILE")
    else:
        fail("升级未正确设置 card_end_of_turn_destination")

# ============================================================
# Test 5: KeywordContainer 关键词判断对齐
# ============================================================
print("=" * 60)
print("Test 5: KeywordContainer 虚无关键词判断")

kw_path = os.path.join(ROOT, "scripts", "ui", "general", "KeywordContainer.gd")
kw_content = read_gd(kw_path)

# 虚无关键词条件应为 card_end_of_turn_destination == EXHAUST_PILE
if "card_end_of_turn_destination == HandManager.EXHAUST_PILE" in kw_content:
    if "keyword_ethereal" in kw_content:
        ok("KeywordContainer 虚无判断使用 card_end_of_turn_destination")
    else:
        fail("KeywordContainer 中无 keyword_ethereal 追加逻辑")
else:
    fail("KeywordContainer 虚无判断未使用 card_end_of_turn_destination")

# ============================================================
# Test 6: CodexCardDetailPanel 详情页标记对齐
# ============================================================
print("=" * 60)
print("Test 6: CodexCardDetailPanel 虚无标记")

codex_path = os.path.join(ROOT, "scripts", "ui", "codex", "CodexCardDetailPanel.gd")
codex_content = read_gd(codex_path)

# 虚无标记不应再引用 card_is_ethereal
if "card_is_ethereal" in codex_content:
    fail("详情页仍有 card_is_ethereal 引用")
else:
    ok("详情页无 card_is_ethereal 引用")

# 应使用 card_end_of_turn_destination
if "card_end_of_turn_destination == HandManager.EXHAUST_PILE" in codex_content:
    ok("详情页虚无标记使用 destination 判断")
else:
    fail("详情页虚无标记未使用 destination 判断")

# 保留标记应使用 does_card_retain()
if "does_card_retain()" in codex_content:
    ok("详情页保留标记使用 does_card_retain()")
else:
    fail("详情页保留标记未使用 does_card_retain()")

# ============================================================
# Test 7: does_card_retain() 与 is_card_ethereal() 对齐对比
# ============================================================
print("=" * 60)
print("Test 7: ethereal/retain 方法接口一致性")

# is_card_ethereal: return card_end_of_turn_destination == HandManager.EXHAUST_PILE
# does_card_retain: return card_is_retained or card_end_of_turn_destination == HandManager.HAND_PILE
ethereal_method = re.search(
    r"func is_card_ethereal.*?\n(\s+return.+)",
    carddata_content
)
retain_method = re.search(
    r"func does_card_retain.*?\n(\s+return.+)",
    carddata_content
)

if ethereal_method:
    body = ethereal_method.group(1).strip()
    if "card_end_of_turn_destination" in body:
        ok(f"is_card_ethereal: {body}")
    else:
        fail(f"is_card_ethereal 方法异常: {body}")

if retain_method:
    body = retain_method.group(1).strip()
    if "card_is_retained" in body or "card_end_of_turn_destination" in body:
        ok(f"does_card_retain: {body}")
    else:
        fail(f"does_card_retain 方法异常: {body}")

# ============================================================
# Test 8: 代码残留检查 — 注释中也不应有误导性 card_is_ethereal
# ============================================================
print("=" * 60)
print("Test 8: card_is_ethereal 相关注释残留检查")

# CardData.gd 注释中不应再有 card_is_ethereal
lines_with_ethereal_comment = [
    f"{carddata_path}:{i}" for i, line in enumerate(carddata_content.split("\n"), 1)
    if "card_is_ethereal" in line
]
if lines_with_ethereal_comment:
    for loc in lines_with_ethereal_comment:
        fail(f"{loc} (注释残留)")
else:
    ok("CardData.gd 中无 card_is_ethereal 相关注释")

# ============================================================
# Summary
# ============================================================
print("=" * 60)
print(f"\n结果: {passed} passed, {failed} failed, {passed + failed} total")
if failed > 0:
    print("\n部分测试未通过，请检查上述 FAIL 项。")
    sys.exit(1)
else:
    print("\n所有测试通过，虚无功能修改正确。")
