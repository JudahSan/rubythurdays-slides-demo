# =============================================================================
# scenes/menu.rb — Title screen, game-over screen, and navigation helpers
# Depends on: constants.rb, ui/button.rb, ui/retro_theme.rb,
#             helpers/rendering.rb, entities/player.rb
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Animated dragon preview (shared by title and used via draw_menu_dragon)
  # ---------------------------------------------------------------------------

  def draw_menu_dragon(args)
    frame = 0.frame_index(count: 6, hold_for: 8, repeat: true)
    bob   = (Math.sin(Kernel.tick_count / 20.0) * 10).round
    size  = touch_ui?(args) ? 160 : 220
    args.outputs.sprites << {
      x: args.grid.w - size - 40, y: 260 + bob,
      w: size, h: (size * 0.8).round,
      path: "sprites/misc/dragon-#{frame}.png",
    }
  end

  # ---------------------------------------------------------------------------
  # Title banner with neon glow
  # ---------------------------------------------------------------------------

  def draw_menu_title(args)
    cx    = args.grid.w / 2
    bar_y = args.grid.h - 170
    bar_h = 130

    draw_title_bar(args, bar_y, bar_h, BTN_AMBER)
    draw_title_glow(args, cx, bar_y + bar_h / 2, 320, BTN_AMBER)

    args.outputs.labels << with_shadow([
      { x: cx, y: bar_y + bar_h - 70,
        text: "TAKING NAMES AND MAKING GAMES",
        size_enum: fs(args, 8),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: 255, g: 210, b: 60 },
    ])
  end

  # ---------------------------------------------------------------------------
  # High-score badge
  # ---------------------------------------------------------------------------

  def draw_menu_hiscore(args)
    hs    = args.state.high_score || 0
    pulse = Math.sin(Kernel.tick_count / 40.0) * 0.4 + 0.6
    args.outputs.labels << with_shadow([
      { x: 42, y: args.grid.h - 200,
        text: "HI-SCORE",
        size_enum: fs(args, -1),
        r: 140, g: 148, b: 200 },
      { x: 42, y: args.grid.h - 240,
        text: hs.to_s.rjust(6, "0"),
        size_enum: fs(args, 9),
        r: (255 * pulse).round, g: (180 * pulse).round, b: 50 },
    ])
  end

  # ---------------------------------------------------------------------------
  # Control legend — removed from menu for minimalism.
  # ---------------------------------------------------------------------------

  def draw_menu_controls(_args); end

  # ---------------------------------------------------------------------------
  # Mute toggle helper (shared by menu and gameplay)
  # ---------------------------------------------------------------------------

  def music_muted?(args)
    args.state.music_muted == true
  end

  def toggle_mute(args)
    args.state.music_muted = !music_muted?(args)
    music = args.audio[:music]
    music.paused = args.state.music_muted if music
  end

  # ---------------------------------------------------------------------------
  # Generic menu button helper (shared by all five menu buttons)
  # ---------------------------------------------------------------------------

  def draw_menu_btn(args, rect, text, color, text_size = 3)
    down  = button_down?(args, rect)
    depth = down ? 2 : 9
    face  = down ? mix(color, 0.2, 255) : color
    base  = mix(color, 0.55, 0)
    rad   = 22
    fh    = rect.h - depth

    max_w = rect.w - 24
    char_count = [text.length, 1].max
    target_char_w = max_w.to_f / char_count
    fitted_size = if target_char_w >= 34
                    6
                  elsif target_char_w >= 28
                    5
                  elsif target_char_w >= 23
                    4
                  elsif target_char_w >= 19
                    3
                  elsif target_char_w >= 15
                    2
                  elsif target_char_w >= 12
                    1
                  elsif target_char_w >= 9
                    0
                  else
                    -1
                  end
    size = [fs(args, text_size), fitted_size].min

    s = []
    s.concat round_rect(rect.x - 4, rect.y - 4, rect.w + 8, rect.h + 8, rad + 3, [255, 255, 255], 60)
    s.concat round_rect(rect.x - 3, rect.y - 3, rect.w + 6, rect.h + 6, rad + 2, color, 70)
    s.concat round_rect(rect.x,     rect.y,      rect.w,     rect.h,     rad,     base)
    s.concat round_rect(rect.x,     rect.y + depth, rect.w,  fh,         rad,     face)
    s.concat round_rect(rect.x + 12, rect.y + depth + fh / 2,
                        rect.w - 24, fh / 2 - 8, rad - 10, mix(face, 0.55, 255), 100)
    args.outputs.sprites << s

    args.outputs.labels << with_shadow([{
      x: rect.x + rect.w / 2, y: rect.y + depth + fh / 2,
      text: text, size_enum: size,
      alignment_enum: 1, vertical_alignment_enum: 1, r: 255, g: 255, b: 255,
    }])
  end

  def draw_menu_play_button(args)
    lo    = layout(args)
    rect  = lo.menu_btn_play
    rect  = rect.merge(y: rect.y - 14, h: rect.h + 14)
    draw_menu_btn(args, rect, "\u25B6  PLAY", BTN_MINT, 6)
  end

  def draw_menu_how_to_play_button(args)
    draw_menu_btn(args, layout(args).menu_btn_how_to_play, "HOW TO PLAY", BTN_BLUE, 2)
  end

  def draw_menu_mute_button(args)
    muted = music_muted?(args)
    label = muted ? "\u{1F507}  MUTED" : "\u{1F50A}  SOUND"
    color = muted ? BTN_CORAL : BTN_AMBER
    draw_menu_btn(args, layout(args).menu_btn_mute, label, color, 2)
  end

  def draw_menu_touch_button(args)
    enabled = touch_ui?(args)
    label   = enabled ? "\u{1F4F1}  TOUCH: ON" : "\u{1F4F1}  TOUCH: OFF"
    color   = enabled ? BTN_MINT : BTN_VIOLET
    draw_menu_btn(args, layout(args).menu_btn_touch, label, color, 2)
  end

  def draw_menu_slides_button(args)
    draw_menu_btn(args, layout(args).menu_btn_slides, "SLIDES  \u25B6", BTN_VIOLET, 2)
  end

  def draw_menu_close_button(args)
    draw_menu_btn(args, layout(args).menu_btn_close, "\u2716  CLOSE", BTN_CORAL, 2)
  end

  # ---------------------------------------------------------------------------
  # title_tick
  # ---------------------------------------------------------------------------

  def title_tick(args)
    args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i
    start_menu_music(args) unless args.state.music_track == MUSIC_MENU

    music = args.audio[:music]
    music.paused = music_muted?(args) if music

    lo           = layout(args)
    just_arrived = args.state.title_arrived_at == Kernel.tick_count

    # Expand play button rect to match the drawn size
    play_rect = lo.menu_btn_play
    play_rect = play_rect.merge(y: play_rect.y - 14, h: play_rect.h + 14)

    unless just_arrived
      if button_pressed?(args, play_rect)
        play_click(args)
        begin_play(args)
        return
      end

      if button_pressed?(args, lo.menu_btn_how_to_play)
        play_click(args)
        args.state.scene = "instructions"
        return
      end

      if button_pressed?(args, lo.menu_btn_mute)
        play_click(args)
        toggle_mute(args)
      end

      if button_pressed?(args, lo.menu_btn_touch)
        play_click(args)
        args.state.touch_ui = !touch_ui?(args)
      end

      if button_pressed?(args, lo.menu_btn_close)
        play_click(args)
        args.gtk.request_quit
        return
      end

      # Keyboard / gamepad fire still works
      if fire_input?(args)
        play_click(args)
        begin_play(args)
        return
      end
    end

    draw_menu_background(args)
    draw_corner_pixels(args, BTN_AMBER)
    draw_menu_dragon(args)
    draw_menu_title(args)
    draw_menu_hiscore(args)

    # Draw all menu buttons
    draw_menu_play_button(args)
    draw_menu_how_to_play_button(args)
    draw_menu_mute_button(args)
    draw_menu_touch_button(args)
    draw_menu_slides_button(args)
    draw_menu_close_button(args)

    draw_accent_line(args, 38,                BTN_AMBER,  2, 130)
    draw_accent_line(args, args.grid.h - 172, BTN_VIOLET, 2, 120)
  end

  # ---------------------------------------------------------------------------
  # Navigation helpers
  # ---------------------------------------------------------------------------

  def slides_button_active?(args)
    args.state.scene != "gameplay" || touch_ui?(args)
  end

  def slides_button_rect(args)
    lo = layout(args)
    case args.state.scene
    when "slides"   then lo.btn_back
    when "title"    then lo.menu_btn_slides
    when "gameplay" then args.state.paused ? lo.btn_pause_slides : nil
    else                 nil
    end
  end

  def slides_button_pressed?(args)
    slides_button_active?(args) && button_pressed?(args, slides_button_rect(args))
  end

  # ---------------------------------------------------------------------------
  # begin / restart
  # ---------------------------------------------------------------------------

  def begin_play(args)
    args.outputs.sounds << "sounds/game-over.wav"
    start_gameplay_music(args)
    args.state.scene = "gameplay"
  end

  def restart_game(args)
    args.state.player           = nil
    args.state.fireballs        = nil
    args.state.targets          = nil
    args.state.explosions       = nil
    args.state.score            = nil
    args.state.timer            = nil
    args.state.saved_high_score = nil
    args.state.high_score       = nil
    args.state.paused           = false
    args.state.stick            = nil

    start_gameplay_music(args)
    args.state.scene = "gameplay"
  end

  # ---------------------------------------------------------------------------
  # game_over_tick
  # ---------------------------------------------------------------------------

  def game_over_tick(args)
    args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

    if !args.state.saved_high_score && args.state.score > args.state.high_score
      args.gtk.write_file(HIGH_SCORE_FILE, args.state.score.to_s)
      args.state.saved_high_score = true
    end

    cx    = args.grid.w / 2
    touch = touch_ui?(args)
    lo    = layout(args)

    draw_menu_background(args)
    draw_corner_pixels(args, BTN_CORAL)
    draw_scanlines(args, 30)
    draw_accent_line(args, 38, BTN_CORAL, 2, 130)

    # Game Over banner
    bar_y = args.grid.h - 170
    bar_h = 130
    draw_title_bar(args, bar_y, bar_h, BTN_CORAL)
    draw_title_glow(args, cx, bar_y + bar_h / 2, 300, BTN_CORAL)
    args.outputs.labels << with_shadow([
      { x: cx, y: bar_y + bar_h / 2 + 10,
        text: "GAME OVER",
        size_enum: fs(args, 10),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: 255, g: 80, b: 80 },
    ])

    # Score display
    new_record  = args.state.score > args.state.high_score
    score_color = new_record ? [255, 214, 80] : [200, 210, 255]

    score_labels = [
      { x: cx, y: args.grid.h - 220,
        text: "SCORE",
        size_enum: fs(args, 0),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: 140, g: 148, b: 200 },
      { x: cx, y: args.grid.h - 280,
        text: args.state.score.to_s.rjust(6, "0"),
        size_enum: fs(args, 11),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: score_color[0], g: score_color[1], b: score_color[2] },
    ]

    score_labels << if new_record
      { x: cx, y: args.grid.h - 340,
        text: "NEW HI-SCORE!",
        size_enum: fs(args, 3),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: 255, g: 214, b: 80 }
    else
      { x: cx, y: args.grid.h - 340,
        text: "HI-SCORE  #{args.state.high_score.to_s.rjust(6, '0')}",
        size_enum: fs(args, 2),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: 160, g: 168, b: 210 }
    end

    args.outputs.labels << with_shadow(score_labels)

    draw_button(args, lo.btn_game_over_restart, "\u21BB  RESTART", BTN_MINT)
    draw_button(args, lo.btn_game_over_menu,    "\u2716  MAIN MENU", BTN_AMBER)
    # draw_button(args, lo.btn_slides,            "Slides", BTN_VIOLET) if touch

    if button_pressed?(args, lo.btn_game_over_menu) || args.inputs.keyboard.key_down.q || args.inputs.keyboard.key_down.m
      play_click(args)
      exit_to_menu(args)
      return
    end

    if button_pressed?(args, lo.btn_game_over_restart) ||
       (args.state.timer < -RESTART_DELAY && (fire_input?(args) || tap_anywhere?(args)))
      play_click(args)
      restart_game(args)
      return
    end
  end

end
