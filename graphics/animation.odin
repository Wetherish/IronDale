package graphics

AnimationClip :: struct {
	row:            int,
	first_frame:    int,
	frame_count:    int,
	frame_duration: f32,
	loop:           bool,
}

AnimationPlayer :: struct {
	clip:          AnimationClip,
	current_frame: int,
	timer:         f32,
	finished:      bool,
}

CreateAnimationClip :: proc(row, first_frame, frame_count: int, frame_duration: f32, loop := true) -> AnimationClip {
	return AnimationClip {
		row            = row,
		first_frame    = first_frame,
		frame_count    = frame_count,
		frame_duration = frame_duration,
		loop           = loop,
	}
}

CreateAnimationPlayer :: proc(clip: AnimationClip) -> AnimationPlayer {
	return AnimationPlayer {
		clip          = clip,
		current_frame = 0,
		timer         = 0,
		finished      = false,
	}
}

PlayAnimation :: proc(p: ^AnimationPlayer, clip: AnimationClip, restart := false) {
	if !restart && p.clip == clip {
		return
	}

	p.clip = clip
	p.current_frame = 0
	p.timer = 0
	p.finished = false
}

UpdateAnimation :: proc(p: ^AnimationPlayer, dt: f32) {
	if p.finished || p.clip.frame_count <= 1 || p.clip.frame_duration <= 0 {
		return
	}

	p.timer += dt
	for p.timer >= p.clip.frame_duration {
		p.timer -= p.clip.frame_duration

		next_frame := p.current_frame + 1
		if next_frame < p.clip.frame_count {
			p.current_frame = next_frame
		} else if p.clip.loop {
			p.current_frame = 0
		} else {
			p.current_frame = p.clip.frame_count - 1
			p.finished = true
			break
		}
	}
}

AnimationRow :: proc(p: AnimationPlayer) -> int {
	return p.clip.row
}

AnimationFrame :: proc(p: AnimationPlayer) -> int {
	return p.clip.first_frame + p.current_frame
}
