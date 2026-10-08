module Main

  FPS = 60
  GAME_SECONDS = 30
  RESTART_DELAY = FPS / 2 # half a second before restart input is accepted
  HIGH_SCORE_FILE = "high-score.txt"

  TARGET_SIZE = 64
  # min space between targets
  TARGET_GAP = 30

  # ---------- title ----------

  def title_tick args
    # load the saved high score so we can show it
    args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

    if fire_input?(args)
      args.outputs.sounds << "sounds/game-over.wav"
      start_gameplay_music(args) # music only begins when gameplay does
      args.state.scene = "gameplay"
      return
    end

    labels = []
    labels << {
      x: 40,
      y: args.grid.h - 40,
      text: "Nairuby 2D Gamedev",
      size_enum: 6,
    }
    labels << {
      x: 40,
      y: args.grid.h - 88,
      text: "Hit the targets!",
    }
    labels << {
      x: 40,
      y: args.grid.h - 120,
      text: "by Judahsan, from Building Games with DragonRuby",
    }
    labels << {
      x: 40,
      y: args.grid.h - 170,
      text: "High score: #{args.state.high_score}",
      size_enum: 3,
    }
    labels << {
      x: 40,
      y: 160,
      text: "Arrows or WASD to move | Z or J to fire | gamepad works too",
    }
    labels << {
      x: 40,
      y: 120,
      text: "Enter / Start to pause | P to toggle music",
    }
    labels << {
      x: 40,
      y: 80,
      text: "Fire to start",
      size_enum: 2,
    }
    args.outputs.labels << labels

    # animated dragon preview, same animation as in gameplay
    dragon_frame = 0.frame_index(count: 6, hold_for: 8, repeat: true)
    args.outputs.sprites << {
      x: 880,
      y: 280,
      w: 200,
      h: 160,
      path: "sprites/misc/dragon-#{dragon_frame}.png",
    }
  end

  # ---------- game over ----------

  def game_over_tick(args)
    args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

    if !args.state.saved_high_score && args.state.score > args.state.high_score
      args.gtk.write_file(HIGH_SCORE_FILE, args.state.score.to_s)
      args.state.saved_high_score = true
    end
    labels = []

    if args.state.score > args.state.high_score
      labels << {
        x: 260,
        y: args.grid.h - 90,
        text: "New high-score!",
        size_enum: 3,
      }
    else
      labels << {
        x: 260,
        y: args.grid.h - 90,
        text: "Score to beat: #{args.state.high_score}",
        size_enum: 3,
      }
    end

    labels << { x: 40, y: args.grid.h - 40, text: "Game Over!", size_enum: 10 }
    labels << { x: 40, y: args.grid.h - 90, text: "Score: #{args.state.score}", size_enum: 4 }
    labels << { x: 40, y: args.grid.h - 132, text: "Fire to restart", size_enum: 2 }

    args.outputs.labels << labels

    restart_game(args) if args.state.timer < -RESTART_DELAY && fire_input?(args)
  end

  # Clears the round's state and jumps straight back into gameplay
  # (instead of $gtk.reset, which wipes everything and lands on the title)
  def restart_game(args)
    args.state.player = nil
    args.state.fireballs = nil
    args.state.targets = nil
    args.state.score = nil
    args.state.timer = nil
    args.state.saved_high_score = nil
    args.state.high_score = nil # re-read from disk so a new record shows up
    args.state.paused = false

    start_gameplay_music(args)
    args.state.scene = "gameplay"
  end

  # ---------- gameplay ----------

  def gameplay_tick(args)
    args.outputs.sprites << {
      x: 0,
      y: 0,
      w: args.grid.w,
      h: args.grid.h,
      path: :solid,
      r: 92,
      g: 120,
      b: 230,
    }
    setup_state(args)
    handle_pause(args)

    if args.state.paused
      # frozen frame: draw everything, but run no game logic
      render(args)
      render_pause_overlay(args)
      return
    end

    args.state.timer -= 1

    if args.state.timer == 0
      args.audio[:music].paused = true
      args.outputs.sounds << "sounds/game-over.wav"
    end

    if args.state.timer < 0
      game_over_tick(args)
      return
    end

    handle_music_toggle(args)
    handle_player_movement(args)
    handle_fire(args)
    update_fireballs(args)
    render(args)
  end

  # circle overlap
  def circle_overlap?(a, b, gap = 0)
    ar = a.w / 2
    br = b.w / 2
    dx = (a.x - ar) - (b.x - br)
    dy = (a.y - ar) - (b.y - br)
    dx * dx + dy * dy < (ar + br + gap) ** 2
  end

  def spawn_target(args, existing = [])
    candidate = nil

    20.times do
      candidate = {
        # x gutter: stays on the screen
        x: rand(args.grid.w * 0.4 - TARGET_SIZE) + args.grid.w * 0.6,
        y: rand(args.grid.h - TARGET_SIZE * 2) + TARGET_SIZE,
        w: TARGET_SIZE,
        h: TARGET_SIZE,
        path: 'sprites/target.png'
      }

      # ensure targets keep distance
      return candidate unless existing.any? { |t| circle_overlap?(candidate, t, TARGET_GAP) }
    end

    # stops after 20 tries to avoid infinite loop
    candidate
  end

  # ---------- input ----------

  # One place to change the fire keys (used for shooting AND restarting)
  def fire_input?(args)
    args.inputs.keyboard.key_down.z ||
      args.inputs.keyboard.key_down.j ||
      args.inputs.controller_one.key_down.a
  end

  # Enter or the gamepad Start button pauses / resumes
  def pause_input?(args)
    args.inputs.keyboard.key_down.enter ||
      args.inputs.controller_one.key_down.start
  end

  # ---------- setup ----------

  def setup_state(args)
    args.state.player ||= {
      x: 120,
      y: 280,
      w: 100,
      h: 80,
      base_speed: 12,
      path: 'sprites/misc/dragon-0.png',
    }

    player_sprite_index = 0.frame_index(count: 6, hold_for: 8, repeat: true)
    args.state.player[:path] = "sprites/misc/dragon-#{player_sprite_index}.png"

    args.state.fireballs ||= []
    args.state.score ||= 0
    args.state.timer ||= GAME_SECONDS * FPS
    args.state.paused ||= false

    return if args.state.targets

    args.state.targets = []
    5.times { args.state.targets << spawn_target(args, args.state.targets) }
  end

  # ---------- music ----------

  # Called when gameplay begins (first start AND every restart).
  # Assigning to the same key replaces whatever was playing before.
  def start_gameplay_music(args)
    args.audio[:music] = { input: "sounds/flight.ogg", looping: true }
  end

  # Press P to pause / resume the music
  def handle_music_toggle(args)
    music = args.audio[:music]
    return unless music
    return unless args.inputs.keyboard.key_down.p

    music.paused = !music.paused
  end

  # ---------- pause ----------

  def handle_pause(args)
    return if game_over?(args) # no pausing once the round has ended
    return unless pause_input?(args)

    args.state.paused = !args.state.paused

    music = args.audio[:music]
    music.paused = args.state.paused if music
  end

  def render_pause_overlay(args)
    args.outputs.sprites << {
      x: 0,
      y: 0,
      w: args.grid.w,
      h: args.grid.h,
      path: :solid,
      r: 0,
      g: 0,
      b: 0,
      a: 140,
    }
    args.outputs.labels << [
      {
        x: args.grid.w / 2,
        y: args.grid.h / 2 + 20,
        text: "Paused",
        size_enum: 12,
        alignment_enum: 1,
        r: 255, g: 255, b: 255,
      },
      {
        x: args.grid.w / 2,
        y: args.grid.h / 2 - 40,
        text: "Enter / Start to resume",
        size_enum: 2,
        alignment_enum: 1,
        r: 255, g: 255, b: 255,
      }
    ]
  end

  # ---------- game over ----------

  def game_over?(args)
    args.state.timer < 0
  end

  # ---------- player ----------

  def handle_player_movement(args)
    player = args.state.player

    # Movement vector
    dx = 0
    dy = 0
    dx -= 1 if args.inputs.left
    dx += 1 if args.inputs.right
    dy += 1 if args.inputs.up
    dy -= 1 if args.inputs.down

    # Normalize so diagonal movement isn't faster
    magnitude = Math.sqrt(dx ** 2 + dy ** 2)
    if magnitude > 0
      player[:x] += (dx / magnitude) * player[:base_speed]
      player[:y] += (dy / magnitude) * player[:base_speed]
    end

    # Set boundaries
    player[:x] = player[:x].clamp(0, args.grid.w - player[:w])
    player[:y] = player[:y].clamp(0, args.grid.h - player[:h])
  end

  def handle_fire(args)
    return unless fire_input?(args)

    player = args.state.player
    args.outputs.sounds << "sounds/fireball.wav"
    args.state.fireballs << {
      x: player[:x] + player[:w] - 12,
      y: player[:y] + 10,
      w: 32,
      h: 32,
      path: 'sprites/misc/fireball-0.png',
      # each fireball remembers when it spawned so it animates from frame 0
      created_at: Kernel.tick_count
    }
  end

  # ---------- fireballs & targets ----------

  def update_fireballs(args)
    args.state.fireballs.each do |fireball|
      fireball[:x] += args.state.player[:base_speed] + 2

      # advance this fireball's animation frame
      frame = fireball[:created_at].frame_index(count: 4, hold_for: 8, repeat: true)
      fireball[:path] = "sprites/misc/fireball-#{frame}.png"

      if fireball.x > args.grid.w
        fireball.dead = true
        next
      end

      check_fireball_hits(args, fireball)
    end

    args.state.targets.reject! { |t| t.dead }
    args.state.fireballs.reject! { |f| f.dead }
  end

  def check_fireball_hits(args, fireball)
    args.state.targets.each do |target|
      next if target.dead
      next unless circle_overlap?(target, fireball)

      target.dead = true
      fireball.dead = true
      args.state.score += 1

      live = args.state.targets.reject { |t| t.dead }
      args.state.targets << spawn_target(args, live)
      break
    end
  end

  # ---------- rendering ----------

  def render(args)
    args.outputs.sprites << [args.state.player, args.state.fireballs, args.state.targets]

    args.outputs.labels << [
      {
        x: 40,
        y: args.grid.h - 40,
        text: "Score: #{args.state.score}",
        size_enum: 4,
      },
      {
        x: args.grid.w - 40,
        y: args.grid.h - 40,
        text: "Time Left: #{(args.state.timer / FPS).round}",
        size_enum: 2,
        alignment_enum: 2,
      }
    ]
  end

  # ---------- slides ----------

  SLIDES = [
    { title: "2D Game Dev & the Kenyan Gaming Ecosystem",
      lines: ["DragonRuby GTK, and the Kenyan ecosystem"] },

    { title: "About Me",
      lines: ["Me: reads slide",
              "Audience: reads slide",
              "",
              "[VISIBLE CONFUSION]",
              "",
              "We're both reading it for the first time"
      ] },

    { title: "Connecting Play & Game design",
      lines: ["What was the very first digital game you ever played?",
              "What is your favourite non-digital game growing up?"] },

    { title: "Notable Mentions",
      lines: ["Snake, bounce, Doom, super mario, nfs",
              "Kati, stick of death, bano, kalongolongo"] },

    { title: "Evolution of Video Games",
      lines: ["1947–1972 (Pre-Industry): Hobbyist patents &amp; *Spacewar!*[2][6].",
              "1972–1983 (Atari Era): Coin-op monetization born; ended in the 1983 US crash[2].",
              "1983–1989 (Nintendo Era): NES licensing safeguards the market and gatekeeps developers[2][8].",
              "1989–1995 (Console Wars Era): Sega Genesis vs. Nintendo; 16-bit market polycentrism[2][8].",
              "1995–2006 (PC &amp; 3D Era): PlayStation, Xbox, and 3D graphics hardware[2][8].",
              "2006–Present (Post-Revolution Era): The indie revolution (digital storefronts/democratized engines) and casual/mobile platforms"] },

    { title: "Evolution of Game Engines: From Custom Code to Modding Culture",
      lines: ["The Olden Days: Developers wrote memory
              allocation, graphics pipelines, and physics from
              scratch for every single game.",
              "id Software, creators of Doom, Quake and Wolfenstein 3D, pioneered the modern engine.",
              "Modern Engine Onset: Unity, Unreal, and Godot
              standardized development through visual editors and
              component systems.",
      ] },

    { title: "Cont...",
      lines: ["Modding existing games is the best entertainment and hands-on learning environment for beginners.",
              "Modders inspect game loops, tweak variables, and add content without building from scratch",
              "Notable example: Euro truck Simulator 2",
              "Some 'bad actors' were able to jailbreak the PS5 ",
              "Modding bridges the gap between playing and professional engineering"] },

    { title: "Production Lifecycle",
      lines: ["The 4-Phase Pipeline",
              "Ideation → Pre-Production (GDD and Prototyping) → Full Production → Post-Production/Live Ops.",
              "Playcentric Research",
              "Start playtesting as early as possible. Conduct user research, gather feedback, and iterate on your game design.",
              "Defining player experience goals prevent scope creep and ensure studio sustainability"] },

    { title: "Why DragonRuby?",
      lines: ["Ruby: expressive, built for developer happiness",
              "Pure 2D, array/hash based rendering",
              "Live reload: edit code while the game runs",
              "DragonRuby launches instantly, eliminating waiting for
heavy engine compiles.",
              "One command to ship to web, desktop, mobile"] },

    { title: "Why NOT DragonRuby?",
      lines: ["Paid license model: pay a fee to build for mobile and unlock premium features",
              "Strictly 2D: No native 3D rendering pipeline — 3D projects require Unity, Godot, or Unreal.",] },

    { title: "Live demo",
      lines: ["Press TAB to jump into the game",
              "Press TAB again to come back here"] },

    { title: "Market landscape",
      lines: [
        "Mobile Dominance: Mobile gaming drives nearly 90% of
African gaming revenues.",
        "South Africa $266M+, Nigeria $249M, Kenya $46M",
        "Mobile-first: 63.2% mobile adoption, 76% digital payments"] },
    { title: "Africa's Mobile Market Growth & Habit Loop Player Monetization",
      lines: [] },

    { title: "Regional Market Landscape",
      lines: ["Mobile Dominance: Mobile gaming drives nearly 90% of African gaming revenues.",
              "South Africa & Nigeria: South Africa ($266M-$333M) and Nigeria ($249M) lead continental revenues.",
              "Kenya Market ($46M Revenue): Backed by 63.2% mobile adoption and 76% digital payment penetration.",
              "Urban Paying Players: Over 30% of urban mobile gamers in Nairobi make regular in-app purchases."] },

    { title: "Case Study: Habit Loop Monetization",
      lines: ["Animal Crossing: Pocket Camp Experience: Played despite region lock restrictions requiring a VPN to access!",
              "Why Consider In-App Purchases? Not paywalls, but building a meaningful daily habit loop and long-term retention.",
              "The Game Design Lesson: Monetization happens when players form a genuine daily relationship with your game world."] },

    { title: "Navigating the Creative, Ethical & Human Touch Debate Surrounding AI",
      lines: [] },

    { title: "The 'Human Touch' & Ethical Split",
      lines: ["Artist Concerns: Critics argue AI art erodes original human craft, authenticity, and artist compensation.",
              "IP & Dataset Consent: Unresolved legal questions regarding training data copyright and stolen assets.",
              "The Developer's Choice: AI is a speed amplifier. Final artistic direction, soul, and ethical standards remain in human hands."] },

    { title: "Speed, Prototyping & Security",
      lines: ["Rapid Prototyping: Solo devs turn rough concepts into playable prototypes in a single day.",
              "Code Analysis & Reverse Engineering: Devs use LLMs to deconstruct legacy assembly code and analyze game binaries.",
              "Console Exploits & Modding: AI assists researchers in identifying memory vulnerabilities and building homebrew software."] },

    { title: "Local Champions Shaping Global & Regional Game Franchises",
      lines: [] },

    { title: "Local Champions",
      lines: ["Maliyo Games (Nigeria): 40+ mobile titles released (Whot King); partnered with Disney Games to launch 'Disney Iwaju: Rising Chef' globally.",
              "Leti Arts (Ghana/Kenya): Pioneering African superhero IP ('Sweave') integrating traditional cultural symbols (Gye Nyame) and Riot Games collabs.",
              "Mekan Games (Kenya): Creators of 'The President' (#1 viral hit in US/UK/Canada with 27M+ players) and everyday mobility games.",
              "Kunta Content (Kenya): Developing rich narrative games like 'Hiru' and releasing 'Bankush' on the global Minecraft Marketplace."] },

    { title: "Overcoming Policy Hurdles & Leveraging Esports as Marketing Engines",
      lines: [] },

    { title: "Policy & Infrastructure Barriers",
      lines: ["Government Misconception: Kenya & regional policymakers mistakenly conflate video game development with the gambling/betting industry.",
              "Funding Shortage: Only 3% of African game developers have ever received direct government funding support.",
              "Infrastructure Challenges: Power instability, variable internet bandwidth, and payment gateway friction."] },

    { title: "Esports as a Growth Catalyst",
      lines: ["Community-Powered Marketing: Esports isn't just playing games. It builds brand-new consumer markets from scratch.",
              "Rapid Adoption: Grassroots tournaments and university leagues drive youth engagement across Kenya.",
              "Monetization Potential: Sponsorships, broadcast rights, and brand partnerships powering local talent."] },

    { title: "Mixing Creative Studio Culture with Smart Capital & Impact Gaming",
      lines: [] },

    { title: "Smart Money Funding Options",
      lines: ["The VC Challenge: Traditional VCs struggle with gaming IP predictability; studios must mix artistry with agile startup culture.",
              "Non-Dilutive Grants: Great for early prototyping seed capital, but non-recurring.",
              "Publisher Deals: High-win corporate co-productions (e.g. Maliyo x Disney, Leti Arts x Riot).",
              "Creative VCs & Community: Specialized gaming funds understanding studio development lifecycles."] },

    { title: "Gamifying Real Life (Impact Games)",
      lines: ["Green Tech Integration: Pokemon GO-style tree planting verified against real carbon credits.",
              "Real Estate & Construction: Gamifying architecture, 3D visualizers, and urban planning.",
              "Financial Literacy: Nedbank 'Chow Town' on Roblox teaching youth entrepreneurship."] },

    { title: "Getting Investor-Ready to Scale African Gaming to Global Prominence",
      lines: [] },

    { title: "Investor Readiness Checklist",
      lines: ["Clean Cap Table: Uncomplicated ownership structures without legal disputes.",
              "Tax & Regulatory Compliance: Full registration and compliance with local tax authorities.",
              "2 Years Clean Financials: Transparent accounting and revenue tracking.",
              "3-Year Strategic Plan: Clear roadmap for IP expansion, UA, and monetization.",
              "Corporate Governance: Basic advisory board and financial controls in place."] },

    { title: "THE BIG TAKEAWAY",
      lines: ["Gaming and Esports are not just entertainment. They are engine blocks for digital economy expansion, youth employment, and cultural export across Africa.",
              "With lightweight 2D tools like DragonRuby GTK and AI workflows, your imagination is the only limitation!"] },

    { title: "Thank You!",
      lines: ["Arigato!",
              "",
              "Questions? Let's talk games.",
              "by Judahsan"] },

  ]

  def toggle_slides(args)
    if args.state.scene == "slides"
      args.state.scene = args.state.return_scene || "title"
    else
      args.state.return_scene = args.state.scene

      # freeze a round in progress so the timer doesn't run while you present
      if args.state.scene == "gameplay" && args.state.timer && args.state.timer >= 0
        args.state.paused = true
        music = args.audio[:music]
        music.paused = true if music
      end

      args.state.scene = "slides"
    end
  end

  def slides_tick(args)
    args.state.slide_index ||= 0
    kb = args.inputs.keyboard

    if kb.key_down.right || kb.key_down.space || kb.key_down.page_down
      args.state.slide_index += 1
    elsif kb.key_down.left || kb.key_down.page_up
      args.state.slide_index -= 1
    end
    args.state.slide_index = args.state.slide_index.clamp(0, SLIDES.length - 1)

    slide = SLIDES[args.state.slide_index]

    args.outputs.sprites << {
      x: 0, y: 0, w: args.grid.w, h: args.grid.h,
      path: :solid, r: 30, g: 30, b: 36,
    }

    labels = []

    title_lines = slide[:title].wrap(45).split("\n")
    title_lines.each_with_index do |t, i|
      labels << { x: 60, y: args.grid.h - 70 - i * 56, text: t,
                  size_enum: 8, r: 220, g: 40, b: 60 }
    end
    y = args.grid.h - 170
    slide[:lines].each do |line|
      line.wrap(70).split("\n").each_with_index do |part, i|
        labels << { x: 60 + (i > 0 ? 24 : 0), y: y, text: (i == 0 ? "• " : "") + part,
                    size_enum: 4, r: 240, g: 240, b: 240 }
        y -= 44
      end
      y -= 12
    end

    labels << { x: args.grid.w - 40, y: 30,
                text: "#{args.state.slide_index + 1} / #{SLIDES.length}",
                alignment_enum: 2, r: 160, g: 160, b: 160 }

    args.outputs.labels << labels
  end

  # ---------- main loop ----------

  def tick args
    args.state.scene ||= "title"

    toggle_slides(args) if args.inputs.keyboard.key_down.tab
    send("#{args.state.scene}_tick", args)
  end

  # reset game
  $gtk.reset

end