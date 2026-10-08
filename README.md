# Nairuby 2D Gamedev

A small 2D game built with [DragonRuby GTK](https://dragonruby.org), with the talk's slide deck built into the game itself. Play the demo, press **Tab**, and you're back in the slides, with no switching between apps.

You are a dragon. Shoot fireballs at the targets before the 30 seconds run out and beat your high score.

## Run it

1. Install [DragonRuby GTK](https://dragonruby.org).
2. Put this project in your DragonRuby `mygame/` folder (or use it as your game folder).
3. Start the engine:

```bash
./dragonruby mygame
```

Saving a file while the game is running hot-reloads it, so slides and code can be edited live.

## Controls

| Action | Keys |
| --- | --- |
| Move | Arrows or WASD (gamepad works too) |
| Fire / select | Z or J (gamepad A) |
| Pause | Enter (gamepad Start) |
| Toggle music | P |
| Switch game and slides | Tab |

**Slides:** Left/Right, Space, or PageUp/PageDown to change slides.

## Project layout

```
app/main.rb      game scenes (title, gameplay, game over) and the slides
sprites/         dragon, fireball, and target art
sounds/          music and sound effects
fonts/           Press Start 2P (pixel font)
```

## How the slides work

The game uses a scene dispatcher: `tick` calls `"#{scene}_tick"`. Slides are just another scene (`slides_tick`) driven by the `SLIDES` array in `app/main.rb`. Tab saves the current scene, switches to slides, and returns to it on the next press. A round in progress is paused while you present.

## References

- [DragonRuby GTK documentation](https://docs.dragonruby.org)
- [Building Games with DragonRuby](https://dragonridersunite.itch.io/dragonruby-book) by Brett Chalupa and the Dragon Riders community. The game demo follows the book's dragon shoot 'em up, extended with a pixel-font menu, pausing, and the built-in slide deck.

## Credits

- Engine: [DragonRuby GTK](https://dragonruby.org)
- Font: [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P) (SIL Open Font License)
- Made by Judahsan
