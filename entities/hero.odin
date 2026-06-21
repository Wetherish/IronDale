package entities

import rl "vendor:raylib"

Hero :: struct {
	position: rl.Vector2,
	speed: f32,
}

DrawHero :: proc(h: Hero) {
	rl.DrawCircleV(h.position, 5, rl.BLUE)
}

UpdateHero :: proc(h: ^Hero, dt: f32) {
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
