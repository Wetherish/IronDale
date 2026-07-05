# Iron Hollow TODO

Roadmap for a 2D top-down Odin + raylib co-op game. Keep this file practical: every item should move the playable build forward.

## Current Baseline

- [x] Open a raylib window.
- [x] Add `Makefile` targets for run, build, release, and clean.
- [x] Add a basic screen manager.
- [x] Add a title/main screen flow.
- [x] Draw a player placeholder.
- [x] Move the player with keyboard input.
- [x] Use frame delta time for player movement.
- [x] Draw a simple environment entity.
- [x] Add a simple entity union for hero/tree dispatch.

## 1. Project Foundation

- [x] Add a simple build/run command through `make run`.
- [ ] Decide target platforms: Windows, Linux, or both.
- [ ] Create folders for `assets/`, `core/`, `game/`, `world/`, and `ui/` as needed.
- [ ] Move game constants into one place: screen size, target FPS, tile size, player speed.
- [ ] Add a `Game_State` struct to own players, world data, camera, and runtime state.
- [x] Split high-level game flow into screens with update/draw/destroy behavior.
- [ ] Split active gameplay state into `init`, `update`, `draw`, and `shutdown` style procedures.
- [ ] Add debug toggles for collision boxes, FPS, player coordinates, and network status.

## 2. Core Game Loop

- [x] Use frame delta time instead of fixed per-frame movement.
- [ ] Add a camera that follows the local player.
- [ ] Add world-space drawing instead of screen-space-only drawing.
- [ ] Add deterministic update order for players, enemies, projectiles, and world objects.
- [x] Add basic menu screen handling.
- [ ] Add in-game pause state handling.
- [ ] Add basic save/load format for settings and local progress if needed.

## 3. Player Character

- [ ] Replace placeholder circle with a sprite or temporary animated shape.
- [ ] Add facing direction.
- [ ] Add idle, walk, attack, hurt, and death animation states.
- [ ] Add health, stamina/energy if needed, damage cooldown, and respawn state.
- [ ] Add primary interaction button.
- [ ] Add primary attack or tool action.
- [ ] Add controller support.
- [ ] Support multiple local player input bindings for testing co-op quickly.

## 4. World And Collision

- [ ] Pick a world format: hand-authored tilemap, procedural rooms, or hybrid.
- [ ] Implement tile/grid coordinates.
- [ ] Add solid collision for trees, walls, rocks, and map bounds.
- [ ] Add trigger zones for doors, pickups, and objectives.
- [ ] Add simple spatial queries so collision and interaction do not scan every object forever.
- [ ] Add a test map with spawn points, obstacles, and one objective.
- [ ] Add map transitions or room loading.

## 5. Entities And Gameplay

- [x] Define initial entity dispatch for hero and tree.
- [ ] Define common entity data: id, type, position, velocity, bounds, health, active flag.
- [ ] Add enemy placeholder with patrol/chase behavior.
- [ ] Add enemy damage and death.
- [ ] Add pickups: health, resources, keys, or currency.
- [ ] Add interactable objects: chest, door, switch, workbench, shrine, or similar.
- [ ] Add objective loop for a first playable slice.
- [ ] Add basic combat feedback: hit flash, knockback, sound, particles.
- [ ] Add win/lose conditions for a small test scenario.

## 6. Co-op Architecture

- [ ] Decide co-op type for the first version: local same-screen, online, or LAN.
- [ ] Build local co-op first unless online is the main requirement.
- [ ] Represent players by stable player ids instead of assuming a single hero.
- [ ] Separate input collection from player simulation.
- [ ] Add join/leave flow for player slots.
- [ ] Add spawn positions for multiple players.
- [ ] Add revive/respawn rules.
- [ ] Decide shared camera rules: follow midpoint, clamp zoom, or split screen.

## 7. Networking, If Online Co-op

- [ ] Decide networking model: host-authoritative, lockstep, or rollback.
- [ ] Start with host-authoritative for a small co-op action game.
- [ ] Define replicated state: player positions, health, entity states, pickups, objectives.
- [ ] Define client commands: movement, attack, interact, join, ready.
- [ ] Add packet serialization/deserialization.
- [ ] Add connection states: disconnected, hosting, joining, loading, in-game.
- [ ] Add client prediction for local movement only after the basic network loop works.
- [ ] Add reconciliation/smoothing for remote players.
- [ ] Add timeout and reconnect behavior.
- [ ] Add debug overlay for ping, packet loss, and host/client role.

## 8. Art And Audio

- [ ] Choose temporary art style and resolution.
- [ ] Add placeholder sprites for player, enemies, trees, walls, floor, and pickups.
- [ ] Add sprite loading and centralized asset ownership.
- [ ] Add animation data format.
- [ ] Add sound effects for movement, attack, hit, pickup, interact, death, and UI.
- [ ] Add music system with at least exploration/combat tracks if needed.
- [ ] Add screen shake, particles, and lighting only after core readability is good.

## 9. UI And Menus

- [x] Add title screen.
- [ ] Add player HUD: health, resources, objective status.
- [ ] Add pause menu.
- [ ] Add settings menu for audio, display, input, and accessibility basics.
- [ ] Add co-op lobby screen for player slots and ready state.
- [ ] Add death/revive prompt.
- [ ] Add end-of-run or mission-complete screen.

## 10. Tools And Content Workflow

- [ ] Decide whether to use Tiled, LDtk, or a custom simple map format.
- [ ] Add map loader.
- [ ] Add asset naming conventions.
- [ ] Add data files for enemies, items, and interactables if hardcoding becomes painful.
- [ ] Add a debug spawn menu.
- [ ] Add hot reload for maps/assets only if iteration becomes slow.

## 11. Testing And Quality

- [ ] Add smoke test checklist: launch, move, collide, attack, interact, quit.
- [ ] Add focused Odin tests for pure logic such as collision, serialization, and map loading.
- [ ] Add a debug test map that exercises collision, combat, pickups, and co-op spawns.
- [ ] Track frame time and entity counts.
- [ ] Check keyboard/controller input on every target platform.
- [ ] Test window resize/fullscreen behavior.
- [ ] Test two-player local co-op before adding network complexity.

## First Playable Slice

Target: a small co-op room where two players can move, collide with obstacles, fight one enemy, collect one pickup, and complete one objective.

- [x] Refactor `main.odin` to use screen-managed flow.
- [x] Add delta-time movement.
- [ ] Add a dedicated gameplay screen/state that owns world entities.
- [ ] Add two player structs and local input bindings.
- [ ] Add camera follow for both players.
- [ ] Add collision against trees/walls.
- [ ] Add one enemy.
- [ ] Add one interactable objective.
- [ ] Add a minimal HUD.
- [ ] Add restart/quit controls.

## Design Questions To Answer Soon

- [ ] What is the core fantasy: survival, dungeon crawl, crafting, extraction, wave defense, or story adventure?
- [ ] Is co-op local first, online first, or both?
- [ ] How many players: 2 only, or 2-4?
- [ ] Is combat melee, ranged, tools, magic, or mixed?
- [ ] Is the world tile-based, freeform, or room-based?
- [ ] What is the smallest fun 5-minute loop?
