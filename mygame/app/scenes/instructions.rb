# =============================================================================
# scenes/instructions.rb — How to Play screen
# Layout is fully dynamic via layout(args) — works in both landscape and portrait.
# Depends on: constants.rb, helpers/layout.rb, ui/button.rb, ui/retro_theme.rb,
#             helpers/rendering.rb
# =============================================================================

module Main

  HOW_TO_PLAY = [
    "Pilot your dragon across the sky.",
    "Fire at targets to score points.",
    "You have #{GAME_SECONDS} seconds — hit as many as you can.",
    "Each hit spawns a fresh target immediately.",
    "Your best score is saved between sessions.",
  ]

  CONTROLS_KB = [
    ["MOVE",       "Arrow Keys  /  WASD  /  Left Stick"],
    ["FIRE",       "Z  /  J  /  Gamepad A"],
    ["PAUSE",      "Enter  /  Esc  /  Gamepad Start"],
    ["MUSIC",      "P  \u2014  toggle music on/off"],
    ["TOUCH MODE", "M  \u2014  toggle touch UI on/off"],
    ["MAIN MENU",  "Q  \u2014  return to main menu"],
  ]

  CONTROLS_TOUCH = [
    ["MOVE",  "Drag left side of screen"],
    ["FIRE",  "FIRE button (bottom-right)"],
    ["PAUSE", "Pause button (top bar)"],
    ["MUSIC", "Music ON/OFF button (top bar)"],
    ["MENU",  "Main Menu button (pause & game over)"],
  ]

  SLIDES_NAV_KB = [
    ["NEXT SLIDE",  "Right Arrow  /  Space  /  Page Down"],
    ["PREV SLIDE",  "Left Arrow  /  Page Up"],
    ["OPEN SLIDES", "Tab  /  Slides button (menu)"],
    ["BACK",        "Back button \u2014 returns to main menu"],
  ]

  SLIDES_NAV_TOUCH = [
    ["NEXT SLIDE",  "Tap right two-thirds of screen"],
    ["PREV SLIDE",  "Tap left third of screen"],
    ["OPEN SLIDES", "Slides button (top bar in game)"],
    ["BACK",        "Back button \u2014 returns to main menu"],
  ]

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def instr_heading(args, x, y, text, color)
    # Label at y (baseline). Accent bar at y - 32, clear of glyphs above
    # and the first content row below.
    args.outputs.labels << with_shadow([
      { x: x, y: y, text: text,
        size_enum: fs(args, 1),
        r: color[0], g: color[1], b: color[2] },
    ])
    args.outputs.sprites << {
      x: x, y: y - 32, w: 110, h: 3, path: :solid,
      r: color[0], g: color[1], b: color[2],
    }
  end

  def instr_bullet(args, x, y, text, color = [220, 228, 255])
    args.outputs.labels << with_shadow([
      { x: x, y: y, text: text,
        size_enum: fs(args, 0),
        r: color[0], g: color[1], b: color[2] },
    ])
  end

  # ---------------------------------------------------------------------------
  # instructions_tick
  # ---------------------------------------------------------------------------

  def instructions_tick(args)
    touch = touch_ui?(args)
    lo    = layout(args)
    rh    = touch ? lo.instr_row_h_t : lo.instr_row_h
    back  = lo.btn_back

    # ------------------------------------------------------------------
    # Background
    # ------------------------------------------------------------------
    draw_gradient(args, SLIDE_BG_STOPS, 24)

    args.outputs.sprites << {
      x: 0, y: 0, w: 14, h: args.grid.h,
      path: :solid,
      r: BTN_MINT[0], g: BTN_MINT[1], b: BTN_MINT[2],
    }

    args.outputs.sprites << disc(lo.w - 80, lo.h - 40, 260,
                                 { r: BTN_MINT[0], g: BTN_MINT[1], b: BTN_MINT[2], a: 14 }, 14)

    # ------------------------------------------------------------------
    # Title bar
    # ------------------------------------------------------------------
    draw_title_bar(args, lo.instr_title_top, lo.h - lo.instr_title_top, BTN_MINT)
    draw_title_glow(args, lo.cx, lo.h - 45, 180, BTN_MINT)
    args.outputs.labels << with_shadow([
      { x: lo.cx, y: lo.h - 38,
        text: "HOW TO PLAY",
        size_enum: fs(args, 6),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: BTN_MINT[0], g: BTN_MINT[1], b: BTN_MINT[2] },
    ])

    # ------------------------------------------------------------------
    # LEFT COLUMN — Objective
    # ------------------------------------------------------------------
    left_x = lo.instr_left_x + lo.instr_indent
    left_y = lo.instr_content_top

    instr_heading(args, left_x, left_y, "OBJECTIVE", BTN_MINT)
    left_y -= lo.instr_heading_h

    HOW_TO_PLAY.each do |line|
      instr_bullet(args, left_x + 10, left_y, line)
      left_y -= rh
    end

    # ------------------------------------------------------------------
    # RIGHT COLUMN — Controls + Slides Navigation
    # Portrait: stacked below Objective; Landscape: side by side
    # ------------------------------------------------------------------
    right_x    = lo.instr_right_x + lo.instr_indent
    right_y    = lo.portrait? ? left_y - 20 : lo.instr_content_top
    controls   = touch ? CONTROLS_TOUCH   : CONTROLS_KB
    slides_nav = touch ? SLIDES_NAV_TOUCH : SLIDES_NAV_KB
    label_x    = right_x
    value_x    = right_x + 160

    instr_heading(args, label_x, right_y, "CONTROLS", BTN_AMBER)
    right_y -= lo.instr_heading_h

    controls.each do |action, keys|
      args.outputs.labels << with_shadow([
        { x: label_x, y: right_y, text: action,
          size_enum: fs(args, 0),
          r: BTN_AMBER[0], g: BTN_AMBER[1], b: BTN_AMBER[2] },
      ])
      args.outputs.labels << with_shadow([
        { x: value_x, y: right_y, text: keys,
          size_enum: fs(args, 0),
          r: 220, g: 228, b: 255 },
      ])
      right_y -= rh
    end

    right_y -= 10
    instr_heading(args, label_x, right_y, "SLIDES", BTN_VIOLET)
    right_y -= lo.instr_heading_h

    slides_nav.each do |action, keys|
      args.outputs.labels << with_shadow([
        { x: label_x, y: right_y, text: action,
          size_enum: fs(args, 0),
          r: BTN_VIOLET[0], g: BTN_VIOLET[1], b: BTN_VIOLET[2] },
      ])
      args.outputs.labels << with_shadow([
        { x: value_x, y: right_y, text: keys,
          size_enum: fs(args, 0),
          r: 220, g: 228, b: 255 },
      ])
      right_y -= rh
    end

    # ------------------------------------------------------------------
    # Column divider (landscape only)
    # ------------------------------------------------------------------
    unless lo.portrait?
      args.outputs.sprites << {
        x: lo.instr_right_x - 20, y: lo.instr_footer_top + 10,
        w: 2, h: lo.instr_content_top - lo.instr_footer_top - 10,
        path: :solid, r: 255, g: 255, b: 255, a: 20,
      }
    end

    # ------------------------------------------------------------------
    # Footer
    # ------------------------------------------------------------------
    args.outputs.sprites << {
      x: 0, y: lo.instr_footer_top, w: args.grid.w, h: 2,
      path: :solid, r: 255, g: 255, b: 255, a: 22,
    }

    draw_button(args, back, "Back", BTN_CORAL)

    mid = back.y + back.h / 2
    args.outputs.labels << {
      x: lo.instr_left_x + lo.instr_indent, y: mid,
      text: touch ? "Tap Back to return to menu" : "Esc  \u2014  return to menu",
      size_enum: fs(args, 0), vertical_alignment_enum: 1,
      r: 130, g: 135, b: 165,
    }

    # ------------------------------------------------------------------
    # Navigation
    # ------------------------------------------------------------------
    if args.inputs.keyboard.key_down.escape || button_pressed?(args, back)
      play_click(args)
      args.state.scene = "title"
    end
  end

end
