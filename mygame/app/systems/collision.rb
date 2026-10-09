# =============================================================================
# systems/collision.rb — Hit detection, target spawning, fireball updates
# Depends on: constants.rb, helpers/layout.rb, ui/button.rb, entities/explosion.rb
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Geometry
  # ---------------------------------------------------------------------------

  def circle_overlap?(a, b, gap = 0)
    ar = a.w / 2
    br = b.w / 2
    dx = (a.x + ar) - (b.x + br)
    dy = (a.y + ar) - (b.y + br)
    dx * dx + dy * dy < (ar + br + gap) ** 2
  end

  # ---------------------------------------------------------------------------
  # Target placement guard
  # ---------------------------------------------------------------------------

  def under_touch_controls?(args, c)
    lo = layout(args)
    return true if c.y + c.h > lo.hud_py - 10

    return false unless touch_ui?(args)

    fh = lo.fire_hit
    return true if c.x + c.w > fh.x - 10 && c.y < fh.y + fh.h + 10
    return true if c.x < lo.stick_zone_x + 10 && c.y < lo.stick_hint_y + lo.stick_radius + 10

    false
  end

  # ---------------------------------------------------------------------------
  # Target spawning — uses layout so spawn area adapts to canvas size
  # ---------------------------------------------------------------------------

  def spawn_target(args, existing = [])
    lo        = layout(args)
    x_min     = lo.target_spawn_x_min
    x_range   = lo.target_spawn_x_range
    y_min     = touch_ui?(args) ? (lo.fire_cy + lo.fire_r).round : TARGET_SIZE
    y_max     = (lo.hud_py - TARGET_SIZE - 10).round
    y_range   = [y_max - y_min, TARGET_SIZE].max

    candidate = nil
    30.times do
      candidate = {
        x:    rand(x_range) + x_min,
        y:    rand(y_range) + y_min,
        w:    TARGET_SIZE,
        h:    TARGET_SIZE,
        path: "sprites/target.png",
      }
      next if under_touch_controls?(args, candidate)
      return candidate unless existing.any? { |t| circle_overlap?(candidate, t, TARGET_GAP) }
    end
    candidate
  end

  # ---------------------------------------------------------------------------
  # Fireball update + hit detection
  # ---------------------------------------------------------------------------

  def update_fireballs(args)
    args.state.fireballs.each do |fireball|
      fireball[:x] += args.state.player[:base_speed] + 2

      if fireball.x > args.grid.w
        fireball.dead = true
        next
      end

      check_fireball_hits(args, fireball)
    end

    args.state.targets.reject!   { |t| t.dead }
    args.state.fireballs.reject! { |f| f.dead }
  end

  def check_fireball_hits(args, fireball)
    args.state.targets.each do |target|
      next if target.dead
      next unless circle_overlap?(target, fireball)

      target.dead   = true
      fireball.dead = true
      args.state.score += 1

      args.outputs.sounds << HIT_SOUND
      spawn_explosion(args, target)

      # Immediately replace the destroyed target
      live = args.state.targets.reject { |t| t.dead }
      args.state.targets << spawn_target(args, live)
      break
    end
  end

end
