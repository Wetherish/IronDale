package entities

import "core:os"
import gr "../graphics"
import rl "vendor:raylib"

PLAYER_FRONT_SPRITE_PATH :: "assets/animations/player_front.png"
PLAYER_SIDE_SPRITE_PATH :: "assets/animations/player_side.png"
PLAYER_FRAME_WIDTH :: f32(50)
PLAYER_FRAME_HEIGHT :: f32(50)
PLAYER_SIDE_FRAME_WIDTH :: f32(76)
PLAYER_SIDE_FRAME_HEIGHT :: f32(88)

Hero :: struct {
	position:           rl.Vector2,
	speed:              f32,
	front_sprite:       gr.Sprite,
	walk_sprite:        gr.Sprite,
	animator:           CharacterAnimator,
	front_sprite_loaded: bool,
	walk_sprite_loaded: bool,
	facing_left:        bool,
}

CreateHero :: proc(position: rl.Vector2, speed: f32) -> Hero {
	idle := gr.CreateAnimationClip(0, 0, 6, 1.0 / 8.0)
	walk := gr.CreateAnimationClip(0, 0, 6, 1.0 / 8.0)
	fight := gr.CreateAnimationClip(0, 0, 6, 1.0 / 12.0)
	animations := CharacterAnimationSet {
		idle  = idle,
		walk  = walk,
		fight = fight,
	}
	front_sprite := gr.Sprite{}
	walk_sprite := gr.Sprite{}
	front_sprite_loaded := false
	walk_sprite_loaded := false

	if os.is_file(PLAYER_FRONT_SPRITE_PATH) {
		front_sprite = gr.CreateSprite(PLAYER_FRONT_SPRITE_PATH, PLAYER_FRAME_WIDTH, PLAYER_FRAME_HEIGHT)
		front_sprite_loaded = gr.SpriteValid(front_sprite)
	}

	if os.is_file(PLAYER_SIDE_SPRITE_PATH) {
		walk_sprite = gr.CreateSprite(PLAYER_SIDE_SPRITE_PATH, PLAYER_SIDE_FRAME_WIDTH, PLAYER_SIDE_FRAME_HEIGHT)
		walk_sprite_loaded = gr.SpriteValid(walk_sprite)
	}

	return Hero {
		position            = position,
		speed               = speed,
		front_sprite        = front_sprite,
		walk_sprite         = walk_sprite,
		animator            = CreateCharacterAnimator(animations),
		front_sprite_loaded = front_sprite_loaded,
		walk_sprite_loaded  = walk_sprite_loaded,
		facing_left         = false,
	}
}

DrawHero :: proc(h: Hero) {
	if h.animator.state_machine.current == .Walk && h.walk_sprite_loaded {
		gr.DrawSprite(
			h.walk_sprite,
			CharacterAnimationRow(h.animator),
			CharacterAnimationFrame(h.animator),
			h.position,
			h.facing_left,
		)
		return
	}

	if h.front_sprite_loaded {
		gr.DrawSprite(
			h.front_sprite,
			CharacterAnimationRow(h.animator),
			CharacterAnimationFrame(h.animator),
			h.position,
		)
		return
	}

	rl.DrawCircleV(h.position, 5, rl.BLUE)
}

UpdateHero :: proc(h: ^Hero, dt: f32) {
	gr.PlayAnimation(&h.animator, h.idle)
	gr.UpdateAnimation(&h.animator, dt)

	input := rl.Vector2{}

	if (rl.IsKeyDown(rl.KeyboardKey.RIGHT)) do input.x += 1
	if (rl.IsKeyDown(rl.KeyboardKey.LEFT)) do input.x -= 1
	if (rl.IsKeyDown(rl.KeyboardKey.UP)) do input.y -= 1
	if (rl.IsKeyDown(rl.KeyboardKey.DOWN)) do input.y += 1

	if input.x < 0 {
		h.facing_left = true
	} else if input.x > 0 {
		h.facing_left = false
	}

	fighting := rl.IsKeyDown(rl.KeyboardKey.SPACE)
	moving := input.x != 0 || input.y != 0
	next_state := CharacterState.Idle

	if fighting {
		next_state = CharacterState.Fight
	} else if moving {
		next_state = CharacterState.Walk
	}

	SetCharacterAnimatorState(&h.animator, next_state)
	UpdateCharacterAnimator(&h.animator, dt)

	if input.x != 0 && input.y != 0 {
		input.x *= 0.70710678
		input.y *= 0.70710678
	}

	h.position.x += input.x * h.speed * dt
	h.position.y += input.y * h.speed * dt
}

DestroyHero :: proc(h: ^Hero) {
	if h.front_sprite_loaded {
		gr.DestroySprite(&h.front_sprite)
		h.front_sprite_loaded = false
	}

	if h.walk_sprite_loaded {
		gr.DestroySprite(&h.walk_sprite)
		h.walk_sprite_loaded = false
	}
}
