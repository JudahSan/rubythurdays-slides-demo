# =============================================================================
# ui/button.rb — Drawing primitives, buttons, panels, text shadow,
#                pointer/input helpers, and music helpers
# Depends on: constants.rb
# =============================================================================

module Main

  CLICK_SOUND = "sounds/click.wav"

  # Play the button click sound effect.
  # Call this immediately after any button_pressed? check returns true.
  def play_click(args)
    args.outputs.sounds << CLICK_SOUND
  end

  # ---------------------------------------------------------------------------
  # Drawing primitives
  # ---------------------------------------------------------------------------

  def font_opts
    FONT ? { font: FONT } : {}
  end

  # Solid-filled rectangle (whole pixels for crisp edges when scaled)
  def solid(x, y, w, h, c)
    { x: x.round, y: y.round, w: w.round, h: h.round, path: :solid,
      r: c[:r], g: c[:g], b: c[:b], a: c[:a] || 255 }
  end

  # Filled circle from thin horizontal strips (no extra art assets needed)
  def disc(cx, cy, r, color, step = 3)
    rows = []
    dy   = -r
    while dy < r
      half = Math.sqrt(r * r - dy * dy)
      rows << solid(cx - half, cy + dy, half * 2, step, color)
      dy += step
    end
    rows
  end

  # Hollow ring from horizontal strips
  def ring(cx, cy, r, thick, color, step = 3)
    rows  = []
    inner = r - thick
    dy    = -r
    while dy < r
      mid        = dy + step / 2.0
      outer_half = Math.sqrt([r * r - mid * mid, 0].max)
      if mid.abs < inner
        inner_half = Math.sqrt(inner * inner - mid * mid)
        rows << solid(cx - outer_half, cy + dy, outer_half - inner_half, step, color)
        rows << solid(cx + inner_half, cy + dy, outer_half - inner_half, step, color)
      else
        rows << solid(cx - outer_half, cy + dy, outer_half * 2,          step, color)
      end
      dy += step
    end
    rows
  end

  # Rounded rectangle from horizontal strips (supports transparency).
  # rgb is [r, g, b];  a is 0..255
  def round_rect(x, y, w, h, radius, rgb, a = 255, step = 4)
    rows   = []
    c      = { r: rgb[0], g: rgb[1], b: rgb[2], a: a }
    radius = [radius, w / 2, h / 2].min
    yy     = 0
    while yy < h
      rh  = [step, h - yy].min
      mid = yy + rh / 2.0
      d   = 0
      if mid < radius
        d = radius - mid
      elsif mid > h - radius
        d = mid - (h - radius)
      end
      inset = d > 0 ? radius - Math.sqrt([radius * radius - d * d, 0].max) : 0
      rows << solid(x + inset, y + yy, w - inset * 2, rh, c)
      yy += rh
    end
    rows
  end

  # Blend an [r, g, b] colour toward a target brightness value
  # (255 = lighter, 0 = darker)
  def mix(rgb, t, target)
    rgb.map { |v| (v + (target - v) * t).round }
  end

  # ---------------------------------------------------------------------------
  # Buttons
  # ---------------------------------------------------------------------------

  # Chunky 3-D arcade button with glow, dark base, coloured face, gloss
  # highlight.  Sinks visually when pressed.
  def draw_button(args, rect, text, color = BTN_BLUE)
    down  = button_down?(args, rect)
    depth = down ? 2 : 7
    face  = down ? mix(color, 0.2, 255) : color
    base  = mix(color, 0.55, 0)
    rad   = 18
    fh    = rect.h - depth

    max_w = rect.w - 18
    char_count = [text.length, 1].max
    target_char_w = max_w.to_f / char_count
    fitted_size = if target_char_w >= 30
                    4
                  elsif target_char_w >= 24
                    3
                  elsif target_char_w >= 19
                    2
                  elsif target_char_w >= 15
                    1
                  elsif target_char_w >= 12
                    0
                  elsif target_char_w >= 9
                    -1
                  else
                    -2
                  end
    size = [3, fitted_size].min

    s = []
    s.concat round_rect(rect.x - 3, rect.y - 3, rect.w + 6, rect.h + 6, rad + 3, [255, 255, 255], 80)
    s.concat round_rect(rect.x,     rect.y,      rect.w,     rect.h,     rad,     base)
    s.concat round_rect(rect.x,     rect.y + depth, rect.w,  fh,         rad,     face)
    s.concat round_rect(rect.x + 8, rect.y + depth + fh / 2,
                        rect.w - 16, fh / 2 - 6, rad - 8, mix(face, 0.55, 255), 110)
    args.outputs.sprites << s

    args.outputs.labels << with_shadow([{
      x: rect.x + rect.w / 2, y: rect.y + depth + fh / 2,
      text: text, size_enum: size, alignment_enum: 1, vertical_alignment_enum: 1,
    }])
  end

  # Dark rounded HUD panel with a coloured border
  def draw_panel(args, x, y, w, h, accent)
    s = []
    s.concat round_rect(x - 3, y - 5, w + 6, h + 6, 22, [0,   0,   0 ], 90)
    s.concat round_rect(x - 3, y - 3, w + 6, h + 6, 22, accent,        230)
    s.concat round_rect(x,     y,     w,      h,     19, [10, 16, 46],   215)
    args.outputs.sprites << s
  end

  # ---------------------------------------------------------------------------
  # Text shadow
  # ---------------------------------------------------------------------------

  # Wraps labels in a dark 8-direction outline + drop shadow so text reads
  # on any background.  The label's own r/g/b (if set) becomes the front colour.
  def with_shadow(labels)
    out = []
    labels.each do |l|
      a = l[:a] || 255
      OUTLINE_OFFSETS.each do |dx, dy|
        out << l.merge(font_opts).merge(x: l.x + dx, y: l.y + dy,
                                        r: 12, g: 14, b: 40,
                                        a: (210 * a / 255).round)
      end
      out << l.merge(font_opts).merge(x: l.x + 3, y: l.y - 4,
                                      r: 0, g: 0, b: 0,
                                      a: (110 * a / 255).round)
      out << WHITE.merge(l).merge(font_opts)
    end
    out
  end

  # ---------------------------------------------------------------------------
  # Pointer / input helpers
  # ---------------------------------------------------------------------------

  # Normalises touch events and mouse into args.state.ptrs [{x:, y:}, ...].
  # Any real touch event permanently enables the touch UI.
  def update_pointers(args)
    list    = []
    touch   = args.inputs.respond_to?(:touch) ? args.inputs.touch : nil
    touches = []
    if touch
      touches = touch.respond_to?(:values) ? touch.values : touch.to_a
    end

    if touches.length > 0
      args.state.touch_ui = true
      touches.each { |t| list << { x: t.x, y: t.y } }
    elsif args.inputs.mouse.button_left
      list << { x: args.inputs.mouse.x, y: args.inputs.mouse.y }
    end

    args.state.ptrs_prev = args.state.ptrs || []
    args.state.ptrs      = list
  end

  def mobile_platform?(args)
    args.gtk.platform?(:mobile) || args.gtk.platform?(:touch)
  rescue
    false
  end

  def touch_ui?(args)
    args.state.touch_ui == true
  end

  # Font size helper: adds MOBILE_FONT_BOOST on touch devices
  def fs(args, size)
    size + (touch_ui?(args) ? MOBILE_FONT_BOOST : 0)
  end

  def inside?(point, rect)
    return false if point.nil? || rect.nil?
    point.x >= rect.x && point.x <= rect.x + rect.w &&
      point.y >= rect.y && point.y <= rect.y + rect.h
  end

  def any_inside?(points, rect)
    return false if points.nil? || rect.nil? || points.empty?
    points.any? { |p| inside?(p, rect) }
  end

  # True while any pointer is inside the rect this frame
  def button_down?(args, rect)
    return false if rect.nil?
    any_inside?(args.state.ptrs, rect)
  end

  # True only on the frame a pointer first enters the rect
  def button_pressed?(args, rect)
    return false if rect.nil?
    button_down?(args, rect) && !any_inside?(args.state.ptrs_prev, rect)
  end

  # True when a brand-new touch begins (nothing was down last frame)
  def tap_started?(args)
    args.state.ptrs.length > 0 && args.state.ptrs_prev.length == 0
  end

  # True on a new tap that is NOT on an interactive button
  def tap_anywhere?(args)
    return false unless tap_started?(args)
    pt = args.state.ptrs.first
    lo = layout(args)
    !inside?(pt, lo.btn_back) &&
      !inside?(pt, lo.btn_game_over_menu) && !inside?(pt, lo.btn_game_over_restart) &&
      !inside?(pt, lo.btn_exit_menu) && !inside?(pt, lo.btn_resume) &&
      !inside?(pt, lo.btn_exit_game) && !inside?(pt, lo.btn_pause_touch) &&
      !inside?(pt, lo.btn_pause_music) && !inside?(pt, lo.btn_pause_slides) &&
      !inside?(pt, lo.menu_btn_slides)
  end

  # ---------------------------------------------------------------------------
  # Music helpers
  # ---------------------------------------------------------------------------

  def start_music(args, path)
    args.audio[:music]     = { input: path, looping: true }
    args.state.music_track = path
    # Respect mute state so music doesn't blare after a scene change
    args.audio[:music].paused = args.state.music_muted == true
  end

  def start_menu_music(args)
    start_music(args, MUSIC_MENU)
  end

  def start_gameplay_music(args)
    start_music(args, MUSIC_BATTLE)
  end

end
