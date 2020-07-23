local flux = require "flux"

local S = {}

local loop
loop = function(graph)
  local dst = S.states.dst[S.states.current]
  local src = S.states.src[S.states.current]
  graph.tweens[1] = flux.to(graph, S.duration, dst)
    :delay(0.5) -- pause to let you see initial state
    :ease(graph.kind)
  graph.tweens[2] = graph.tweens[1]
    :after(S.duration, src)
    :delay(0.5) -- pause so you see they all finished
    :ease(graph.kind)
    :oncomplete(function()
      loop(graph)
    end)
end

local function stop_all_loops()
  for kind,graph in pairs(S.graphs) do
    for key,t in pairs(graph.tweens) do
      t:stop()
      graph.tweens[key] = nil
    end
    -- Snap to initial state
    for _,keyval in ipairs(S.states.src) do
      for key,val in pairs(keyval) do
        graph[key] = val
      end
    end
  end
  S.is_running = false
end

local function run_all_loops()
  S.states.label:set(S.states.names[S.states.current])
  stop_all_loops()
  for kind,graph in pairs(S.graphs) do
    loop(graph)
  end
  S.is_running = true
end

function love.load()
  local font = love.graphics.newFont(20)
  S.size = 100
  S.duration = 4
  S.graphs = {}
  S.keys = {}
  S.states = {
    label = love.graphics.newText(font),
    names = {
      "Translation",
      "Alpha",
      "Scale",
    },
    src = {
      { y = 0 },
      { alpha = 1 },
      { size = 10 },
    },
    dst = {
      { y = S.size },
      { alpha = 0 },
      { size = 50 },
    },

  }
  S.states.current = 1


  for kind,fn in pairs(flux.easing) do
    local g = { kind = kind, pts = {}, tweens = {} }

    for x=0,S.size,1 do
      table.insert(g.pts, x)
      table.insert(g.pts, fn(x/S.size)*S.size)
    end
    S.graphs[kind] = g
    table.insert(S.keys, kind)
  end
  table.sort(S.keys)

  -- need enough space for all graphs
  local dimensions = { 1200, 700 }
  love.window.setMode(unpack(dimensions))
  love.window.setTitle('flux - easing functions visualized')


  S.canvas_color = {1,1,1,1}
  S.canvas = love.graphics.newCanvas(unpack(dimensions))

  love.graphics.setCanvas(S.canvas)
  -- Clear to solid black to prevent transparency from causing text aliasing.
  -- https://love2d.org/forums/viewtopic.php?p=208884&sid=ac10f765ea06acb7f889a65c5059a610#p208884
  love.graphics.clear(0,0,0,1)
  S.draw_static_content()
  love.graphics.setCanvas()

  S.canvas_color[4] = 0

  flux.to(S.canvas_color, 0.5, {[4] = 1})
  run_all_loops()
end


function love.update(dt)
  if S.is_running then
    flux.update(dt)
  end
end


function love.keypressed(k)
  if k == "escape" then 
    love.event.quit()
  elseif k == "n" then 
    S.states.current = (S.states.current % #S.states.src) + 1
    run_all_loops()
  elseif k == "r" then 
    run_all_loops()
  elseif k == "space" then 
    S.is_running = not S.is_running
  end
end


function S.draw_static_content()
  love.graphics.push()

  local outside_pad = 50
  love.graphics.translate(outside_pad,outside_pad)
  love.graphics.push()
  local win_width, win_height = love.graphics.getDimensions()
  win_width = win_width - outside_pad
  win_height = win_height - outside_pad

  local x,y = 0,0
  local white = {1, 1, 1, 1}
  local grey = {0.3, 0.3, 0.3, 1}

  local xpad = 60
  local ypad = 50
  for i,kind in ipairs(S.keys) do
    local g = S.graphs[kind]
    love.graphics.setColor(grey)
    love.graphics.line(1,S.size, S.size,S.size)
    love.graphics.line(0,S.size, 0,0)
    love.graphics.setColor(white)
    love.graphics.points(g.pts)
    love.graphics.print(g.kind, 0, 100)

    local offset = S.size + xpad
    x = x + offset
    if x + S.size >= win_width then
      x = 0
      y = y + S.size + ypad
      love.graphics.pop()
      love.graphics.push()
      love.graphics.translate(0,y)
    else
      love.graphics.translate(offset,0)
    end

  end
  love.graphics.pop()
  love.graphics.pop()

  love.graphics.setColor(grey)
  love.graphics.printf("n - next mode, space - pause, r - restart", win_width - 400, win_height + 15, 400, "right")
end

function love.draw()
  local white = {1, 1, 1, 1}
  local grey = {0.3, 0.3, 0.3, 1}

  love.graphics.setColor(S.canvas_color)
  love.graphics.draw(S.canvas)
  love.graphics.setBlendMode("replace")

  love.graphics.push()

  local outside_pad = 50
  love.graphics.translate(outside_pad,outside_pad)
  love.graphics.push()
  local win_width, win_height = love.graphics.getDimensions()
  win_width = win_width - outside_pad
  win_height = win_height - outside_pad

  local x,y = 0,0

  local xpad = 60
  local ypad = 50
  for i,kind in ipairs(S.keys) do
    local g = S.graphs[kind]

    love.graphics.setColor(1, 1, 1, g.alpha)
    love.graphics.rectangle("fill", S.size, g.y, g.size, g.size)

    local offset = S.size + xpad
    x = x + offset
    if x + S.size >= win_width then
      x = 0
      y = y + S.size + ypad
      love.graphics.pop()
      love.graphics.push()
      love.graphics.translate(0,y)
    else
      love.graphics.translate(offset,0)
    end
  end

  love.graphics.pop()
  love.graphics.pop()

  love.graphics.setColor(white)
  love.graphics.draw(S.states.label, win_width/2 - S.states.label:getWidth()/2, win_height)

  love.graphics.setColor(grey)
  love.graphics.print("fps: " .. love.timer.getFPS() .. "\n" .. "tweens: " .. #flux.tweens, outside_pad, win_height)
end
