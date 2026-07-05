package screens

import game "../game"

TestScreen :: struct {
	game:  game.Game_State,
	debug: DebugOverlay,
}

@(private = "file")
MAIN_PROCS := ScreenBehavior {
	Init    = Init,
	Update  = Update,
	Draw    = Draw,
	Destroy = Destroy,
}

CreateTestScreen :: proc() -> Screen {
	s := new(TestScreen)
	s.game = game.CreateGameState()
	s.debug = CreateDebugOverlay(Debug_Enabled)
	return Screen{behavior = &MAIN_PROCS, data = s}
}

@(private = "file")
Init :: proc(raw: rawptr) {}

@(private = "file")
Destroy :: proc(raw: rawptr) {
	s := cast(^TestScreen)raw
	game.DestroyGameState(&s.game)
	free(raw)
}

@(private = "file")
Update :: proc(raw: rawptr, dt: f32, mgr: ^ScreenManager) {
	s := cast(^TestScreen)raw
	game.UpdateGameState(&s.game, dt)
	UpdateDebugOverlay(&s.debug, DebugHero(s))
}

@(private = "file")
Draw :: proc(raw: rawptr) {
	s := cast(^TestScreen)raw
	game.DrawGameState(&s.game)
	DrawDebugOverlay(&s.debug, DebugHero(s), len(s.game.entities))
}
