function readNum(h)
	return tonumber(h.readLine())
end

function readStr(h)
	return tostring(h.readLine())
end


print("Locust Dispatcher ~ 2.02q EXPERIMENTAL:quarry")

if fs.exists("/disk/job") then shell.run("rm /disk/job") end

config = fs.open("disk/cfg","r")
mode = readStr(config)


----------
--QUARRY--
----------
if mode == "quarry"

	y_spawn = readNum(config) -- global y of spawnpoint

	x1 = readNum(config) -- 1st grid corner
	y1 = readNum(config)
	z1 = readNum(config)

	x2 = readNum(config) -- 2nd grid corner
	y2 = readNum(config)
	x2 = readNum(config)

	r = reaNum(config) -- area each turtle mines

	config.close()

	xdif = math.abs(x1 - x2)
	ydif = math.abs(y1 - y2)
	zdif = math.abs(z1 - z2)

	--create job file
	for row = 1,math.floor(xdif/r) do
		for col = 1,math.floor(zdif/r) do

			xj1 = ((row-1)*r)+1
			zj1 = ((col-1)*r)+1

			xj2 =


			h = fs.open("job","w")

			h.writeLine(tostring(quarry))
			h	.writeLine(tostring(y_spawn))

			h.writeLine(tostring(xj1)) -- job startpoint
			h.writeLine(tostring(y1))
			h.writeLine(tostring(zj1))

			h.writeLine(tostring(xj2)) -- job endpoint
			h.writeLine(tostring(yj2))
			h.writeLine(tostring(zj2))

			h.writeLine(tostring(r))  --chunk size


			h.close()

			while fs.exists("disk/job") do sleep(0.5) end

			shell.run("mv ../job ../disk/job")

		end
	end
end
