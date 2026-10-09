# =============================================================================
# entities/explosion.rb — Explosion spawn, aging, and rendering
# Depends on: constants.rb, ui/button.rb  (with_shadow, fs)
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Spawn
  # ---------------------------------------------------------------------------

  # Creates a new explosion centred on the target that was just hit.
  def spawn_explosion(args, target)
    args.state.explosions ||= []
    args.state.explosions << {
      cx:  target.x + target.w / 2,
      cy:  target.y + target.h / 2,
      age: 0,
    }
  end

  # ---------------------------------------------------------------------------
  # Update
  # ---------------------------------------------------------------------------

  # Ages every live explosion by one frame and removes finished ones.
  # Should NOT be called while the game is paused.
  def update_explosions(args)
    args.state.explosions ||= []
    args.state.explosions.each    { |e| e[:age] += 1 }
    args.state.explosions.reject! { |e| e[:age] >= EXPLOSION_FRAMES * EXPLOSION_HOLD }
  end

  # ---------------------------------------------------------------------------
  # Render
  # ---------------------------------------------------------------------------

  # Draws all live explosions and their floating "+1" score pop.
  # Called from render() during active gameplay AND from gameplay_tick() during
  # game-over so the last explosion triggered before time runs out is visible.
  def render_explosions(args)
    return unless args.state.explosions && !args.state.explosions.empty?

    total   = EXPLOSION_FRAMES * EXPLOSION_HOLD
    sprites = []
    labels  = []

    args.state.explosions.each do |e|
      frame = (e[:age] / EXPLOSION_HOLD).clamp(0, EXPLOSION_FRAMES - 1)

      sprites << {
        x:    e[:cx] - EXPLOSION_SIZE / 2,
        y:    e[:cy] - EXPLOSION_SIZE / 2,
        w:    EXPLOSION_SIZE,
        h:    EXPLOSION_SIZE,
        path: "sprites/misc/explosion-#{frame}.png",
      }

      # Floating "+1" that rises and fades over the explosion lifetime
      t = e[:age].to_f / total
      labels << {
        x: e[:cx], y: e[:cy] + 36 + e[:age] * 1.6,
        text: "+1",
        size_enum: fs(args, 5),
        alignment_enum: 1, vertical_alignment_enum: 1,
        r: 255, g: 226, b: 90, a: (255 * (1 - t)).round,
      }
    end

    args.outputs.sprites << sprites
    args.outputs.labels  << with_shadow(labels)
  end

end
