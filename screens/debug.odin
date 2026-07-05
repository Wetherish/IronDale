package screens

import e "../entities"
import "core:strconv"
import rl "vendor:raylib"

Debug_Enabled: bool

DebugField :: enum {
	None,
	Speed,
	Pos_X,
	Pos_Y,
}

DebugOverlay :: struct {
	visible:     bool,
	active:      DebugField,
	input:       [32]byte,
	input_len:   int,
	parse_error: bool,
}

CreateDebugOverlay :: proc(enabled: bool) -> DebugOverlay {
	return DebugOverlay {
		visible = enabled,
		active  = .None,
	}
}

DebugHero :: proc(s: ^TestScreen) -> ^e.Hero {
	for &entity in s.game.entities {
		switch &value in entity {
		case e.Hero:
			return &value
		case e.Tree:
		}
	}

	return nil
}

UpdateDebugOverlay :: proc(debug: ^DebugOverlay, hero: ^e.Hero) {
	if rl.IsKeyPressed(rl.KeyboardKey.F3) {
		debug.visible = !debug.visible
		if !debug.visible do debug.active = .None
	}

	if !debug.visible || hero == nil {
		return
	}

	if debug.active != .None {
		UpdateDebugInput(debug, hero)
		return
	}

	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		mouse := rl.GetMousePosition()
		if rl.CheckCollisionPointRec(mouse, DebugFieldRect(.Speed)) {
			BeginDebugEdit(debug, .Speed, hero.speed)
		} else if rl.CheckCollisionPointRec(mouse, DebugFieldRect(.Pos_X)) {
			BeginDebugEdit(debug, .Pos_X, hero.position.x)
		} else if rl.CheckCollisionPointRec(mouse, DebugFieldRect(.Pos_Y)) {
			BeginDebugEdit(debug, .Pos_Y, hero.position.y)
		}
	}
}

DrawDebugOverlay :: proc(debug: ^DebugOverlay, hero: ^e.Hero, entity_count: int) {
	if !debug.visible {
		return
	}

	x: f32 = 10
	y: f32 = 10
	w: f32 = 260
	h: f32 = 184

	rl.DrawRectangleRec({x, y, w, h}, {20, 24, 28, 220})
	rl.DrawRectangleLinesEx({x, y, w, h}, 1, {90, 98, 110, 255})
	rl.DrawText("DEBUG  F3", i32(x + 10), i32(y + 8), 16, rl.RAYWHITE)

	if hero == nil {
		rl.DrawText("hero: missing", i32(x + 10), i32(y + 38), 14, rl.RED)
		return
	}

	sm := hero.animator.state_machine
	rl.DrawText(rl.TextFormat("fps: %i  entities: %i", rl.GetFPS(), entity_count), i32(x + 10), i32(y + 34), 14, rl.LIGHTGRAY)
	rl.DrawText(rl.TextFormat("state: %s  prev: %s", DebugStateName(sm.current), DebugStateName(sm.previous)), i32(x + 10), i32(y + 54), 14, rl.LIGHTGRAY)
	rl.DrawText(rl.TextFormat("time in state: %.2f", sm.time_in_state), i32(x + 10), i32(y + 74), 14, rl.LIGHTGRAY)
	DrawDebugValue(debug, .Speed, "speed", hero.speed)
	DrawDebugValue(debug, .Pos_X, "pos x", hero.position.x)
	DrawDebugValue(debug, .Pos_Y, "pos y", hero.position.y)
	rl.DrawText("click value, type, Enter / Esc", i32(x + 10), i32(y + 162), 12, rl.GRAY)
}

DebugStateName :: proc(state: e.CharacterState) -> cstring {
	switch state {
	case .Idle:
		return "Idle"
	case .Walk:
		return "Walk"
	case .Fight:
		return "Fight"
	}

	return "Unknown"
}

DebugFieldRect :: proc(field: DebugField) -> rl.Rectangle {
	x: f32 = 96
	y: f32 = 96

	switch field {
	case .Speed:
		return {x, y, 92, 22}
	case .Pos_X:
		return {x, y + 26, 92, 22}
	case .Pos_Y:
		return {x, y + 52, 92, 22}
	case .None:
	}

	return {}
}

DrawDebugValue :: proc(debug: ^DebugOverlay, field: DebugField, label: cstring, value: f32) {
	rect := DebugFieldRect(field)
	label_y := i32(rect.y + 4)
	active := debug.active == field

	rl.DrawText(label, 20, label_y, 14, rl.LIGHTGRAY)
	rl.DrawRectangleRec(rect, active ? rl.WHITE : rl.LIGHTGRAY)
	rl.DrawRectangleLinesEx(rect, 1, active ? rl.YELLOW : rl.GRAY)

	if active {
		color := debug.parse_error ? rl.RED : rl.BLACK
		rl.DrawText(cstring(&debug.input[0]), i32(rect.x + 6), i32(rect.y + 4), 14, color)
	} else {
		rl.DrawText(rl.TextFormat("%.2f", value), i32(rect.x + 6), i32(rect.y + 4), 14, rl.BLACK)
	}
}

BeginDebugEdit :: proc(debug: ^DebugOverlay, field: DebugField, value: f32) {
	debug.active = field
	debug.parse_error = false
	CopyDebugValue(debug, value)
}

CopyDebugValue :: proc(debug: ^DebugOverlay, value: f32) {
	text := string(rl.TextFormat("%.2f", value))
	debug.input_len = 0

	for ch in text {
		if debug.input_len >= len(debug.input) - 1 do break
		debug.input[debug.input_len] = byte(ch)
		debug.input_len += 1
	}

	debug.input[debug.input_len] = 0
}

UpdateDebugInput :: proc(debug: ^DebugOverlay, hero: ^e.Hero) {
	if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
		debug.active = .None
		debug.parse_error = false
		return
	}

	if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
		if CommitDebugValue(debug, hero) {
			debug.active = .None
			debug.parse_error = false
		} else {
			debug.parse_error = true
		}
		return
	}

	if rl.IsKeyPressed(rl.KeyboardKey.BACKSPACE) && debug.input_len > 0 {
		debug.input_len -= 1
		debug.input[debug.input_len] = 0
		debug.parse_error = false
	}

	for {
		ch := rl.GetCharPressed()
		if ch == 0 do break

		if DebugCharAllowed(ch) && debug.input_len < len(debug.input) - 1 {
			debug.input[debug.input_len] = byte(ch)
			debug.input_len += 1
			debug.input[debug.input_len] = 0
			debug.parse_error = false
		}
	}
}

DebugCharAllowed :: proc(ch: rune) -> bool {
	return (ch >= '0' && ch <= '9') || ch == '-' || ch == '.' || ch == ','
}

CommitDebugValue :: proc(debug: ^DebugOverlay, hero: ^e.Hero) -> bool {
	text := string(debug.input[:debug.input_len])
	normalized: [32]byte

	for ch, i in text {
		normalized[i] = ch == ',' ? '.' : byte(ch)
	}

	value, ok := strconv.parse_f32(string(normalized[:debug.input_len]))
	if !ok {
		return false
	}

	switch debug.active {
	case .Speed:
		hero.speed = value
	case .Pos_X:
		hero.position.x = value
	case .Pos_Y:
		hero.position.y = value
	case .None:
		return false
	}

	return true
}
