package main

import sc "screens"
import rl "vendor:raylib"

main :: proc() {
	screenW: i32 = 800
	screenH: i32 = 450

	rl.InitWindow(screenW, screenH, "hollow iron")

	mgr: sc.ScreenManager
	sc.ManagerInit(&mgr)
	defer sc.ManagerDestroy(&mgr)

	sc.ManagerPush(&mgr, sc.CreateMainScreen("Main Menu"))

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		rl.BeginDrawing()
			rl.ClearBackground(rl.WHITE)
			sc.ManagerUpdate(&mgr, dt)
			sc.ManagerDraw(&mgr)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
