package entities

import rl "vendor:raylib"

Hero :: struct {
	position: rl.Vector2,
}

draw :: proc(h: Hero) {
	rl.DrawCircleV(h.position, 5, rl.BLUE)
}

update :: proc(h: ^Hero) {
	if (rl.IsKeyDown(rl.KeyboardKey.RIGHT)) do h.position.x += 2.0
	if (rl.IsKeyDown(rl.KeyboardKey.LEFT)) do h.position.x -= 2.0
	if (rl.IsKeyDown(rl.KeyboardKey.UP)) do h.position.y -= 2.0
	if (rl.IsKeyDown(rl.KeyboardKey.DOWN)) do h.position.y += 2.0
}
