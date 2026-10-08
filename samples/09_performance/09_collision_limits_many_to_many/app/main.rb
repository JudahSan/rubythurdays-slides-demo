# main entry point for the game
module Main
  def start
    # initialize the game and create 100 random squares
    @squares = create_random_squares
  end

  def create_random_squares
    # function creates 100 random squares
    # that are within the bounds of the screen
    # in a circle around the center of the screen
    100.map do
      # generate a vector given a random angle and distance
      angle = rand 360
      distance = rand Grid.h / 2
      Geometry.vec2_add Grid.center,
                        Geometry.vec2_scale(angle.to_vector, distance)
    end.find_all do |pos|
      # filter out any positions that are outside the bounds of the screen
      pos.x.between?(0, Grid.w) &&
      pos.y.between?(0, Grid.h)
    end.map do |pos|
      # create a new square at the position
      Square.new pos
    end
  end

  def tick
    # tick function that is called every frame
    calc
    render
  end

  def calc
    # add 100 new squares when the mouse is clicked
    if inputs.mouse.click
      @squares.concat create_random_squares
    end

    # call tick on each square
    Array.each(@squares, &:tick)

    # check for collisions between squares
    Geometry.each_intersect_rect(@squares) do |a, b|
      a.mark_collision!
      b.mark_collision!
    end
  end

  def render
    # render the squares
    outputs.watch "FPS: #{DR.current_framerate}"
    outputs.watch "Count: #{@squares.length}"

    # set the background color to a dark gray
    outputs.background_color = [32, 32, 32]

    # render the squares by mapping their primitives to the outputs
    outputs.primitives << @squares.map(&:primitives)
  end
end

# class that represents the square
class Square
  # public attributes
  attr :x, :y, :w, :h, :dir, :anchor_x, :anchor_y

  def initialize(x:, y:)
    # constructor sets up the initial position
    # and selects a random speed (dx)
    @x = x
    @y = y
    @w = 4
    @h = 4
    @anchor_x = 0.5
    @anchor_y = 0.5
    @dx = random_dx * [1, -1].sample
    @a = 0
  end

  def random_dx
    Numeric.rand(1..5)
  end

  def tick
    # reset collision state and move square by dx
    # if the square is at the edge of the screen,
    # select a new random speed and reverse direction
    @collision = false
    @x += @dx

    # fade in the square when it is created
    @a = @a.lerp(255, 0.1, tolerance: 1)
    if @x >= Grid.w
      @dx = random_dx * -1
    elsif @x <= 0
      @dx = random_dx
    end
  end

  def mark_collision!
    # function that marks the square as having collided with another square
    @collision = true
  end

  def collision?
    # function that returns whether the square has collided with another square
    @collision
  end

  def primitives
    # returns a render primitives that returns
    # a red or blue square depending on whether it has collided with another square
    color = if @collision
              { r: 200, g: 80, b: 80 }
            else
              { r: 80, g: 80, b: 200 }
            end
    {
      x: @x, y: @y, w: @w, h: @h,
      anchor_x: @anchor_x, anchor_y: @anchor_y,
      path: :solid,
      a: @a,
      **color
    }
  end
end
