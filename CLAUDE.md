# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Slay The Robot is a **roguelike deckbuilder framework** for **Godot 4.6** (GDScript, `gl_compatibility` renderer), similar to Slay the Spire. It is designed as a reusable framework so others can build their own deckbuilders on top of it. The main entry scene is `res://scenes/Root.tscn`.

- [GitHub Wiki](https://github.com/DesirePathGames/Slay-The-Robot/wiki) (WIP)
- [Terminology translation spreadsheet](https://docs.google.com/spreadsheets/d/1J3o8d5gMbzAwjXUZgvvEui8mhHdSobRWEZeRn1sFmvs/edit) — maps framework concepts to Slay the Spire equivalents
- License: MIT

## Running the Game

- Open the project in Godot 4.6 and press F5, or launch via Godot MCP.
- Main scene: `res://scenes/Root.tscn`
- Window size: 1200×700, non-resizable.
- **No build step** — run scenes directly in the Godot editor.
- **No unit tests** — testing is done by running the game with auto-generated data.
- Test data is generated at startup by `GlobalTestDataGenerator.generate_test_data()` (called in `Global._ready()`). The project ships with zero JSON data files; all game data is generated from code.
- To export data as JSON: uncomment `FileLoader.export_read_only_data()` in `Global._ready()`, run once, then re-comment it.
- To switch to production data: comment `GlobalTestDataGenerator.generate_test_data()` and uncomment `GlobalProdDataGenerator.generate_production_data()`.
- GDScript warnings disabled in project settings: `unused_signal` (signals are often connected dynamically), `integer_division` (intentional use).

## GDScript Conventions

- **Heavy static typing**: All `@export` fields, function parameters, and return types use explicit type annotations. Arrays use `Array[Type]`, dictionaries use `Dictionary[KeyType, ValueType]`. `Variant` is allowed only where truly needed (e.g., serialized values).
- **Data classes MUST use `class_name`**: The schema-driven serialization system (`SerializableData._build_serializable_script_cache()`) maps class names to scripts at runtime via `ProjectSettings.get_global_class_list()`. Any new data type **must** declare a `class_name` matching its filename.
- **File naming**: PascalCase throughout. Actions have an `Action` prefix, Validators have a `Validator` prefix, Interceptors have an `Interceptor` prefix, data classes have a `Data` suffix. Filename always matches `class_name`.
- **Autoloads use `*` prefix** in `project.godot` (load before any scene).
- **Comments may be in Chinese**: Key files (especially `Global.gd`, `EnemyIntentData.gd`) use Chinese for inline documentation comments. This is an intentional convention by the original author — do not convert to English unless replacing the entire comment with equivalent detail.

## Architecture

### High-Level Directory Structure

| Directory | Purpose |
|---|---|
| `autoload/` | 14 singleton scripts (see loading order below) — global state, factories, managers |
| `autoload/act/` | Per-act content generators (`act_one.gd`, `act_two.gd`, `act_three.gd`) + `global_enemies.gd` (shared enemies) |
| `autoload/card_generators/` | Per-color card set generators (`blue_cards.gd`, `green_cards.gd`, `red_cards.gd`, `orange_cards.gd`, `white_cards.gd`) |
| `autoload/event_generators/` | Global event and dialogue generators (`global_dialogues.gd`) |
| `data/` | Data layer — `SerializableData` base class, prototype templates, readonly config, mutable runtime state, filters |
| `data/prototype/` | Read-only template data (`CardData`, `EnemyData`, etc.) — cloned via `.get_prototype(true)` for mutable runtime copies |
| `data/readonly/` | Immutable dictionary configs (keywords, colors, acts, events, run modifiers, card packs, etc.) |
| `data/mutable/` | Runtime-mutable containers (`CombatStats`, `ShopData`, `RunStatsData`, `ProfileData`, etc.) |
| `data/filters/` | `CardFilter`, `ArtifactFilter`, `ConsumableFilter` — method-chaining query builders with cache support |
| `scripts/actions/` | All game behaviors — card operations, combat, status effects, shop, world gen, rewards, etc. |
| `scripts/action_interceptors/` | Dynamically modify actions before execution (status effects, relics, modifiers) |
| `scripts/validators/` | Conditional logic — "can this card be played?", "should this effect trigger?" |
| `scripts/artifacts/` | Relic passive skill implementations |
| `scripts/status_effects/` | Combat status effect logic (stacking, decay, interceptor hooks) |
| `scripts/card_decorators/` | Enchantment-like card visual/behavior modifiers |
| `scripts/combatants/` | Player, Enemy, health bars, status effect rendering, combat floats |
| `scripts/ui/` | All UI logic — menus, combat HUD, map, shop, codex, rewards, tooltips, hand management |
| `scripts/run_modifiers/` | Difficulty (ascension) levels and custom run mutators |
| `scenes/` | `.tscn` scene files mirroring the scripts/ structure |
| `external/` | **External assets** — sprites, audio, mods, data files. Uses `.gdignore` to prevent Godot import scanning. Paths switch from `res://` to the executable's sibling directory in exported builds |
| `ui/components/` | Reusable UI components — `Tooltip`, `VolumeSlider`, `ResizingGridScrollContainer`, `AutoResizingGridContainer` |
| `addons/` | Editor plugins — `sound_manager` (Nathan Hoad's audio plugin), `label_font_auto_sizer` |
| `animations/` | Godot `AnimationLibrary` resources for combatants (`.res` files) |
| `sprites/` | Editor-imported sprite assets (buttons, frames, icons) — distinct from `external/sprites/` for runtime-loaded content |
| `sounds/` | Editor-imported audio bus layout and fallback audio |
| `themes/` | Godot `.tres` theme resources (keyword tooltip, panel, title screen) |
| `shortcuts/` | Input shortcut `.tres` resources |
| `misc/` | Curves and other miscellaneous Godot resources |

### SerializableData Inheritance Chain

```
Resource
└── SerializableData          # Base: JSON (de)serialization, @export reflection, recursive nesting
    ├── (readonly data)       # Uses object_id as identifier, stored in Global lookup dicts
    └── PrototypeData         # Template pattern — adds object_uid for unique instances
        ├── CardData          # Cloned via get_prototype(true) for each card instance
        ├── EnemyData
        ├── ArtifactData
        └── PlayerData        # The central mutable run-state object
```

Only properties with `@export` are serialized. The system introspects Godot's global class list at runtime to build the recursive property cache — this is why `class_name` matching the filename is mandatory. `PrototypeData.get_prototype(true)` deep-clones the object and all nested `PrototypeData` children, assigning new unique `object_uid` values and repairing internal UID references.

### Autoload Singletons — Loading Order

Order is critical because later autoloads depend on earlier ones. `Global._ready()` requires `Scripts`, `Scenes`, `FileLoader`, and `Random` to already be ready.

| # | Singleton | Purpose |
|---|---|---|
| 1 | `Signals` | Global event bus — all cross-system signals + dynamic `CustomSignal` management |
| 2 | `Scenes` | Registry of all `PackedScene` preloads (cards, enemies, UI elements, etc.) |
| 3 | `Scripts` | Registry of hardcoded `const String` script paths for Actions, Validators, Interceptors, Decorators, and Run Modifiers |
| 4 | `FileLoader` | External file loading (sprites, audio, JSON), save/load, mod loading & caching |
| 5 | `Random` | Deterministic RNG — all randomness flows through player-seed-based RNG tracks |
| 6 | `Global` | Central data hub — schema generation, data lookup tables, caching, run management, validator dispatch |
| 7 | `GlobalTestDataGenerator` | Generates test data via code (cards, enemies, artifacts, etc.) |
| 8 | `GlobalProdDataGenerator` | Generates production data via code |
| 9 | `ActionHandler` | Action stack & queue processor — manages execution order, timing, and interception |
| 10 | `ActionGenerator` | Factory that creates Action instances from data |
| 11 | `DebugLogger` | Centralized logging |
| 12 | `HandManager` | Manages the player's hand cards |
| 13 | `SoundManager` | Audio playback (plugin-based, registered as `uid://`) |
| 14 | `StatsHandler` | Tracks per-turn, per-combat, per-run statistics; manages profile save/load |
| 15 | `UIMessage` | Global UI message overlay for floating notifications |

### Data Layer (`data/`)

**Schema System** (`Global.SCHEMA`): A central `Array[Array]` mapping each data type's class name, script, lookup table property name, and external folder path. `Global._generate_schema()` builds fast lookup tables from this schema. **Any new data type must be added to SCHEMA.**

- **`data/CardPlayRequest.gd`** — Extends `RefCounted` (not `Resource`/`SerializableData`). A request payload carrying `card_data`, `selected_target`, `card_values`, refund/input energy, and pile routing info. Created by `HandManager` when a player clicks a hand card; flows through the action system as a value/targeting reference. Also used for card-less action payloads via `card_values` alone.
- **`data/prototype/`** — Read-only template data. Call `Global.get_card_data_from_prototype(id)` (which internally calls `.get_prototype(true)`) to get a mutable copy. `CardData` now includes `card_hint` (new-player hint text), `card_status_effect_object_ids` (explicit status effect tooltip bindings), and `CARD_TYPE_DISPLAY` / `CARD_RARITY_DISPLAY` constants (moved from `Card.gd` to the data layer for reuse across all UI).
- **`data/readonly/`** — Immutable lookup data (ActData, EventData, DialogueData, KeywordData, ColorData, StatusEffectData, RunModifierData, CustomSignalData, CharacterData, mod configs, etc.).
- **`data/readonly/embedded/`** — Nested readonly data types embedded inside parent data objects: `DialogueOptionData`, `DialogueStateData` (used by `DialogueData`), `EnemyIntentData` (used by `EnemyData`).
- **`data/readonly/modding/`** — Mod support data types. Notably `CustomSignal.gd` extends `RefCounted` (not `SerializableData`) — it's the only data type that doesn't participate in serialization; it's a runtime observer-pattern signal carrier.
- **`data/mutable/`** — Runtime-mutable data (PlayerData, CombatStatsData, RunStatsData, ShopData, LocationData, ProfileData, UserSettingsData).
- **`data/filters/`** — CardFilter, ArtifactFilter, ConsumableFilter — content packs use these to query and cache filtered subsets.

### Action System (`scripts/actions/`)

All game behavior flows through Actions. Inheritance chain: `BaseAction` → `BaseAsyncAction`.

- **ActionHandler** maintains an action queue stack. Push actions via `add_action()`/`add_actions()`; they auto-execute via `_perform_actions()`.
- Actions can be **synchronous** or **asynchronous** (waiting for user input, animations, timers).
- Actions carry a `time_delay` for pacing and an interceptor pipeline (see below).
- **ActionGenerator** is the factory — it builds action trees from JSON/dictionary action data payloads.
- Key action categories:
  - `card_actions/` — play cards, pick cards, transform, discard, upgrade
  - `combatant_actions/` — attack, block, heal, apply status (to players and enemies)
  - `meta_actions/` — random selection, validators, action generation/modification
  - `world_generation_actions/` — generate Act maps
  - `world_interaction_actions/` — visit locations, start combat, open chests
  - `shop_actions/`, `rewards/`, `artifact_actions/`, `audio_actions/`, `custom_actions/`

**Value Hierarchy**: When an Action looks up a parameter via `get_action_value(key, default)`, it searches in order: Action's own `values` → `CardPlayRequest.card_values` → `CardData.card_values` → `PlayerData.player_values` → `default`. This lets cards, players, and individual actions override values at different scopes.

**Card Play Flow**: Click a hand card → `HandManager` creates `CardPlayRequest` (with card data, targets, costs) → enqueued in `card_play_queue` → `_perform_card_plays()` pops each request → `ActionGenerator.generate_card_play()` builds the action tree → actions execute through `ActionHandler` → `card_play_finished` signal fires → resolve next card or end turn.

**TextParser & Templating** (`autoload/TextParser.gd`): All rich text in the game (card descriptions, tooltips, enemy intents, forge actions) is passed through `TextParser.parse(text, context_dictionary)` before display. It supports dynamic value substitution via `[key_name]` placeholders, looked up from the provided context dictionary or the Value Hierarchy. Special macros exist:
- `[status_icon:status_id]` / `[status_name:status_id]` — dynamically replaced with the status effect's icon and localized name.
- `[key_name_energy_icons]` — replaced with N energy-icon sprites matching the integer value of `key_name` from the context.
- `[variable_energy_icons]` — replaced with energy icons matching the player's currently-consumable energy (respects `card_energy_cost_variable_upper_bound` and `multiplier_offset` for X-cost cards).
- `[energy_icon]` — a standalone macro for a single energy icon.

**Card Keywords** (`KeywordData`, `KeywordContainer`, `KeywordTooltip`): Card keyword metadata (e.g., "保留", "物理删除", "虚无") is displayed as keyword chips when hovering over a card — no longer embedded in `CardData.get_card_description()`. `KeywordData.keyword_prefix` (e.g., `[前置] `, `[后置] `) indicates when a keyword triggers (before or after an action), displayed as a prefix on the keyword tooltip. The `keyword_unplayable` keyword auto-appends to cards where `card_is_playable = false`. `[energy_icon]` placeholders in keyword text are replaced at display time.

Keywords, status effects, and card hints can each be independently toggled on/off via user settings (`settings_enable_card_keywords`, `settings_enable_card_status_effects`, `settings_enable_card_hints`), accessible from the Settings menu. When enabled, `KeywordContainer.populate_card_keywords()` auto-parses `ACTION_APPLY_STATUS` from `card_play_actions` to discover implicit status effects and displays them alongside explicit keywords. Card hints (`card_hint`) are shown as `init_custom()` tooltips, and status effects use `init_status_effect()` with their name, icon, and description.

**Card Decorator Tooltips** (`CardDecorator.gd`): Decorator descriptions are now shown as standalone tooltips when hovering over the decorator icon on a card, rather than being injected into the card's description text. `CardDecoratorData.card_decorator_description` drives the tooltip text, supporting `[key_name]` dynamic value substitution from `card_values`. The `card_decorator_pre_description` / `card_decorator_post_description` fields on `CardDecoratorData` are retained for future use but no longer automatically mutate card text.

### Action Interceptors (`scripts/action_interceptors/`)

Interceptors dynamically modify Actions just before they execute. They are the core mechanism behind status effects (Vulnerable, Weaken), relics/artifacts, and other persistent modifiers. Registered via `ActionHandler.register_action_interceptor()` per combatant. Interceptors are data-driven (`ActionInterceptorData`) and can be loaded from JSON.

Each interceptor returns an `ActionInterceptorProcessor` chain that modifies the Action's values per target. The interceptor preview system drives both enemy intent display AND card description text — the UI uses the exact same interceptor pipeline as game logic, guaranteeing consistency.

### Validators (`scripts/validators/`)

Validators drive conditional logic: "Can this card be played?", "Should this effect trigger?". Called via `Global.validate(validators, card_data, action)`. Organized by domain: card properties, card plays, deck state, hand state, combat stats, enemy state, player state.

### Content Packs

CardPackData, ArtifactPackData, and ConsumablePackData define filtered subsets of content. Content packs auto-generate filter caches at startup (`Global._generate_card_pack_cache()` etc.). Adding a card to a pack automatically makes it available in relevant drafts, shops, and reward pools.

### Filter/Cache System (`data/filters/`)

CardFilter, ArtifactFilter, and ConsumableFilter use **method chaining**. Build queries via filter methods (e.g., `.filter_type()`, `.filter_rarity()`, `.filter_colors()`), then call a terminal method (`.convert_to_card_prototypes()`, `.convert_to_unique_card_object_ids()`). Filters can be cached via `.cache_filter(id)` and stored in `Global._id_to_card_filter_cache` — content packs use this at startup. Cached filters are locked against further modification.

### Deterministic RNG

`Random.gd` provides all randomization. Each Run seeds RNG tracks from `player_data.player_run_seed`. Different game systems pull from different named RNG tracks (e.g., `"rng_reward_card_drafts"`, `"rng_shop"`), stored as `Dictionary[String, RandomNumberGenerator]` in `PlayerData.player_rng_tracks`. Tracks are lazily created on first access. This prevents cross-contamination — shuffling doesn't affect event outcomes.

### Save/Load System

Managed by `FileLoader`. **Single save slot** at `external/saves/save.json`. Key methods:
- `save_game()` / `load_game()` — JSON serialize/deserialize `Global.player_data`
- `autosave()` / `autoload()` — convenience wrappers controlled by `AUTOSAVING_ENABLED`
- `has_save_file()` / `delete_save()` — save slot management
- `save_user_settings()` / `load_user_settings()` — persistent settings at `external/user_settings.json`
- `save_profile()` / `load_profile()` — cross-run progression at `external/profile.json`

In exported builds, paths switch from `res://` to the executable's sibling directory. Multi-save-slot UI is not yet supported (code has `TODO: Profile implementation` comments).

### PlayerData (`data/prototype/PlayerData.gd`)

The central mutable data object for the current Run. Key subsystems:

- **RNG tracks** (`player_rng_tracks`): Named RNG instances seeded from `player_run_seed`
- **Card reward pool** (`player_reward_card_filter_cache`, `reward_draft_card_pack_ids`, `player_rare_card_modifier_current`): Rare card pity system; filter caches built from activated packs
- **Artifact pool** (`player_artifact_pool`, `player_artifact_pack_ids`): Shuffled pool of all artifact IDs; rewards pop from front, shop pops from back; rarity-bucketed
- **Consumable pool**: Same pattern as artifact pool
- **Event pool**: `get_next_event_object_id_from_pool()` pulls events from EventPoolData with failure handling strategies (KEEP, APPEND, REMOVE, REINSERT, BLACKLIST)
- **Location data**: `location_id_to_location_data` holds the full generated Act map
- **Run config**: `player_run_seed`, `player_run_difficulty_level`, `player_run_modifier_object_ids`

### Combat Flow

Combat is a **signal-driven state machine** in `scripts/ui/Combat.gd` (no dedicated CombatManager class):

1. `combat_started` → enemies spawn, play turn start animations
2. `start_turn()` → reset energy, process pre-draw status effects, reset block, draw cards, unlock hand
3. Player plays cards through the `CardPlayRequest` queue → Actions execute via `ActionHandler`
4. `end_turn` → `CombatEndTurn` object manages immediacy levels (WAIT_FOR_ALL_CARD_PLAYS, WAIT_FOR_ACTIONS, IMMEDIATE)
5. Player turn ends → discard/exhaust/retain logic, process post-turn status effects
6. Enemy turn → for each living enemy: pre-intent status processing → execute intent → post-intent status processing
7. Loop back to step 2
8. Combat ends when all non-summon enemies die or player dies

### Run Modifiers

`RunModifierData` drives difficulty (like Ascension) and custom modifiers. Three types:
- **Standard difficulty** (`run_modifier_is_custom = false`): Difficulty level selection on NewRunMenu. Difficulties 1-5 currently exist as stubs.
- **Custom** (`run_modifier_is_custom = true`): Player-chosen toggles (Easy Mode, Endless Mode, Draft All Colors). Can be mutually exclusive via `run_modifier_exclusive_to_modifier_ids`.
- **Automatic** (`run_modifier_is_automatic = true`): Always active (e.g., Consumable Auto-Revive). No player choice.

Modifiers work by registering action interceptors (`run_modifier_interceptor_ids`), or by running modifier scripts (`run_modifier_modifier_script_path`) that call `run_start_modification()` once at run start. Active modifier IDs are persisted in `RunStatsData.run_modifier_ids` and displayed in the Run History menu.

### Custom Signals & Stat Hooks

`CustomSignalData` (in `data/readonly/modding/`) defines data-driven signals for mods. The `Signals` singleton manages `CustomSignal` instances (each extends `RefCounted` and carries a `custom_signal` signal). `StatsHandler` connects to custom signals where `custom_signal_is_stat = true`, enabling data-driven stat tracking without code changes.

### Act (Map) Generation

`ActionGenerateActSpire.perform_action()` builds a Slay the Spire-style branching path map:

- **Data-driven floor layouts**: `ActData.act_map_floor_templates` — an array of `{min, max, pool, fixed}` dicts defining each floor's node count, combat pool, and fixed location types (SHOP, TREASURE, REST_SITE, MINIBOSS). Start and Boss floors are auto-generated.
- **Connection density**: `ActData.act_map_connection_density` (0.0–1.0) controls branching; 0.0 = clean parallel lanes, 0.5 = typical branching.
- **Connection algorithm**: Nodes sorted by x-position; each source connects to a sliding window of destination nodes centered on position-proportional target, with orphan-fixing and boss-reachability guarantees.
- Configurable `location_obfuscation_rate` (default 0.3), `location_non_combat_event_rate` (default 0.12)
- Generated via `rng_world_generation` track; fully deterministic (same seed = same map)
- Custom generation scripts can be injected via `ActData.act_action_script_path`
- Per-act content (enemies, events, event pools) is generated by the corresponding `GlobalProdDataGeneratorAct*` class in `autoload/act/`

### Event System

Uses `EventPoolData` with weighted pools. `PlayerData.get_next_event_object_id_from_pool()` copies the pool, shuffles, and validates each event against its conditions. Failed events are handled by configurable strategies (KEEP, APPEND, REMOVE, REINSERT, BLACKLIST). Events can be combat or non-combat; dialogue is state-machine-driven.

### Mod Support (`external/`)

Mods are loaded from `external/`. Each mod has a `mod_info.json` specifying folders and data types. Scripts can be loaded from mods to inject or override behavior. `mod_list.json` controls which mods are active. An example mod is at `external/mods/example_mod/`.

### Dynamic Mod Support (Asset Override System)

`FileLoader` provides a fallback mechanism for external assets: when loading from `external/` fails, it checks internal `res://` paths. This means mods can provide replacement sprites/audio in `external/` and they take priority; the game falls back to built-in assets automatically.

At runtime, `Global._on_node_added_global()` calls `_apply_fileloader_to_node()` on every node entering the scene tree. This method:
- Scans `texture`, `texture_normal`, `texture_pressed`, `texture_hover`, `texture_disabled`, `texture_focused` properties — if a node has a texture loaded from `res://sprites/`, it replaces it with a `FileLoader.load_texture()` call (enabling mod overrides)
- Scans `stream` properties for `res://sounds/` paths and redirects through `FileLoader.load_audio()`
- Guarded by `Engine.is_editor_hint()` to never run in the Godot editor

This means any sprite or audio asset can be overridden by a mod without changing scene files or scripts — just place a replacement file in the corresponding `external/` subdirectory.

Some nodes also call `FileLoader.load_texture()` directly in `_ready()`: `LayeredHealthBar`, `CardDecorator`, `Enemy.init()`, and `MapLocation.init()`. This ensures their textures participate in the mod-override system even before the global node-added hook fires.

Since v1.4, `FileLoader.load_texture()` also handles `res://` internal paths directly (using `ResourceLoader.exists()` as a fast path), not just `external/` paths. This means any node loading textures through `FileLoader` gets unified caching regardless of whether the asset is internal or external.

### Editor Plugins (`addons/`)

- **`sound_manager/`** — Nathan Hoad's audio manager plugin. Registered as editor plugin + autoload. Provides audio player pools, music/SFX/ambient channels.
- **`label_font_auto_sizer/`** — Custom `AutoSizeLabel` and `AutoSizeRichTextlabel` nodes. Registered as editor plugin.
- **`smooth_scroll_container/`** — `SmoothScrollContainer` with velocity-based inertia and overscroll. Reusable script (not registered as editor plugin).

### Shaders

Single shader: `scripts/ui/outline.gdshader` — a `canvas_item` shader drawing configurable outlines (width, color, brightness) around sprites. Used primarily on `MapLocation` nodes with animation tracks for pulsing highlight effects.

### UI Architecture

All UI scenes are preloaded in the `Scenes` singleton. UI scripts are in `scripts/ui/`. The root scene (`Root.tscn`) has three top-level children: **TitleScreen** (menus), **RunScreen** (in-game HUD), and **Tooltips** (global tooltip layer, Z-index 1000). Key subsystems:
- **Card display**: `Card.tscn` + `CardDecorator.tscn` (for enchantment-like card visual modifications)
- **Codex**: Browseable content encyclopedia with five tabs: Cards, Artifacts, Consumables, Enemies, and Glossary (keywords + status effects with descriptions). Card tab supports sorting by rarity/cost/type and **double-click** on any card opens `CodexCardDetailPanel` — a full overlay showing all card data: basic info, flags, pile routing, numeric values, upgrade paths, decorators, action hooks, keywords, and tags.
- **Map**: `MapLocation.tscn` with `Line2D` connections for Act navigation
- **Rewards**: Card draft, artifact, and money reward screens
- **Shop**: Purchase cards, artifacts, and consumables
- **Tooltips**: `KeywordTooltip.tscn` (single keyword with optional status icon) and `Tooltip.tscn` (positioned rich text); keywords support nested sub-keywords via BFS. `KeywordTooltip` also supports `init_custom(title, text)` for arbitrary tooltips (hints, decorators) and `init_status_effect(id)` for status effect tooltips with name + icon + description. Decorator tooltips are triggered from `CardDecorator._on_mouse_entered()` via `Tooltips.display_decorator_tooltip()`.
- **Combat**: Hand area, enemy container, energy display, piles, end turn button, target selection

### Combatants (`scenes/combatants/`, `scripts/combatants/`)

`Player.tscn` and `Enemy.tscn` are combatant scenes. Health is displayed via `LayeredHealthBar` + `HealthLayer`. `StatusEffect.tscn` renders status icons. Combat floaters (text, artifact, image) provide visual feedback for actions.

## Key Patterns & Best Practices

- **Read-only → prototype pattern**: Data templates in Global's lookup tables are read-only. To get a mutable instance, call `Global.get_card_data_from_prototype(id)` (internally calls `.get_prototype(true)`).
- **Signal-driven communication**: Cross-system events go through the `Signals` singleton. Avoid direct coupling between systems.
- **Action composition**: Actions can contain child actions enabling nested behavior (for loops, conditionals, random branches via meta_actions).
- **Validator sharing**: Game logic ("Can this card be played?") and UI ("Should this card glow? Should this text be highlighted?") both use the same `Global.validate()` pipeline.
- **Startup caching**: Card/artifact/consumable filter caches are generated once at startup. Don't repeatedly query raw data.
- **`class_name` requirement**: The serialization system resolves class names at runtime through Godot's global class list. New data classes must use a `class_name` matching their filename.
- **Interceptor previews**: Enemy intents and card description text use the exact same interceptor pipeline as game logic — there is absolutely no separate calculation system.
- **`.gdignore` in `external/`**: Prevents Godot from scanning external assets on project load. Always keep this file present.

