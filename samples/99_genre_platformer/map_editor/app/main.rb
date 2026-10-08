require 'app/level_editor.rb'
require 'app/camera.rb'

module Main
  attr :level_editor, :player

  def start
    @level_editor = LevelEditor.new args

    @player ||= {
      x: 0,
      y: 750,
      w: 16,
      h: 16,
      dy: 0,
      dx: 0,
      facing: 1,
      on_ground: false,
      path: "sprites/1-bit-platformer/0280.png"
    }

    @gravity = 0.25

    @camera = {
      x: 0,
      y: 0,
      target_x: 0,
      target_y: 0,
      target_scale: 2,
      scale: 1
    }

    @terrain = @level_editor.load_terrain
  end

  def tick
    calc_player
    calc_camera
    calc_level_editor
    render
  end

  def calc_player
    if inputs.keyboard.left
      @player.dx = -3
      @player.facing = -1
    elsif inputs.keyboard.right
      @player.dx = 3
      @player.facing = 1
    end

    if (inputs.keyboard.key_down.space || inputs.key_down.up) && @player.on_ground
      @player.dy = 10
      @player.on_ground = false
    end

    @player.x += @player.dx

    collision = @terrain.find do |t|
      Geometry.intersect_rect?(t, @player) && t.has_collision
    end

    if collision
      if @player.dx > 0
        @player.x = collision.x - @player.w
      else
        @player.x = collision.x + collision.w
      end

      @player.dx = 0
    end

    @player.dx *= 0.8
    @player.dx = 0 if @player.dx.abs < 0.5

    @player.y += @player.dy
    @player.on_ground = false

    collision = @terrain.find do |t|
      t.intersect_rect?(@player) && t.has_collision
    end

    if collision
      if @player.dy > 0
        @player.y = collision.y - @player.h
      else
        @player.y = collision.y + collision.h
        @player.on_ground = true
      end
      @player.dy = 0
    end

    @player.dy -= @gravity

    if (@player.y + @player.h) < -750
      @player.y = 750
      @player.dy = 0
    end
  end

  def calc_camera
    if inputs.keyboard.key_down.equal_sign || inputs.keyboard.key_down.plus
      @camera.target_scale += 0.25
    elsif inputs.keyboard.key_down.minus
      @camera.target_scale -= 0.25
      @camera.target_scale = 0.25 if @camera.target_scale < 0.25
    elsif inputs.keyboard.zero
      @camera.target_scale = 1
    end

    ease = 0.1
    @camera.scale += ((@camera.target_scale + -@player.dy.abs * 0.05 * @camera.scale) - @camera.scale) * ease
    @camera.target_x = @player.x + @player.dx * 8 * @camera.scale
    @camera.target_y = @player.y + @player.dy * 8 * @camera.scale

    @camera.x += (@camera.target_x - @camera.x) * ease
    @camera.y += (@camera.target_y - @camera.y) * ease
  end

  def calc_level_editor
    @level_editor.args = args
    @level_editor.tick @camera, @terrain
  end

  def render
    outputs.background_color = [0, 0, 0]

    outputs[:scene].set w: Camera.viewport_w,
                        h: Camera.viewport_h,
                        background_color: [30, 30, 30, 30]

    outputs[:scene].primitives << Camera.primitives(@camera,
                                                    @terrain,
                                                    player_primitives,
                                                    @level_editor.scene_primitives)

    outputs.primitives << { **Camera.viewport, path: :scene }

    outputs.primitives << @level_editor.overlay_primitives

    outputs.labels << { x: 640,
                        y: 30.from_top,
                        anchor_x: 0.5,
                        text: "WASD: move around / jump. +/-: Zoom in and out. MOUSE: select tile/edit map (select very TOP LEFT blank tile to DELETE).",
                        r: 255,
                        g: 255,
                        b: 255 }
  end

  def player_primitives
    path = if !@player.on_ground
             # falling
             "sprites/1-bit-platformer/0284.png"
           elsif @player.dx != 0
             # running
             frame_index = Numeric.frame_index start_at: 0,
                                               frame_count: 3,
                                               hold_for: 5,
                                               repeat: true
             "sprites/1-bit-platformer/028#{frame_index + 1}.png"
           else
             #standing
             "sprites/1-bit-platformer/0280.png"
           end

    {
      **@player,
      path: path,
      flip_horizontally: @player.facing < 0,
      r: 200, g: 255, b: 200
    }
  end
end

DR.reset
