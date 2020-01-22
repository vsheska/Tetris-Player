movelist = {"A", "B", "Up", "Down", "Left", "Right"}
joy = {}
joy["Power"] = "False"
joy["Select"] = "False"
joy["Start"] = "False"
for i, move in pairs(movelist) do
	joy[move] = false
end
--frames = 1000
mutationstrength = 100

function setContains(set, key)
    return set[key] ~= nil
end

function tablelength(t)
	count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function joyreset()
	joy["A"] = "False"
	joy["B"] = "False"
	joy["Down"] = "False"
	joy["Left"] = "False"
	joy["Power"] = "False"
	joy["Right"] = "False"
	joy["Select"] = "False"
	joy["Start"] = "False"
	joy["Up"] = "False"
	joypad.set(joy)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function initialize()
	local algorithm
	local memadd1
	local memadd2
	algorithm = {}
	for _, move in ipairs(movelist) do
		algorithm[move] = {}
		for i = 1, 10 do
			memadd1 = math.random(0x9800, 0x9BFF)
			--if memadd1 < 1024 then 
			--	memadd1 = memadd1 + 0x9800
			--else
			--	memadd1 = memadd1 + 0xFE00 - 1024
			--end
			memadd2 = math.random(0xFE00, 0xFE9F)
			--if memadd2 < 1024 then 
			--	memadd2 = memadd2 + 0x9800
			--else
			--	memadd2 = memadd2 + 0xFE00 - 1024
			--end
			--if memadd1 > memadd2 then
			--	temp = memadd2
			--	memadd2 = memadd1
			--	memadd1 = temp
			--end
			algorithm[move][{memadd1, memadd2}] = {}
		end
	end
	return algorithm
end

function detmoves(alg)
	local tlen
	local prob
	local q
	joylist = {0, 0, 0, 0, 0, 0}
	for i = 1, 6 do
		tlen = tablelength(alg[movelist[i]])
		for memadd in pairs(alg[movelist[i]]) do
			prob = alg[movelist[i]][memadd][{memory.readbyte(memadd[1]), memory.readbyte(memadd[2])}]
			if prob == nil then
				prob = math.random(0, 100)
				alg[movelist[i]][memadd][{memory.readbyte(memadd[1]), memory.readbyte(memadd[2])}] = prob
			end
			joylist[i] = joylist[i] + prob
		end
		joylist[i] = joylist[i]/tlen
	end
end

function setjoy(list)
	for i = 1, 6 do
		if joylist[i] > 50 then
			joy[movelist[i]] = "True"
		else
			joy[movelist[i]] = "False"
		end
	end
	joypad.set(joy)
end

function bulbasaur()
	for j = 10, 2, -1 do
		for i = 1, j-1 do
			if population[i][1] < population[i + 1][1] or (population[i][1] == population[i + 1][1] and population[i][3] < population[i + 1][3]) then
				temp = population[i]
				population[i] = population[i + 1]
				population[i + 1] = temp
			end
		end
	end
end

function mutate(alg)
	local new
	local randmove
	local randmemadd1
	local randmemadd2
	local randmemadd
	local randmemval
	local randmemval1
	local randmemval2
	local randmodifier
	local temp
	new = deepcopy(alg)
	for i = 1, 10 do
		randmove = math.random(6)
		randmemadd1 = math.random(0x9800, 0x9BFF)
		--if randmemadd1 < 1024 then 
		--	randmemadd1 = randmemadd1 + 0x9800
		--else
		--	randmemadd1 = randmemadd1 + 0xFE00 - 1024
		--end
		randmemadd2 = math.random(0xFE00, 0xFE9F)
		--if randmemadd2 < 1024 then 
		--	randmemadd2 = randmemadd2 + 0x9800
		--else
		--	randmemadd2 = randmemadd2 + 0xFE00 - 1024
		--end
		
		--if randmemadd1 > randmemadd2 then
		--	temp = randmemadd2
		--	randmemadd2 = randmemadd1
		--	randmemadd1 = temp
		--end
		randmemadd = {randmemadd1, randmemadd2}
		randmemval1 = math.random(0, 255)
		randmemval2 = math.random(0, 255)
		randmemval = {randmemval1, randmemval2}
		
		--print(randmove)
		--print(randmemadd)
		--print(randmemval)
		
		if new[movelist[randmove]][randmemadd] == nil then
			new[movelist[randmove]][randmemadd] = {}
		else
			if tablelength(new[movelist[randmove]][randmemadd]) > 0 then
			
			if math.random(2) == 2 and tablelength(new[movelist[randmove]]) > 10 then
				new[movelist[randmove]][randmemadd] = nil
			else
				randmodifier = math.random(-10, 10)
				while randmodifier == 0 do randmodifier = math.random(-10, -10) end
			
				while new[movelist[randmove]][randmemadd][randmemval] == nil do
					if randmemval2 == 255 then
						randmemval1 = (randmemval1 + 1) % 256
						randmemval2 = 0
					else
						randmemval2 = (randmemval2 + 1) % 256
					end
				end
				new[movelist[randmove]][randmemadd][randmemval] = new[movelist[randmove]][randmemadd][randmemval] + randmodifier
				if new[movelist[randmove]][randmemadd][randmemval] < 0 then new[movelist[randmove]][randmemadd][randmemval] = 0
				elseif new[movelist[randmove]][randmemadd][randmemval] > 100 then new[movelist[randmove]][randmemadd][randmemval] = 100
				end
			
			end
			
			end
		end
	end
	return new
end

--function nope()
	if population == nil then
		population = {{-1, initialize(), 0}}
		for q = 1, 9 do
			table.insert(population, {-1, initialize(), 0})
		end
	end
	n=0
	while true do
	print ("Generation")
	print (n)
	for i = 1, 10 do
		if population[i][1] == -1 then
			print(i)
			joyreset()
			savestate.loadslot(1)
			while memory.readbyte(0x9844) == 47 do
				detmoves(population[i][2])
				setjoy(population[i][2])
				emu.frameadvance()
			end
			population[i][1] = memory.readbyte(0xE0A0) + 16*16*memory.readbyte(0xE0A1) + 16*16*16*16*memory.readbyte(0xE0A2)
			population[i][3] = emu.framecount()
		end
	end
	bulbasaur()
	for i = 1, 10 do
		--if population[i][1] == 0 then
			--population[i] = {-1, initialize()}
			--population[i+ 5] = {-1, initialize()}
		--else
			population[i + 5] = {-1, mutate(population[i][2]), 0}
		--end
	end
	best = population[1][2]
	for w = 1, 5 do
		print(population[w][1])
	end
	n = n + 1
	end
--end
