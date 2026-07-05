package entities

import gr "../graphics"

StateMachine :: struct($State: typeid) {
	current:       State,
	previous:      State,
	time_in_state: f32,
}

CreateStateMachine :: proc(initial_state: $State) -> StateMachine(State) {
	return StateMachine(State) {
		current       = initial_state,
		previous      = initial_state,
		time_in_state = 0,
	}
}

SetState :: proc(sm: ^StateMachine($State), next_state: State) -> bool {
	if sm.current == next_state {
		return false
	}

	sm.previous = sm.current
	sm.current = next_state
	sm.time_in_state = 0
	return true
}

UpdateStateMachine :: proc(sm: ^StateMachine($State), dt: f32) {
	sm.time_in_state += dt
}

CharacterState :: enum {
	Idle,
	Walk,
	Fight,
}

CharacterStateMachine :: StateMachine(CharacterState)

CreateCharacterStateMachine :: proc(initial_state := CharacterState.Idle) -> CharacterStateMachine {
	return CreateStateMachine(initial_state)
}

SetCharacterState :: proc(sm: ^CharacterStateMachine, next_state: CharacterState) -> bool {
	return SetState(sm, next_state)
}

UpdateCharacterStateMachine :: proc(sm: ^CharacterStateMachine, dt: f32) {
	UpdateStateMachine(sm, dt)
}

CharacterAnimationSet :: struct {
	idle:  gr.AnimationClip,
	walk:  gr.AnimationClip,
	fight: gr.AnimationClip,
}

CharacterAnimator :: struct {
	state_machine: CharacterStateMachine,
	animations:    CharacterAnimationSet,
	player:        gr.AnimationPlayer,
}

AnimationForCharacterState :: proc(animations: CharacterAnimationSet, state: CharacterState) -> gr.AnimationClip {
	switch state {
	case .Idle:
		return animations.idle
	case .Walk:
		return animations.walk
	case .Fight:
		return animations.fight
	}

	return animations.idle
}

CreateCharacterAnimator :: proc(
	animations: CharacterAnimationSet,
	initial_state := CharacterState.Idle,
) -> CharacterAnimator {
	return CharacterAnimator {
		state_machine = CreateCharacterStateMachine(initial_state),
		animations    = animations,
		player        = gr.CreateAnimationPlayer(AnimationForCharacterState(animations, initial_state)),
	}
}

SetCharacterAnimatorState :: proc(animator: ^CharacterAnimator, next_state: CharacterState) -> bool {
	state_changed := SetCharacterState(&animator.state_machine, next_state)
	gr.PlayAnimation(
		&animator.player,
		AnimationForCharacterState(animator.animations, animator.state_machine.current),
		state_changed,
	)
	return state_changed
}

UpdateCharacterAnimator :: proc(animator: ^CharacterAnimator, dt: f32) {
	gr.UpdateAnimation(&animator.player, dt)
	UpdateCharacterStateMachine(&animator.state_machine, dt)
}

CharacterAnimationRow :: proc(animator: CharacterAnimator) -> int {
	return gr.AnimationRow(animator.player)
}

CharacterAnimationFrame :: proc(animator: CharacterAnimator) -> int {
	return gr.AnimationFrame(animator.player)
}
