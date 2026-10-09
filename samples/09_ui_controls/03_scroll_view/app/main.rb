require 'app/scroll_view.rb'

module Main
  attr :sv_left, :sv_right

  def start
    sprite_paths = [
      "sprites/square/red.png",
      "sprites/square/orange.png",
      "sprites/square/yellow.png",
      "sprites/square/green.png",
      "sprites/square/blue.png",
      "sprites/square/indigo.png",
      "sprites/square/violet.png",
      "sprites/square/white.png",
      "sprites/square/black.png",
      "sprites/square/gray.png",
    ]

    @things_left = 51.map do |i|
      {
        name: "Item #{i}",
        price: Numeric.rand(10..100),
        path: sprite_paths.sample
      }
    end

    @things_right = 51.map do |i|
      {
        name: "Item #{i}",
        price: Numeric.rand(10..100),
        path: sprite_paths.sample
      }
    end

    @sv_left = ScrollView.new(
      row: 1,
      col: 1,
      w: 8,
      h: 10
    )

    build_sv @sv_left, @things_left

    @sv_right = ScrollView.new(
      row: 1,
      col: 15,
      w: 8,
      h: 10
    )

    build_sv @sv_right, @things_right
  end

  def build_sv sv, things
    scroll_y = sv.scroll_y
    sv.clear
    things.each do |t|
      sv.add w: 2,
             h: 2,
             text: [t.name, t.price],
             path: t.path,
             ref: t
    end
    sv.scroll_y = scroll_y
  end

  def switch_input_modes!
    @sv_left.scroll_to id: @sv_left.items.first.id
    @sv_right.scroll_to id: @sv_right.items.first.id
    @hovered_item_id = nil
    @active_sv = @sv_left
  end

  def move_item item_rect
    return if !item_rect
    DR.notify "Item moved: #{item_rect.item.text} #{item_rect.item.scroll_view_id}"
    if item_rect.item.scroll_view_id == @sv_left.id
      @things_left.reject! { |t| t == item_rect.item.ref }
      @things_right << item_rect.item.ref
      build_sv @sv_left, @things_left
      build_sv @sv_right, @things_right
      item = @sv_right.items.find { |i| i.ref == item_rect.item.ref }
      @sv_right.scroll_to id: item.id
      @hovered_item_id = @sv_left.find_item_rect(rect: item_rect.rect)&.item&.id
      @sv_left.scroll_to id: @hovered_item_id
    elsif item_rect.item.scroll_view_id == @sv_right.id
      @things_right.reject! { |t| t == item_rect.item.ref }
      @things_left << item_rect.item.ref
      build_sv @sv_left, @things_left
      build_sv @sv_right, @things_right
      item = @sv_left.items.find { |i| i.ref == item_rect.item.ref }
      @sv_left.scroll_to id: item.id
      @hovered_item_id = @sv_right.find_item_rect(rect: item_rect.rect)&.item&.id
      @sv_right.scroll_to id: @hovered_item_id
    end
  end

  def key_repeat_left_right
    if inputs.last_active == :keyboard
      inputs.keyboard.key_repeat.left_right
    else
      if inputs.controller_one.key_down.left_right != 0
        inputs.controller_one.left_right
      elsif (inputs.controller_one.key_held.left || inputs.controller_one.key_held.right)
        t = inputs.controller_one.key_held.left || inputs.controller_one.key_held.right
        if t.elapsed_time > 12 && t.elapsed_time.zmod?(2)
          inputs.controller_one.left_right
        else
          0
        end
      else
        0
      end
    end
  end

  def key_repeat_up_down
    if inputs.last_active == :keyboard
      inputs.keyboard.key_repeat.up_down
    else
      if inputs.controller_one.key_down.up_down != 0
        inputs.controller_one.up_down
      elsif (inputs.controller_one.key_held.up || inputs.controller_one.key_held.down)
        t = inputs.controller_one.key_held.up || inputs.controller_one.key_held.down
        if t.elapsed_time > 12 && t.elapsed_time.zmod?(2)
          inputs.controller_one.up_down
        else
          0
        end
      else
        0
      end
    end
  end

  def calc_buy_mouse
    if inputs.mouse.intersect_rect?(@sv_left.rect)
      @active_sv = @sv_left
    elsif inputs.mouse.intersect_rect?(@sv_right.rect)
      @active_sv = @sv_right
    end

    @sv_left.tick_mouse inputs.mouse
    @sv_right.tick_mouse inputs.mouse
    @hovered_item_id = @sv_left.hovered_item(inputs.mouse)&.item&.id ||
                       @sv_right.hovered_item(inputs.mouse)&.item&.id

    move_item(@sv_left.clicked_item(inputs.mouse) || @sv_right.clicked_item(inputs.mouse))
  end

  def calc_buy_keyboard
    return if @sv_left.items.length == 0 && @sv_right.items.length == 0

    if @sv_left.items.length == 0 && !@hovered_item_id
      @active_sv = @sv_right
      @hovered_item_id = @active_sv.items_rects.first&.item&.id
      @active_sv.scroll_to id: @hovered_item_id
    elsif @sv_right.items.length == 0 && !@hovered_item_id
      @active_sv = @sv_left
      @hovered_item_id = @active_sv.items_rects.first&.item&.id
      @active_sv.scroll_to id: @hovered_item_id
    end

    @hovered_item_id ||= @sv_left.items_rects.first&.item&.id
    prev_id = @hovered_item_id
    nav_rects = if key_repeat_left_right != 0
                  @sv_left.items_rects + @sv_right.items_rects
                else
                  @active_sv.items_rects
                end

    hovered_rect = Geometry.rect_navigate(rect: @active_sv.find_item_rect(id: @hovered_item_id),
                                          rects: nav_rects,
                                          left_right: key_repeat_left_right,
                                          up_down: key_repeat_up_down,
                                          wrap_x: false,
                                          wrap_y: false,
                                          using: :rect)

    @hovered_item_id = hovered_rect.item.id

    if @hovered_item_id && @hovered_item_id != prev_id
      if hovered_rect.item.scroll_view_id == @sv_left.id
        @active_sv = @sv_left
      elsif hovered_rect.item.scroll_view_id == @sv_right.id
        @active_sv = @sv_right
      end

      @active_sv.scroll_to(id: @hovered_item_id)
    end

    @sv_left.tick_scroll_y
    @sv_right.tick_scroll_y

    if inputs.keyboard.key_down.enter || inputs.controller_one.key_down.s
      move_item @active_sv.find_item_rect(id: @hovered_item_id)
    end
  end

  def tick
    $outputs.watch "#{DR.current_framerate}"

    @active_sv ||= @sv_left

    if inputs.last_active_at == Kernel.tick_count - 1
      switch_input_modes!
    else
      if inputs.last_active == :mouse
        calc_buy_mouse
      elsif inputs.last_active == :keyboard || inputs.last_active == :controller
        calc_buy_keyboard
      end
    end

    render
  end

  def render
    outputs[@sv_left.id].set w: @sv_left.content_rect.w,
                             h: @sv_left.content_rect.h,
                             background_color: [0, 0, 0, 0]

    outputs[@sv_left.id].primitives << @sv_left.primitives

    outputs[@sv_right.id].set w: @sv_right.content_rect.w,
                              h: @sv_right.content_rect.h,
                              background_color: [0, 0, 0, 0]

    outputs[@sv_right.id].primitives << @sv_right.primitives

    if @hovered_item_id
      if inputs.last_active == :mouse && !inputs.mouse.buttons.left.buffered_held && !inputs.mouse.wheel
        item_rect = @sv_left.find_item_rect(id: @hovered_item_id) ||
                    @sv_right.find_item_rect(id: @hovered_item_id)
        outputs[@active_sv.id].primitives <<  {
          **item_rect.content_rect,
          path: :solid,
          r: 255, g: 255, b: 255, a: 128
        }
      elsif (inputs.last_active == :keyboard || inputs.last_active == :controller) && !@active_sv.target_scroll_y
        item_rect = @sv_left.find_item_rect(id: @hovered_item_id) ||
                    @sv_right.find_item_rect(id: @hovered_item_id)
        if item_rect
          outputs[@active_sv.id].primitives <<  {
            **item_rect.content_rect,
            path: :solid,
            r: 255, g: 255, b: 255, a: 128
          }
        end
      end
    end


    outputs.background_color = [0, 0, 0, 0]

    outputs.primitives << { **@sv_left.rect, path: @sv_left.id }
    outputs.primitives << { **@sv_right.rect, path: @sv_right.id }

    # outputs.primitives << Layout.debug_primitives(a: 128, invert_colors: true)
  end
end

DR.reboot
