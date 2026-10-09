# =============================================================================
# ui/retro_theme.rb — Retro arcade visual effects for menu and game-over screens
# Depends on: constants.rb, ui/button.rb, helpers/rendering.rb
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # CRT scanlines
  # ---------------------------------------------------------------------------

  # Semi-transparent dark bars every 4 px simulate a CRT scanline effect
  def draw_scanlines(args, alpha = 38)
    bars = []
    y    = 0
    while y < args.grid.h
      bars << { x: -2000, y: y, w: args.grid.w + 4000, h: 2,
                path: :solid, r: 0, g: 0, b: 0, a: alpha }
      y += 4
    end
    args.outputs.sprites << bars
  end

  # ---------------------------------------------------------------------------
  # Vignette
  # ---------------------------------------------------------------------------

  # Dark bars on all four edges to simulate a CRT screen vignette
  def draw_vignette(args)
    [
      { x: -2000,              y: -2000, w: 2180,              h: args.grid.h + 4000 },
      { x: args.grid.w - 180,  y: -2000, w: 2180,              h: args.grid.h + 4000 },
      { x: -2000,              y: args.grid.h - 100, w: args.grid.w + 4000, h: 2100  },
      { x: -2000,              y: -2100, w: args.grid.w + 4000, h: 2180              },
    ].each do |r|
      args.outputs.sprites << r.merge(path: :solid, r: 0, g: 0, b: 0, a: 58)
    end
  end

  # ---------------------------------------------------------------------------
  # Accent line
  # ---------------------------------------------------------------------------

  def draw_accent_line(args, y, color, thickness = 3, alpha = 200)
    args.outputs.sprites << {
      x: -2000, y: y, w: args.grid.w + 4000, h: thickness,
      path: :solid, r: color[0], g: color[1], b: color[2], a: alpha,
    }
  end

  # ---------------------------------------------------------------------------
  # Neon title glow
  # ---------------------------------------------------------------------------

  def draw_title_glow(args, cx, cy, r, color)
    args.outputs.sprites << disc(cx, cy, r,               { r: color[0], g: color[1], b: color[2], a: 18 }, 12)
    args.outputs.sprites << disc(cx, cy, (r * 0.6).round, { r: color[0], g: color[1], b: color[2], a: 28 }, 10)
    args.outputs.sprites << disc(cx, cy, (r * 0.3).round, { r: color[0], g: color[1], b: color[2], a: 38 },  8)
  end

  # ---------------------------------------------------------------------------
  # Title marquee bar
  # ---------------------------------------------------------------------------

  def draw_title_bar(args, y, h, color)
    args.outputs.sprites << round_rect(-2000, y, args.grid.w + 4000, h, 0, [4, 6, 20], 230)
    args.outputs.sprites << { x: -2000, y: y + h - 3, w: args.grid.w + 4000, h: 5,
                              path: :solid, r: color[0], g: color[1], b: color[2], a: 220 }
    args.outputs.sprites << { x: -2000, y: y,          w: args.grid.w + 4000, h: 5,
                              path: :solid, r: color[0], g: color[1], b: color[2], a: 220 }
  end

  # ---------------------------------------------------------------------------
  # Corner pixel decorations
  # ---------------------------------------------------------------------------

  def draw_corner_pixels(args, color)
    c   = { r: color[0], g: color[1], b: color[2], a: 180 }
    sz  = 10
    gap = 6
    [
      [gap,                              gap                             ],
      [gap + sz + 2,                     gap                             ],
      [gap,                              gap + sz + 2                    ],
      [args.grid.w - gap - sz * 2 - 2,   gap                             ],
      [args.grid.w - gap - sz,           gap                             ],
      [args.grid.w - gap - sz * 2 - 2,   gap + sz + 2                    ],
      [gap,                              args.grid.h - gap - sz * 2 - 2  ],
      [gap,                              args.grid.h - gap - sz           ],
      [gap + sz + 2,                     args.grid.h - gap - sz * 2 - 2  ],
      [args.grid.w - gap - sz * 2 - 2,   args.grid.h - gap - sz * 2 - 2  ],
      [args.grid.w - gap - sz,           args.grid.h - gap - sz           ],
      [args.grid.w - gap - sz * 2 - 2,   args.grid.h - gap - sz           ],
    ].each do |px, py|
      args.outputs.sprites << solid(px, py, sz, sz, c)
    end
  end

  # ---------------------------------------------------------------------------
  # Blinking text
  # ---------------------------------------------------------------------------

  def draw_blink_text(args, text, y, color, period = 50)
    return if (Kernel.tick_count / period) % 2 == 0
    args.outputs.labels << {
      x: args.grid.w / 2, y: y,
      text: text,
      size_enum: fs(args, 3),
      alignment_enum: 1, vertical_alignment_enum: 1,
      r: color[0], g: color[1], b: color[2], a: 255,
    }
  end

  # ---------------------------------------------------------------------------
  # Scrolling ticker
  # ---------------------------------------------------------------------------

  def draw_ticker(args, color)
    char_w = 14
    full   = TICKER_TEXT + TICKER_TEXT
    offset = (Kernel.tick_count * 2) % (TICKER_TEXT.length * char_w)
    args.outputs.labels << {
      x: -offset.round, y: 22,
      text: full,
      size_enum: 1,
      vertical_alignment_enum: 1,
      r: color[0], g: color[1], b: color[2], a: 160,
    }
  end

  # ---------------------------------------------------------------------------
  # Starfield
  # ---------------------------------------------------------------------------

  def draw_starfield(args)
    t     = Kernel.tick_count
    rects = []
    MENU_STARS.each do |s|
      twinkle = (Math.sin(t * 0.05 + s[:x]) * 40).round
      a       = (s[:bright] + twinkle).clamp(40, 255)
      rects << { x: (s[:x] - t * s[:speed]) % args.grid.w,
                 y: s[:y],
                 w: s[:size], h: s[:size],
                 path: :solid, r: 255, g: 255, b: 255, a: a }
    end
    args.outputs.sprites << rects
  end

  # ---------------------------------------------------------------------------
  # Composite menu background
  # ---------------------------------------------------------------------------

  def draw_menu_background(args)
    draw_gradient(args, MENU_BG_STOPS, 24)
    draw_starfield(args)
    draw_scanlines(args, 28)
    draw_vignette(args)
  end

end
