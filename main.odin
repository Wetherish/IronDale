package main

import "core:os"
import sc "screens"
import rl "vendor:raylib"

main :: proc() {
	screenW: i32 = 800
	screenH: i32 = 450

	sc.Debug_Enabled = HasDebugArg()

	rl.InitWindow(screenW, screenH, "hollow iron")

	mgr: sc.ScreenManager
	sc.ManagerInit(&mgr)

	sc.ManagerPush(&mgr, sc.CreateMainScreen("Main Menu"))

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		rl.BeginDrawing()
			rl.ClearBackground(rl.WHITE)
			sc.ManagerUpdate(&mgr, dt)
			sc.ManagerDraw(&mgr)
		rl.EndDrawing()
	}
	sc.ManagerDestroy(&mgr)
	rl.CloseWindow()
}

HasDebugArg :: proc() -> bool {
	for arg in os.args {
		if arg == "--debug" || arg == "-debug" {
			return true
		}
	}

	return false
}
