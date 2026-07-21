# Iron Hollow Notes

## Entity Architecture Direction

Project is expected to have many NPCs, multiple playable co-op characters, enemies, pickups, interaction objects, and combat. Because of that, the current `Entity` union is fine as a starting point, but new gameplay should move toward an ECS-lite style.

Do not rewrite everything into a full ECS immediately. Prefer gradual steps:

1. Add shared data/components when multiple entity kinds need the same behavior.
2. Keep unique behavior small and specific.
3. Move common logic into systems: movement, collision, interaction, combat, rendering.

Useful mental model:

```text
Hero       = Transform + Motion + Collider + Hurtbox + Health + Combat + Player_Controlled + Sprite + Animator
Enemy      = Transform + Motion + Collider + Hurtbox + Health + Combat + Enemy_Brain + Sprite + Animator
Villager   = Transform + Collider + Interactable + Dialogue + Sprite + Animator
Trader     = Transform + Collider + Interactable + Dialogue + Trader + Sprite + Animator
Tree       = Transform + Collider + Sprite
Projectile = Transform + Motion + Hitbox + Damage + Lifetime + Collider
```

## Collision

Collision should be split by purpose:

```text
Collider = blocks movement
Hurtbox  = area that can receive damage
Hitbox   = area that deals damage
Trigger  = detects proximity or special events without blocking movement
```

The first collision implementation uses AABB rectangles. Movement should be resolved one axis at a time:

```text
move X
if collides, undo X

move Y
if collides, undo Y
```

This lets characters slide along walls and obstacles instead of getting fully stuck.

## NPC Interaction

Talking to NPCs should use proximity interaction, not physical collision.

Basic flow:

```text
player is close enough to NPC
show interaction prompt
player presses E
start dialogue
```

Suggested data:

```odin
Interaction_Kind :: enum {
	Talk,
	Trade,
	Chest,
	Door,
}

Interactable :: struct {
	radius: f32,
	kind:   Interaction_Kind,
}
```

NPC examples:

```text
Normal NPC = Transform + Collider + Interactable(radius=45) + Dialogue
Trader     = Transform + Collider + Interactable(radius=50) + Dialogue + Trader
Door       = Transform + Interactable(radius=35) + Door
Chest      = Transform + Collider + Interactable(radius=35) + Loot
```

Interaction system:

1. Find the local player.
2. Search nearby entities with `Interactable`.
3. Pick the closest valid target.
4. Show a prompt.
5. On `E`, start the matching action.

For traders, do not open the shop directly from NPC update logic. The NPC should only have data such as `Trader.shop_id`. The interaction system can decide to open a shop screen or overlay.

## Enemies And Damage

Combat should also be data-driven enough to reuse across players, enemies, and projectiles.

Suggested data:

```odin
Health :: struct {
	current: int,
	max:     int,
}

Faction :: enum {
	Player,
	Enemy,
	Neutral,
}

Hurtbox :: struct {
	offset: rl.Vector2,
	size:   rl.Vector2,
}

Hitbox :: struct {
	offset: rl.Vector2,
	size:   rl.Vector2,
	damage: int,
	active: bool,
}
```

Basic hero attack flow:

```text
player presses SPACE
hero enters attack state
attack creates/activates a hitbox in front of the hero
combat system checks hitbox against enemy hurtboxes
if overlap and factions can damage each other, subtract HP
if HP <= 0, mark enemy dead/inactive
```

Important safeguards:

1. Add faction checks so allies do not damage each other by accident.
2. Add hit cooldown or invulnerability after damage.
3. Make sure one attack swing does not hit the same target every frame.

Simple first implementation:

```text
SPACE -> create attack bounds in front of hero
for each enemy:
    if attack bounds overlap enemy hurtbox:
        enemy health -= 1
```

Better later implementation:

```text
attack animation starts
only selected animation frames activate the hitbox
targets hit by this attack_id are remembered
hit enemies receive damage, knockback, hit flash, and cooldown
```

## Enemy AI First Pass

Start simple:

```text
if enemy is far from player:
    idle or patrol

if enemy is inside chase radius:
    move toward player

if enemy is inside attack radius:
    stop and attack
```

Suggested enemy components:

```text
Enemy = Transform + Motion + Collider + Hurtbox + Health + Faction(Enemy) + Enemy_Brain
```

Keep enemy movement using the same collision/movement path as players. This avoids separate movement bugs for each character type.

## Recommended Implementation Order

1. Keep current collision and union dispatch working.
2. Add `Health` and `Faction`.
3. Add a simple `Enemy` entity with position, collider, health, and draw placeholder.
4. Add a simple hero attack bounds check on `SPACE`.
5. Damage enemies and remove/disable them at 0 HP.
6. Add `Interactable` and a test NPC.
7. Add proximity prompt and `E` interaction.
8. Add dialogue placeholder.
9. Add trader/shop data later.
10. Move repeated logic toward ECS-lite systems as patterns become clear.

