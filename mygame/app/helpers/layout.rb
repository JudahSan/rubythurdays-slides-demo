# =============================================================================
# helpers/layout.rb — Dynamic layout helper
# =============================================================================
# DragonRuby always works in a fixed logical canvas (1280x720 landscape, or
# 720x1280 portrait when orientation=landscape,portrait is set in metadata).
# ALL coordinates in this file are computed from args.grid.w / args.grid.h so
# that every scene, HUD element, and button adapts automatically when the
# canvas dimensions change on rotation or browser resize.
#
# Usage:
#   lo = layout(args)
#   draw_button(args, lo.btn_fire_hit, "FIRE", BTN_AMBER)
#   lo.portrait?   # => true when h > w
#   lo.cx          # => horizontal centre
#   lo.cy          # => vertical centre
#
# Every value is a simple number or a {x:, y:, w:, h:} hash so it slots
# directly into the existing draw_button / button_pressed? helpers.
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Layout struct — computed once per frame, cached on args.state
  # ---------------------------------------------------------------------------

  class Layout
    attr_reader :w, :h, :cx, :cy, :portrait

    def initialize(w, h)
      @w  = w
      @h  = h
      @cx = w / 2
      @cy = h / 2
      @portrait = h > w
    end

    alias portrait? portrait

    # -------------------------------------------------------------------------
    # Gameplay Pause button — top center between score (left) and time (right)
    # -------------------------------------------------------------------------

    def btn_pause
      bw = portrait? ? 150 : 140
      bh = portrait? ? 54  : 56
      { x: (@cx - bw / 2).round, y: @h - bh - 10, w: bw, h: bh }
    end

    # -------------------------------------------------------------------------
    # Back button (slides + instructions screen) — bottom-right corner
    # -------------------------------------------------------------------------

    def btn_back
      bw = portrait? ? 140 : 170
      { x: @w - bw - 10, y: 10, w: bw, h: 76 }
    end

    # -------------------------------------------------------------------------
    # Fire button — bottom-right zone, well clear of the joystick
    # -------------------------------------------------------------------------

    def fire_r;  portrait? ? 75  : 85;  end
    def fire_cx; @w - fire_r - 30;     end
    def fire_cy; fire_r + 30;          end

    def fire_hit
      pad = fire_r + 35
      { x: fire_cx - pad, y: fire_cy - pad, w: pad * 2, h: pad * 2 }
    end

    # -------------------------------------------------------------------------
    # Joystick zone — left half of screen, below HUD
    # -------------------------------------------------------------------------

    def stick_zone_x;     portrait? ? @w * 0.6 : @w * 0.55; end
    def stick_zone_max_y; @h - 90;                           end
    def stick_radius;     portrait? ? 80 : 90;               end
    def stick_deadzone;   14;                                 end
    def stick_hint_x;     portrait? ? @w * 0.22 : 170;       end
    def stick_hint_y;     fire_r + 30;                       end

    # -------------------------------------------------------------------------
    # Pause-screen buttons (6 buttons: Resume, Music, Slides, Touch UI, Main Menu, Exit)
    # Landscape: 2 columns of 3 buttons; Portrait: 1 centered column of 6 buttons
    # -------------------------------------------------------------------------

    def btn_pause_col_w
      portrait? ? [320, @w - 60].min : 280
    end

    def btn_pause_col_h; 52; end

    # Portrait single column positions
    def btn_resume
      if portrait?
        { x: (@cx - btn_pause_col_w / 2).round, y: @cy + 130, w: btn_pause_col_w, h: 52 }
      else
        { x: (@cx - 290).round, y: @cy + 45, w: 270, h: 52 }
      end
    end

    def btn_pause_music
      if portrait?
        { x: (@cx - btn_pause_col_w / 2).round, y: @cy + 68, w: btn_pause_col_w, h: 52 }
      else
        { x: (@cx - 290).round, y: @cy - 17, w: 270, h: 52 }
      end
    end

    def btn_pause_slides
      if portrait?
        { x: (@cx - btn_pause_col_w / 2).round, y: @cy + 6, w: btn_pause_col_w, h: 52 }
      else
        { x: (@cx - 290).round, y: @cy - 79, w: 270, h: 52 }
      end
    end

    def btn_pause_touch
      if portrait?
        { x: (@cx - btn_pause_col_w / 2).round, y: @cy - 56, w: btn_pause_col_w, h: 52 }
      else
        { x: (@cx + 20).round, y: @cy + 45, w: 270, h: 52 }
      end
    end

    def btn_exit_menu
      if portrait?
        { x: (@cx - btn_pause_col_w / 2).round, y: @cy - 118, w: btn_pause_col_w, h: 52 }
      else
        { x: (@cx + 20).round, y: @cy - 17, w: 270, h: 52 }
      end
    end

    def btn_exit_game
      if portrait?
        { x: (@cx - btn_pause_col_w / 2).round, y: @cy - 180, w: btn_pause_col_w, h: 52 }
      else
        { x: (@cx + 20).round, y: @cy - 79, w: 270, h: 52 }
      end
    end

    # -------------------------------------------------------------------------
    # Game Over screen buttons — centered horizontally in lower section
    # -------------------------------------------------------------------------

    def btn_game_over_restart
      bw = portrait? ? [300, @w - 60].min : 240
      x  = portrait? ? @cx - bw / 2 : @cx - bw - 12
      y  = portrait? ? 116 : 56
      { x: x.round, y: y, w: bw, h: 60 }
    end

    def btn_game_over_menu
      bw = portrait? ? [300, @w - 60].min : 240
      x  = portrait? ? @cx - bw / 2 : @cx + 12
      y  = portrait? ? 42 : 56
      { x: x.round, y: y, w: bw, h: 60 }
    end

    # -------------------------------------------------------------------------
    # HUD panels (score top-left, time top-right)
    # -------------------------------------------------------------------------

    def hud_h;    84; end
    def hud_py;   @h - 20 - hud_h; end   # same as "h - 20 - 84"

    def hud_panel_w
      portrait? ? [(@w - 56) / 2, 220].min : 230
    end

    def score_panel
      { x: 24, y: hud_py, w: hud_panel_w, h: hud_h }
    end

    def time_panel
      pw = hud_panel_w
      { x: @w - 24 - pw, y: hud_py, w: pw, h: hud_h }
    end

    # -------------------------------------------------------------------------
    # Target spawn area — right portion of canvas, below HUD
    # -------------------------------------------------------------------------

    def target_spawn_x_min
      portrait? ? @w * 0.1 : @w * 0.5
    end

    def target_spawn_x_range
      portrait? ? (@w * 0.8).round : (@w * 0.4).round
    end

    # -------------------------------------------------------------------------
    # Menu screen buttons — vertically & horizontally centred stack
    # -------------------------------------------------------------------------

    def menu_btn_w
      portrait? ? (@w * 0.72).round : 320
    end

    def menu_btn_h;   68; end
    def menu_btn_gap; 12; end

    # Returns {x:, y:, w:, h:} for slot i where i=0 is the TOPMOST button.
    def menu_btn_at(i)
      bw       = menu_btn_w
      bh       = menu_btn_h
      gap      = menu_btn_gap
      rows     = portrait? ? 6 : 4
      sh       = rows * bh + (rows - 1) * gap
      avail_cy = (50 + (@h - 200)) / 2
      top_y    = (avail_cy + sh / 2 - bh).round
      row_idx  = portrait? ? i : (i == 5 ? 3 : i)
      y        = top_y - row_idx * (bh + gap)
      { x: (@cx - bw / 2).round, y: y, w: bw, h: bh }
    end

    # Landscape pair helpers
    def menu_btn_pair_gap; 12; end
    def menu_btn_pair_half_w; (menu_btn_w - menu_btn_pair_gap) / 2; end

    def menu_btn_pair_left(y_val)
      { x: (@cx - menu_btn_w / 2).round,
        y: y_val,
        w: menu_btn_pair_half_w.round, h: menu_btn_h }
    end

    def menu_btn_pair_right(y_val)
      left_x = (@cx - menu_btn_w / 2).round
      { x: left_x + menu_btn_pair_half_w.round + menu_btn_pair_gap,
        y: y_val,
        w: menu_btn_pair_half_w.round, h: menu_btn_h }
    end

    # Named accessors — visual order: Play, How To Play + Sound, Touch UI + Slides, Close
    def menu_btn_play;        menu_btn_at(0); end
    def menu_btn_how_to_play; portrait? ? menu_btn_at(1) : menu_btn_pair_left(menu_btn_at(1).y); end
    def menu_btn_mute;        portrait? ? menu_btn_at(2) : menu_btn_pair_right(menu_btn_at(1).y); end
    def menu_btn_touch;       portrait? ? menu_btn_at(3) : menu_btn_pair_left(menu_btn_at(2).y); end
    def menu_btn_slides;      portrait? ? menu_btn_at(4) : menu_btn_pair_right(menu_btn_at(2).y); end
    def menu_btn_close;       portrait? ? menu_btn_at(5) : menu_btn_at(3); end

    # -------------------------------------------------------------------------
    # Instructions screen layout zones
    # -------------------------------------------------------------------------

    def instr_title_top;   @h - 90;  end   # title bar height = 90 px
    def instr_content_top; @h - 108; end   # first heading baseline
    def instr_footer_top;  80;       end
    def instr_left_x;      40;       end
    def instr_right_x;     portrait? ? 40 : 660; end
    def instr_indent;      24;       end
    def instr_row_h;       portrait? ? 36 : 32; end
    def instr_row_h_t;     portrait? ? 44 : 40; end
    def instr_heading_h;   52;       end

    # -------------------------------------------------------------------------
    # Slides screen footer
    # -------------------------------------------------------------------------

    def slide_footer_btn_back; btn_back; end
  end

  # ---------------------------------------------------------------------------
  # layout(args) — returns a cached Layout for the current canvas size.
  # Recalculates automatically when the canvas dimensions change (rotation).
  # ---------------------------------------------------------------------------

  def layout(args)
    w = args.grid.w
    h = args.grid.h

    # Invalidate cache on dimension change (handles rotation mid-session)
    cached = args.state.layout_cache
    if cached.nil? || cached.w != w || cached.h != h
      args.state.layout_cache = Layout.new(w, h)
    end

    args.state.layout_cache
  end

  # ---------------------------------------------------------------------------
  # Convenience predicate — true when canvas is taller than wide
  # ---------------------------------------------------------------------------

  def portrait?(args)
    args.grid.h > args.grid.w
  end

  # ---------------------------------------------------------------------------
  # Joystick zone guard using dynamic layout
  # ---------------------------------------------------------------------------

  def in_stick_zone?(args, pt)
    lo = layout(args)
    pt.x < lo.stick_zone_x && pt.y < lo.stick_zone_max_y
  end

end
