package game

import cfg "../core"
import e "../entities"
import rl "vendor:raylib"

Game_State :: struct {
	entities: [dynamic]e.Entity,
	camera:   rl.Camera2D,
}

CreateGameState :: proc() -> Game_State {
	state := Game_State {
		entities = make([dynamic]e.Entity),
		camera   = CreateGameCamera(),
	}

	append(&state.entities, e.CreateHeroEntity({100, 100}, cfg.PLAYER_SPEED))
	append(&state.entities, e.CreateTreeEntity({250, 160}))

	UpdateGameCamera(&state)
	return state
}

DestroyGameState :: proc(state: ^Game_State) {
	for &entity in state.entities {
		e.Destroy(&entity)
	}
	delete(state.entities)
}

UpdateGameState :: proc(state: ^Game_State, dt: f32) {
	for &entity in state.entities {
		e.Update(&entity, dt)
	}

	UpdateGameCamera(state)
}

DrawGameState :: proc(state: ^Game_State) {
	rl.BeginMode2D(state.camera)
	for entity in state.entities {
		e.Draw(entity)
	}
	rl.EndMode2D()
}

LocalHero :: proc(state: ^Game_State) -> ^e.Hero {
	for &entity in state.entities {
		switch &value in entity {
		case e.Hero:
			return &value
		case e.Tree:
		}
	}

	return nil
}

CreateGameCamera :: proc() -> rl.Camera2D {
	return rl.Camera2D {
		offset   = {f32(cfg.SCREEN_WIDTH) * 0.5, f32(cfg.SCREEN_HEIGHT) * 0.5},
		target   = {},
		rotation = 0,
		zoom     = 1,
	}
}

UpdateGameCamera :: proc(state: ^Game_State) {
	hero := LocalHero(state)
	if hero == nil {
		return
	}

	state.camera.target = hero.position
}
