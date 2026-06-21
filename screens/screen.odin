package screens

ScreenBehavior :: struct {
	Init:    proc(screen: rawptr),
	Update:  proc(screen: rawptr, dt: f32, mgr: ^ScreenManager),
	Draw:    proc(screen: rawptr),
	Destroy: proc(screen: rawptr),
}

Screen :: struct {
	behavior:  ^ScreenBehavior,
	data:      rawptr,
}
