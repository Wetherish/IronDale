package screens

ScreenManager :: struct {
	stack:   [dynamic]Screen,
	pending: Maybe(Screen),
	action:  ScreenAction,
}

ScreenAction :: enum {
	None,
	Push,
	Pop,
	Replace,
}

ManagerInit :: proc(m: ^ScreenManager) {
	m.stack = make([dynamic]Screen)
	m.action = .None
}

ManagerDestroy :: proc(m: ^ScreenManager) {
	for screen in m.stack {
		screen.behavior.Destroy(screen.data)
	}
	delete(m.stack)
}

ManagerPush :: proc(m: ^ScreenManager, screen: Screen) {
	m.pending = screen
	m.action = .Push
}

ManagerPop :: proc(m: ^ScreenManager) {
	m.action = .Pop
}

ManagerReplace :: proc(m: ^ScreenManager, screen: Screen) {
	m.action = .Replace
	m.pending = screen
}

ManagerTransform :: proc(m: ^ScreenManager) {
	switch m.action {
	case .Push:
		screen, ok := m.pending.?
		if ok do append(&m.stack, screen)
	case .Pop:
		if len(m.stack) > 0 {
			screen := pop(&m.stack)
			screen.behavior.Destroy(screen.data)
		}
	case .Replace:
		if len(m.stack) > 0 {
			screen := pop(&m.stack)
			screen.behavior.Destroy(screen.data)
		}
		screen, ok := m.pending.?
		if ok do append(&m.stack, screen)
	case .None:
	}

	m.pending = nil
	m.action = .None
}

ManagerDraw :: proc(m: ^ScreenManager) {
	if len(m.stack) > 0 {
		top := m.stack[len(m.stack) - 1]
		top.behavior.Draw(top.data)
	}
}

ManagerUpdate :: proc(m: ^ScreenManager, dt: f32) {
	ManagerTransform(m)
	if len(m.stack) > 0 {
		top := m.stack[len(m.stack) - 1]
		top.behavior.Update(top.data, dt, m)
	}
}
