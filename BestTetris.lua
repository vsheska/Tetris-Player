movelist = {"A", "B", "Up", "Down", "Left", "Right"}
joy = {}
joy["Power"] = "False"
joy["Select"] = "False"
joy["Start"] = "False"
for i, move in pairs(movelist) do
	joy[move] = false
end


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


joyreset()
savestate.loadslot(1)
	while memory.readbyte(0x9844) == 47 do
		detmoves(population[1][2])
		setjoy(population[1][2])
		emu.frameadvance()
	end
