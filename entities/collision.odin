package entities

import rl "vendor:raylib"

Collider :: struct {
	offset: rl.Vector2,
	size:   rl.Vector2,
	solid:  bool,
}

Bounds :: struct {
	x: f32,
	y: f32,
	w: f32,
	h: f32,
}

BoundsFromCollider :: proc(position: rl.Vector2, collider: Collider) -> Bounds {
	return Bounds {
		x = position.x + collider.offset.x,
		y = position.y + collider.offset.y,
		w = collider.size.x,
		h = collider.size.y,
	}
}

BoundsOverlap :: proc(a, b: Bounds) -> bool {
	return a.x < b.x + b.w &&
	       a.x + a.w > b.x &&
	       a.y < b.y + b.h &&
	       a.y + a.h > b.y
}

