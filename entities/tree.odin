package entities

import rl "vendor:raylib"

Tree :: struct {
}

CreateTree :: proc() -> Tree {
	return Tree{}
}

DrawTree :: proc(t: Tree, position: rl.Vector2, collider: Collider) {
	rl.DrawRectangleV(position, collider.size, rl.GREEN)
}
