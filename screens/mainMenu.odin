package screens

import rl "vendor:raylib"

MenuEntry :: struct {
	label:  cstring,
	action: proc(mgr: ^ScreenManager),
}

Menu :: struct {
	entries: [3]MenuEntry,
	index:   int,
}

@(private = "file")
MAIN_MENU_PROCS := ScreenBehavior {
	Init = Init,
	Update = Update,
	Draw = Draw,
	Destroy = Destroy,
}

CreateMainMenu :: proc() -> Screen {
	d := new(Menu)
	d.entries = [3]MenuEntry {
		{label = "Start", action = StartGame},
		{label = "Debug UI", action = ToggleDebugUI},
		{label = "Quit", action = QuitGame},
	}
	d.index = 0
	return Screen{data = d, behavior = &MAIN_MENU_PROCS}
}

StartGame :: proc(mgr: ^ScreenManager) {
	ManagerPush(mgr, CreateTestScreen())
}

ToggleDebugUI :: proc(mgr: ^ScreenManager) {
	Debug_Enabled = !Debug_Enabled
}

QuitGame :: proc(mgr: ^ScreenManager) {}

@(private = "file")
Init :: proc(ptr: rawptr) {}

@(private = "file")
Draw :: proc(data: rawptr) {
	m := cast(^Menu)data
	start_y: i32 = 150

	for entry, i in m.entries {
		color := rl.BLACK

		if i == m.index {
			color = rl.RED
		}

		label := entry.label
		if entry.action == ToggleDebugUI {
			label = Debug_Enabled ? "Debug UI: On" : "Debug UI: Off"
		}

		rl.DrawText(label, 300, start_y + i32(i) * 40, 30, color)
	}
}

@(private = "file")
Update :: proc(data: rawptr, dt: f32, mgr: ^ScreenManager) {
	m := cast(^Menu)data
	if rl.IsKeyPressed(rl.KeyboardKey.UP) {
		if m.index > 0 {
			m.index -= 1
		}
	}

	if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
		if m.index < len(m.entries) - 1 {
			m.index += 1
		}
	}

	if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
		if m.entries[m.index].action != nil {
			m.entries[m.index].action(mgr)
		}
	}
}

@(private = "file")
Destroy :: proc(ptr: rawptr) {
	free(ptr)
}
