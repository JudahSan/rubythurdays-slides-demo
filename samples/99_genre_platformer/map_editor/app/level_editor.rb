class LevelEditor
  attr_dr

  def initialize args
    @args = args
    @tilesheet_rect = Layout.rect(row: 5, col: 0, w: 7, h: 7)
    @toggle_collision_button = Layout.rect(row: 4, col: 0, w: 7, h: 1)
    @tilesheet_button_size = @tilesheet_rect.w.fdiv(20)
    @tilesheet_metadata = {}
    @mode = :add
    init_tilesheet_buttons
  end

  def tick camera, terrain
    if mouse.click && hovered_tile
      @selected_tile = hovered_tile.copy
    end

    if mouse.click && @selected_tile && inside_toggle_collision_button_rect?
      tile_id = @selected_tile.id
      selected_tilesheet_button.has_collision = !selected_tilesheet_button.has_collision
      @selected_tile.has_collision = selected_tilesheet_button.has_collision
    end

    world_mouse = Camera.to_world_space camera, inputs.mouse.rect
    ifloor_x = world_mouse.x.ifloor(@tilesheet_button_size)
    ifloor_y = world_mouse.y.ifloor(@tilesheet_button_size)

    @mouse_world_rect =  { x: ifloor_x,
                           y: ifloor_y,
                           w: @tilesheet_button_size,
                           h: @tilesheet_button_size }

    if @selected_tile
      @selected_tile.x = @mouse_world_rect.x
      @selected_tile.y = @mouse_world_rect.y
    end

    if !inside_tilesheet_rect? && !inside_toggle_collision_button_rect?
      if delete_mode? && (mouse.click || (mouse.held && mouse.moved))
        terrain.reject! { |t| Geometry.intersect_rect? t, @mouse_world_rect }
        save_terrain terrain
      elsif @selected_tile && (mouse.click || (mouse.held && mouse.moved))
        if @mode == :add
          terrain.reject! { |t| Geometry.intersect_rect? t, @selected_tile }
          terrain << @selected_tile.copy
        else
          terrain.reject! { |t| Geometry.intersect_rect? t, @selected_tile }
        end
        save_terrain terrain
      end
    end
  end

  def selected_tilesheet_button
    return nil if !@selected_tile
    @tilesheet_buttons.find { |t| t.id == @selected_tile.id }
  end

  def hovered_tile
    return nil if !inside_tilesheet_rect?
    Geometry.find_intersect_rect({ click_box: inputs.mouse.rect }, @tilesheet_buttons, using: :click_box)
  end

  def inside_tilesheet_rect?
    Geometry.intersect_rect? mouse.rect, @tilesheet_rect
  end

  def inside_toggle_collision_button_rect?
    Geometry.intersect_rect? mouse.rect, @toggle_collision_button
  end

  def delete_mode?
    @selected_tile&.x_ordinal == 0 && @selected_tile&.y_ordinal == 0
  end

  def hovered_tile_primitives
    return nil if !hovered_tile

    { x: hovered_tile.click_box.x,
      y: hovered_tile.click_box.y,
      w: hovered_tile.click_box.w,
      h: hovered_tile.click_box.h,
      path: :pixel,
      r: 255, g: 0, b: 0, a: 128 }
  end

  def delete_instruction_primitives
    return nil if !delete_mode?

    { **@toggle_collision_button.center,
      text: "Select tile to delete.",
      r: 255,
      g: 255,
      b: 255,
      anchor_x: 0.5,
      anchor_y: 0.5 }
  end

  def current_tile_marker_primitives
    return nil if !@selected_tile

    { **selected_tilesheet_button.click_box,
      path: :solid,
      r: 0,
      g: 255,
      b: 0,
      a: 128 }
  end

  def overlay_primitives
    [
      { **@tilesheet_rect, path: :tilesheet },
      hovered_tile_primitives,
      delete_instruction_primitives,
      toggle_collision_button_primitives,
      current_tile_marker_primitives,
      current_tile_marker_primitives
    ]
  end

  def scene_primitives
    return nil if !@selected_tile

    if delete_mode?
      { **@selected_tile, path: :solid, r: 255, g: 0, b: 0, a: 128 }
    else
      [
        { **@selected_tile, path: :solid, r: 0, g: 0, b: 0 },
        { **@selected_tile, r: 128, g: 255, b: 255 }
      ]
    end
  end

  def toggle_collision_button_primitives
    return nil if !@selected_tile
    return nil if delete_mode?

    text = if selected_tilesheet_button.has_collision
             "Collidable? Yes (click to toggle)"
           else
             "Collidable? No (click to toggle)"
           end

    [
      { **@toggle_collision_button,
        path: :solid,
        r: 255,
        g: 255,
        b: 255 },
      { **@toggle_collision_button.center,
        text: text,
        anchor_x: 0.5,
        anchor_y: 0.5,
        size_px: 16,
        r: 0,
        g: 0,
        b: 0 }
    ]
  end

  def init_tilesheet_buttons
    @tilesheet_buttons = []

    rows = 20
    cols = 20
    height = rows * @tilesheet_button_size
    width = cols * @tilesheet_button_size

    rows.map_with_index do |row|
      cols.map_with_index do |col|
        x = col * @tilesheet_button_size
        y = height - row * @tilesheet_button_size - @tilesheet_button_size
        @tilesheet_buttons << {
          id: "#{col},#{row}",
          x_ordinal: col,
          y_ordinal: row,
          click_box: {
            x: @tilesheet_rect.x + x,
            y: @tilesheet_rect.y + y,
            w: @tilesheet_button_size,
            h: @tilesheet_button_size,
          },
          x: x,
          y: y,
          w: @tilesheet_button_size,
          h: @tilesheet_button_size,
          path: tile_path(row, col, cols),
          has_collision: true
        }
      end
    end

    outputs[:tilesheet].w = width
    outputs[:tilesheet].h = height
    outputs[:tilesheet].primitives << { x: 0, y: 0, w: width, h: height, path: :pixel, r: 0, g: 0, b: 0 }
    outputs[:tilesheet].primitives << @tilesheet_buttons
  end

  def mouse
    inputs.mouse
  end

  def tile_path row, col, cols
    file_name = (row * cols + col).to_s.rjust(4, "0")
    "sprites/1-bit-platformer/#{file_name}.png"
  end

  def save_terrain terrain
    contents = terrain.uniq.map do |terrain_element|
      [
        terrain_element.x.to_i,
        terrain_element.y.to_i,
        terrain_element.w.to_i,
        terrain_element.h.to_i,
        terrain_element.path,
        terrain_element.has_collision
      ].join(",")
    end

    File.write "data/terrain.txt", contents.join("\n")
  end

  def load_terrain
    contents = File.read("data/terrain.txt")

    return [] if !contents

    contents.lines.map do |line|
      l = line.strip
      if l.empty?
        nil
      else
        x, y, w, h, path, has_collision = l.split ","
        parsed_collision = if has_collision.nil?
                             true
                           else
                             has_collision == "true"
                           end
        { x: x.to_f,
          y: y.to_f,
          w: w.to_f,
          h: h.to_f,
          path: path,
          has_collision: parsed_collision }
      end
    end.compact.uniq
  end
end

DR.reset
