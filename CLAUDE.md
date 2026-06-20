# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Slay The Robot is a **Godot 4.6** roguelike deckbuilder framework (similar to Slay the Spire), written in GDScript. It uses the `gl_compatibility` renderer. The main entry scene is `res://scenes/Root.tscn`.

There is no build step — the Godot editor runs scenes directly. **There are no unit tests**; testing is done by running the game with auto-generated data.

## Running the Game

- Open the project in Godot 4.6 and press F5, or run via the Godot MCP.
- Main scene: `res://scenes/Root.tscn`
- Window: 1200×700, non-resizable.
- Test data is auto-generated on startup by `GlobalTestDataGenerator.generate_test_data()` (called in `Global._ready()`). No JSON data files ship with the project; game data is generated from code.
- To export data to JSON: uncomment `FileLoader.export_read_only_data()` in `Global._ready()`, run once, then re-comment.
- To switch to production data: comment out `GlobalTestDataGenerator.generate_test_data()`, uncomment `GlobalProdDataGenerator.generate_production_data()`.

## GDScript Conventions

- **Heavy static typing**: All `@export` properties, function parameters, and return types use explicit type annotations. Arrays use `Array[Type]`, dictionaries use `Dictionary[KeyType, ValueType]`. Only `Variant` where genuinely needed (serialization values).
- **`class_name` is mandatory for data classes**: The schema-driven serialization system (`SerializableData._build_serializable_script_cache()`) uses `ProjectSettings.get_global_class_list()` to map class names to scripts at runtime. Any new data type **must** declare `class_name` matching its filename.
- **File naming**: PascalCase throughout. Actions are prefixed `Action`, validators `Validator`, interceptors `Interceptor`, data classes suffixed `Data`. Filename always matches `class_name`.
- **Autoloads use `*` prefix** in `project.godot` (singleton mode, loaded before any scene).

## Architecture

### Autoloads (Singletons) — exact load order from project.godot

Order matters because later autoloads depend on earlier ones. `Global._ready()` depends on `Scripts`, `Scenes`, `FileLoader`, and `Random` already being available.

| # | Autoload | Purpose |
|---|---|---|
| 1 | `Signals` | Global event bus — all cross-system signals defined here, plus dynamic `CustomSignal` management |
| 2 | `Scenes` | Central registry of all `PackedScene` preloads (cards, enemies, UI elements, etc.) |
| 3 | `Scripts` | Central registry of hardcoded `const String` script paths for actions, validators, interceptors, decorators, and run modifiers |
| 4 | `FileLoader` | External file loading (textures, audio, JSON), save/load, mod loading, caching |
| 5 | `Random` | Deterministic RNG utilities — all randomness flows through player-seeded RNG tracks |
| 6 | `Global` | Central data hub — schema generation, data lookup tables, caching, run management, validation dispatch |
| 7 | `GlobalTestDataGenerator` | Generates test data (cards, enemies, artifacts, etc.) from code |
| 8 | `GlobalProdDataGenerator` | Generates production data from code |
| 9 | `ActionHandler` | Action stack + queue processor; manages action execution order, timing, and interception |
| 10 | `ActionGenerator` | Factory for creating action instances from data |
| 11 | `DebugLogger` | Centralized logging |
| 12 | `HandManager` | Manages the player's hand of cards |
| 13 | `SoundManager` | Audio playback (addon-based, registered as `uid://`) |
| 14 | `StatsHandler` | Tracks per-turn, per-combat, and per-run statistics; manages profile save/load |

### Data Layer (`data/`)

All data classes inherit from **`SerializableData`** (extends Godot `Resource`). Only `@export`-annotated properties are serialized/loaded. The system supports recursive nested serialization.

- **`data/prototype/`** — Read-only template data (CardData, ArtifactData, EnemyData, PlayerData). Use `.get_prototype(true)` to create mutable copies.
- **`data/readonly/`** — Immutable lookup data (ActData, EventData, DialogueData, KeywordData, ColorData, StatusEffectData, RunModifierData, CustomSignalData, CharacterData, modding configs, etc.).
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

**Value hierarchy**: When an action looks up a parameter via `get_action_value(key, default)`, it searches in order: action's own `values` → `CardPlayRequest.card_values` → `CardData.card_values` → `PlayerData.player_values` → `default`. This enables cards, the player, and individual actions to override values at different scopes.

**Card play flow**: Hand click → `HandManager` creates `CardPlayRequest` (with card data, targets, energy cost) → queued in `card_play_queue` → `_perform_card_plays()` pops each request → `ActionGenerator.generate_card_play()` builds action tree → actions execute via `ActionHandler` → `card_play_finished` signal → next card or end turn.

### Action Interceptors (`scripts/action_interceptors/`)

Interceptors dynamically modify actions before they execute. They're the mechanism behind status effects (Vulnerable, Weak), relics/artifacts, and other persistent modifiers. Registered per-combatant via `ActionHandler.register_action_interceptor()`. Interceptors are data-driven (`ActionInterceptorData`) and can be loaded from JSON.

Each interceptor returns an `ActionInterceptorProcessor` chain that modifies action values for each target. Interceptor previews power both enemy intent display and card description text — the UI uses the same interceptor pipeline as game logic, ensuring consistency.

### Validators (`scripts/validators/`)

Validators drive conditional logic: "can this card be played?", "does this effect trigger?" Called via `Global.validate(validators, card_data, action)`. Organized by domain: card properties, card plays, deck state, hand state, combat stats, enemy state, player state.

### Content Packs

CardPackData, ArtifactPackData, and ConsumablePackData define filtered subsets of content. Packs auto-generate filter caches on startup (`Global._generate_card_pack_cache()` etc.). Adding a card to a pack automatically includes it in relevant drafts, shops, and rewards.

### Filter/Cache System (`data/filters/`)

CardFilter, ArtifactFilter, and ConsumableFilter use a **method chaining** pattern. Build a query with filter methods (e.g., `.filter_type()`, `.filter_rarity()`, `.filter_colors()`), then call a terminal method (`.convert_to_card_prototypes()`, `.convert_to_unique_card_object_ids()`). Filters can be cached via `.cache_filter(id)` which stores them in `Global._id_to_card_filter_cache` — content packs use this for startup caching. Cached filters are locked against further mutation.

### Deterministic RNG

`Random.gd` provides all randomization utilities. RNG tracks are seeded per-run from `player_data.player_run_seed`. Different game systems pull from different named RNG tracks (e.g., `"rng_reward_card_drafts"`, `"rng_shop"`) stored in `PlayerData.player_rng_tracks` as a `Dictionary[String, RandomNumberGenerator]`. Tracks are lazily created on first access. This prevents cross-contamination — shuffling cards won't affect event outcomes.

### Save/Load System

Managed by `FileLoader`. **Single save slot** at `external/saves/save.json`. Key methods:
- `save_game()` / `load_game()` — serialize/deserialize `Global.player_data` via JSON
- `autosave()` / `autoload()` — convenience wrappers gated by `AUTOSAVING_ENABLED`
- `has_save_file()` / `delete_save()` — save slot management
- `save_user_settings()` / `load_user_settings()` — persistent settings at `external/user_settings.json`
- `save_profile()` / `load_profile()` — cross-run progression at `external/profile.json`

In exported builds, paths switch from `res://` to the executable's directory. There is no multi-slot save UI yet (code has a `TODO: Profile implementation` comment).

### PlayerData (`data/prototype/PlayerData.gd`)

The central mutable data object for the current run. Key subsystems:

- **RNG tracks** (`player_rng_tracks`): Named RNG instances seeded from `player_run_seed`
- **Card reward pool** (`player_reward_card_filter_cache`, `reward_draft_card_pack_ids`, `player_rare_card_modifier_current`): Pity system for rare cards; filter cache built from active card packs
- **Artifact pool** (`player_artifact_pool`, `player_artifact_pack_ids`): Shuffled pool of all artifact IDs; rewards pop from front, shops from back; rarity-bucketed
- **Consumable pool**: Same pattern as artifacts
- **Event pools**: `get_next_event_object_id_from_pool()` pulls events from EventPoolData with failure strategies (KEEP, APPEND, REMOVE, REINSERT, BLACKLIST)
- **Location data**: `location_id_to_location_data` holds the entire generated act map
- **Run config**: `player_run_seed`, `player_run_difficulty_level`, `player_run_modifier_object_ids`

### Combat Flow

Combat is a **signal-driven state machine** in `scripts/ui/Combat.gd` (no CombatManager class):

1. `combat_started` → enemies populate, turn start animation plays
2. `start_turn()` → resets energy, processes pre-draw status effects, resets block, draws cards, unlocks hand
3. Player plays cards via `CardPlayRequest` queue → actions execute via `ActionHandler`
4. `end_turn` → `CombatEndTurn` object manages immediacy levels (WAIT_FOR_ALL_CARD_PLAYS, WAIT_FOR_ACTIONS, IMMEDIATE)
5. Player turn ends → discard/exhaust/retain logic, post-turn status effects
6. Enemy turn → each alive enemy: pre-intent statuses → execute intent → post-intent statuses
7. Loop back to step 2
8. Combat ends when all non-minion enemies die or player dies

### Run Modifiers

`RunModifierData` powers both difficulty (ascension-like) and custom modifiers. Three types:
- **Standard difficulty** (`run_modifier_is_custom = false`): Selected via difficulty level on NewRunMenu. Difficulty 1-5 exist as stubs.
- **Custom** (`run_modifier_is_custom = true`): Player-chosen toggles (easy mode, endless mode, draft all colors). Can have exclusivity via `run_modifier_exclusive_to_modifier_ids`.
- **Automatic** (`run_modifier_is_automatic = true`): Always active (e.g., consumable auto-revive). No player choice.

Modifiers work by registering action interceptors (`run_modifier_interceptor_ids`) or running modifier scripts (`run_modifier_modifier_script_path`) that call `run_start_modification()` once at run start.

### Custom Signals & Stat Hooks

`CustomSignalData` (in `data/readonly/modding/`) defines data-driven signals for mods. `Signals` autoload manages `CustomSignal` instances (each extends `RefCounted` and carries a `custom_signal` signal). `StatsHandler` connects to custom signals where `custom_signal_is_stat = true`, enabling data-driven stat tracking without code changes.

### Act Generation

`ActionGenerateAct.perform_action()` builds a grid-based map:
- Fixed floor layout: floor 0 = start, floors 1-3 = easy combat, floor 4 = shop, floor 5 = treasure, floor 6 = rest, floor 7 = miniboss, floors 8-10 = hard combat, final floor = boss
- Configurable `floors_per_act` (default 10), `locations_per_floor` (default 5)
- 50% obfuscation rate (locations shown as "?"), 30% chance combat → non-combat event
- Branching connections: each node connects to the node directly above, above-left, and above-right (Slay-the-Spire-style)
- Seeded by `rng_world_generation` track
- Custom generation scripts can be plugged in via `ActData.act_action_script_path`

### Event System

Events use `EventPoolData` with weighted pools. `PlayerData.get_next_event_object_id_from_pool()` copies the pool, shuffles, and validates each event against its conditions. Failed events are handled by a configurable strategy (KEEP, APPEND, REMOVE, REINSERT, BLACKLIST). Events can be combat or non-combat, with dialogue driven by a state machine.

### Mod Support (`external/`)

Mods are loaded from `external/` directory. Each mod has a `mod_info.json` specifying folders and data types. Scripts can be loaded from mods to inject or override behavior. `mod_list.json` controls which mods are active. The example mod is at `external/mods/example_mod/`.

### Editor Plugins (`addons/`)

- **`sound_manager/`** — Nathan Hoad's audio manager addon. Registered as an editor plugin + autoload. Provides audio player pooling, music/SFX/ambient channels.
- **`label_font_auto_sizer/`** — Custom `AutoSizeLabel` and `AutoSizeRichTextlabel` nodes. Registered editor plugin.
- **`smooth_scroll_container/`** — `SmoothScrollContainer` with velocity-based momentum and overdrag. Reusable script (not registered as an editor plugin).

### Shaders

One shader: `scripts/ui/outline.gdshader` — a `canvas_item` shader that draws a configurable outline (width, color, brightness) around sprites. Used on `MapLocation` nodes with an animation track for a pulsing highlight effect.

### UI Architecture

All UI scene preloads are in the `Scenes` autoload. UI scripts are in `scripts/ui/`. Root scene (`Root.tscn`) has three top-level children: **TitleScreen** (menus), **RunScreen** (in-game HUD), and **Tooltips** (global tooltip layer, z-index 1000). Key subsystems:
- **Card display**: `Card.tscn` + `CardDecorator.tscn` (for enchantment-like card modifications)
- **Codex**: browseable content encyclopedia showing all cards, artifacts, consumables, enemies
- **Map**: `MapLocation.tscn` for act navigation with `Line2D` connections
- **Rewards**: card draft, artifact, and money reward screens
- **Shop**: card, artifact, and consumable purchasing
- **Tooltips**: `KeywordTooltip.tscn` (individual keyword with optional status effect icon) and `Tooltip.tscn` (rich text with positioning); keywords support recursive child keywords via BFS
- **Combat**: Hand area, enemy container, energy display, piles, end turn button, target selection

### Combatants (`scenes/combatants/`, `scripts/combatants/`)

`Player.tscn` and `Enemy.tscn` are the combatant scenes. Health is displayed via `LayeredHealthBar` + `HealthLayer`. `StatusEffect.tscn` renders status icons. Combat fades (text, artifact, image) provide visual feedback for actions.

## Key Patterns

- **Read-only → prototype pattern**: Data templates are read-only in Global's lookup tables. To get a mutable instance, call `Global.get_card_data_from_prototype(id)` (which calls `.get_prototype(true)` internally).
- **Signal-driven communication**: Cross-system events go through `Signals` autoload. Avoid direct coupling between systems.
- **Action composition**: Actions contain child actions, enabling nested behavior (for-loops, conditionals, random branches via meta_actions).
- **Validation is shared**: The same `Global.validate()` pipeline powers both game logic (can this card be played?) and UI (should this card glow? should this text be highlighted?).
- **Cache on startup**: Card/artifact/consumable filter caches are generated once at startup. Don't query raw data repeatedly.
- **`class_name` requirement**: The serialization system resolves class names via Godot's global class list at runtime. New data classes must use `class_name` matching their filename.
- **Interceptor previews**: Enemy intent and card descriptions use the same interceptor pipeline as game logic — no separate calculation systems.

## Godot MCP Tools

Godot MCP tools are available for this project. The project path is `F:/Godot/games/Slay-The-Robot`. Use `mcp__godot-mcp__run_project` to launch and `mcp__godot-mcp__stop_project` to stop.
