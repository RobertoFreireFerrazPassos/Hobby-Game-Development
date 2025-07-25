pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- main game
function _init()
	state = intro
	menuitem(1, "return to menu", function()
		state = menu
	end)
end

function _update()
	state:update()
end

function _draw()
	cls()
	state:draw()
end

intro = {
	t = 0,
	update = function(this)
		this.t += 1

		-- press z/x to continue
		if btnp(4) or btnp(5) then
			state = menu
		end
	end,
	draw = function(this)
		-- background flicker effect (simulate digital ai feel)
		for i=0,128,8 do
			for j=0,128,8 do
				pset(i, j, rnd(1) > 0.95 and 5 or 0)
			end
		end

		-- title text with slight oscillation
		local title_y = 20 + sin(this.t/20) * 2
		print("\^wneural trainer", 12, title_y, 11)

		-- subtitle
		print("by roberto freire", 24, 36, 6)

		-- flashing "press z/x to start"
		if (this.t \ 30) % 2 == 0 then
			print("press 🅾️/❎ to start", 28, 90, 7)
		end
	end
}

menu = {
	update = function()
    if btnp(4) or btnp(5) then
        state=game
        game.init()
    end
    
    if btnp(0) and curtlvl > 0 then
        curtlvl-=1
    end
    
    if btnp(1) and curtlvl < #levels then
        curtlvl+=1
    end
	end,	
	draw = function()			
    for i=1,#levels do
    				local initspr = levels[i].win and 15 or 79
        spr(i+initspr,24+(i-1)*24,60)
        if curtlvl == i then
        				pal(6,12)
            spr(1,24+(i-1)*24,60)
            pal()
        end
    end
	end
}

game = {
	init = function()
		levels[curtlvl]:init()
     build_nn_ui()
     replace_labels()
     cursor = {x=0, y=0}
	end,
	update = function()
					local lvl = levels[curtlvl]
					if not lvl.win and lvl.score > 15 then
						sfx(1)
						lvl.win = true
					end
	    lvl:update()
	    updateneuralnetwork()
	end,	
	draw = function()					
     levels[curtlvl]:draw()
     drawneuralnetwork()
     local lvl = levels[curtlvl]
					print("score: "..lvl.score, 80, 2,lvl.win and 9 or 7)
	end
}
-->8
-- levels
curtlvl=1
levels = {}

-- dino
levels[1] = {
 score = 0,
 win = false,
	dino_x = 2,
	dino_y = 56,
	dino_vy = 0,
	on_ground = true,
	obstacle={},
	obs_speed = 1,
    nn_structure = {
        input = 1,
        hidden = { 1, 1 }, -- two hidden layers
        output = 1,
    },
    nn_labels = {
        input = { "distance from obstacle" },
        output = { 48 }
    },
	add_obstacle = function(this)
	  this.obstacle={
        x = flr(128+rnd(32)),
        passed = false
    }
	end,
	init = function(this)
        this:add_obstacle()
	end,
	update = function(this)
			this.obstacle.x -= this.obs_speed

   -- increment score
   if this.obstacle.x + 8 < this.dino_x and not this.obstacle.passed then
       this.score += 1
       this.obstacle.passed = true
   end

   if this.obstacle.x < -8 then
       this:add_obstacle()
   end

   local x0 = flr(this.dino_x - this.obstacle.x)/12
   nn_input = { x0 }
   local y = ui_elements[#ui_elements].v

   if y > 0 and this.on_ground then
       this.dino_vy = -5
       this.on_ground = false
   end
   
   this.dino_y += this.dino_vy
   if not this.on_ground then
       this.dino_vy += 0.5
   end
   if this.dino_y >= 56 then
       this.dino_y = 56
       this.dino_vy = 0
       this.on_ground = true
   end

   -- collision detection
   if this.dino_x + 8 > this.obstacle.x + 2 and this.dino_x < this.obstacle.x + 6 and this.dino_y + 8 > 62 then
       sfx(0)
       this.score = 0
       this:add_obstacle()
   end
	end,
	draw = function(this)
					rectfill(0, 0, 127, 63, 15)    
					line(0, 64, 127, 64, 5)
     spr(16,this.dino_x, this.dino_y)
     spr(32,this.obstacle.x, 56)
	end
}

-- bird
levels[2] = {
    score = 0,
    win = false,
    bird_x = 20,
    bird_y = 40,
    bird_vy = 0,
    gravity = 0.5,
    flap_strength = -3,
    pipes = {},
    pipe_gap = 24,
    pipe_width = 10,
    obs_speed = 1,
    nn_structure = {
        input = 2,
        hidden = { 1, 1 }, -- two hidden layers
        output = 1,
    },
    nn_labels = {
        input = { "distance x from hole", "distance y from hole" },
        output = { 49 }
    },
    add_obstacle = function(this)
        this.pipes = { 
            x = flr(128+rnd(32)), gap_y = 8 + flr(rnd(24)),
            passed = false
        }
    end,
    init = function(this)
        this.pipes = {}
        this.bird_y = 40
        this.bird_vy = 0
        this:add_obstacle()
    end,
    update = function(this)
        this.bird_vy = 0

        -- increment score
        if this.pipes.x + 8 < this.bird_x and not this.pipes.passed then
            this.score += 1
            this.pipes.passed = true
        end

        -- calculate x0 (horizontal distance to pipe) and x1 (vertical distance to hole)
        if this.pipes then
            local x0 = (this.pipes.x + this.pipe_width / 2 - this.bird_x) / 128
            local x1 = ((this.pipes.gap_y + this.pipe_gap / 2) - this.bird_y) / 128

            nn_input = { x0, x1 }

            local y = ui_elements[#ui_elements].v

            if y > 0 then
                this.bird_vy = this.flap_strength
            end
        end

        -- bird physics
        this.bird_vy += this.gravity
        this.bird_y += this.bird_vy

        -- update pipe
        this.pipes.x -= this.obs_speed

        -- remove and add pipes
        if this.pipes.x < -8 then
            this:add_obstacle()
        end

        -- ground collision
        if this.bird_y > 56 then
            this.bird_y = 56
            this.bird_vy = 0
        end
        
        -- ceiling collision
        if this.bird_y < 0 then
            this.bird_y = 0
        end

        -- collision detection
        if this.pipes.x < this.bird_x and this.pipes.x + 8 > this.bird_x 
            and (this.bird_y < this.pipes.gap_y or this.bird_y +  8 > this.pipes.gap_y + this.pipe_gap) then
            sfx(0)
            this.score = 0
            this:add_obstacle()
        end
    end,
    draw = function(this)
        rectfill(0, 0, 127, 64, 12) -- sky
        rectfill(0, 60, 127, 64, 3) -- ground

        -- bird
        spr(17,this.bird_x, this.bird_y)

        -- pipe
        rectfill(this.pipes.x, 0, this.pipes.x+this.pipe_width, this.pipes.gap_y - 1, 11)
        rectfill(this.pipes.x, this.pipes.gap_y + this.pipe_gap, this.pipes.x+this.pipe_width, 64, 11)
    end
}

-- ping pong
levels[3] = {
	score = 0,
	paddle_y = 28,
	ball = {},
	ball_speed = {x = 1, y = 1},
	nn_structure = {
    input = 2,
    hidden = { 2, 2 },
    output = 2,
 },
 nn_labels = {
    input = { "distance x from ball", "distance y from ball" },
    output = { 49, 50 }
 },
	add_ball = function(this)
		this.ball = {
			x = 10,
			y = 32,
			dir_x = 1,
			dir_y = rnd({-1, 1})
		}
	end,
	init = function(this)
		this:add_ball()
	end,
	update = function(this)
		local x0, x1 = (this.ball.x - 4) / 127,
		 (this.ball.y - (this.paddle_y + 4)) / 64
		
		nn_input = { x0, x1 }
		
		local y0, y1 = ui_elements[#ui_elements-1].v,
			ui_elements[#ui_elements].v

		-- player control
		if y0 > 0 then
			this.paddle_y -= 1
		end
        if y1 > 0 then
			this.paddle_y += 1
		end
		this.paddle_y = mid(0, this.paddle_y, 56)

		-- move ball
		this.ball.x += this.ball.dir_x * this.ball_speed.x
		this.ball.y += this.ball.dir_y * this.ball_speed.y

		-- top/bottom wall collision
		if this.ball.y <= 0 or this.ball.y >= 63 then
			this.ball.dir_y *= -1
		end

		-- right wall: score
		if this.ball.x >= 127 then
			this.score += 1
			this.ball.dir_x *= -1
		end

		-- left wall: reset
		if this.ball.x <= 0 then
			this.score = 0
			sfx(0)
			this:add_ball()
		end

		-- paddle collision
		if this.ball.x <= 6 and this.ball.y >= this.paddle_y and this.ball.y <= this.paddle_y + 8 then
			this.ball.dir_x *= -1
			this.ball.x = 6 -- prevent sticking
		end
	end,
	draw = function(this)
		-- draw walls
		rect(0, 0, 127, 63, 7)
		-- draw paddle (left side)
		rectfill(2, this.paddle_y, 4, this.paddle_y + 8, 11)
		-- draw ball
		circfill(this.ball.x, this.ball.y, 2, 8)
	end
}

-- catch the apple
levels[4] = {
    score = 0,
    win = false,
    basket_x = 60,
    basket_w = 16,
    basket_h = 12,
    object = {},
    gravity = 1,
    speed = 1,    
    nn_structure = {
        input = 4,
        hidden = { 3, 4, 2 },
        output = 2,
    },    
    nn_labels = {
        input = { "x distance to object", "y distance to object", "apple", "bomb" },
        output = { 51, 52 }
    },
    add_object = function(this)
        this.object = {
            x = 32 + flr(rnd(40)),
            y = -8,
            type = rnd() < 0.5 and "apple" or "bomb"
        }
    end,
    init = function(this)
        this:add_object()
    end,
    update = function(this)
        -- move basket with ai output or player
        local x0, x1, x2, x3 = (this.object.x - 4 - this.basket_x) / 16,
            (this.object.y - 60) / 16,
            this.object.type == "apple" and 1 or -1,
            this.object.type == "bomb" and 1 or -1
        nn_input = { x0, x1, x2, x3 }

        local y0, y1 = ui_elements[#ui_elements-1].v,
									ui_elements[#ui_elements].v

        -- move basket (left or right)
        if y0 > 0 then
            this.basket_x -= this.speed
        end
        if y1 > 0 then
            this.basket_x += this.speed
        end
        this.basket_x = mid(16, this.basket_x, 98 - this.basket_w)

        -- move object down
        this.object.y += this.gravity

        local ox = this.object.x + 4
        local oy = this.object.y + 4
        local bx1 = this.basket_x
        local bx2 = this.basket_x + this.basket_w
        local by = 56

        -- check if object is in basket
        local in_basket = ox > bx1 and ox < bx2 and oy > by and oy < by + this.basket_h + 8

        if this.object.type == "apple" then
            if in_basket then
                this.score += 1
                this:add_object()
            elseif this.object.y > 56 then
                this.score = 0
                sfx(0)
                this:add_object()
            end
        elseif this.object.type == "bomb" then
            if in_basket then
                this.score = 0
                sfx(0)
                this:add_object()
            elseif this.object.y > 56 then                
                this:add_object()
            end
        end
    end,
    draw = function(this)
        rectfill(0, 0, 127, 63, 12) -- sky
        rectfill(0, 62, 127, 64, 11) -- ground

        -- draw object
        if this.object.type == "apple" then
            circfill(this.object.x + 4, this.object.y + 4, 3, 8) -- red apple
        else
            spr(19,this.object.x, this.object.y) -- black
        end
        
        -- draw basket
        rectfill(this.basket_x, 52, this.basket_x + this.basket_w, 52 + this.basket_h, 9)
    end
}

-- to do next levels[5]
todo = {
 score = 0,
 win = false,
	init = function(this)
	end,
	update = function(this)
	end,
	draw = function(this)
			print("level: "..2,10,10)
	end
}
-->8
-- neural network
nn_input = { } -- this will be a dinamic value for "distance from obstacle"
knob_values = { -2.5, -2, -1.5, -1, 0, 1, 1.5, 2, 2.5 }

xs = {} -- x0, x1,...

--[[
ui_elements
{
  { id="in1", grid_x=0, grid_y=0, label="in1", v=0 }, -- v is input value 1
  { id="in2", grid_x=0, grid_y=1, label="in2", v=0 }, -- v is input value 2
  { id="h1_1", grid_x=1, grid_y=0, label="hidden layer: 1_1", v=0 }, -- v is the node result value from wo*xo + w1*x1 + .. + bias
  { id="h1_2", grid_x=1, grid_y=1, label="hidden layer: 1_2", v=0 }, -- v is the node result value from wo*xo + w1*x1 + .. + bias
  { id="h2_1", grid_x=2, grid_y=0, label="hidden layer: 2_1", v=0 }, -- v is the node result value from wo*xo + w1*x1 + .. + bias
  { id="out1", grid_x=3, grid_y=0, label="", v=0 } -- v is output value 1
}
ui_knobs
{
  { {v=5}, {v=5}, {v=5} }, -- h1_1 (takes 2 inputs, 2 weights + 1 bias)
  { {v=5}, {v=5}, {v=5} }, -- h1_2 (takes 2 inputs, 2 weights + 1 bias)
  { {v=5}, {v=5}, {v=5} }  -- h2_1 (takes 2 inputs from previous hidden layer, 2 weights + 1 bias)
}
]]

function process_input()
    for i=1, levels[curtlvl].nn_structure.input do
        ui_elements[i].v = nn_input[i]
        add(xs,nn_input[i])
    end
end

function process_layer(s,l)
    local new_xs = {}

    for i=s + 1, s + levels[curtlvl].nn_structure.hidden[l] do
        local sum = 0
        for j=1, #ui_knobs[i - levels[curtlvl].nn_structure.input] do
            if j == #ui_knobs[i - levels[curtlvl].nn_structure.input] then
                sum+= knob_values[ui_knobs[i - levels[curtlvl].nn_structure.input][j].v]
            else
                sum+= knob_values[ui_knobs[i - levels[curtlvl].nn_structure.input][j].v]*xs[j]
            end
        end
        ui_elements[i].v = sigmoid(sum)
        add(new_xs,ui_elements[i].v)
    end

    xs = new_xs
end

function sigmoid(res)
  return res > 0 and 1 or -1
end

function process_output()
    local len = levels[curtlvl].nn_structure.output
    for i=1, len do
        ui_elements[#ui_elements - len + i].v = xs[i]
    end
end

function process_layers()
    xs={}
    process_input()    
    local startidx=levels[curtlvl].nn_structure.input
    for i=1, #levels[curtlvl].nn_structure.hidden do
        process_layer(startidx,i)
        startidx+=levels[curtlvl].nn_structure.hidden[i]
    end
    process_output()
end

-- build ui_elements from neural network
ui_elements = {}
ui_knobs = {}
knob_idx = 1
ui_knob_idx = 0
knob_curlen = 1
ui_layer = 1 -- 1 - neural network, 2 - knobs

function replace_labels()
    local inputlen = 1
    local outputlen = 1
    for i,e in pairs(ui_elements) do
        if i <= levels[curtlvl].nn_structure.input then
            e.label = levels[curtlvl].nn_labels.input[inputlen]
            inputlen+=1
        elseif i > #ui_elements - levels[curtlvl].nn_structure.output then
            e.label = levels[curtlvl].nn_labels.output[outputlen]
            outputlen+=1
        end
    end
end

function build_nn_ui()
    nn_input = { }
    xs = {}
    ui_elements = {}
    ui_knobs = {}
    knob_idx = 1
    ui_knob_idx = 0
    knob_curlen = 1
    ui_layer = 1
    local layer_x = 0

    -- input layer
    for i=1, levels[curtlvl].nn_structure.input do
        add(ui_elements, {
            id="in"..i, 
            grid_x=layer_x, 
            grid_y=i-1,
            label="in"..i,
            v=0
        })
    end
    
    local lenlastlayer = levels[curtlvl].nn_structure.input

    -- hidden layers
    for l=1, #levels[curtlvl].nn_structure.hidden do
        layer_x += 1
        local count = levels[curtlvl].nn_structure.hidden[l]
        for i=1, count do
            add(ui_elements, {
                id="h"..l.."_"..i,
                grid_x=layer_x, grid_y=i-1,
                label="hidden layer: "..l.."_"..i,
                v=0 -- w0x0 + w1x1 + ... + bias
            })

            local knob = {}
            for i=1, lenlastlayer do
                add(knob, { 
                    label="w"..(i -1),
                    v = 5 
                }) -- weights
            end
            add(knob, {
                label="bias",
                v = 5 
            }) -- bias
            add(ui_knobs, knob)
        end
        lenlastlayer = count
    end

    -- output layer
    layer_x += 1
    for i=1, levels[curtlvl].nn_structure.output do
        add(ui_elements, {
            id="out"..i, 
            grid_x=layer_x, grid_y=i-1,
            label="",
            v=0
        })
    end
end

function get_element_at(x, y)
    for e in all(ui_elements) do
        if e.grid_x == x and e.grid_y == y then
            return e
        end
    end
    return nil
end

function move_cursor(dx, dy)
    local new_x = cursor.x + dx
    local new_y = cursor.y + dy
    if get_element_at(new_x, new_y) then
        cursor.x = new_x
        cursor.y = new_y
    end
end

nntimer = 0

function updateneuralnetwork()
    -- call every time
    nntimer+=1
    if nntimer > 2 then
        process_layers()
        nntimer = 0
    end

    if ui_layer == 1 then
        if btnp(⬅️) then move_cursor(-1, 0) end
        if btnp(➡️) and cursor.x < #levels[curtlvl].nn_structure.hidden then move_cursor(1, 0) end
        if btnp(⬆️) then move_cursor(0, -1) end
        if btnp(⬇️) then move_cursor(0, 1) end        

        for i,e in pairs(ui_elements) do
            local is_selected = (e.grid_x == cursor.x and e.grid_y == cursor.y)
            if is_selected and i > levels[curtlvl].nn_structure.input and i <= #ui_elements - levels[curtlvl].nn_structure.output then
                if btnp(5) then 
                    ui_layer = 2 
                    knob_idx = 1
                    knob_curlen = #ui_knobs[i - levels[curtlvl].nn_structure.input]
                    ui_knob_idx = i - levels[curtlvl].nn_structure.input
                end
            end
        end	
    elseif ui_layer == 2 then
        if btnp(5) then 
            ui_layer = 1
            knob_idx = 0  
        end

        if btnp(⬅️) and knob_idx > 1 then knob_idx-=1 end
        if btnp(➡️) and knob_idx < knob_curlen then knob_idx+=1 end
        
        if btnp(⬆️) and ui_knobs[ui_knob_idx][knob_idx].v < 9 then
            -- reset score
            levels[curtlvl].score = 0 
            ui_knobs[ui_knob_idx][knob_idx].v+=1 
        end
        if btnp(⬇️) and ui_knobs[ui_knob_idx][knob_idx].v > 1 then
            -- reset score
            levels[curtlvl].score = 0 
            ui_knobs[ui_knob_idx][knob_idx].v-=1 
        end
    end
end

function drawneuralnetwork()
    for i,e in pairs(ui_elements) do
        local x = 2 + e.grid_x * 12
        local y = 68 + e.grid_y * 12
        local is_selected = (e.grid_x == cursor.x and e.grid_y == cursor.y)								
        rect(62, 65, 127, 118, ui_layer == 1 and 5 or 12)
        
        if i > #ui_elements - levels[curtlvl].nn_structure.output then
            pal(5,e.v > 0 and 11 or 5)
            spr(e.label, x, y+1)
            pal()
        elseif i <= levels[curtlvl].nn_structure.input then
            pal(5,e.v > 0 and 11 or 8)
            spr(12, x, y)
            pal()
        else
            pal(5,e.v > 0 and 11 or 8)
            spr(2, x, y)
            pal()
        end								
        if is_selected then           
           spr(1, x, y)
           rect(0, 118, 127, 127, 5)
           print(e.label.."("..round1(e.v)..")", 2, 120, 12)
           if i > levels[curtlvl].nn_structure.input and i <= #ui_elements - levels[curtlvl].nn_structure.output then
                for idx,e in pairs(ui_knobs[i - levels[curtlvl].nn_structure.input]) do
                    if knob_idx == idx then
                        spr(1, 56 + idx*10, 80)
                        print(e.label, 56 + idx*10, 90, 5)
                    end
                    spr(2 + e.v, 56 + idx*10, 80)
                end
           end
        end
    end
end
-->8
-- utils
function round1(n)
    return flr(n * 10 + 0.5) / 10
end
__gfx__
00000000600660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000000000000000000000
00000000000000000055550000ffff0000ffff0000ffff00044fff0000f44f0000fff44000ffff0000ffff0000ffff0000050005000000000000000000000000
0070070000000000055555500ffffff00ffffff00444fff00444fff00ff44ff00fff44400fff44400ffffff00ffffff000055005000000000000000000000000
0007700060000006055555500ff44ff00ff44ff004444ff00f444ff00ff44ff00ff444f00ff444400ff44ff00ff44ff055555505000000000000000000000000
0007700060000006055555500f444ff004444ff00ff44ff00ff44ff00ff44ff00ff44ff00ff44ff00ff444400ff444f055555505000000000000000000000000
0070070000000000055555500444fff00444fff00ffffff00ffffff00ffffff00ffffff00ffffff00fff44400fff444000055005000000000000000000000000
000000000000000000555500044fff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000fff44000050005000000000000000000000000
00000000600660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000000000000000000000
0000333300aaaa000000000000222200055005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000030330aaaaaa00900000002122120888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000333366aa75a00900000022222222818881880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30033300aa6a75a00900800022222222616661660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333330aaaa88880900000022122122818881880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0333330066aa88800900000022211222818881880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333000099aaa000900000002122120888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030300009990000000000000222200055005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0ee0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500000550000005500000050000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550005555000005500000550000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055000055555500555555005555500005555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055000000550000055550005555500005555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000550000005500000550000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550000000000000000000050000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666006666000000000000666600066006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006066066666600600000006066060666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666606600600000066666666606660660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60066600666606600600600066666666606660660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660666666660600000066066066606660660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666600666666600600000066600666606660660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666000066666000600000006066060666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060600006660000000000000666600066006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003045029450204501945014450104500c45009450074500645005450054500545007450094500b4500d4501045014450174501b4502045027450000000000000000000000000000000000000000000000
001a00000c0500c0500a0500a0500c05010050150501705018050160501405012050110501105013050160501a0501d0501000010000100001000001000010000100001000000000000000000000000000000000
