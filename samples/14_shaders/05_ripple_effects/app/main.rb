# https://www.youtube.com/watch?v=8rCRsOLiO7k

require "shaders/ripples.frag.hlsl"

module Main
  def start
    @ripple_queue = []
  end

  def tick
    if inputs.mouse.click
      @ripple_queue << { x: inputs.mouse.x, y: inputs.mouse.y, at: Kernel.tick_count, duration: 120 }
    end

    @ripple_queue.reject! do |ripple|
      ripple.at.elapsed_time(Kernel.tick_count) > ripple.duration
    end

    outputs[:displacement].set w: 1280, h: 720, background_color: [0, 0, 0, 0]
    outputs[:displacement].primitives << scrolling_tiles(
      tile_size: 275,
      viewport_w: 1280,
      viewport_h: 720,
      dx: 0.1,
      dy: 0.0,
      path: "sprites/displacement.png",
      tick_count: Kernel.tick_count
    )

    outputs[:displacement].primitives << @ripple_queue.map do |ripple|
      perc = Easing.smooth_stop(start_at: ripple.at,
                               duration: ripple.duration,
                               power: 2,
                               tick_count: Kernel.tick_count)
      {
        x: ripple.x,
        y: ripple.y,
        w: 128 * perc,
        h: 128 * perc,
        path: "sprites/ripple.png",
        anchor_x: 0.5,
        anchor_y: 0.5,
        a: 128 * (1 - perc)
      }
    end

    outputs[:soup].set w: 1280, h: 720, background_color: [0, 0, 0, 0]
    outputs[:soup].primitives << scrolling_tiles(
      tile_size: 546,
      viewport_w: 1280,
      viewport_h: 720,
      dx: 0.2,
      dy: 0.2,
      tick_count: Kernel.tick_count,
      path: "sprites/soup-left.png",
      a: 128
    )

    outputs[:soup].primitives << scrolling_tiles(
      tile_size: 546,
      viewport_w: 1280,
      viewport_h: 720,
      dx: -0.1,
      dy: 0.1,
      tick_count: Kernel.tick_count,
      path: "sprites/soup-right.png",
      a: 128
    )

    outputs[:soup].primitives << @ripple_queue.map do |ripple|
      perc = Easing.smooth_stop(start_at: ripple.at,
                               duration: ripple.duration,
                               power: 2,
                               tick_count: Kernel.tick_count)
      {
        x: ripple.x,
        y: ripple.y,
        w: 256 * perc,
        h: 256 * perc,
        path: "sprites/ripple.png",
        anchor_x: 0.5,
        anchor_y: 0.5,
        a: 128 * (1 - perc)
      }
    end

    outputs[:mask].set w: 1280, h: 720, background_color: [0, 0, 0, 0]
    outputs[:mask].primitives << { x: 635,
                                   y: 365,
                                   w: 475,
                                   h: 475,
                                   path: "sprites/circle/solid.png",
                                   r: 0, g: 0, b: 0,
                                   anchor_x: 0.5, anchor_y: 0.5 }

    outputs[:scene].shader = {
      path: "shaders/ripples.frag.hlsl",
      textures: [
        :displacement,
        :soup,
        :mask
      ],
    }

    outputs[:scene].set w: 1280, h: 720, background_color: [219, 208, 191]
    outputs[:scene].primitives << { x: 640,
                                    y: 360,
                                    w: 933,
                                    h: 700,
                                    path: 'sprites/arena.png',
                                    anchor_x: 0.5,
                                    anchor_y: 0.5 }

    outputs.primitives << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      path: :scene
    }
  end

  def scrolling_tiles(tile_size:, viewport_w:, viewport_h:,
                      dx:, dy:, tick_count:,
                      path:, a: 255)
    period = tile_size * 2
    x_offset = (tick_count * dx) % period
    y_offset = (tick_count * dy) % period

    cols = viewport_w.fdiv(tile_size).ceil + 2
    rows = viewport_h.fdiv(tile_size).ceil + 2

    cols.map do |cx|
      rows.map do |cy|
        {
          x: cx * tile_size + x_offset - period,
          y: cy * tile_size + y_offset - period,
          w: tile_size,
          h: tile_size,
          path: path,
          flip_horizontally: cx.even?,
          flip_vertically: cy.even?,
          a: a
        }
      end
    end
  end
end

DR.reset
