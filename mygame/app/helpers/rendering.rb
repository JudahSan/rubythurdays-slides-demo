# =============================================================================
# helpers/rendering.rb — Gradient, sky, cloud and hill drawing helpers
# Depends on: constants.rb, ui/button.rb  (solid, disc)
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Colour interpolation
  # ---------------------------------------------------------------------------

  def lerp_color(a, b, t)
    [(a[0] + (b[0] - a[0]) * t).round,
     (a[1] + (b[1] - a[1]) * t).round,
     (a[2] + (b[2] - a[2]) * t).round]
  end

  # Returns the interpolated [r, g, b] at position t (0 = top, 1 = bottom)
  # given an array of colour stops [[pos, [r,g,b]], ...]
  def gradient_at(stops, t)
    i = 0
    while i < stops.length - 2 && t > stops[i + 1][0]
      i += 1
    end
    a     = stops[i]
    b     = stops[i + 1]
    span  = b[0] - a[0]
    local = span > 0 ? (t - a[0]) / span : 0
    local = local.clamp(0, 1)
    lerp_color(a[1], b[1], local)
  end

  # ---------------------------------------------------------------------------
  # Gradient background
  # ---------------------------------------------------------------------------

  # Vertical gradient rendered as thin horizontal strips.
  # Top and bottom strips are extended far past the canvas to fill letterbox areas.
  def draw_gradient(args, stops, strips = 32)
    step = args.grid.h / strips
    out  = []
    strips.times do |i|
      c = gradient_at(stops, 1.0 - (i + 0.5) / strips)
      y = i * step
      h = step + 1
      if i == 0
        y = -2000
        h += 2000
      elsif i == strips - 1
        h += 2000
      end
      out << { x: -2000, y: y, w: args.grid.w + 4000, h: h, path: :solid,
               r: c[0], g: c[1], b: c[2] }
    end
    args.outputs.sprites << out
  end

  # ---------------------------------------------------------------------------
  # Clouds
  # ---------------------------------------------------------------------------

  def draw_cloud(args, x, y, r, shade)
    c = { r: shade, g: shade, b: 255 }
    args.outputs.sprites << disc(x,         y,            r,               c, 6)
    args.outputs.sprites << disc(x + r,     y - r * 0.2,  (r * 0.8).round, c, 6)
    args.outputs.sprites << disc(x - r,     y - r * 0.25, (r * 0.7).round, c, 6)
  end

  # ---------------------------------------------------------------------------
  # Hills
  # ---------------------------------------------------------------------------

  def draw_hills(args, heights, r, g, b)
    cols = []
    heights.each_with_index do |h, i|
      cols << { x: i * 8, y: -2, w: 9, h: h + 2, path: :solid, r: r, g: g, b: b }
    end
    args.outputs.sprites << cols
  end

  # ---------------------------------------------------------------------------
  # Full sky background (gradient + drifting clouds + two hill layers)
  # Used by gameplay, title, and slides scenes.
  # ---------------------------------------------------------------------------

  def draw_sky(args)
    draw_gradient(args, SKY_STOPS, 32)
    t = Kernel.tick_count
    CLOUDS.each do |cl|
      x = (cl[:x] - t * cl[:speed]) % (args.grid.w + 300) - 150
      draw_cloud(args, x, cl[:y], cl[:r], cl[:shade])
    end
    draw_hills(args, HILLS_BACK,  52, 108, 160)
    draw_hills(args, HILLS_FRONT, 28,  70, 112)
  end

end
