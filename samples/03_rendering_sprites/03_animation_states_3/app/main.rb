module Main
  def start
    @game = Game.new
  end

  def tick
    @game.inputs = inputs
    @game.tick
    outputs.background_color = [30, 30, 30]
    outputs.primitives << @game.primitives
  end
end

class Game
  attr :inputs

  def initialize
    @player = Player.new
  end

  def tick
    @player.inputs = inputs
    @player.tick

    if @player.y < 64
      @player.y = 64
      @player.dy = 0
      @player.on_ground = true
      @player.jump_count = 0
    end

    if @player.x < 4
      @player.x = 4
      @player.dx = 0
    elsif @player.x > 252
      @player.x = 252
      @player.dx = 0
    end
  end

  def primitives
    [
      { x: 0, y: 0, w: 256, h: 68, path: :solid, r: 128, g: 128, b: 128 },
      { x: 0, y: 64, w: 2, h: 256, path: :solid, r: 128, g: 128, b: 128 },
      { x: 254, y: 64, w: 2, h: 256, path: :solid, r: 128, g: 128, b: 128 },
      @player.primitives,
      instruction_primitives
    ]
  end

  def instruction_primitives
    if inputs.last_active == :controller
      {
        x: Grid.center_x,
        y: Grid.h - 5,
        text: "D-PAD: move, jump, and fast fall. A/X: attack",
        font: "tiny.ttf",
        size_px: 10,
        anchor_x: 0.5,
        anchor_y: 0.5,
        r: 255, g: 255, b: 255,
      }
    else
      {
        x: Grid.center_x,
        y: Grid.h - 5,
        text: "WASD/ARROWS: move, jump, and fast fall. J/F: attack",
        font: "tiny.ttf",
        size_px: 10,
        anchor_x: 0.5,
        anchor_y: 0.5,
        r: 255, g: 255, b: 255,
      }
    end
  end
end

class Player
  attr :inputs, :x, :y, :dx, :dy, :on_ground, :jump_count

  def initialize
    @x = 128
    @y = 64
    @dx = 0
    @dy = 0
    @action = :stand
    @action_at = 0
    @next_action_queue = {}
    @facing = 1
    @jump_at = 0
    @jump_count = 0
    @max_speed = 1.0
    @on_ground = true
    @sabre = nil
    @buffered_action = nil
    @sabre_spline = [
      [0, 0,    0.66, 1],
      [1, 1,    1,    1],
      [1, 0.33, 0,    0]
    ]
    @action_lookup = {
      stand: {
        repeat: true,
        frame_count: 1,
        hold_for: 5,
        next_action: :slash_0,
        interrupt_frame_index: 0,
        calc: lambda do
          dx! magnitude: 0
          if inputs.left_right != 0
            action! :run
          else
            friction! perc: 0.95
          end
        end,
      },
      run: {
        repeat: true,
        frame_count: 4,
        hold_for: 5,
        next_action: :slash_0,
        interrupt_frame_index: 0,
        calc: lambda do
          if inputs.left_right != 0
            action! :run
          end

          dx! magnitude: 0.25 * inputs.left_right

          if inputs.left_right == 0
            friction! perc: 0.95
          end

          @dx = @dx.clamp(-1, 1)
          transition_to_stand!
        end,
      },
      first_jump: {
        repeat: true,
        frame_count: 1,
        hold_for: 5,
        next_action: :slash_0,
        interrupt_frame_index: -1,
        calc: lambda do
          dx! magnitude: 0.25 * 0.5 * inputs.left_right
          transition_to_fall!
          @dx = @dx.clamp(-1, 1)
        end,
      },
      second_jump: {
        repeat: false,
        frame_count: 9,
        hold_for: 5,
        next_action: :slash_0,
        interrupt_frame_index: -9,
        calc: lambda do
          dx! magnitude: 0.25 * 0.5 * inputs.left_right
          friction! perc: 0.1
          transition_to_fall!
          @dx = @dx.clamp(-1, 1)
        end,
      },
      fall: {
        repeat: true,
        frame_count: 1,
        hold_for: 5,
        next_action: :slash_0,
        interrupt_frame_index: 0,
        calc: lambda do
          dx! magnitude: 0.25 * 0.5 * inputs.left_right
          friction! perc: 0.1
          @dx = @dx.clamp(-1, 1)
          if @y <= 64
            action! :stand
          end
        end,
      },
      slash_0: {
        frame_count: 6,
        repeat: false,
        hold_for: 5,
        next_action: :slash_1,
        interrupt_frame_index: -2,
        activated: lambda do
          dx! magnitude: 1.0 * @facing
          @dx += 1 * @facing
          @dy = 0.6 if !@on_ground
        end,
        calc: lambda do
          friction! perc: 0.1
          transition_to_fall!
          transition_to_stand!
        end,
      },
      slash_1: {
        frame_count: 6,
        repeat: false,
        hold_for: 5,
        next_action: :throw_0,
        interrupt_frame_index: -2,
        activated: lambda do
          dx! magnitude: 1.0 * @facing
          @dy = 0.6 if !@on_ground
        end,
        calc: lambda do
          friction! perc: 0.1
          transition_to_fall!
          transition_to_stand!
        end,
      },
      throw_0: {
        frame_count: 8,
        repeat: false,
        hold_for: 5,
        next_action: :throw_1,
        interrupt_frame_index: 0,
        activated: lambda do
          dx! magnitude: 1.0 * @facing
          @dy = 1.0 if !@on_ground
        end,
        calc: lambda do
          if frame.frame_index == 2 && frame.frame_elapsed_time == 0
            @sabre = { x: @x,
                       y: @y,
                       at: Kernel.tick_count,
                       duration: 20,
                       distance: 32 }
          end
          friction! perc: 0.1
          transition_to_fall!
          transition_to_stand!
        end,
      },
      throw_1: {
        frame_count: 8,
        repeat: false,
        hold_for: 5,
        next_action: :throw_2,
        interrupt_frame_index: 0,
        activated: lambda do
          dx! magnitude: 1.0 * @facing
          @dy = 1.0 if !@on_ground
        end,
        calc: lambda do
          if frame.frame_index == 2 && frame.frame_elapsed_time == 0
            @sabre = { x: @x,
                       y: @y,
                       at: Kernel.tick_count,
                       duration: 25,
                       distance: 48 }
          end
          friction! perc: 0.1
          transition_to_fall!
          transition_to_stand!
        end,
      },
      throw_2: {
        frame_count: 9,
        repeat: false,
        hold_for: 5,
        next_action: :spin_slash,
        interrupt_frame_index: 0,
        activated: lambda do
          dx! magnitude: 1.0 * @facing
          @dy = 1.0 if !@on_ground
        end,
        calc: lambda do
          if frame.frame_index == 2 && frame.frame_elapsed_time == 0
            @sabre = { x: @x,
                       y: @y,
                       at: Kernel.tick_count,
                       duration: 25,
                       distance: 64 }
          end
          friction! perc: 0.1
          transition_to_fall!
          transition_to_stand!
        end,
      },
      spin_slash: {
        frame_count: 10,
        repeat: false,
        hold_for: 5,
        next_action: :finisher,
        interrupt_frame_index: 0,
        activated: lambda do
          dx! magnitude: 2.0 * @facing
          if @on_ground
            @dy = 1.0
          else
            @dy = 1.5
          end
        end,
        calc: lambda do
          friction! perc: 0.05
          transition_to_fall!
          transition_to_stand!
        end,
      },
      finisher: {
        frame_count: 8,
        repeat: false,
        hold_for: 5,
        interrupt_frame_index: 0,
        activated: lambda do
          dx! magnitude: 2.5 * @facing
          @dy = 0.6 if !@on_ground
        end,
        calc: lambda do
          if frame.frame_index == 2 && frame.frame_elapsed_time == 0
            @sabre = { x: @x,
                       y: @y,
                       at: Kernel.tick_count,
                       duration: 25,
                       distance: 128 }
          end
          friction! perc: 0.05
          transition_to_fall!
          transition_to_stand!
        end,
      },
    }
  end

  def tick
    input_attack!
    input_jump!
    tick_buffered_action
    tick_sabre
    tick_physics
  end

  def attack_requested?
    inputs.keyboard.key_down.j ||
    inputs.keyboard.key_down.f ||
    inputs.controller_one.key_down.s
  end

  def input_attack!
    return if !attack_requested?
    if next_action && frame
      @buffered_action = { name: next_action, at: earliest_next_action_at }
    else
      @buffered_action = nil
    end
  end

  def jump_requested?
    inputs.up
  end

  def input_jump!
    return if !jump_requested?
    if next_action && frame
      if Kernel.tick_count >= earliest_next_action_at
        jump!
      end
    else
      jump!
    end
  end

  def jump!
    if @jump_count == 0
      @dy = 1.5
      @on_ground = false
      @jump_count += 1
      action! :first_jump
    elsif @jump_count == 1 && @action_at.elapsed_time > 20
      @dy = 1.5
      @on_ground = false
      @jump_count += 1
      action! :second_jump
    end
  end

  def tick_buffered_action
    if @buffered_action && Kernel.tick_count >= @buffered_action.at
      action! @buffered_action.name
      @buffered_action = nil
    end

    current_action.calc.call if current_action.calc
  end

  def action! name
    return if @action == name
    raise "action_lookup does not contain #{name}" if !@action_lookup[name]
    @action = name
    @action_at = Kernel.tick_count

    if @action_lookup[@action].activated
      @action_lookup[@action].activated.call
    end
  end

  def transition_to_fall!
    return if @on_ground
    if (frame.repeat && @dy < -0.5) || (frame.completed && @dy < -0.5)
      action! :fall
    end
  end

  def transition_to_stand!
    return if !@on_ground
    if (frame.repeat && @dx.abs <= 0.1) || (frame.completed)
      @dx = 0
      action! :stand
    end
  end

  def tick_sabre
    if @sabre && @sabre.at.elapsed_time >= @sabre.duration
      @sabre = nil
    end
  end

  def fast_fall_requested?
    inputs.up_down == -1
  end

  def tick_physics
    @dy -= 0.05
    @dy -= 0.05 if fast_fall_requested?
    @x += @dx
    @y += @dy
  end

  def friction!(perc:)
    @dx = @dx.lerp(0, perc)
  end

  def dx!(magnitude:)
    if inputs.left_right != 0
      @facing = inputs.left_right.sign
    end

    @dx += magnitude
  end

  def current_action
    @action_lookup[@action]
  end

  def next_action
    @action_lookup[@action].next_action
  end

  def frame
    Numeric.frame start_at: @action_at, **@action_lookup[@action]
  rescue
    raise "#{@action} not in action_lookup"
  end

  def earliest_next_action_at
    if frame.repeat
      Kernel.tick_count
    else
      Kernel.tick_count + frame.duration - frame.elapsed_time + frame.hold_for * (current_action.interrupt_frame_index || 0)
    end
  end

  def primitives
    [
      {
        x: @x,
        y: @y,
        w: 16,
        h: 16,
        path: "sprites/kenobi/#{@action}/#{frame.frame_index}.png",
        flip_horizontally: @facing == -1,
        anchor_x: 0.5,
        anchor_y: 0
      },
      saber_primitives
    ]
  end

  def saber_primitives
    return nil if !@sabre
    perc = Easing.spline @sabre.at,
                         Kernel.tick_count,
                         @sabre.duration,
                         @sabre_spline
    {
      x: @x + perc * @sabre.distance * @facing,
      y: @y,
      w: 16,
      h: 16,
      anchor_x: 0.5,
      path: "sprites/sabre-throw/#{Numeric.frame_index(start_at: @sabre.at, frame_count: 4, hold_for: 2, repeat: true)}.png"
    }
  end
end

DR.reset
