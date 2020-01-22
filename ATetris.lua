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
	local memadd
	algorithm = {}
	for _, move in ipairs(movelist) do
		algorithm[move] = {}
		for i = 1, 10 do
			memadd = math.random(0, 1183)
			if memadd < 1024 then 
				memadd = memadd + 0x9800
			else
				memadd = memadd + 0xFE00 - 1024
			end
			algorithm[move][memadd] = {}
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
			prob = alg[movelist[i]][memadd][memory.readbyte(memadd) + 1]
			if prob == nil then
				prob = math.random(0, 100)
				alg[movelist[i]][memadd][memory.readbyte(memadd) + 1] = prob
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
	for j = 100, 2, -1 do
		for i = 1, j-1 do
			if population[i][1] <= population[i + 1][1] then
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
	local randmemadd
	local randmemval
	local randmodifier
	new = deepcopy(alg)
	for i = 1, 100 do
		randmove = math.random(6)
		randmemadd = math.random(0, 1183)
		if randmemadd < 1024 then 
			randmemadd = randmemadd + 0x9800
		else
			randmemadd = randmemadd + 0xFE00 - 1024
		end
		randmemval = math.random(1, 256)
		--print(randmove)
		--print(randmemadd)
		--print(randmemval)
		
		if new[movelist[randmove]][randmemadd] == nil then
			new[movelist[randmove]][randmemadd] = {}
		else
			if tablelength(new[movelist[randmove]][randmemadd]) > 0 then
			
			randmodifier = math.random(-25, 25)
			while randmodifier == 0 do randmodifier = math.random(-25, 25) end
			
			while new[movelist[randmove]][randmemadd][randmemval] == nil do
				randmemval = (randmemval + 1) % 257
			end
			new[movelist[randmove]][randmemadd][randmemval] = new[movelist[randmove]][randmemadd][randmemval] + randmodifier
			
			if new[movelist[randmove]][randmemadd][randmemval] < 0 then new[movelist[randmove]][randmemadd][randmemval] = 0
			elseif new[movelist[randmove]][randmemadd][randmemval] > 100 then new[movelist[randmove]][randmemadd][randmemval] = 100
			end
			
			end
		end
	end
	return new
end

--function nope()
	if population == nil then
		population = {{-1, initialize()}}
		for q = 1, 99 do
			table.insert(population, {-1, initialize()})
		end
	end
	n=0
	while true do
	print ("Generation")
	print (n)
	for i = 1, 100 do
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
		end
	end
	bulbasaur()
	for i = 1, 50 do
		if population[i][1] == 0 then
			population[i] = {-1, initialize()}
			population[i+ 50] = {-1, initialize()}
		else
			population[i + 50] = {-1, mutate(population[i][2])}
		end
	end
	best = population[1][2]
	for w = 1, 50 do
		print(population[w][1])
	end
	n = n + 1
	end
--end
