package screens

import e "../entities"
import "core:testing"

@(test)
debug_overlay_starts_visible_when_enabled :: proc(t: ^testing.T) {
	debug := CreateDebugOverlay(true)

	testing.expect_value(t, debug.visible, true)
	testing.expect_value(t, debug.active, DebugField.None)
	testing.expect_value(t, debug.parse_error, false)
}

@(test)
debug_overlay_starts_hidden_when_disabled :: proc(t: ^testing.T) {
	debug := CreateDebugOverlay(false)

	testing.expect_value(t, debug.visible, false)
	testing.expect_value(t, debug.active, DebugField.None)
}

@(test)
debug_input_accepts_numeric_characters :: proc(t: ^testing.T) {
	testing.expect(t, DebugCharAllowed('0'))
	testing.expect(t, DebugCharAllowed('9'))
	testing.expect(t, DebugCharAllowed('-'))
	testing.expect(t, DebugCharAllowed('.'))
	testing.expect(t, DebugCharAllowed(','))
	testing.expect(t, !DebugCharAllowed('a'))
	testing.expect(t, !DebugCharAllowed('/'))
}

@(test)
debug_commit_updates_hero_values :: proc(t: ^testing.T) {
	hero := e.Entity {
		position = {10, 20},
		data     = e.Hero {
			speed = 140,
		},
	}
	heroData := e.EntityGet(&hero, e.Hero)

	debug := CreateDebugOverlay(true)

	SetDebugTestInput(&debug, "220.5")
	debug.active = .Speed
	testing.expect(t, CommitDebugValue(&debug, &hero))
	testing.expect_value(t, heroData.speed, f32(220.5))

	SetDebugTestInput(&debug, "-12,25")
	debug.active = .Pos_X
	testing.expect(t, CommitDebugValue(&debug, &hero))
	testing.expect_value(t, hero.position.x, f32(-12.25))

	SetDebugTestInput(&debug, "64")
	debug.active = .Pos_Y
	testing.expect(t, CommitDebugValue(&debug, &hero))
	testing.expect_value(t, hero.position.y, f32(64))
}

@(test)
debug_commit_rejects_invalid_or_inactive_input :: proc(t: ^testing.T) {
	hero := e.Entity {
		position = {10, 20},
		data     = e.Hero {
			speed = 140,
		},
	}
	heroData := e.EntityGet(&hero, e.Hero)

	debug := CreateDebugOverlay(true)

	SetDebugTestInput(&debug, "abc")
	debug.active = .Speed
	testing.expect(t, !CommitDebugValue(&debug, &hero))
	testing.expect_value(t, heroData.speed, f32(140))

	SetDebugTestInput(&debug, "55")
	debug.active = .None
	testing.expect(t, !CommitDebugValue(&debug, &hero))
	testing.expect_value(t, heroData.speed, f32(140))
}

SetDebugTestInput :: proc(debug: ^DebugOverlay, text: string) {
	debug.input_len = 0
	debug.parse_error = false

	for ch in text {
		if debug.input_len >= len(debug.input) - 1 do break
		debug.input[debug.input_len] = byte(ch)
		debug.input_len += 1
	}

	debug.input[debug.input_len] = 0
}
