pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
function _init()
 intrest()
 initintro()
end

function _update()
	if introoption then
		updateintro()
		return
	end
	
	if youlose then
 	updatevcm()
	 updtrest()
		return
	end

	strmake()
 updatestr()
 updateprt()
 updaterct()
	
	if gametmr>0 then
		gametmr=gametmr-1
		return	
	end
	
 p:update()
 
 updateitem()
 
 rndenemy() 
 foreach(e, function(e)
		e:update()
	end) 
end

function _draw()
 cls()
 if introoption then
 	drawintro()
 	return
 end
 
 if youlose then
 	prtdraw(vcm)
		return
	end
	
	if p.x<1 then
		rect(0,0,128,128,1)
	end
	
	local sx, sy = get_shake_offset()
 camera(sx, sy)
 
 prtdraw(str)
 prtdraw(rct)
 
 foreach(e, function(e)
		e:draw()
	end)
	prtdraw(prt)
 p:draw()
 
 drawitem()
 prtdraw(str2)
 
 camera()
 drawhud()
end
-->8
-- player
p = {
	x = 56,
	y = 56,
	s = 1,
	v = 1,
	l = 3, --lifes
	pwr=0,--power laser
	b = {},
	bt = 0,
	hb={x=1,y=3,w=12,h=10},
	shd={ -- shield
	 a = 0,
	 s = 32
	},
	update = function(s)
			if s.l == 0 then
				restart()
			end
			
			if s.shd.a > 0 then
				s.shd.a = s.shd.a -1
			end
			s.s = 1
			s.hb={x=1,y=3,w=12,h=10}
			if s.y > 8 and btn(⬆️) then 
				s.y = s.y - s.v
				s.s = 7 
			end
			if s.y < 112 and btn(⬇️) then 
				s.y = s.y + s.v
				s.s = 5
			end
			if s.x < 112 and btn(➡️) then
			 s.x = s.x + s.v
			 rctmake(s.x,s.y+3)
			 sfx(2)
			end
			if s.x >= 0 and btn(⬅️) then s.x = s.x - s.v end
			
			if btn(❎) and s.bt == 0 then
				add(s.b,newbullet(s.x+16,s.y+7))
			 s.bt = 1
			 sfx(0)
			end
			
			if s.s == 7 then
				s.hb={x=1,y=5,w=12,h=8}
			elseif s.s == 5 then
				s.hb={x=1,y=3,w=12,h=8}
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
			
			if it and rect_overlap(it,s) then
				if it.s == 34 then
						if s.l < 3 then
							s.l=s.l+1
							sfx(4)
						end
				elseif it.s == 35 then
						s.pwr=8
						sfx(4)
				elseif it.s == 36 then
						s.v=2
						sfx(4)
				end
				it=nil
			end
			
			if s.shd.a == 0 then
		  foreach(e, function(ei)
		 		local damage = false
		 		if ei.x < -8 then
		 			damage = true
		 		elseif rect_overlap(ei,s) then
						if s.shd.a == 0 then
							damage = true
						end
					end
					
					if damage then
							del(e,ei)
							s.pwr=0
							s.v=1
							s.l=s.l-1
							ltmr=5
							shake_screen(4,10)
							sfx(1)
							s.shd.a = 90
					end
				end)
			end
	end,
	draw = function(s)		
		foreach(s.b, function(b)
			b:draw()
		end)
		spr(s.s,s.x,s.y,2,2)
		if s.shd.a > 0 then
			if s.shd.a < 20 then
				pal(12, 6)
			end
			spr(s.shd.s,s.x,s.y,2,2)
			pal()
		end
	end
}

-- bullet
newbullet = function(x,y)
		local o = {}
	
		o = {
			x = x,
			y = y,
			a = 15 + p.pwr,
			c = 8,
			hb = {x=0,y=0,w=4,h=1},
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
				rectfill(s.x,s.y,s.x+8+3*flr(s.a/5),s.y+1,s.c)
			end
		}
		
		return o		
end
-->8
-- hud
drawhud = function()
		if ltmr>0 then
				ltmr=ltmr-1
				pal(6,8)
				pal(5,8)
		end
		
		for i=1,p.l do
			spr(16,(i-1)*10,0)
		end
		pal()
		
		prttxt(score,110,0,6)
end

function prttxt(n, x, y, col)
    local str = "0"..n  -- add leading zeros
    str = sub(str, -5)     -- get the last 5 characters
    print(str,x,y,col)  -- print at position (x, y) with color col
end
-->8
-- enemy
rndenemy = function()
	entmr = entmr - 1
	
	if entmr > 0 then
			return
	end
	
	entmr=64+flr(rnd(32))
	ypos={1,2,3,4,5,6,7}
	del(ypos,enstpt)	
	enstpt=rnd(ypos)
	
	newememy(
			130,
			enstpt*16,
			3,
			{x=3,y=1,w=12,h=14},
			1)
end

newememy = function(x,y,s,hb,scr)
		local o = {}

		o = {
			x = x,
			y = y,
			s = s,
			scr=scr,
			hb = hb,
			update = function(s)
				s.x = s.x - 1
				
				foreach(p.b, function(b)
					if rect_overlap(b,s) then
						del(e,s)
						del(p.b,b)
						score = score + s.scr
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
    local x1,y1,w1,h1,x2,y2,w2,h2=
    				o1.x+o1.hb.x,
								o1.y+o1.hb.y,
								o1.hb.w,
								o1.hb.h,
								o2.x+o2.hb.x,
								o2.y+o2.hb.y,
								o2.hb.w,
								o2.hb.h
    
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end
-->8
-- particles

-- draw
function prtdraw(prt)
	for p in all(prt) do
		circfill(p.x,p.y,p.rad,p.clr)
	end
end

--update
function vcmmake()
	for i=1,100 do
			add(vcm,{
				 x=flr(rnd(148))-20,
					y=flr(rnd(148))-20,
					dx=1,
					dy=1,
					rad=0,act=30,
					clr=rnd({2,7,14})
				})
		end
end

function updatevcm()
	for p in all(vcm) do
		if p.x<64 then p.x+=p.dx*2 end
		if p.x>64 then p.x-=p.dx*2 end
		if p.y<64 then p.y+=p.dy*2 end
		if p.y>64 then p.y-=p.dy*2 end
		if p.x==64 or p.y==64 then p.act=-1 end
		p.act-=1
		if p.act<0 then
			del(vcm,p)
		end
	end
end

function rctmake(x,y)
 for i=1,4 do
   add(rct,{
    x=x-flr(rnd(5)),
    y=y+flr(rnd(10)),
    dx=-2-flr(rnd(3)),
    dy=0,
    rad=flr(rnd(2)),
    act=8,
    clr=8})
 end
end

function updaterct()
	for p in all(rct) do
   p.y+=p.dy*1.5
   if p.act<=8 then p.clr=8 end
   if p.act<=6 then p.clr=9 end
   if p.act<=4 then p.clr=10 end
   p.act-=1
   if p.act<0 then
       del(rct,p)
   end
	end
end

function strmake()
  for i=1,16-#str do
  	local v = flr(rnd(2))
   add(str,{x=128+flr(rnd(128)),
     y=16+rnd(100),
     dx=1+v/2,
     clr=6+v})
  end  
  
  for i=1,2-#str2 do
   add(str2,{x=256+flr(rnd(256)),
   		rad=2+flr(rnd(32)),
     y=-100+flr(rnd(300)),
     dx=3,
     clr=rnd({5,6})})
  end
end

function updatestr()
  for p in all(str) do
    p.x-=p.dx
    if p.x<0 then
      del(str,p)
    end
  end
  
  for p in all(str2) do
    p.x-=p.dx
    if p.x<-300 then
      del(str2,p)
    end
  end
end

function prtmake(x,y)
  for i=1,30 do
    add(prt,{x=x,y=y,
      dx=flr(rnd(2))-1,
      dy=flr(rnd(2))-1,
      rad=flr(rnd(2)),
      act=6,
      clr=5+flr(rnd(2))})
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

-->8
--restart
function restart() 
 youlose = true
 vcmmake()
 sfx(3)
end

function intrest()
 shake_intensity = 0
 shake_duration = 0
	youlose=false
 restartimer = 30
 ltmr=0
 it = nil --item
 ittmr=1028+flr(rnd(1028))
 p.l = 3 -- p player
 p.x = 56
	p.y = 56
	p.b = {}
 p.shd={a = 0,s = 32}
	prt={} --splosion
	str={} --star
	str2={}--str22
	rct={} --rocket
	vcm={} -- vacum
 e = {} --enemies
 enstpt = 1
 entmr = 64+flr(rnd(64))
 score = 0
end

function updtrest()
	restartimer = restartimer - 1	 
 if restartimer == 0 then
		_init()
	end
end


-->8
-- screen
function shake_screen(intensity, duration)
    shake_intensity = intensity
    shake_duration = duration
end

function get_shake_offset()
    if shake_duration > 0 then
        shake_duration -= 1
        return flr(rnd(shake_intensity * 2)) - shake_intensity, flr(rnd(shake_intensity * 2)) - shake_intensity
    end
    return 0, 0
end
-->8
-- items
function updateitem()
		if ittmr > 0 then
				ittmr=ittmr-1				
				if it then
					it.x=it.x-1
				end
				return
		end
		ittmr=1028+flr(rnd(1028))
		local sprite=34
		
		if p.l == 3 then
			sprite=35
		end
		
		if sprite==35 and p.pwr>0 then
			sprite=36
		end
		
		if sprite==36 and p.v>1 then
			return
		end
		
		if it == nil or it.x<-8 then
			it={
				s=sprite,
				x=128+flr(rnd(128)),
				y=16+flr(rnd(80)),
				hb={x=0,y=0,w=8,h=8},
			}
		end
end

function drawitem()
	if it then
		spr(it.s,it.x,it.y)
	end
end
-->8
-- intro
function initintro()
	strintro={}
	introoption=true
	inttmrs=30
	
	blink = false
	blink_timer = 0
	blink_duration = 60
	done = false
end

function updateintro()
	if done then
		movetogame()
		return
	end
	
 if blink then
   blink_timer -= 1
   if blink_timer <= 0 then
     blink = false
     done = true
     return
   end
 end
    
	if inttmrs > 0 then
		inttmrs = inttmrs - 1
	else
		inttmrs=30
		strmake()
	end
	
 updatestr()
	
	if not blink then
		if btn(❎) then
			sfx(5)
			blink = true
	  blink_timer = blink_duration
	  done = false
		end
 end
end

function drawintro()
	prtdraw(str)
	spr(1,56,56,2,2)
	prtdraw(str2)
	local clr = 5
	if blink_timer % 10 < 5 then
		clr = 6
	end
	print("press ❎ to start",30,90,clr)
end

function movetogame()
	strintro={}
	introoption=false
	gametmr=10
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000056666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000055666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000055005566600000000000000055666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000055000555500000000000000066665500550055555000000000006666600000000000000000000000000000000000000000000000000000000000000
00700700055600ddc55500000000000000665500055000dddd550000055000dddd66000000000000000000000000000000000000000000000000000000000000
000000000666d055ccdd000000000005555550000666d055dddd00000666d056ccd6000000000000000000000000000000000000000000000000000000000000
0000000006666d566ccdd559005566ccccc6665006666d56666dd55906666d5666cdd66900000000000000000000000000000000000000000000000000000000
0660066006666d566ccdd559005566ccccc6665006666d5666cdd66906666d56666dd55900000000000000000000000000000000000000000000000000000000
656666560666d055ccdd000000000005555550000666d056ccd600000666d055dddd000000000000000000000000000000000000000000000000000000000000
66666666055600ddc55500000000000000665500055000dddd660000055000dddd55000000000000000000000000000000000000000000000000000000000000
66666666055000555500000000000000066665500000066666000000055005555500000000000000000000000000000000000000000000000000000000000000
65666656055005566600000000000000055666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660000000000000000000000000055666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000000000000056666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077770000777700007777000666666666666660000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000007877870077aa770077777700000000555000000000000000000000000000000000000000000000000000000000000000000000000000000
0c00c0c0c0c000007888888777a99a77775555770000000060000000000000000000000000000000000000000000000000000000000000000000000000000000
c00c000000000000788888877a9889a7759997570000000060000000000000000000000000000000000000000000000000000000000000000000000000000000
00000c0000c0c000788888877a9889a7759997570000000555000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007788887777a99a77775555770000006666600000000000000000000000000000000000000000000000000000000000000000000000000000
00000c000000c0c007788770077aa77007777770000006c555660000000000000000000000000000000000000000000000000000000000000000000000000000
c00000000000000c00777700007777000077770000000cc666560000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000c00000000000000000000000000000cc666560000000000000000000000000000000000000000000000000000000000000000000000000000
c0000c000000c0c0000000000000000000000000000006c555660000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000006666600000000000000000000000000000000000000000000000000000000000000000000000000000
00000c0000c0c0000000000000000000000000000000000555000000000000000000000000000000000000000000000000000000000000000000000000000000
c00c0000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000
0c00c0c0c0c000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000555000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000666666666666660000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003c140371702f1702b160231601e1601a15017150121400f1300c1200a1100a1103220035200382003c2003d2000000000000000000000000000000000000000000000000000000000000000000000000
000100003f6303d6403866035670316702e6702b67029670276702567022670206701e6601d6601b6501864016630126201262011610000000000000000000000000000000000000000000000000000000000000
000200000763007650076600764007630076100760007600076000760006600066000560005600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500003b231372503025028253272602a25030260312602c271222701b2501f25323260262701a270162501726118260192500c2430b2400b25006250052400325000203002030020300203002030020300203
000400001d450254501d4501c4501f450274502f450394502d4502c4502e45033450394503c4503145032450384503a4500040000400004000040000400004000040000400004000040000400004000040000400
0001000023320273402a3602d3703036033350333302a30028300223001e300163000c30000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
