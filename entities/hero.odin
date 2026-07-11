package entities

import "core:os"
import gr "../graphics"
import rl "vendor:raylib"

PLAYER_IDLE_DOWN_SPRITE_PATH :: "assets/TempAssets/Sprites/IDLE/idle_down.png"
PLAYER_IDLE_UP_SPRITE_PATH :: "assets/TempAssets/Sprites/IDLE/idle_up.png"
PLAYER_IDLE_LEFT_SPRITE_PATH :: "assets/TempAssets/Sprites/IDLE/idle_left.png"
PLAYER_IDLE_RIGHT_SPRITE_PATH :: "assets/TempAssets/Sprites/IDLE/idle_right.png"
PLAYER_RUN_DOWN_SPRITE_PATH :: "assets/TempAssets/Sprites/RUN/run_down.png"
PLAYER_RUN_UP_SPRITE_PATH :: "assets/TempAssets/Sprites/RUN/run_up.png"
PLAYER_RUN_LEFT_SPRITE_PATH :: "assets/TempAssets/Sprites/RUN/run_left.png"
PLAYER_RUN_RIGHT_SPRITE_PATH :: "assets/TempAssets/Sprites/RUN/run_right.png"
PLAYER_ATTACK_DOWN_SPRITE_PATH :: "assets/TempAssets/Sprites/ATTACK 1/attack1_down.png"
PLAYER_ATTACK_UP_SPRITE_PATH :: "assets/TempAssets/Sprites/ATTACK 1/attack1_up.png"
PLAYER_ATTACK_LEFT_SPRITE_PATH :: "assets/TempAssets/Sprites/ATTACK 1/attack1_left.png"
PLAYER_ATTACK_RIGHT_SPRITE_PATH :: "assets/TempAssets/Sprites/ATTACK 1/attack1_right.png"
PLAYER_FRAME_WIDTH :: f32(96)
PLAYER_FRAME_HEIGHT :: f32(80)

Hero_Facing :: enum {
	Down,
	Up,
	Left,
	Right,
}

Loaded_Sprite :: struct {
	sprite: gr.Sprite,
	loaded: bool,
}

Directional_Hero_Sprites :: struct {
	down:  Loaded_Sprite,
	up:    Loaded_Sprite,
	left:  Loaded_Sprite,
	right: Loaded_Sprite,
}

Hero :: struct {
	position: rl.Vector2,
	speed:    f32,
	idle:     Directional_Hero_Sprites,
	run:      Directional_Hero_Sprites,
	fight:    Directional_Hero_Sprites,
	animator: CharacterAnimator,
	facing:   Hero_Facing,
}

CreateHero :: proc(position: rl.Vector2, speed: f32) -> Hero {
	idle := gr.CreateAnimationClip(0, 0, 8, 1.0 / 8.0)
	walk := gr.CreateAnimationClip(0, 0, 8, 1.0 / 12.0)
	fight := gr.CreateAnimationClip(0, 0, 8, 1.0 / 14.0, false)
	animations := CharacterAnimationSet {
		idle  = idle,
		walk  = walk,
		fight = fight,
	}

	return Hero {
		position = position,
		speed    = speed,
		idle     = LoadDirectionalHeroSprites(
			PLAYER_IDLE_DOWN_SPRITE_PATH,
			PLAYER_IDLE_UP_SPRITE_PATH,
			PLAYER_IDLE_LEFT_SPRITE_PATH,
			PLAYER_IDLE_RIGHT_SPRITE_PATH,
		),
		run = LoadDirectionalHeroSprites(
			PLAYER_RUN_DOWN_SPRITE_PATH,
			PLAYER_RUN_UP_SPRITE_PATH,
			PLAYER_RUN_LEFT_SPRITE_PATH,
			PLAYER_RUN_RIGHT_SPRITE_PATH,
		),
		fight = LoadDirectionalHeroSprites(
			PLAYER_ATTACK_DOWN_SPRITE_PATH,
			PLAYER_ATTACK_UP_SPRITE_PATH,
			PLAYER_ATTACK_LEFT_SPRITE_PATH,
			PLAYER_ATTACK_RIGHT_SPRITE_PATH,
		),
		animator = CreateCharacterAnimator(animations),
		facing   = .Down,
	}
}

LoadDirectionalHeroSprites :: proc(
	down_path,
	up_path,
	left_path,
	right_path: cstring,
) -> Directional_Hero_Sprites {
	return Directional_Hero_Sprites {
		down  = LoadHeroSprite(down_path),
		up    = LoadHeroSprite(up_path),
		left  = LoadHeroSprite(left_path),
		right = LoadHeroSprite(right_path),
	}
}

LoadHeroSprite :: proc(path: cstring) -> Loaded_Sprite {
	loaded_sprite := Loaded_Sprite{}

	if os.is_file(string(path)) {
		loaded_sprite.sprite = gr.CreateSprite(path, PLAYER_FRAME_WIDTH, PLAYER_FRAME_HEIGHT)
		loaded_sprite.loaded = gr.SpriteValid(loaded_sprite.sprite)
	}

	return loaded_sprite
}

DrawHero :: proc(h: Hero) {
	sprite_set := h.idle

	switch h.animator.state_machine.current {
	case .Walk:
		sprite_set = h.run
	case .Fight:
		sprite_set = h.fight
	case .Idle:
	}

	if DrawHeroSprite(sprite_set, h.facing, h.animator, h.position) {
		return
	}

	rl.DrawCircleV(h.position, 5, rl.BLUE)
}

DrawHeroSprite :: proc(
	sprites: Directional_Hero_Sprites,
	facing: Hero_Facing,
	animator: CharacterAnimator,
	position: rl.Vector2,
) -> bool {
	sprite := HeroSpriteForFacing(sprites, facing)
	if !sprite.loaded {
		sprite = HeroSpriteForFacing(sprites, .Down)
	}

	if !sprite.loaded {
		return false
	}

	gr.DrawSprite(
		sprite.sprite,
		CharacterAnimationRow(animator),
		CharacterAnimationFrame(animator),
		position,
	)
	return true
}

HeroSpriteForFacing :: proc(sprites: Directional_Hero_Sprites, facing: Hero_Facing) -> Loaded_Sprite {
	switch facing {
	case .Down:
		return sprites.down
	case .Up:
		return sprites.up
	case .Left:
		return sprites.left
	case .Right:
		return sprites.right
	}

	return sprites.down
}

UpdateHero :: proc(h: ^Hero, dt: f32) {
	input := rl.Vector2{}

	if (rl.IsKeyDown(rl.KeyboardKey.RIGHT)) do input.x += 1
	if (rl.IsKeyDown(rl.KeyboardKey.LEFT)) do input.x -= 1
	if (rl.IsKeyDown(rl.KeyboardKey.UP)) do input.y -= 1
	if (rl.IsKeyDown(rl.KeyboardKey.DOWN)) do input.y += 1

	if HeroAttackLocked(h) {
		UpdateCharacterAnimator(&h.animator, dt)
		return
	}

	UpdateHeroFacing(h, input)

	fighting := rl.IsKeyPressed(rl.KeyboardKey.SPACE)
	moving := input.x != 0 || input.y != 0
	next_state := CharacterState.Idle

	if fighting {
		next_state = CharacterState.Fight
	} else if moving {
		next_state = CharacterState.Walk
	}

	SetCharacterAnimatorState(&h.animator, next_state)
	if fighting && h.animator.state_machine.current == .Fight {
		gr.PlayAnimation(&h.animator.player, h.animator.animations.fight, true)
		h.animator.state_machine.time_in_state = 0
	}
	UpdateCharacterAnimator(&h.animator, dt)

	if next_state == .Fight {
		return
	}

	if input.x != 0 && input.y != 0 {
		input.x *= 0.70710678
		input.y *= 0.70710678
	}

	h.position.x += input.x * h.speed * dt
	h.position.y += input.y * h.speed * dt
}

HeroAttackLocked :: proc(h: ^Hero) -> bool {
	return h.animator.state_machine.current == .Fight && !h.animator.player.finished
}

UpdateHeroFacing :: proc(h: ^Hero, input: rl.Vector2) {
	if input.y < 0 {
		h.facing = .Up
	} else if input.y > 0 {
		h.facing = .Down
	} else if input.x < 0 {
		h.facing = .Left
	} else if input.x > 0 {
		h.facing = .Right
	}
}

DestroyHero :: proc(h: ^Hero) {
	DestroyDirectionalHeroSprites(&h.idle)
	DestroyDirectionalHeroSprites(&h.run)
	DestroyDirectionalHeroSprites(&h.fight)
}

DestroyDirectionalHeroSprites :: proc(sprites: ^Directional_Hero_Sprites) {
	DestroyLoadedSprite(&sprites.down)
	DestroyLoadedSprite(&sprites.up)
	DestroyLoadedSprite(&sprites.left)
	DestroyLoadedSprite(&sprites.right)
}

DestroyLoadedSprite :: proc(sprite: ^Loaded_Sprite) {
	if sprite.loaded {
		gr.DestroySprite(&sprite.sprite)
		sprite.loaded = false
	}
}
