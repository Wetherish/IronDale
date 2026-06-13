package screens

import rl "vendor:raylib"

MainScreen :: struct {
	title:     string,
	selection: int,
}

@(private = "file")
MAIN_PROCS := ScreenBehavior {
	Init    = Init,
	Update  = Update,
	Draw    = Draw,
	Destroy = Destroy,
}

CreateMainScreen :: proc(title: string) -> Screen {
	s := new(MainScreen)
	s.title = title
	s.selection = 0
	return Screen{behavior = &MAIN_PROCS, data = s}
}

@(private = "file")
Init :: proc(raw: rawptr) {}

@(private = "file")
Update :: proc(raw: rawptr, dt: f32, mgr: ^ScreenManager) {
	if rl.IsKeyPressed(rl.KeyboardKey.ENTER) do ManagerPush(mgr, CreateMainMenu())
}

@(private = "file")
Draw :: proc(raw: rawptr) {
	rl.DrawText("Press enter to continue", 260, 210, 20, rl.RED)
}

@(private = "file")
Destroy :: proc(raw: rawptr) {
	free(raw)
}
