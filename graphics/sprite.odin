package graphics

import rl "vendor:raylib"

Sprite :: struct {
	texture: rl.Texture2D,
	width:   f32,
	height:  f32,
}

CreateSprite :: proc(path: cstring, width, height: f32) -> Sprite {
	return Sprite {
		texture = rl.LoadTexture(path),
		width   = width,
		height  = height,
	}
}

DestroySprite :: proc(s: ^Sprite) {
	if SpriteValid(s^) {
		rl.UnloadTexture(s.texture)
	}
	s.texture = {}
}

SpriteValid :: proc(s: Sprite) -> bool {
	return rl.IsTextureValid(s.texture)
}

DrawSprite :: proc(s: Sprite, row, col: int, position: rl.Vector2, flip_x := false) {
	if !SpriteValid(s) {
		return
	}

	width := s.width
	if flip_x {
		width = -width
	}

	source := rl.Rectangle {
		x      = f32(col) * s.width,
		y      = f32(row) * s.height,
		width  = width,
		height = s.height,
	}

	rl.DrawTextureRec(s.texture, source, position, rl.WHITE)
}
