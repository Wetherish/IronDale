package main

import "core:fmt"
import "entities"
import rl "vendor:raylib"

main :: proc() {
	fmt.println("\a")
	screenWidth: i32 = 800
	screenHeight: i32 = 450

	ballPosition: rl.Vector2 = {cast(f32)screenHeight / 2, cast(f32)screenWidth / 2}

	h := entities.Hero{ballPosition}
	rl.InitWindow(screenWidth, screenHeight, "test")
	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		entities.draw(h)
		entities.update(&h)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
