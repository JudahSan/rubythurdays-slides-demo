# Nairuby 2D Gamedev

A small 2D game built with [DragonRuby GTK](https://dragonruby.org), with the talk's slide deck built into the game itself. Play the demo, press **Tab**, and you're back in the slides, with no switching between apps.

You are a dragon. Shoot fireballs at the targets before the 30 seconds run out and beat your high score.

## Run it

1. Install [DragonRuby GTK](https://dragonruby.org).
2. Put this project in your DragonRuby `mygame/` folder (or use it as your game folder).
3. Start the engine:

```bash
./dragonruby
```

Saving a file while the game is running hot-reloads it, so slides and code can be edited live.

## Packaging

To package the game for distribution:

```bash
./dragonruby-publish --only-package
```

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

## References & Resources

Resources used for preparing the slides and the talk (with the DragonRuby book used as the follow-along for the demo):

### Blogs & Articles

- [History of Game engines](https://dev.to/ispmanager/the-history-of-game-engines-from-assembly-coding-to-photorealism-and-ai-d9h)
- [Spiiin’s Blog — Game Development: History, Industry, and Engine Design](https://spiiin.github.io/blog/490626496/)
- [Africa Game report](https://africagamesreport.com/)
- [Designing through play: an iterative approach](https://getcreativetoday.com/designing-through-play-an-iterative-approach/)
- [Berklee Online (Take Note) — Video Game Design and the Playcentric Approach](https://online.berklee.edu/takenote/video-game-design-and-the-playcentric-approach/)
- [Games User Research — Richard Lemarchand: Playtesting and a Playful Production Process](https://gamesuserresearch.com/richard-lemarchand-playtesting-and-a-playful-production-process/)
- [3dsense Media School Blog — Game Development Pipeline Explained: From Concept to Release](https://3dsense.net/blogs/the-game-design-pipeline-from-concept-to-release)

### Books & Documentation

- [DragonRuby GTK documentation](https://docs.dragonruby.org)
- [Building Games with DragonRuby (v1.2)](https://book.dragonriders.community/) by Brett Chalupa and the Dragon Riders community (follow along for the demo; also on [itch.io](https://dragonridersunite.itch.io/dragonruby-book))
- [A Playful Production Process: For Game Designers (and Everyone)](https://mitpress.mit.edu/9780262045513/a-playful-production-process/)
- [Game Design Workshop: A Playcentric Approach to Creating Innovative Games (5th Edition)](https://ndl.ethernet.edu.et/bitstreams/2b275efd-7d3e-4a7b-a6e9-ad920787dc6e/download)

## Asset & Music Resources

- [High Quality 16-Bit Music](https://hydrogene.itch.io/high-quality-16-bit-music) by Hydrogene
- [Brackeys Platformer Bundle](https://brackeysgames.itch.io/brackeys-platformer-bundle) by Brackeys
- [Free 25 Fantasy RPG Game Tracks Vol. 2](https://alkakrab.itch.io/free-25-fantasy-rpg-game-tracks-no-copyright-vol-2) by AlkaKrab
- [Free Game Sound Effects](https://mixkit.co/free-sound-effects/game/) by Mixkit

## Credits

- Engine: [DragonRuby GTK](https://dragonruby.org)
- Font: [Press Start 2P](https://fonts.google.com/specimen/Press+Start+2P) (SIL Open Font License)
- Made by Judahsan
