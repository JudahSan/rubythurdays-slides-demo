# # example of how to roll your own scroll view
# # copypasta this code into your game and customize as needed
class ScrollView
  # a UUID represented as a string that uniquely identifies this
  # scroll view
  attr :id

  # the layout that the scroll view was initialized with
  # can be passed into Layout.rect, eg: Layout.rect(**@scroll_view.layout)
  attr :layout

  # the rect of the scroll view in the
  # screen
  attr :rect

  # the content layout that the scroll view was initialized with
  # can be passed into Layout.rect, eg: Layout.rect(**@scroll_view.content_layout)
  attr :content_layout

  # the rect of the scroll view content
  # (aligned to 0, 0 -> Hash[x: 0, y: 0, w: 320, h: 320])
  attr :content_rect

  # the layout representing the size of a single row
  # with origin a 0, 0
  # can be passed into Layout.rect, eg: Layout.rect(**@scroll_view.row_layout)
  attr :row_layout

  # the rect of a single row
  # (aligned to 0, 0 -> Hash[x: 0, y: 0, w: 320, h: 320])
  attr :row_rect

  # the current location of the where the content has
  # been scrolled to
  attr :scroll_y

  # the scroll_y location that the scroll view should
  # lerp to (if set)
  attr :target_scroll_y

  # inertia of scroll view, scroll way is incremented by this value
  # and then dy is dampened by 5%
  attr :dy

  # Array of Hash with the following properties:
  # Hash[
  #   :id,             # UUID
  #   :index,          # int
  #   :highlighted,    # boolean
  #   :scroll_view_id, # UUID
  #   :text,           # Array of String that is used for primitives rendering
  #   :path            # item background sprite used for primitives rendering
  #   :layout          # Hash[:w, :h] (partial Layout.rect information)
  #   :ref             # Reference to the source object the item was derived from
  # ]
  attr :items

  # parameters to the constructor represents the location on
  # the screen that you want to render the scroll view to
  def initialize(row:, col:, w:, h:)
    @id = DR.create_uuid
    @layout = {
      row: row, col: col,
      w: w, h: h,
      include_gutter: true,
    }

    @content_layout = {
      row: 0, col: 0,
      w: w, h: h,
      include_gutter: true,
      origin: :bottom_left,
      safe_area: false
    }

    @row_layout = {
      row: 0, col: 0,
      w: w, h: 1,
      include_gutter: false,
      origin: :bottom_left,
      safe_area: false
    }

    @rect = Layout.rect(**@layout)
    @content_rect = Layout.rect(**@content_layout)
    @row_rect = Layout.rect(**@row_layout)

    @items = []
    @scroll_y = 0
    @dy = 0
  end

  # function adds an item to the scroll view,
  # items will be auto filled left to right,
  # top to bottom
  def add(w:, h:, text:, path:, ref:)
    @items << {
      id: DR.create_uuid,
      index: @items.length,
      highlighted: false,
      highlighted_at: nil,
      scroll_view_id: @id,
      text: text.is_a?(Array) ? text : [text],
      path: path,
      layout: {
        w: w,
        h: h,
        origin: :bottom_left,
        safe_area: false
      }.freeze,
      ref: ref
    }.freeze
  end

  def content_h
    rects = items_rects.sort_by { |ir| ir.rect.y }
                       .map(&:rect)

    return 0 if rects.length == 0

    (rects.first.y - rects.last.y).abs + rects.first.h + Layout.gutter
  end

  def max_scroll_y
    content_h - @rect.h + Layout.gutter
  end

  def min_scroll_y
    0
  end

  # gets the layout args for each item
  # in the context of the content rect (origin bottom left, 0, 0)
  # returns Hash[:layout, :item, :rect]
  def items_rects
    curr_row = @layout.h - 1
    curr_col = 0
    prev_item_h = nil
    @items.map do |item|
      if curr_col + item.layout.w > @content_layout.w
        curr_row -= prev_item_h || item.layout.h
        curr_col = 0
        prev_item_h = nil
      end

      prev_item_h = Numeric.max(prev_item_h, item.layout.h)

      item_layout = {
        **item.layout,
        row: curr_row - (item.layout.h - 1),
        col: curr_col,
      }

      layout_rect = Layout.rect(**item_layout)
      content_rect = Geometry.rect(**layout_rect, y: layout_rect.y + @scroll_y)
      rect = Geometry.rect(**layout_rect,
                           x: layout_rect.x + @rect.x,
                           y: layout_rect.y + @rect.y + @scroll_y)

      curr_col += item_layout.w

      {
        layout: item_layout,
        item: item,
        rect: rect,
        layout_rect: layout_rect,
        content_rect: content_rect
      }
    end
  end

  def find_item_rect(id: nil, rect: nil)
    return nil if !id && !rect
    if id
      items_rects.find { |ir| ir.item.id == id }
    elsif rect
      rect = Geometry.rect rect
      items_rects.sort_by { |ir| Geometry.distance_squared(rect, ir.rect) }
                 .first
    end
  end

  def hovered_item mouse
    return nil if !Geometry.intersect_rect?(mouse, @rect)

    Geometry.find_intersect_rect(
      mouse,
      visible_rects,
      using: :rect
    )
  end

  def clicked_item mouse
    return nil if !mouse.buttons.left.buffered_click

    hovered_item mouse
  end

  def visible_rects
    Geometry.find_all_intersect_rect(
      { content_rect: @content_rect },
      items_rects,
      using: :content_rect
    )
  end

  def clear
    @items.clear
  end

  def scroll_row d_row
    @target_scroll_y ||= @scroll_y
    @target_scroll_y += (Layout.rect(**@row_layout, h: d_row.abs).h + Layout.gutter) * d_row.sign * -1
    @target_scroll_y = @target_scroll_y.clamp(min_scroll_y, max_scroll_y)
  end

  def scroll_to(id:)
    item_rect = items_rects.find { |ir| ir.item.id == id }
    return if !item_rect
    return if Geometry.intersect_rect? item_rect.content_rect, @content_rect
    if item_rect
      if item_rect.content_rect.y < 0
        @target_scroll_y = @scroll_y + item_rect.content_rect.y * -1 + Layout.gutter
      else
        @target_scroll_y = @scroll_y + (item_rect.content_rect.y * -1) +
                           (@content_rect.h - item_rect.content_rect.h) - Layout.gutter
      end
    end
  end

  def tick_scroll_y mouse = nil
    if @target_scroll_y
      @dy = 0
      @scroll_y = @scroll_y.lerp @target_scroll_y, 0.5 ** 2, tolerance: 4
      if @scroll_y.round(4) == @target_scroll_y.round(4)
        @scroll_y = @target_scroll_y
        @target_scroll_y = nil
      end
    end

    @scroll_y += @dy
    @dy *= 0.95
    @dy = @dy.round(4)
    if @dy.abs <= 0.5 && @dy != 0
      @dy = 0
      @scroll_y = @scroll_y.round
    end

    if @scroll_y <= min_scroll_y && ((mouse && !mouse.buttons.left.buffered_held && !mouse.wheel) || !mouse)
      @target_scroll_y = nil
      @scroll_y = @scroll_y.lerp(min_scroll_y, 0.1, tolerance: 1)
      @dy = 0
    elsif @scroll_y >= max_scroll_y && ((mouse && !mouse.buttons.left.buffered_held && !mouse.wheel) || !mouse)
      @target_scroll_y = nil
      @scroll_y = @scroll_y.lerp(max_scroll_y, 0.1, tolerance: 1)
      @dy = 0
    end
  end

  def tick_mouse mouse
    tick_scroll_y mouse
    tick_mouse_wheel mouse
    tick_mouse_held mouse
  end

  def tick_mouse_wheel mouse
    return nil if !Geometry.intersect_rect?(mouse, @rect)
    return nil if !mouse.wheel

      perc = if @scroll_y < min_scroll_y
               (1 - (min_scroll_y - @scroll_y).abs / @rect.h) ** 4
             elsif @scroll_y > max_scroll_y
               (1 - (max_scroll_y - @scroll_y).abs / @rect.h) ** 4
             else
               1
             end

    if mouse.wheel.inverted
      @dy -= mouse.wheel.y * perc
    else
      @dy += mouse.wheel.y * perc
    end
  end

  def tick_mouse_held mouse
    return if !Geometry.intersect_rect?(mouse, @rect)
    return if !mouse.buttons.left.buffered_held

    if mouse.buttons.left.buffered_held.created_at == Kernel.tick_count
      @dy = 0
    else
      perc = if @scroll_y < min_scroll_y
               (1 - (min_scroll_y - @scroll_y).abs / @rect.h) ** 4
             elsif @scroll_y > max_scroll_y
               (1 - (max_scroll_y - @scroll_y).abs / @rect.h) ** 4
             else
               1
             end
      @dy = mouse.relative_y * perc
    end
  end

  def items_primitives
    visible_rects.map do |vr|
      item = vr.item
      text = vr.item.text
      [
        { **vr.content_rect, path: vr.item.path },
        {
          **vr.content_rect.center,
          w: vr.content_rect.w - 16,
          h: vr.item.text.length * 28 + 4,
          anchor_x: 0.5,
          anchor_y: 0.5,
          r: 0, g: 0, b: 0,
          path: :solid
        },
        String.line_anchors(text).map do |anchor, s|
          {
            **vr.content_rect.center,
            text: s,
            size_px: 22,
            anchor_x: 0.5,
            anchor_y: anchor,
            r: 255, g: 255, b: 255
          }
        end
      ]
    end
  end

  # primitives for the background of the scroll view
  def background_primitives
    {
      **@content_rect,
      path: :solid,
      r: 255, g: 255, b: 255, a: 255
    }
  end

  # all the primitives for the scroll view that
  # should be sent to a render target
  # Example rendering:
  # #+begin_src
  #  outputs[@scroll_view.id].set w: @scroll_view.rect.w,
  #                               h: @scroll_view.rect.h,
  #                               background_color: [0, 0, 0, 0]
  #
  #  outputs[@scroll_view.id].primitives << @scroll_view.primitives
  #  outputs.primitives << {
  #    **@scroll_view.rect,
  #    path: @scroll_view.id
  #  }
  #
  #  outputs.primitives << Layout.debug_primitives(a: 128, invert_colors: true)
  # #+end_src
  def primitives
    [
      background_primitives,
      items_primitives
    ]
  end
end

DR.reboot
