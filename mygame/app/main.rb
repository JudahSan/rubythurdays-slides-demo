# =============================================================================
# main.rb — Entry point and tick dispatcher
# =============================================================================
# Load order (explicit require_relative guarantees correctness regardless of
# DragonRuby's alphabetical auto-load behaviour):
#
#   1. constants.rb              — all game-wide constants
#   2. helpers/rendering.rb      — gradient, sky, clouds, hills
#   3. ui/button.rb              — primitives, buttons, text shadow,
#                                  pointer helpers, music helpers
#   4. ui/retro_theme.rb         — scanlines, starfield, title bar, etc.
#   5. entities/player.rb        — player state, movement, firing, joystick
#   6. entities/explosion.rb     — spawn, update, render explosions
#   7. systems/collision.rb      — hit detection, target spawning
#   8. systems/animation.rb      — HUD, touch controls, pause overlay
#   9. scenes/menu.rb            — title_tick, game_over_tick, nav helpers
#  10. scenes/slides.rb          — slide deck data and rendering
#  11. scenes/game.rb            — gameplay_tick, setup_state
# =============================================================================

require_relative "constants"
require_relative "helpers/rendering"
require_relative "helpers/layout"
require_relative "ui/button"
require_relative "ui/retro_theme"
require_relative "entities/player"
require_relative "entities/explosion"
require_relative "systems/collision"
require_relative "systems/animation"
require_relative "scenes/menu"
require_relative "scenes/slides"
require_relative "scenes/instructions"
require_relative "scenes/game"

module Main

  # ---------------------------------------------------------------------------
  # tick — called by DragonRuby once per frame (60 fps)
  # ---------------------------------------------------------------------------

  def tick(args)
    args.state.scene     ||= "title"
    args.state.ptrs      ||= []
    args.state.ptrs_prev ||= []
    args.state.touch_ui = true if args.state.touch_ui.nil?

    update_pointers(args)

    # M key toggles the touch-control overlay (useful for desktop testing)
    args.state.touch_ui = !touch_ui?(args) if args.inputs.keyboard.key_down.m

    # TAB or the Slides / Back button enters / exits the slide deck
    if args.inputs.keyboard.key_down.tab || slides_button_pressed?(args)
      toggle_slides(args)
    end

    # Dispatch to the active scene
    send("#{args.state.scene}_tick", args)
  end

end

$gtk.reset
