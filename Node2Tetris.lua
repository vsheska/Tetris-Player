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
		for i = 1, 50 do
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
			algorithm[move][memadd1] = {}
			algorithm[move][memadd1][memadd2] = {}
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
		for memadd1 in pairs(alg[movelist[i]]) do
			for memadd2 in pairs(alg[movelist[i]][memadd1]) do
				if alg[movelist[i]][memadd1][memadd2][memory.readbyte(memadd1) + 1] == nil then
					prob = math.random(0, 100)
					alg[movelist[i]][memadd1][memadd2][memory.readbyte(memadd1) + 1] = {}
					alg[movelist[i]][memadd1][memadd2][memory.readbyte(memadd1) + 1][memory.readbyte(memadd2) + 1] = prob
				else
					prob = alg[movelist[i]][memadd1][memadd2][memory.readbyte(memadd1) + 1][memory.readbyte(memadd2) + 1]
					if prob == nil then
					prob = math.random(0, 100)
					alg[movelist[i]][memadd1][memadd2][memory.readbyte(memadd1) + 1][memory.readbyte(memadd2) + 1] = prob
					end
				end
			joylist[i] = joylist[i] + prob
			end
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
		randmemval1 = math.random(0, 255)
		randmemval2 = math.random(0, 255)
		
		--print(randmove)
		--print(randmemadd)
		--print(randmemval)
		
		if new[movelist[randmove]][randmemadd1] == nil then
			new[movelist[randmove]][randmemadd1] = {}
			new[movelist[randmove]][randmemadd1][randmemadd2] = {}
		elseif new[movelist[randmove]][randmemadd1][randmemadd2] == nil then
			new[movelist[randmove]][randmemadd1][randmemadd2] = {}
		else
			if tablelength(new[movelist[randmove]][randmemadd1][randmemadd2]) > 0 then
			
			if math.random(4) == 1 and tablelength(new[movelist[randmove]]) > 10 then
				new[movelist[randmove]][randmemadd1][randmemadd2] = nil
				if tablelength(new[movelist[randmove]][randmemadd1]) == 0 then new[movelist[randmove]][randmemadd1] = nil end
			else
				randmodifier = math.random(-10, 10)
				while randmodifier == 0 do randmodifier = math.random(-10, -10) end
			
				while new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1] == nil do
					randmemval1 = (randmemval1 + 1) % 257
				end
				while new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1][randmemval2] == nil do
					randmemval2 = (randmemval2 + 1) % 257
				end
				
				new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1][randmemval2] = new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1][randmemval2] + randmodifier
				if new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1][randmemval2] < 0 then new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1][randmemval2] = 0
				elseif new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1][randmemval2] > 100 then new[movelist[randmove]][randmemadd1][randmemadd2][randmemval1][randmemval2] = 100
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
		for q = 1, 99 do
			table.insert(population, {-1, initialize(), 0})
		end
	end
	
	if n == nil then n=0 end
	
	while true do
	print ("Generation")
	print (n)
	for i = 1, 100 do
		if population[i][1] == -1 then
			print(i)
			joyreset()
			savestate.loadslot(1)
			while memory.readbyte(0x9843) ~= 135 do
				detmoves(population[i][2])
				setjoy(population[i][2])
				emu.frameadvance()
			end
			population[i][1] = memory.readbyte(0xE0A0) + 16*16*memory.readbyte(0xE0A1) + 16*16*16*16*memory.readbyte(0xE0A2)
			population[i][3] = emu.framecount()
		end
	end
	bulbasaur()
	for i = 1, 50 do
		--if population[i][1] == 0 then
			--population[i] = {-1, initialize()}
			--population[i+ 5] = {-1, initialize()}
		--else
			population[i + 50] = {-1, mutate(population[i][2]), 0}
		--end
	end
if n % 10 == 0 then 
f = io.open(n .. ".txt", "w")
for move in pairs(population[1][2]) do
	for mem1 in pairs(population[1][2][move]) do
		for mem2 in pairs(population[1][2][move][mem1]) do
			for val1 in pairs(population[1][2][move][mem1][mem2]) do
				for val2, prob in pairs(population[1][2][move][mem1][mem2][val1]) do
					f:write(move .. " " .. mem1 .. " " .. mem2 .. " " .. val1 .. " " .. val2 .. " " .. prob .. "\n")
				end
			end
		end
	end
end
f:close()
end
	best = population[1][2]
	for w = 1, 10 do
		print(population[w][1])
	end
	print(population[50][1])
	n = n + 1
	end
--end
