# =============================================================================
# scenes/slides.rb — Slide deck data, rendering, and navigation
# Depends on: constants.rb, ui/button.rb, helpers/rendering.rb
# Back button always returns to "title" (main menu), regardless of origin.
# =============================================================================

module Main

  # ---------------------------------------------------------------------------
  # Slide data
  # ---------------------------------------------------------------------------

  SLIDES = [
    { title: "2D Game Dev & the Kenyan Gaming Ecosystem",
      lines: ["DragonRuby GTK, and the Kenyan ecosystem"] },

    { title: "About Me",
      lines: [
        "Me: reads slide",
        "Audience: reads slide",
        "",
        "[VISIBLE CONFUSION]",
        "",
        "We're both reading it for the first time",
      ] },

    { title: "Connecting Play & Game design",
      lines: [
        "What was the very first digital game you ever played?",
        "What is your favourite non-digital game growing up?",
      ] },

    { title: "Notable Mentions",
      lines: [
        "Snake, bounce, Doom, super mario, nfs",
        "Kati, stick of death, bano, kalongolongo",
      ] },

    { title: "Evolution of Video Games",
      lines: [
        "1947-1972 (Pre-Industry): Hobbyist patents & Spacewar!",
        "1972-1983 (Atari Era): Coin-op monetization born; ended in the 1983 US crash.",
        "1983-1989 (Nintendo Era): NES licensing safeguards the market and gatekeeps developers.",
        "1989-1995 (Console Wars Era): Sega Genesis vs. Nintendo; 16-bit market polycentrism.",
        "1995-2006 (PC & 3D Era): PlayStation, Xbox, and 3D graphics hardware.",
        "2006-Present (Post-Revolution Era): The indie revolution and casual/mobile platforms.",
      ] },

    { title: "Evolution of Game Engines: From Custom Code to Modding Culture",
      lines: [
        "The Olden Days: Developers wrote memory allocation, graphics pipelines, and physics from scratch for every single game.",
        "id Software, creators of Doom, Quake and Wolfenstein 3D, pioneered the modern engine.",
        "Modern Engine Onset: Unity, Unreal, and Godot standardized development through visual editors and component systems.",
      ] },

    { title: "Cont...",
      lines: [
        "Modding existing games is the best entertainment and hands-on learning environment for beginners.",
        "Modders inspect game loops, tweak variables, and add content without building from scratch.",
        "Notable example: Euro Truck Simulator 2.",
        "Some 'bad actors' were able to jailbreak the PS5.",
        "Modding bridges the gap between playing and professional engineering.",
      ] },

    { title: "Production Lifecycle",
      lines: [
        "The 4-Phase Pipeline",
        "Ideation to Pre-Production (GDD and Prototyping) to Full Production to Post-Production/Live Ops.",
        "Playcentric Research",
        "Start playtesting as early as possible. Conduct user research, gather feedback, and iterate on your game design.",
        "Defining player experience goals prevent scope creep and ensure studio sustainability.",
      ] },

    { title: "Why DragonRuby?",
      lines: [
        "Ruby: expressive, built for developer happiness.",
        "Pure 2D, array/hash based rendering.",
        "Live reload: edit code while the game runs.",
        "DragonRuby launches instantly, eliminating waiting for heavy engine compiles.",
        "One command to ship to web, desktop, mobile.",
      ] },

    { title: "Why NOT DragonRuby?",
      lines: [
        "Paid license model: pay a fee to build for mobile and unlock premium features.",
        "Strictly 2D: No native 3D rendering pipeline — 3D projects require Unity, Godot, or Unreal.",
      ] },

    { title: "Live demo",
      lines: [
        "Press TAB to jump into the game",
        "Press TAB again to come back here",
      ],
      touch_lines: [
        "Tap Back (bottom right) to jump into the game",
        "Tap Slides (top bar) to come back here",
      ] },

    { title: "Market landscape",
      lines: [
        "Mobile Dominance: Mobile gaming drives nearly 90% of African gaming revenues.",
        "South Africa $266M+, Nigeria $249M, Kenya $46M",
        "Mobile-first: 63.2% mobile adoption, 76% digital payments",
      ] },

    { title: "Africa's Mobile Market Growth & Habit Loop Player Monetization",
      lines: [] },

    { title: "Regional Market Landscape",
      lines: [
        "Mobile Dominance: Mobile gaming drives nearly 90% of African gaming revenues.",
        "South Africa & Nigeria: South Africa ($266M-$333M) and Nigeria ($249M) lead continental revenues.",
        "Kenya Market ($46M Revenue): Backed by 63.2% mobile adoption and 76% digital payment penetration.",
        "Urban Paying Players: Over 30% of urban mobile gamers in Nairobi make regular in-app purchases.",
      ] },

    { title: "Case Study: Habit Loop Monetization",
      lines: [
        "Animal Crossing: Pocket Camp Experience: Played despite region lock restrictions requiring a VPN to access!",
        "Why Consider In-App Purchases? Not paywalls, but building a meaningful daily habit loop and long-term retention.",
        "The Game Design Lesson: Monetization happens when players form a genuine daily relationship with your game world.",
      ] },

    { title: "Navigating the Creative, Ethical & Human Touch Debate Surrounding AI",
      lines: [] },

    { title: "The 'Human Touch' & Ethical Split",
      lines: [
        "Artist Concerns: Critics argue AI art erodes original human craft, authenticity, and artist compensation.",
        "IP & Dataset Consent: Unresolved legal questions regarding training data copyright and stolen assets.",
        "The Developer's Choice: AI is a speed amplifier. Final artistic direction, soul, and ethical standards remain in human hands.",
      ] },

    { title: "Speed, Prototyping & Security",
      lines: [
        "Rapid Prototyping: Solo devs turn rough concepts into playable prototypes in a single day.",
        "Code Analysis & Reverse Engineering: Devs use LLMs to deconstruct legacy assembly code and analyze game binaries.",
        "Console Exploits & Modding: AI assists researchers in identifying memory vulnerabilities and building homebrew software.",
      ] },

    { title: "Local Champions Shaping Global & Regional Game Franchises",
      lines: [] },

    { title: "Local Champions",
      lines: [
        "Maliyo Games (Nigeria): 40+ mobile titles released (Whot King); partnered with Disney Games to launch 'Disney Iwaju: Rising Chef' globally.",
        "Leti Arts (Ghana/Kenya): Pioneering African superhero IP ('Sweave') integrating traditional cultural symbols and Riot Games collabs.",
        "Mekan Games (Kenya): Creators of 'The President' (#1 viral hit in US/UK/Canada with 27M+ players) and everyday mobility games.",
        "Kunta Content (Kenya): Developing rich narrative games like 'Hiru' and releasing 'Bankush' on the global Minecraft Marketplace.",
      ] },

    { title: "Overcoming Policy Hurdles & Leveraging Esports as Marketing Engines",
      lines: [] },

    { title: "Policy & Infrastructure Barriers",
      lines: [
        "Government Misconception: Kenya & regional policymakers mistakenly conflate video game development with the gambling/betting industry.",
        "Funding Shortage: Only 3% of African game developers have ever received direct government funding support.",
        "Infrastructure Challenges: Power instability, variable internet bandwidth, and payment gateway friction.",
      ] },

    { title: "Esports as a Growth Catalyst",
      lines: [
        "Community-Powered Marketing: Esports isn't just playing games. It builds brand-new consumer markets from scratch.",
        "Rapid Adoption: Grassroots tournaments and university leagues drive youth engagement across Kenya.",
        "Monetization Potential: Sponsorships, broadcast rights, and brand partnerships powering local talent.",
      ] },

    { title: "Mixing Creative Studio Culture with Smart Capital & Impact Gaming",
      lines: [] },

    { title: "Smart Money Funding Options",
      lines: [
        "The VC Challenge: Traditional VCs struggle with gaming IP predictability; studios must mix artistry with agile startup culture.",
        "Non-Dilutive Grants: Great for early prototyping seed capital, but non-recurring.",
        "Publisher Deals: High-win corporate co-productions (e.g. Maliyo x Disney, Leti Arts x Riot).",
        "Creative VCs & Community: Specialized gaming funds understanding studio development lifecycles.",
      ] },

    { title: "Gamifying Real Life (Impact Games)",
      lines: [
        "Green Tech Integration: Pokemon GO-style tree planting verified against real carbon credits.",
        "Real Estate & Construction: Gamifying architecture, 3D visualizers, and urban planning.",
        "Financial Literacy: Nedbank 'Chow Town' on Roblox teaching youth entrepreneurship.",
      ] },

    { title: "Getting Investor-Ready to Scale African Gaming to Global Prominence",
      lines: [] },

    { title: "Investor Readiness Checklist",
      lines: [
        "Clean Cap Table: Uncomplicated ownership structures without legal disputes.",
        "Tax & Regulatory Compliance: Full registration and compliance with local tax authorities.",
        "2 Years Clean Financials: Transparent accounting and revenue tracking.",
        "3-Year Strategic Plan: Clear roadmap for IP expansion, UA, and monetization.",
        "Corporate Governance: Basic advisory board and financial controls in place.",
      ] },

    { title: "THE BIG TAKEAWAY",
      lines: [
        "Gaming and Esports are not just entertainment. They are engine blocks for digital economy expansion, youth employment, and cultural export across Africa.",
        "With lightweight 2D tools like DragonRuby GTK and AI workflows, your imagination is the only limitation!",
      ] },

    { title: "Thank You!",
      lines: [
        "Arigato!",
        "",
        "Questions? Let's talk games.",
        "by Judahsan",
      ] },
  ]

  # [font size_enum, line_height, wrap_width_in_chars]
  # First step whose card bottom clears the footer (y >= 88) wins.
  SLIDE_STEPS_DESKTOP  = [[6, 52, 58], [5, 46, 66], [4, 40, 76], [3, 36, 86]]
  SLIDE_STEPS_TOUCH    = [[9, 62, 42], [8, 56, 48], [7, 50, 54], [6, 44, 60], [5, 38, 68]]
  # Portrait has a narrower canvas (720 logical px) so wrap widths are tighter
  SLIDE_STEPS_PORTRAIT = [[5, 46, 34], [4, 40, 40], [3, 34, 46]]

  # ---------------------------------------------------------------------------
  # Navigation — Back always returns to the main menu ("title")
  # ---------------------------------------------------------------------------

  def toggle_slides(args)
    args.state.stick = nil

    if args.state.scene == "slides"
      play_click(args)
      args.state.scene = "title"
      args.state.title_arrived_at = Kernel.tick_count
    else
      # Freeze a live round while presenting
      if args.state.scene == "gameplay" && args.state.timer && args.state.timer >= 0
        args.state.paused = true
        music = args.audio[:music]
        music.paused = true if music
      end
      args.state.scene = "slides"
    end
  end

  # ---------------------------------------------------------------------------
  # Slide classification helpers
  # ---------------------------------------------------------------------------

  # Section counter increments at every empty-body (divider) slide
  def slide_section(index)
    n = 0
    (0..index).each { |i| n += 1 if SLIDES[i][:lines].empty? }
    n
  end

  def slide_kind(index)
    return :hero    if index == 0 || index == SLIDES.length - 1
    return :section if SLIDES[index][:lines].empty?
    :content
  end

  # 0..255 fade-in over the first 10 frames after a slide change
  def slide_alpha(args)
    age = Kernel.tick_count - (args.state.slide_shown_at || 0)
    [age * 255 / 10, 255].min
  end

  def text_width(args, text, size)
    args.gtk.calcstringbox(text, size)[0]
  rescue
    text.length * (11 + size * 2)
  end

  # Collapses internal newlines from multi-line string literals then word-wraps
  def wrap_lines(text, width)
    flat    = text.split("\n").map(&:strip).join(" ")
    wrapped = flat.wrap(width)
    wrapped.is_a?(String) ? wrapped.split("\n") : wrapped
  end

  # Returns [flattened_text, head_char_count] — "Key: value" gets coloured key
  def split_head(text)
    flat     = text.split("\n").map(&:strip).join(" ")
    idx      = flat.index(": ")
    head_len = (idx && idx > 0 && idx <= 42) ? idx + 1 : 0
    [flat, head_len]
  end

  # ---------------------------------------------------------------------------
  # Slide background
  # ---------------------------------------------------------------------------

  def draw_slide_background(args, accent)
    draw_gradient(args, SLIDE_BG_STOPS, 24)

    # Decorative glow anchored to the top-right of the canvas
    gx = (args.grid.w * 0.87).round
    gy = (args.grid.h * 0.89).round
    args.outputs.sprites << disc(gx, gy, 240, { r: accent[0], g: accent[1], b: accent[2], a: 22 }, 10)
    args.outputs.sprites << disc(gx, gy, 150, { r: accent[0], g: accent[1], b: accent[2], a: 26 },  8)

    # Drifting bubbles spread across the actual canvas width
    t       = Kernel.tick_count
    cw      = args.grid.w
    ch      = args.grid.h
    bubbles = []
    7.times do |i|
      bx = (cw * 0.1 + i * cw * 0.13 + Math.sin((t + i * 70) / 180.0) * (cw * 0.04)).round
      by = (ch * 0.08 + (i * 97) % (ch * 0.75) + Math.cos(t / 220.0 + i) * (ch * 0.03)).round
      bubbles.concat(disc(bx, by, 14 + (i % 3) * 10,
                          { r: accent[0], g: accent[1], b: accent[2], a: 38 }, 4))
    end
    args.outputs.sprites << bubbles

    # Left accent strip
    args.outputs.sprites << { x: 0, y: 0, w: 14, h: args.grid.h, path: :solid,
                              r: accent[0], g: accent[1], b: accent[2] }
  end

  # ---------------------------------------------------------------------------
  # Slide footer — progress bar + counter + Back button
  # ---------------------------------------------------------------------------

  def draw_slide_footer(args, index, accent, touch)
    back = layout(args).btn_back

    args.outputs.sprites << { x: 0, y: 0, w: args.grid.w, h: 6,
                              path: :solid, r: 255, g: 255, b: 255, a: 28 }
    args.outputs.sprites << { x: 0, y: 0,
                              w: (args.grid.w * (index + 1) / SLIDES.length).round,
                              h: 6, path: :solid,
                              r: accent[0], g: accent[1], b: accent[2] }

    mid = back.y + back.h / 2
    args.outputs.labels << {
      x: args.grid.w / 2, y: mid,
      text: "#{index + 1} / #{SLIDES.length}",
      size_enum: fs(args, 3), alignment_enum: 1, vertical_alignment_enum: 1,
      r: 170, g: 175, b: 205,
    }
    args.outputs.labels << {
      x: 70, y: mid,
      text: touch ? "Tap left / right" : "Left / Right / Space",
      size_enum: fs(args, 2), vertical_alignment_enum: 1,
      r: 130, g: 135, b: 165,
    }
    draw_button(args, back, "Back", BTN_CORAL)
  end

  # ---------------------------------------------------------------------------
  # Hero slide  (first / last)
  # ---------------------------------------------------------------------------

  def draw_hero_slide(args, slide, accent, touch, alpha)
    cx    = args.grid.w / 2
    ch    = args.grid.h
    port  = portrait?(args)

    # Wrap title tighter in portrait
    title_wrap  = port ? 18 : 24
    title_lines = wrap_lines(slide[:title], title_wrap)
    n           = title_lines.length

    # In portrait the canvas is much taller — anchor title to upper half
    title_centre_y = port ? (ch * 0.70).round : (ch * 0.62).round
    title_step     = port ? 72 : 88
    first_y        = title_centre_y + ((n - 1) * title_step / 2.0).round
    labels = []

    title_lines.each_with_index do |t, i|
      labels << { x: cx, y: first_y - i * title_step, text: t,
                  size_enum: port ? 14 : 18,
                  alignment_enum: 1, vertical_alignment_enum: 1,
                  r: 255, g: 255, b: 255, a: alpha }
    end

    last_y = first_y - (n - 1) * title_step
    bar_y  = last_y - 54
    args.outputs.sprites << { x: cx - 80, y: bar_y, w: 160, h: 8, path: :solid,
                              r: accent[0], g: accent[1], b: accent[2], a: alpha }

    y     = bar_y - 50
    lines = (touch && slide[:touch_lines]) || slide[:lines]
    body_wrap = port ? 32 : 60
    first = true
    lines.each do |line|
      if line.strip.empty?
        y -= 26
        next
      end
      wrap_lines(line, body_wrap).each do |part|
        size = first ? (touch ? 11 : 10) : (touch ? 9 : 8)
        size = [size - 2, 3].max if port    # scale down in portrait
        col  = first ? [accent[0], accent[1], accent[2]] : [215, 222, 255]
        labels << { x: cx, y: y, text: part, size_enum: size,
                    alignment_enum: 1, vertical_alignment_enum: 1,
                    r: col[0], g: col[1], b: col[2], a: alpha }
        y -= (port ? 42 : 54)
      end
      first = false
    end
    args.outputs.labels << labels
  end

  # ---------------------------------------------------------------------------
  # Section divider slide  ("PART n" + big centred title)
  # ---------------------------------------------------------------------------

  def draw_section_slide(args, slide, accent, touch, alpha, index)
    cx    = args.grid.w / 2
    ch    = args.grid.h
    port  = portrait?(args)
    wrap  = port ? 22 : 30
    step  = port ? 54 : 66

    title_lines = wrap_lines(slide[:title], wrap)
    n           = title_lines.length
    first_y     = port ? (ch * 0.60).round : (390 + (n - 1) * 33)
    labels      = []

    labels << { x: cx, y: first_y + (port ? 80 : 100),
                text: "PART #{slide_section(index)}",
                size_enum: touch ? 9 : 7,
                alignment_enum: 1, vertical_alignment_enum: 1,
                r: accent[0], g: accent[1], b: accent[2], a: alpha }

    title_lines.each_with_index do |t, i|
      labels << { x: cx, y: first_y - i * step, text: t,
                  size_enum: port ? 11 : 14,
                  alignment_enum: 1, vertical_alignment_enum: 1,
                  r: 255, g: 255, b: 255, a: alpha }
    end

    last_y = first_y - (n - 1) * step
    args.outputs.sprites << { x: cx - 80, y: last_y - 54, w: 160, h: 8, path: :solid,
                              r: accent[0], g: accent[1], b: accent[2], a: alpha }
    args.outputs.labels << labels
  end

  # ---------------------------------------------------------------------------
  # Content slide  (title + underline + auto-sizing bullet card)
  # ---------------------------------------------------------------------------

  def draw_content_slide(args, slide, accent, touch, alpha, index)
    labels  = []
    sprites = []
    port    = portrait?(args)
    cw      = args.grid.w
    ch      = args.grid.h

    left    = 26   # left margin (right of the accent strip)
    text_x  = left + 30

    # --- Title ---
    title_wrap  = port ? 26 : 42
    title_size  = port ? 7  : 10
    title_step  = port ? 52 : 64
    title_lines = wrap_lines(slide[:title], title_wrap)

    title_lines.each_with_index do |t, i|
      labels << { x: left, y: ch - 70 - i * title_step, text: t,
                  size_enum: title_size,
                  vertical_alignment_enum: 1,
                  r: 255, g: 255, b: 255, a: alpha }
    end
    last_title_y = ch - 70 - (title_lines.length - 1) * title_step
    sprites << { x: left, y: last_title_y - 36, w: 120, h: 6, path: :solid,
                 r: accent[0], g: accent[1], b: accent[2], a: alpha }

    # Faint slide number — anchored to right edge
    labels << { x: cw - 26, y: ch - 70,
                text: "#{index + 1}".rjust(2, "0"),
                size_enum: port ? 14 : 24, alignment_enum: 2, vertical_alignment_enum: 1,
                r: accent[0], g: accent[1], b: accent[2], a: (45 * alpha / 255) }

    # --- Body area ---
    body_top    = last_title_y - (port ? 90 : 120)
    footer_floor = layout(args).btn_back.y + layout(args).btn_back.h + 10
    lines       = (touch && slide[:touch_lines]) || slide[:lines]

    steps = if port
              SLIDE_STEPS_PORTRAIT
            elsif touch
              SLIDE_STEPS_TOUCH
            else
              SLIDE_STEPS_DESKTOP
            end

    size = steps.last[0]; line_h = steps.last[1]; entries = nil
    steps.each do |step|
      candidate  = lines.map { |l| flat, hl = split_head(l); [flat, hl, wrap_lines(flat, step[2])] }
      height     = candidate.sum { |e| e[2].length * step[1] + 12 }
      size       = step[0]; line_h = step[1]; entries = candidate
      bottom_est = body_top - (height - step[1] - 12) - step[1] / 2.0 - 22
      break if bottom_est >= footer_floor
    end

    marker = 12
    y      = body_top

    entries.each do |_flat, head_len, parts|
      next if parts.empty?
      sprites << { x: left, y: (y - marker / 2).round, w: marker, h: marker,
                   path: :solid, r: accent[0], g: accent[1], b: accent[2], a: alpha }

      offset = 0
      parts.each do |part|
        start      = offset
        offset    += part.length + 1
        head_chars = (head_len - start).clamp(0, part.length)

        if head_chars > 0
          head_text = part[0, head_chars]
          labels << { x: text_x, y: y, text: head_text, size_enum: size,
                      vertical_alignment_enum: 1,
                      r: accent[0], g: accent[1], b: accent[2], a: alpha }
          rest = part[head_chars, part.length - head_chars].to_s.lstrip
          unless rest.empty?
            w = text_width(args, head_text, size)
            labels << { x: text_x + w + 8, y: y, text: rest, size_enum: size,
                        vertical_alignment_enum: 1, r: 238, g: 240, b: 255, a: alpha }
          end
        else
          labels << { x: text_x, y: y, text: part, size_enum: size,
                      vertical_alignment_enum: 1, r: 238, g: 240, b: 255, a: alpha }
        end
        y -= line_h
      end
      y -= 12
    end

    # Translucent backing card
    last_center = y + line_h + 12
    card_top    = (body_top + line_h / 2.0 + 22).round
    card_bottom = [(last_center - line_h / 2.0 - 22).round, footer_floor].max
    card_bottom = card_top - 90 if card_top - card_bottom < 90

    args.outputs.sprites << [
      { x: 20, y: card_bottom, w: cw - 40, h: card_top - card_bottom,
        path: :solid, r: 255, g: 255, b: 255, a: (20 * alpha / 255) },
      { x: 20, y: card_bottom, w: 8, h: card_top - card_bottom,
        path: :solid, r: accent[0], g: accent[1], b: accent[2], a: alpha },
    ]
    args.outputs.sprites << sprites
    args.outputs.labels  << labels
  end

  # ---------------------------------------------------------------------------
  # slides_tick
  # ---------------------------------------------------------------------------

  def slides_tick(args)
    args.state.slide_index ||= 0
    previous_index = args.state.slide_index
    kb    = args.inputs.keyboard
    touch = touch_ui?(args)

    if kb.key_down.right || kb.key_down.space || kb.key_down.page_down
      args.state.slide_index += 1
    elsif kb.key_down.left || kb.key_down.page_up
      args.state.slide_index -= 1
    elsif tap_started?(args)
      pt = args.state.ptrs.first
      unless inside?(pt, layout(args).btn_back)
        args.state.slide_index += pt.x < args.grid.w * 0.35 ? -1 : 1
      end
    end
    args.state.slide_index = args.state.slide_index.clamp(0, SLIDES.length - 1)

    index = args.state.slide_index
    args.state.slide_shown_at = Kernel.tick_count if index != previous_index || args.state.slide_shown_at.nil?

    slide  = SLIDES[index]
    accent = ACCENTS[slide_section(index) % ACCENTS.length]
    alpha  = slide_alpha(args)

    draw_slide_background(args, accent)

    case slide_kind(index)
    when :hero    then draw_hero_slide(args, slide, accent, touch, alpha)
    when :section then draw_section_slide(args, slide, accent, touch, alpha, index)
    else               draw_content_slide(args, slide, accent, touch, alpha, index)
    end

    draw_slide_footer(args, index, accent, touch)
  end

end
