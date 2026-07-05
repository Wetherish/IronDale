package entities

import rl "vendor:raylib"

EntityData :: union {
	Hero,
	Tree,
}

Entity :: struct {
	position: rl.Vector2,
	collider: Collider,
	data:     EntityData,
}

CreateHeroEntity :: proc(position: rl.Vector2, speed: f32) -> Entity {
	return Entity {
		position = position,
		collider = Collider {
			offset = {40, 40},
			size   = {14, 20},
			solid  = true,
		},
		data = CreateHero(speed),
	}
}

CreateTreeEntity :: proc(position: rl.Vector2) -> Entity {
	return Entity {
		position = position,
		collider = Collider {
			offset = {0, 0},
			size   = {10, 50},
			solid  = true,
		},
		data = CreateTree(),
	}
}


Draw :: proc(entity: Entity) {
	switch value in entity.data {
	case Hero:
		DrawHero(value, entity.position)
	case Tree:
		DrawTree(value, entity.position, entity.collider)
	}
}

DrawCollisionDebug :: proc(entity: Entity) {
	DrawColliderDebug(entity.position, entity.collider)
}

DrawColliderDebug :: proc(position: rl.Vector2, collider: Collider) {
	bounds := BoundsFromCollider(position, collider)
	rect := rl.Rectangle{bounds.x, bounds.y, bounds.w, bounds.h}
	line_color := collider.solid ? rl.RED : rl.YELLOW
	fill_color := rl.Color{line_color.r, line_color.g, line_color.b, 36}

	rl.DrawRectangleRec(rect, fill_color)
	rl.DrawRectangleLinesEx(rect, 2, line_color)
}

Update :: proc(entity: ^Entity, entities: []Entity, self_index: int, dt: f32) {
	switch &value in entity.data {
	case Hero:
		UpdateHero(&value, entity, entities, self_index, dt)
	case Tree:
	}
}

Destroy :: proc(entity: ^Entity) {
	switch &value in entity.data {
	case Hero:
		DestroyHero(&value)
	case Tree:
	}
}

EntityCollidesWithSolids :: proc(
	position: rl.Vector2,
	collider: Collider,
	entities: []Entity,
	selfIndex: int,
) -> bool {
	if !collider.solid {
		return false
	}

	bounds := BoundsFromCollider(position, collider)
	for entity, index in entities {
		if index == selfIndex {
			continue
		}

		if !entity.collider.solid {
			continue
		}

		if BoundsOverlap(bounds, BoundsFromCollider(entity.position, entity.collider)) {
			return true
		}
	}

	return false
}

EntityGet :: proc(entity: ^Entity, $T: typeid) -> ^T {
	if entity == nil {
		return nil
	}

	if value, ok := &entity.data.(T); ok {
		return value
	}

	return nil
}