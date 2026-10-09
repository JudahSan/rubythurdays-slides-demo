# =============================================================================
# entities/player.rb — Player state initialisation, movement, firing,
#                      and the floating joystick for touch input
# Depends on: constants.rb, helpers/layout.rb, ui/button.rb
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # State initialisation
  # ---------------------------------------------------------------------------

  def init_player(args)
    args.state.player ||= {
      x:          120,
      y:          280,
      w:          100,
      h:          80,
      base_speed: 12,
      path:       "sprites/misc/dragon-0.png",
    }
    frame = 0.frame_index(count: 6, hold_for: 8, repeat: true)
    args.state.player[:path] = "sprites/misc/dragon-#{frame}.png"
  end

  # ---------------------------------------------------------------------------
  # Floating joystick (touch only)
  # ---------------------------------------------------------------------------

  def update_stick(args)
    lo    = layout(args)
    stick = (args.state.stick ||= { active: false, ox: 0, oy: 0, dx: 0.0, dy: 0.0 })
    p     = args.state.ptrs.find { |pt| pt.x < lo.stick_zone_x && pt.y < lo.stick_zone_max_y }
    sr    = lo.stick_radius

    if p.nil?
      stick.active = false
      stick.dx     = 0.0
      stick.dy     = 0.0
      return
    end

    unless stick.active
      stick.active = true
      stick.ox     = p.x
      stick.oy     = p.y
    end

    vx   = p.x - stick.ox
    vy   = p.y - stick.oy
    dist = Math.sqrt(vx * vx + vy * vy)

    if dist > sr
      excess    = (dist - sr) / dist
      stick.ox += vx * excess
      stick.oy += vy * excess
      vx        = p.x - stick.ox
      vy        = p.y - stick.oy
      dist      = sr
    end

    if dist < lo.stick_deadzone
      stick.dx = 0.0
      stick.dy = 0.0
    else
      stick.dx = vx / sr
      stick.dy = vy / sr
    end
  end

  # ---------------------------------------------------------------------------
  # Movement
  # ---------------------------------------------------------------------------

  def handle_player_movement(args)
    player = args.state.player
    dx = 0
    dy = 0
    dx -= 1 if args.inputs.left
    dx += 1 if args.inputs.right
    dy += 1 if args.inputs.up
    dy -= 1 if args.inputs.down

    stick = args.state.stick
    if dx == 0 && dy == 0 && stick && (stick.dx != 0 || stick.dy != 0)
      dx = stick.dx
      dy = stick.dy
    end

    magnitude = Math.sqrt(dx ** 2 + dy ** 2)
    if magnitude > 0
      strength   = magnitude > 1 ? 1.0 : magnitude
      player[:x] += (dx / magnitude) * player[:base_speed] * strength
      player[:y] += (dy / magnitude) * player[:base_speed] * strength
    end

    player[:x] = player[:x].clamp(0, args.grid.w - player[:w])

    lo = layout(args)
    top_limit = args.grid.h - lo.hud_h - 10 - player[:h]
    bot_limit = touch_ui?(args) ? (lo.fire_cy + lo.fire_r - 20) : 0
    player[:y] = player[:y].clamp(bot_limit, top_limit)
  end

  # ---------------------------------------------------------------------------
  # Fire input
  # ---------------------------------------------------------------------------

  def fire_input?(args)
    args.inputs.keyboard.key_down.z ||
      args.inputs.keyboard.key_down.j ||
      args.inputs.controller_one.key_down.a ||
      (touch_ui?(args) && button_pressed?(args, layout(args).fire_hit))
  end

  def handle_fire(args)
    return unless fire_input?(args)
    player = args.state.player
    args.outputs.sounds << "sounds/fireball.wav"
    args.state.fireballs << {
      x:          player[:x] + player[:w] - 12,
      y:          player[:y] + 10,
      w:          32,
      h:          32,
      path:       "sprites/fireball.png",
      created_at: Kernel.tick_count,
    }
  end

end
