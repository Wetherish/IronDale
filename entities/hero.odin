package entities

import "core:os"
import gr "../graphics"
import rl "vendor:raylib"

PLAYER_FRONT_SPRITE_PATH :: "assets/animations/player_front.png"
PLAYER_FRAME_WIDTH :: f32(50)
PLAYER_FRAME_HEIGHT :: f32(50)

Hero :: struct {
	position:      rl.Vector2,
	speed:         f32,
	sprite:        gr.Sprite,
	idle:          gr.AnimationClip,
	animator:      gr.AnimationPlayer,
	sprite_loaded: bool,
}

CreateHero :: proc(position: rl.Vector2, speed: f32) -> Hero {
	idle := gr.CreateAnimationClip(0, 0, 6, 1.0 / 8.0)
	sprite := gr.Sprite{}
	sprite_loaded := false

	if os.is_file(PLAYER_FRONT_SPRITE_PATH) {
		sprite = gr.CreateSprite(PLAYER_FRONT_SPRITE_PATH, PLAYER_FRAME_WIDTH, PLAYER_FRAME_HEIGHT)
		sprite_loaded = gr.SpriteValid(sprite)
	}

	return Hero {
		position      = position,
		speed         = speed,
		sprite        = sprite,
		idle          = idle,
		animator      = gr.CreateAnimationPlayer(idle),
		sprite_loaded = sprite_loaded,
	}
}

DrawHero :: proc(h: Hero) {
	if h.sprite_loaded {
		gr.DrawSprite(
			h.sprite,
			gr.AnimationRow(h.animator),
			gr.AnimationFrame(h.animator),
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

	if input.x != 0 && input.y != 0 {
		input.x *= 0.70710678
		input.y *= 0.70710678
	}

	h.position.x += input.x * h.speed * dt
	h.position.y += input.y * h.speed * dt
}

DestroyHero :: proc(h: ^Hero) {
	if h.sprite_loaded {
		gr.DestroySprite(&h.sprite)
		h.sprite_loaded = false
	}
}
