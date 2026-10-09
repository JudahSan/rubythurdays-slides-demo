# =============================================================================
# constants.rb — All game-wide constants
# Loaded first so every other file can reference these values.
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Timing
  # ---------------------------------------------------------------------------

  FPS           = 60
  GAME_SECONDS  = 30
  RESTART_DELAY = FPS / 2   # half-second grace before restart input is accepted

  # ---------------------------------------------------------------------------
  # Persistence
  # ---------------------------------------------------------------------------

  HIGH_SCORE_FILE = "high-score.txt"

  # ---------------------------------------------------------------------------
  # Targets
  # ---------------------------------------------------------------------------

  TARGET_SIZE = 64
  TARGET_GAP  = 30   # minimum gap between target bounding-circle centres

  # ---------------------------------------------------------------------------
  # Audio paths
  # ---------------------------------------------------------------------------

  MUSIC_MENU   = "music/menu.wav"
  MUSIC_BATTLE = "music/battle.wav"
  HIT_SOUND    = "sounds/hit.wav"

  # ---------------------------------------------------------------------------
  # Font
  # Optional custom font.  Set to e.g. "fonts/PressStart2P.ttf" to use it.
  # nil → DragonRuby built-in bitmap font.
  # ---------------------------------------------------------------------------

  FONT = nil

  # ---------------------------------------------------------------------------
  # Explosion animation
  # ---------------------------------------------------------------------------

  EXPLOSION_FRAMES = 7    # explosion-0.png … explosion-6.png
  EXPLOSION_HOLD   = 4    # game-frames each image is held (~0.47 s total)
  EXPLOSION_SIZE   = 150  # rendered size in logical pixels

  # ---------------------------------------------------------------------------
  # HUD
  # ---------------------------------------------------------------------------

  HUD_H = 120   # top strip height reserved for HUD; targets never spawn here

  # ---------------------------------------------------------------------------
  # Touch / mobile
  # ---------------------------------------------------------------------------

  MOBILE_FONT_BOOST = 4   # extra size_enum added on touch devices

  # ---------------------------------------------------------------------------
  # Touch-UI button layout  (1280×720 logical canvas)
  # ---------------------------------------------------------------------------

  # Top-bar gameplay buttons (≥76 px tall — stay tappable after scaling)
  BTN_PAUSE  = { x: 476, y: 640, w: 124, h: 76 }
  BTN_MUSIC  = { x: 608, y: 640, w: 124, h: 76 }
  BTN_SLIDES = { x: 740, y: 640, w: 124, h: 76 }

  # Back button on the slides screen (bottom-right corner)
  BTN_BACK = { x: 1076, y: 14, w: 170, h: 76 }

  # Prominent Slides button on the title / menu screen
  # Positioned at the bottom-left, above the "FIRE TO START" blink prompt (y:170)
  MENU_BTN_SLIDES = { x: 42, y: 230, w: 220, h: 80 }

  # How to Play button on the title screen (sits to the right of Slides)
  MENU_BTN_HOW_TO_PLAY = { x: 280, y: 230, w: 220, h: 80 }

  # Mute button on the title screen (sits to the right of How to Play)
  MENU_BTN_MUTE = { x: 518, y: 230, w: 160, h: 80 }

  # ---------------------------------------------------------------------------
  # Fire button (bottom-right touch control)
  # ---------------------------------------------------------------------------

  FIRE_CX  = 1130
  FIRE_CY  = 130
  FIRE_R   = 85
  FIRE_HIT = { x: FIRE_CX - 120, y: FIRE_CY - 120, w: 240, h: 240 }

  # ---------------------------------------------------------------------------
  # Floating joystick
  # ---------------------------------------------------------------------------

  STICK_ZONE_X     = 700   # anything left of this (and below the top bar) steers
  STICK_ZONE_MAX_Y = 620
  STICK_RADIUS     = 90
  STICK_DEADZONE   = 14
  STICK_HINT_X     = 170
  STICK_HINT_Y     = 170

  # ---------------------------------------------------------------------------
  # Button colour palette  [r, g, b]
  # ---------------------------------------------------------------------------

  BTN_AMBER  = [255, 176,  52]
  BTN_MINT   = [ 52, 205, 160]
  BTN_VIOLET = [146, 104, 255]
  BTN_CORAL  = [255,  92, 108]
  BTN_BLUE   = [ 66, 160, 255]

  # ---------------------------------------------------------------------------
  # Text rendering
  # ---------------------------------------------------------------------------

  WHITE = { r: 255, g: 255, b: 255 }

  OUTLINE_OFFSETS = [
    [-2,  0], [2,  0], [0, -2], [0, 2],
    [-2, -2], [2,  2], [-2, 2], [2, -2],
  ]

  # ---------------------------------------------------------------------------
  # Sky / environment gradient stops  [position 0..1, [r, g, b]]
  # ---------------------------------------------------------------------------

  SKY_STOPS = [
    [0.0, [ 16,  24,  78]],
    [0.5, [ 62, 100, 212]],
    [1.0, [150, 208, 246]],
  ]

  SLIDE_BG_STOPS = [
    [0.0, [12, 16, 42]],
    [1.0, [46, 22, 78]],
  ]

  MENU_BG_STOPS = [
    [0.0, [ 2,  4, 18]],
    [0.4, [ 8, 12, 48]],
    [1.0, [ 0,  2, 12]],
  ]

  # ---------------------------------------------------------------------------
  # Slide accent colours — one per section, cycled via ACCENTS[section % len]
  # ---------------------------------------------------------------------------

  ACCENTS = [
    [255,  99, 115],  # coral
    [255, 196,  72],  # amber
    [ 72, 222, 176],  # mint
    [ 90, 184, 255],  # sky
    [178, 128, 255],  # violet
    [255, 140,  70],  # orange
  ]

  # ---------------------------------------------------------------------------
  # Environment decoration data
  # ---------------------------------------------------------------------------

  CLOUDS = [
    { x: 120,  y: 590, r: 40, speed: 0.25, shade: 228 },
    { x: 520,  y: 520, r: 52, speed: 0.40, shade: 240 },
    { x: 900,  y: 620, r: 36, speed: 0.20, shade: 225 },
    { x: 1150, y: 470, r: 58, speed: 0.55, shade: 250 },
    { x: 330,  y: 410, r: 44, speed: 0.50, shade: 246 },
  ]

  # One column height per 8 px of screen width
  HILLS_BACK  = (0...160).map { |i| (150 + Math.sin(i * 0.065) * 34 + Math.sin(i * 0.19  + 1) * 12).round }
  HILLS_FRONT = (0...160).map { |i| ( 92 + Math.sin(i * 0.05  + 2) * 28 + Math.sin(i * 0.23     ) *  9).round }

  # Scrolling info ticker text (used by the retro menu)
  TICKER_TEXT = "* DRAGONRIDERS UNITE *  HIT THE TARGETS!  *  USE ARROW KEYS OR WASD  *  FIRE = Z OR J  *  SLIDES = TAB  *  "

  # Pre-computed star field for the menu background (seeded so it is stable)
  MENU_STARS = begin
    rng = Random.new(42)
    (0...80).map do
      { x:      rng.rand(1280),
        y:      rng.rand(720),
        size:   rng.rand(3) + 1,
        speed:  (rng.rand(3) + 1) * 0.15,
        bright: rng.rand(120) + 80 }
    end
  end

end
