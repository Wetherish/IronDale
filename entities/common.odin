package entities

import rl "vendor:raylib"

Entity :: union {
	Hero,
	Tree,
}

CreateHeroEntity :: proc(position: rl.Vector2, speed: f32) -> Entity {
	return CreateHero(position, speed)
}

CreateTreeEntity :: proc(position: rl.Vector2) -> Entity {
	return Tree{position = position}
}


Draw :: proc(entity: Entity) {
	switch value in entity {
	case Hero:
		DrawHero(value)
	case Tree:
		DrawTree(value)
	}
}

Update :: proc(entity: ^Entity, dt: f32) {
	switch &value in entity^ {
	case Hero:
		UpdateHero(&value, dt)
	case Tree:
	}
}

Destroy :: proc(entity: ^Entity) {
	switch &value in entity^ {
	case Hero:
		DestroyHero(&value)
	case Tree:
	}
}
