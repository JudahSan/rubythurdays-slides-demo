# =============================================================================
# scenes/game.rb — Gameplay tick: state setup, pause, game-over delegation,
#                  fireball/explosion/render orchestration
# Depends on: constants.rb, ui/button.rb, helpers/rendering.rb,
#             entities/player.rb, entities/explosion.rb,
#             systems/collision.rb, systems/animation.rb,
#             scenes/menu.rb  (game_over_tick)
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Pause input
  # ---------------------------------------------------------------------------

  def pause_input?(args)
    return true if args.inputs.keyboard.key_down.enter ||
                   args.inputs.keyboard.key_down.escape ||
                   args.inputs.controller_one.key_down.start
    button_pressed?(args, layout(args).btn_pause)
  end

  # ---------------------------------------------------------------------------
  # State initialisation
  # ---------------------------------------------------------------------------

  def setup_state(args)
    init_player(args)                       # entities/player.rb

    args.state.fireballs  ||= []
    args.state.explosions ||= []
    args.state.score      ||= 0
    args.state.timer      ||= GAME_SECONDS * FPS
    args.state.paused     ||= false

    return if args.state.targets

    args.state.targets = []
    5.times { args.state.targets << spawn_target(args, args.state.targets) }
  end

  # ---------------------------------------------------------------------------
  # Music toggle  (P key or Music button)
  # ---------------------------------------------------------------------------

  def handle_music_toggle(args)
    music = args.audio[:music]
    return unless music
    if args.inputs.keyboard.key_down.p
      play_click(args)
      toggle_mute(args)
    end
  end

  def handle_pause(args)
    return if game_over?(args)
    return unless pause_input?(args)

    play_click(args)
    args.state.paused = !args.state.paused
    args.state.stick  = nil

    music = args.audio[:music]
    music.paused = args.state.paused if music
  end

  # ---------------------------------------------------------------------------
  # Exit to main menu — resets the current session completely
  # ---------------------------------------------------------------------------

  def exit_to_menu(args)
    # Stop music immediately
    music = args.audio[:music]
    music.paused = true if music

    # Wipe all gameplay state so the next play starts fresh
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

    args.state.scene = "title"
  end

  # ---------------------------------------------------------------------------
  # Game-over predicate
  # ---------------------------------------------------------------------------

  def game_over?(args)
    args.state.timer && args.state.timer < 0
  end

  # ---------------------------------------------------------------------------
  # Full-scene render  (active gameplay only — not called during game-over)
  # ---------------------------------------------------------------------------

  def render(args)
    args.outputs.sprites << [args.state.player, args.state.fireballs, args.state.targets]
    #render_explosions(args)    # entities/explosion.rb
    render_hud(args)           # systems/animation.rb
    render_touch_controls(args)
  end

  # ---------------------------------------------------------------------------
  # gameplay_tick — main scene entry point
  # ---------------------------------------------------------------------------

  def gameplay_tick(args)
    draw_sky(args)
    setup_state(args)

    if args.state.paused
      lo = layout(args)

      if button_pressed?(args, lo.btn_resume) ||
         args.inputs.keyboard.key_down.enter ||
         args.inputs.keyboard.key_down.escape ||
         args.inputs.controller_one.key_down.start
        play_click(args)
        args.state.paused = false
        return
      end

      if button_pressed?(args, lo.btn_pause_music) || args.inputs.keyboard.key_down.p
        play_click(args)
        toggle_mute(args)
        return
      end

      if button_pressed?(args, lo.btn_pause_slides) || args.inputs.keyboard.key_down.tab
        play_click(args)
        toggle_slides(args)
        return
      end

      if button_pressed?(args, lo.btn_exit_menu) || args.inputs.keyboard.key_down.q
        play_click(args)
        exit_to_menu(args)
        return
      end

      if button_pressed?(args, lo.btn_exit_game)
        play_click(args)
        args.gtk.request_quit
        return
      end

      if button_pressed?(args, lo.btn_pause_touch) || args.inputs.keyboard.key_down.m
        play_click(args)
        args.state.touch_ui = !touch_ui?(args)
        return
      end

      render(args)
      render_pause_overlay(args)
      return
    end

    handle_pause(args)

    if args.state.paused
      render(args)
      render_pause_overlay(args)
      return
    end

    args.state.timer -= 1

    if args.state.timer == 0
      args.audio[:music].paused = true if args.audio[:music]
      args.outputs.sounds << "sounds/game-over.wav"
    end

    if args.state.timer < 0
      # Age and render any in-flight explosions so the last kill's
      # animation is visible during game-over (game_over_tick skips render).
      update_explosions(args)
      render_explosions(args)
      game_over_tick(args)
      return
    end

    handle_music_toggle(args)
    update_stick(args) if touch_ui?(args)
    handle_player_movement(args)
    handle_fire(args)
    update_fireballs(args)
    update_explosions(args)
    render(args)
  end

end
