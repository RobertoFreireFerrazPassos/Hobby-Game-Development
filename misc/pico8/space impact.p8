pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
function _init()
end

function _update()
	strmake()
 updatestr()
 updateprt()
 
	if rnd(1000) > 980 then
		rndenemy()
	end

 p:update()
 
 foreach(e, function(e)
		e:update()
	end) 
end

function _draw()
 cls()
 prtdraw(str)
 foreach(e, function(e)
		e:draw()
	end)
	prtdraw(prt)
 p:draw()
 drawhud()
end
-->8
-- player
score = "-----"

p = {
	x = 0,
	y = 16,
	s = 1,
	v = 1,
	l = 3,
	b = {},
	bt = 0,
	hb = {
		x = 0,
		y = 3,
		w = 16,
		h = 13
	},
	update = function(s)
			if s.y > 8 and btn(⬆️) then s.y = s.y - s.v end
			if s.y < 112 and btn(⬇️) then s.y = s.y + s.v end
			if s.x < 64 and btn(➡️) then s.x = s.x + s.v end
			if s.x > 0 and btn(⬅️) then s.x = s.x - s.v end
			
			if btn(❎) and s.bt == 0 then
				add(s.b,newbullet(s.x+16,s.y+7))
			 s.bt = 1
			 sfx(0)
			end
			
			if s.bt > 0 then
				s.bt = s.bt + 1
			end
			
			if s.bt > 10 then
				s.bt = 0
			end
			
			foreach(s.b, function(b)
				b:update()
			end)
	end,
	draw = function(s)		
		foreach(s.b, function(b)
			b:draw()
		end)
		spr(s.s,s.x,s.y,2,2)
	end
}

-- bullet
newbullet = function(x,y)
		local o = {}
	
		o = {
			x = x,
			y = y,
			a = 15,
			c = 8,
			hb = {
				x = 0,
				y = 0,
				w = 4,
				h = 1
			},
			update = function(s)
				s.a = s.a - 1
				s.c = 10 - flr(s.a/5)
				if s.a < 0 or s.x > 128 then
				 del(p.b,s)
					return
				end
				s.x = s.x + 2
			end,
			draw = function(s)
				rectfill(s.x,s.y,s.x+4,s.y+1,s.c)
			end
		}
		
		return o		
end
-->8
-- hud
drawhud = function()
		for i=1,p.l do
			spr(16,(i-1)*10,0)
		end
		
		print(score,100,0,6)
end
-->8
-- enemy
e = {}

rndenemy = function()
	newememy(
			130,
			rnd(64)+16,
			3,
			{
				x = 1,
				y = 1,
				w = 15,
				h = 14,
			})
end

newememy = function(x,y,s,hb)
		local o = {}

		o = {
			x = x,
			y = y,
			s = s,
			hb = hb,
			update = function(s)
				s.x = s.x - 1
				
				foreach(p.b, function(b)
					if rect_overlap(b,s) then
						del(e,s)
						del(p.b,b)
						prtmake(
						s.x+s.hb.x+s.hb.w/2,
						s.y+s.hb.y+s.hb.h/2)
						sfx(1)
					end
				end)
			end,
			draw = function(s)
				spr(s.s,s.x,s.y,2,2)
			end
		}
		add(e,o)
		return o		
end
-->8
-- utils
function rect_overlap(o1,o2)
    local x1, y1, w1, h1, x2, y2, w2, h2=
    				o1.x+o1.hb.x,
								o1.y+o1.hb.y,
								o1.hb.x+o1.hb.w,
								o1.hb.y+o1.hb.h,
								o2.x+o2.hb.x,
								o2.y+o2.hb.y,
								o2.hb.x+o2.hb.w,
								o2.hb.y+o2.hb.h
    
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end
-->8
-- particles
prt={} --basic
str={} --star

-- draw
function prtdraw(prt)
	for p in all(prt) do
		circfill(p.x,p.y,p.rad,p.clr)
	end
end

--update
function strmake()
  for i=1,16-#str do
  	local v = rnd(2)
   add(str,{x=128+rnd(128),
     y=16+rnd(100),
     dx=1+v/2,
     clr=6+v})
  end
end

function updatestr()
  for p in all(str) do
    p.x-=p.dx
    if p.x<0 then
      del(str,p)
    end
  end
end

function prtmake(x,y)
  for i=1,30 do
    add(prt,{x=x,y=y,
      dx=rnd(2)-1,
      dy=rnd(2)-1,
      rad=rnd(2),
      act=6,
      clr=8+rnd(2)})
  end
end

function updateprt()
		for p in all(prt) do
    p.x+=p.dx*2
    p.y+=p.dy*2
    p.act-=1
    if p.act<0 then
        del(prt,p)
    end
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000099999000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000950005566600000000000999999900900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000950000555500000000009990009990900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006600ddc555000000099900000990900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005d0055ccdd000000999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009565d6566ccdd55500999999999990900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066006609565d6566ccdd55500999999999990900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65666656005d0055ccdd000000999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666006600ddc555000000099900000990900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666950000555500000000009990009990900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65666656950005566600000000000999999900900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660000000000000000000000099999000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003c140371702f1702b160231601e1601a15017150121400f1300c1200a1100a1103220035200382003c2003d2000000000000000000000000000000000000000000000000000000000000000000000000
000100003f6303d6403866035670316702e6702b67029670276702567022670206701e6601d6601b6501864016630126201262011610000000000000000000000000000000000000000000000000000000000000
