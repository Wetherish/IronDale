package screens

import e "../entities"

TestScreen :: struct
{
    entities: [dynamic]e.Entity,
}

@(private = "file")
MAIN_PROCS := ScreenBehavior {
	Init    = Init,
	Update  = Update,
	Draw    = Draw,
	Destroy = Destroy,
}

CreateTestScreen :: proc() -> Screen {
	s := new(TestScreen)
    s.entities = make([dynamic]e.Entity)
    append(&s.entities, e.CreateHeroEntity({100, 100}, 140))
    append(&s.entities, e.CreateTreeEntity({250, 160}))
	return Screen{behavior = &MAIN_PROCS, data = s}
}

@(private = "file")
Init :: proc(raw: rawptr) {}

@(private = "file")
Destroy :: proc(raw: rawptr) {
	s := cast(^TestScreen)raw
	delete(s.entities)
	free(raw)
}

@(private = "file")
Update :: proc(raw: rawptr, dt: f32, mgr: ^ScreenManager) {
	s := cast(^TestScreen)raw
    for &entity in s.entities {
        e.Update(&entity, dt)
    }
}

@(private = "file")
Draw :: proc(raw: rawptr) {
    s := cast(^TestScreen)raw
    for entity in s.entities {
        e.Draw(entity)
    }
}
