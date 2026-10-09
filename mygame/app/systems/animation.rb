# =============================================================================
# systems/animation.rb — HUD, touch controls, and pause overlay rendering
# All positions computed via layout(args) so landscape and portrait both work.
# Depends on: constants.rb, helpers/layout.rb, ui/button.rb, helpers/rendering.rb
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # HUD — score panel (top-left) and time panel (top-right)
  # ---------------------------------------------------------------------------

  def render_hud(args)
    lo = layout(args)
    sp = lo.score_panel
    tp = lo.time_panel
    ph = lo.hud_h

    # Score panel
    draw_panel(args, sp.x, sp.y, sp.w, ph, [255, 190, 60])
    args.outputs.labels << with_shadow([
      { x: sp.x + sp.w / 2, y: sp.y + ph - 18,
        text: "SCORE", size_enum: -1,
        alignment_enum: 1, vertical_alignment_enum: 1, r: 255, g: 206, b: 96 },
      { x: sp.x + sp.w / 2, y: sp.y + 36,
        text: args.state.score.to_s, size_enum: 9,
        alignment_enum: 1, vertical_alignment_enum: 1 },
    ])

    # Time panel
    # Time panel
    secs   = [((args.state.timer || 0) / FPS.to_f).ceil.to_i, 0].max
    low    = secs <= 5
    pulse  = low ? (Math.sin(Kernel.tick_count / 4.0) * 0.5 + 0.5) : 0.0
    accent = low ? [255, (80 + 60 * pulse).round, 80] : [90, 184, 255]
    front  = low ? { r: 255, g: (110 + 100 * (1 - pulse)).round, b: 110 } : WHITE

    draw_panel(args, tp.x, tp.y, tp.w, ph, accent)

    frac = (args.state.timer.to_f / (GAME_SECONDS * FPS)).clamp(0, 1)
    args.outputs.sprites << round_rect(tp.x + 18, tp.y + 10, tp.w - 36, 8, 4, [255, 255, 255], 40, 2)
    if frac > 0
      args.outputs.sprites << round_rect(tp.x + 18, tp.y + 10, ((tp.w - 36) * frac).round, 8, 4, accent, 255, 2)
    end

    args.outputs.labels << with_shadow([
      { x: tp.x + tp.w / 2, y: tp.y + ph - 18,
        text: "TIME", size_enum: -1,
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: accent[0], g: accent[1], b: accent[2] },
      { x: tp.x + tp.w / 2, y: tp.y + 44,
        text: secs.to_s, size_enum: 9,
        alignment_enum: 1, vertical_alignment_enum: 1 }.merge(front),
    ])
  end

  # ---------------------------------------------------------------------------
  # Touch controls — joystick, FIRE button, and Pause button
  # ---------------------------------------------------------------------------

  def render_touch_controls(args)
    return unless touch_ui?(args)

    lo   = layout(args)
    fcx  = lo.fire_cx
    fcy  = lo.fire_cy
    fr   = lo.fire_r

    # Floating joystick
    stick = args.state.stick
    shx   = lo.stick_hint_x.round
    shy   = lo.stick_hint_y.round
    sr    = lo.stick_radius

    if stick && stick.active
      kx = stick.ox + stick.dx * sr
      ky = stick.oy + stick.dy * sr
      args.outputs.sprites << disc(stick.ox, stick.oy, sr,   { r: 255, g: 255, b: 255, a: 40  })
      args.outputs.sprites << ring(stick.ox, stick.oy, sr, 5, { r: 255, g: 255, b: 255, a: 150 })
      args.outputs.sprites << disc(kx, ky, 46, { r: 20,  g: 30,  b: 80,  a: 90  })
      args.outputs.sprites << disc(kx, ky, 42, { r: 235, g: 242, b: 255, a: 210 })
      args.outputs.sprites << disc(kx - 8, ky + 9, 24, { r: 255, g: 255, b: 255, a: 120 })
    else
      args.outputs.sprites << disc(shx, shy, sr,   { r: 255, g: 255, b: 255, a: 28 })
      args.outputs.sprites << ring(shx, shy, sr, 5, { r: 255, g: 255, b: 255, a: 80 })
      args.outputs.sprites << disc(shx, shy, 42,   { r: 255, g: 255, b: 255, a: 80 })
      args.outputs.sprites << disc(shx - 8, shy + 9, 24, { r: 255, g: 255, b: 255, a: 60 })
    end

    # FIRE button
    held   = button_down?(args, lo.fire_hit)
    face_r = held ? fr - 5 : fr
    args.outputs.sprites << disc(fcx, fcy, fr + 14, { r: 255, g: 170, b: 60,  a: held ? 80 : 45 })
    args.outputs.sprites << disc(fcx, fcy, fr + 6,  { r: 130, g: 40,  b: 10,  a: 235 })
    args.outputs.sprites << disc(fcx, fcy, face_r,
                                 held ? { r: 255, g: 168, b: 60 } : { r: 255, g: 122, b: 30 })
    args.outputs.sprites << disc(fcx - 16, fcy + 22, (face_r * 0.55).round,
                                 { r: 255, g: 220, b: 140, a: 110 })
    args.outputs.sprites << ring(fcx, fcy, face_r, 4, { r: 255, g: 235, b: 190, a: 200 })
    args.outputs.labels << with_shadow([
      { x: fcx, y: fcy, text: "FIRE", size_enum: 6,
        alignment_enum: 1, vertical_alignment_enum: 1 },
    ])

    # Top-bar Pause button (centered between score and timer)
    draw_button(args, lo.btn_pause, "Pause", BTN_AMBER)
  end

  # ---------------------------------------------------------------------------
  # Pause overlay
  # ---------------------------------------------------------------------------

  def render_pause_overlay(args)
    lo = layout(args)
    cx = lo.cx

    args.outputs.sprites << {
      x: -2000, y: -2000, w: args.grid.w + 4000, h: args.grid.h + 4000,
      path: :solid, r: 4, g: 8, b: 30, a: 175,
    }

    title_y = lo.portrait? ? lo.cy + 195 : lo.cy + 115
    args.outputs.labels << with_shadow([
      { x: cx, y: title_y,
        text: "PAUSED", size_enum: fs(args, 11),
        alignment_enum: 1, vertical_alignment_enum: 1 },
    ])

    music_lbl = music_muted?(args) ? "Music OFF" : "Music ON"
    music_col = music_muted?(args) ? BTN_CORAL : BTN_AMBER

    touch_lbl = touch_ui?(args) ? "Touch UI: ON" : "Touch UI: OFF"
    touch_col = touch_ui?(args) ? BTN_MINT : BTN_VIOLET

    draw_button(args, lo.btn_resume,      "Resume Game",    BTN_MINT)
    draw_button(args, lo.btn_pause_music, music_lbl,        music_col)
    draw_button(args, lo.btn_pause_slides, "Slides",        BTN_VIOLET)
    draw_button(args, lo.btn_pause_touch, touch_lbl,        touch_col)
    draw_button(args, lo.btn_exit_menu,   "Open Main Menu", BTN_AMBER)
    draw_button(args, lo.btn_exit_game,   "Exit Game",      BTN_CORAL)
  end

end
