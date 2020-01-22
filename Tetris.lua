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
function fitness()
	return 10000*memory.readbyte(0x00A2) + 100*memory.readbyte(0x00A1) + memory.readbyte(0x00A0)
end

function setContains(set, key)
    return set[key] ~= nil
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
	local actions
	actions = {}
	for i = 1, 100 do
		a = math.random(0, 8191)
		b = math.random(0, 8191)
		if a > b then
			temp = b
			b = a
			a = temp
		end
		z = {}
		for j = 1, 6 do
			table.insert(z, {math.random(0, 10), math.random(0, 10), math.random(0, 10)})
		end
		actions[{a, b}] = z
	end
	return actions
end
-- initalize produces a table with keys consisting of an order pair of memory
-- addresses, and the values an 8 (7 excluding select) element array, which consists of 2 element
-- arrays

--for i, v in pairs(a) do
--	print(i)
--	print(v)
--end
function detmoves(a)
	joylist = {0, 0, 0, 0, 0, 0, 0}
	for k, v in pairs(a) do
		for j = 1, 6 do
			joylist[j] = joylist[j] + (((v[j][1])*(mainmemory.readbyte(k[1])) + (v[j][2])*(mainmemory.readbyte(k[2])) + v[j][3]) % 11)/10
		end
	end
end

function setjoy(list)
	for i = 1, 6 do
		if joylist[i] > tablelength(list)/2 then
			joy[movelist[i]] = "True"
		else
			joy[movelist[i]] = "False"
		end
	end
	joypad.set(joy)
end

function tablelength(t)
	count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function mutate(alist)
	local new
	new = deepcopy(alist)
	for i = 1, mutationstrength do
		a = math.random(0, 8191)
		b = math.random(0, 8191)
		if a > b then
			temp = b
			b = a
			a = temp
		end
		if new[{a, b}] ~= nil then
			x = new[{a, b}]
			print(x)
		else
			z = {}
			for j = 1, 6 do
				table.insert(z, {math.random(0, 10), math.random(0, 10), math.random(0, 10)})
			end
			new[{a, b}] = z
		end
	return new
	end
end

--population = {{-1, initialize()}}
--for q = 1, 9 do
--	table.insert(population, {-1, initialize()})
--end

function bulbasaur()
	for j = 10, 2, -1 do
		for i = 1, j-1 do
			if population[i][1] < population[i + 1][1] then
				temp = population[i]
				population[i] = population[i + 1]
				population[i + 1] = temp
			end
		end
	end
end
n = 0
while true do
print("n")
print(n)
for i = 1, 10 do
	if population[i][1] == -1 then
	print(i)
	joyreset()
	savestate.loadslot(1)
--	for q = 1, 20 do
--		emu.frameadvance()
--	end
	
	while memory.readbyte(0x9844) == 47 do
		detmoves(population[i][2])
		setjoy(population[i][2])
		emu.frameadvance()
	end
	population[i][1] = memory.readbyte(0xE0A0) + 16*16*memory.readbyte(0xE0A1) + 16*16*16*16*memory.readbyte(0xE0A2)
	end
end
bulbasaur()
for i = 1, 5 do
	if population[i][1] ==0 then
		population[i] = {-1, initialize()}
		population[i+5] = {-1, initialize()}
	else
		population[i + 5] = {-1, mutate(population[i][2])}
	end
end
best = population[1][2]
for w = 1, 5 do
print(population[w][1])
end
n = n + 1
if n % 10 == 0 and mutationstrength > 5 then mutationstrength = mutationstrength - 1 end
if population[1][1] > 0 then frames = frames + 1 end
end