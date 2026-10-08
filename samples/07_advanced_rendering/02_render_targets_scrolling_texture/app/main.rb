module Main
  def start
    @tile_size = 80
    @dx = 1
    @dy = 1
    @viewport_w = 1280
    @viewport_h = 720
  end

  def scrolling_tiles(tile_size:, viewport_w:, viewport_h:, dx:, dy:, tick_count:, path:)
    period = tile_size * 2
    x_offset = (tick_count * dx) % period
    y_offset = (tick_count * dy) % period

    cols = viewport_w.fdiv(tile_size).ceil + 1
    rows = viewport_h.fdiv(tile_size).ceil + 1

    cols.map do |cx|
      rows.map do |cy|
        {
          x: cx * tile_size + x_offset - period,
          y: cy * tile_size + y_offset - period,
          w: tile_size,
          h: tile_size,
          path: path
        }
      end
    end
  end

  def tick
    calc
    render
  end

  def calc
    if inputs.keyboard.key_repeat.w && inputs.keyboard.shift
      @viewport_w += 16
    elsif inputs.keyboard.key_repeat.w
      @viewport_w -= 16
    end

    if inputs.keyboard.key_repeat.h && inputs.keyboard.shift
      @viewport_h += 16
    elsif inputs.keyboard.key_repeat.h
      @viewport_h -= 16
    end

    if inputs.keyboard.key_repeat.t && inputs.keyboard.shift
      @tile_size += 4
    elsif inputs.keyboard.key_repeat.t
      @tile_size -= 4
    end

    @dx += inputs.keyboard.key_repeat.left_right * 0.5
    @dy += inputs.keyboard.key_repeat.up_down * 0.5

    @dx = @dx.round(2)
    @dy = @dy.round(2)
    @tile_size = @tile_size.clamp(32, 1440)
    @viewport_w = @viewport_w.clamp(128, 1280)
    @viewport_h = @viewport_h.clamp(128, 720)
  end

  def render
    outputs.background_color = [0, 0, 0]

    outputs[:viewport].set w: @viewport_w, h: @viewport_h, background_color: [0, 0, 0, 0]

    outputs[:viewport].primitives << scrolling_tiles(
      tile_size: @tile_size,
      viewport_w: @viewport_w,
      viewport_h: @viewport_h,
      dx: @dx,
      dy: @dy,
      tick_count: Kernel.tick_count,
      path: "sprites/square/blue.png"
    )

    outputs.primitives << {
      x: 640,
      y: 360,
      w: @viewport_w,
      h: @viewport_h,
      path: :viewport,
      anchor_x: 0.5,
      anchor_y: 0.5
    }

    outputs.primitives << [
      ["viewport width (W, w)", @viewport_w],
      ["viewport height (H, h)", @viewport_h],
      ["tile size (T, t)", @tile_size],
      ["dx (←, →)", @dx],
      ["dy (↑, ↓)", @dy],
    ].map_with_index do |(label, v), i|
      [
        {
          x: 0,
          y: Grid.h,
          w: 320,
          h: 28,
          path: :solid,
          r: 0,
          g: 0,
          b: 0,
          a: 200,
          anchor_y: 1.0 + i
        },
        {
          x: 8,
          y: Grid.h - 16,
          text: "#{label}: #{v}",
          r: 255, g: 255, b: 255,
          size_px: 24, anchor_x: 0, anchor_y: 0.5 + i
        }
      ]
    end
  end
end

DR.reset
