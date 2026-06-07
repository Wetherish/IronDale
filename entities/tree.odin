package entities

import rl "vendor:raylib"

Tree :: struct {
	position: rl.Vector2,
}

DrawTree :: proc(t: Tree) {
    rl.DrawRectangleV(t.position, {10, 50}, rl.GREEN)
}


