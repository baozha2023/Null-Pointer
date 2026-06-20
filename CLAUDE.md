# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Slay The Robot is a **Godot 4.6** roguelike deckbuilder framework (similar to Slay the Spire), written in GDScript. It uses the `gl_compatibility` renderer. The main entry scene is `res://scenes/Root.tscn`.

There is no build step — the Godot editor runs scenes directly. The project uses editor plugins loaded from `res://addons/` (sound_manager).

## Running the Game

- Open the project in Godot 4.6 and press F5, or run via the Godot MCP.
- Main scene: `res://scenes/Root.tscn`
- Window: 1200×700, non-resizable.
- Test data is auto-generated on startup by `GlobalTestDataGenerator.generate_test_data()` (called in `Global._ready()`). No JSON data files ship with the project; game data is generated from code.
- To export data to JSON: uncomment `FileLoader.export_read_only_data()` in `Global._ready()`, run once, then re-comment.
- To switch to production data: comment out `GlobalTestDataGenerator.generate_test_data()`, uncomment `GlobalProdDataGenerator.generate_production_data()`.

## Architecture

### Autoloads (Singletons) — loaded order matters

| Autoload | Purpose |
|---|---|
| `Signals` | Global event bus — all cross-system signals defined here, plus dynamic custom signals |
| `Scenes` | Central registry of all `PackedScene` preloads (cards, enemies, UI elements, etc.) |
| `Scripts` | Central registry of hardcoded script paths for actions, validators, interceptors, decorators, and run modifiers |
| `FileLoader` | External file loading (textures, audio, JSON), save/load, mod loading, caching |
| `Random` | Deterministic RNG utilities — all randomness flows through player-seeded RNG tracks |
| `Global` | Central data hub — schema generation, data lookup tables, caching, run management, validation dispatch |
| `GlobalTestDataGenerator` | Generates test data (cards, enemies, artifacts, etc.) from code |
| `GlobalProdDataGenerator` | Generates production data from code |
| `ActionHandler` | Action stack + queue processor; manages action execution order, timing, and interception |
| `ActionGenerator` | Factory for creating action instances from data |
| `DebugLogger` | Centralized logging |
| `HandManager` | Manages the player's hand of cards |
| `SoundManager` | Audio playback (addon-based) |
| `StatsHandler` | Tracks per-turn, per-combat, and per-run statistics |

### Data Layer (`data/`)

All data classes inherit from **`SerializableData`** (extends Godot `Resource`). Only `@export`-annotated properties are serialized/loaded. The system supports recursive nested serialization.

- **`data/prototype/`** — Read-only template data (CardData, ArtifactData, EnemyData, PlayerData). Use `.get_prototype(true)` to create mutable copies.
- **`data/readonly/`** — Immutable lookup data (ActData, EventData, DialogueData, KeywordData, ColorData, StatusEffectData, modding configs, etc.).
- **`data/mutable/`** — Runtime-mutable data (PlayerData, CombatStatsData, RunStatsData, ShopData, LocationData, ProfileData, UserSettingsData).
- **`data/filters/`** — CardFilter, ArtifactFilter, ConsumableFilter — used by content packs to query and cache filtered subsets.
- **`data/SerializableData.gd`** — The base class. Contains the recursive property script cache system that enables automatic JSON (de)serialization for all data types.

**Schema system** (`Global.SCHEMA`): A central `Array[Array]` that maps every data type's class name, Script, lookup table property name, and external folder paths. `Global._generate_schema()` builds fast lookup tables from this schema. **Any new data type must be added to SCHEMA**.

### Action System (`scripts/actions/`)

All game behavior flows through actions. `BaseAction` → `BaseAsyncAction` is the inheritance chain.

- **ActionHandler** maintains a stack of action queues. `add_action()`/`add_actions()` push actions; they auto-execute via `_perform_actions()`.
- Actions can be **synchronous** or **asynchronous** (awaiting user input, animations, timers).
- Actions carry a `time_delay` for pacing, and an interception pipeline (see below).
- **ActionGenerator** is the factory — it constructs action trees from JSON/dict action data payloads.
- Key action categories:
  - `card_actions/` — playing, picking, transforming, discarding, upgrading cards
  - `combatant_actions/` — attacking, blocking, healing, applying statuses (for player + enemies)
  - `meta_actions/` — random selection, validators, action generation/modification
  - `world_generation_actions/` — generating act maps
  - `world_interaction_actions/` — visiting locations, starting combat, opening chests
  - `shop_actions/`, `rewards/`, `artifact_actions/`, `audio_actions/`, `custom_actions/`

### Action Interceptors (`scripts/action_interceptors/`)

Interceptors dynamically modify actions before they execute. They're the mechanism behind status effects (Vulnerable, Weak), relics/artifacts, and other persistent modifiers. Registered per-combatant via `ActionHandler.register_action_interceptor()`. Interceptors are data-driven (`ActionInterceptorData`) and can be loaded from JSON.

### Validators (`scripts/validators/`)

Validators drive conditional logic: "can this card be played?", "does this effect trigger?" Called via `Global.validate(validators, card_data, action)`. Organized by domain: card properties, card plays, deck state, hand state, combat stats, enemy state, player state.

### Content Packs

CardPackData, ArtifactPackData, and ConsumablePackData define filtered subsets of content. Packs auto-generate filter caches on startup (`Global._generate_card_pack_cache()` etc.). Adding a card to a pack automatically includes it in relevant drafts, shops, and rewards.

### Deterministic RNG

`Random.gd` provides all randomization utilities. RNG tracks are seeded per-run from `player_data.player_run_seed`. Different game systems pull from different named RNG tracks (e.g., `"rng_reward_card_drafts"`, `"rng_shop"`) to prevent cross-contamination — shuffling cards won't affect event outcomes.

### Mod Support (`external/`)

Mods are loaded from `external/` directory. Each mod has a `mod_info.json` specifying folders and data types. Scripts can be loaded from mods to inject or override behavior. `mod_list.json` controls which mods are active. The example mod is at `external/mods/example_mod/`.

### UI Architecture

All UI scene preloads are in the `Scenes` autoload. UI scripts are in `scripts/ui/`. Key subsystems:
- **Card display**: `Card.tscn` + `CardDecorator.tscn` (for enchantment-like card modifications)
- **Codex**: browseable content encyclopedia showing all cards, artifacts, consumables, enemies
- **Map**: `MapLocation.tscn` for act navigation
- **Rewards**: card draft, artifact, and money reward screens
- **Shop**: card, artifact, and consumable purchasing
- **Tooltips**: `KeywordTooltip.tscn` and `Tooltip.tscn` components

### Combatants (`scenes/combatants/`, `scripts/combatants/`)

`Player.tscn` and `Enemy.tscn` are the combatant scenes. Health is displayed via `LayeredHealthBar` + `HealthLayer`. `StatusEffect.tscn` renders status icons. Combat fades (text, artifact, image) provide visual feedback for actions.

## Key Patterns

- **Read-only → prototype pattern**: Data templates are read-only in Global's lookup tables. To get a mutable instance, call `Global.get_card_data_from_prototype(id)` (which calls `.get_prototype(true)` internally).
- **Signal-driven communication**: Cross-system events go through `Signals` autoload. Avoid direct coupling between systems.
- **Action composition**: Actions contain child actions, enabling nested behavior (for-loops, conditionals, random branches via meta_actions).
- **Validation is shared**: The same `Global.validate()` pipeline powers both game logic (can this card be played?) and UI (should this card glow? should this text be highlighted?).
- **Cache on startup**: Card/artifact/consumable filter caches are generated once at startup. Don't query raw data repeatedly.

## Godot MCP Tools

Godot MCP tools are available for this project. The project path is `F:/Godot/games/Slay-The-Robot`. Use `mcp__godot-mcp__run_project` to launch and `mcp__godot-mcp__stop_project` to stop.
