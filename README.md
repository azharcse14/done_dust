# PhysicsTodo (Flutter)

A to-do list where finished tasks crumble into a glass jar of letters.
Flutter port of the original Jetpack Compose app, with new features on top.

## Run it

This folder contains `lib/`, `assets/` and `pubspec.yaml` only. Generate the
platform folders once, then run:

```bash
flutter create --org com.bitbytestudio --project-name physics_todo .
flutter pub get
flutter run
```

Requires Flutter 3.19 or newer. No extra Android or iOS permissions are needed.
Tilt and shake only work on a real device; on an emulator use
**⋮ → Empty the jar** instead of shaking.

## What it does

- **Letters fall into a jar.** Checking a task breaks its text into letters
  that tumble into the jar with gravity, collisions and stacking. Unchecking
  flies them back to the row, even while the list scrolls.
- **Tilt** the phone to slide the pile (accelerometer, low-pass filtered).
- **Layers by weekday.** Letters take the colour of the day they were
  finished, so the pile builds up in visible strata. The checkbox fills with
  the same colour; the header shows the key.
- **Priority is material.** Low = light, bouncy letters. Normal = sand.
  High = bold, heavy letters (2.6× mass) that shove the others aside.
- **Touch the pile.** Drag and fling a letter, or tap to knock letters around.
  Touches that miss a letter go to the list as usual.
- **Swipe a task** sideways to blow its letters off-screen (with undo).
- **Shake** to throw every finished task out of the jar into the archive
  (with undo). Reopen archived tasks from **⋮ → Archive**.
- **Sound and vibration** scale with impact speed and are throttled.
  Sounds mix with your music instead of pausing it. Both can be turned off
  in the menu.
- **Everything persists**, including where each letter came to rest.
  Positions are stored relative to the jar, so the pile survives a
  different screen size.
- **Bangla and emoji safe.** Text is split by grapheme cluster, not by
  UTF-16 unit, so vowel signs stay attached.

## Changes to the physics engine

- Ported 1:1 from `ParticleController.kt`: 8 substeps, inelastic impulses,
  tangential friction, shoulder slip, floor and wall constraints, settling.
  Constants were divided by ~2.75 because Compose used physical pixels and
  Flutter uses logical pixels.
- Collisions now go through a **uniform spatial grid** (`spatial_grid.dart`)
  instead of comparing every pair, so a pile of hundreds of letters stays
  smooth.
- Impulses and position correction are **mass-weighted**, which reduces to
  the original formulas when both masses are equal.
- **Real sleeping.** The original only skipped frames when tilt was near
  zero, which never happens with the phone upright. Now the jar sleeps after
  0.6 s of calm, the frame ticker stops entirely, and a tilt change of more
  than 0.06 wakes it.

## Project structure

```
lib/
├── main.dart                     Entry point, portrait lock, themes
├── theme.dart                    Palette, weekday strata colours, type
├── models/todo.dart              Todo + Priority
├── physics/
│   ├── particle.dart             Particle, material, task group, dust
│   ├── spatial_grid.dart         Broad-phase collision grid
│   └── particle_world.dart       Simulation, touch, wind, shake, save/restore
├── services/
│   ├── motion_sensor.dart        Tilt + shake detection
│   ├── feedback_service.dart     Haptics + sound pool
│   └── storage.dart              shared_preferences JSON store
├── state/todo_store.dart         Tasks, archive, settings (ChangeNotifier)
└── ui/
    ├── todo_screen.dart          Frame loop, actions, header, list
    ├── todo_tile.dart            Row, checkbox, swipe gesture
    ├── task_text.dart            Text with exact per-grapheme anchors
    ├── particle_layer.dart       Letter painter, jar, touch gate
    ├── task_editor_sheet.dart    Add / edit sheet
    └── archive_sheet.dart        Archive list
```

## Credits

Typeface: Bricolage Grotesque, SIL Open Font License (`assets/fonts/OFL.txt`).
Sound effects are synthesized for this project.

Licensed under the Apache License, Version 2.0, like the original.
