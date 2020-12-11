function readNum(h)
	return tonumber(h.readLine())
end

print("Locust Dispatcher 2.0a2q - EXPERIMENTAL")

if fs.exists("/disk/job") then shell.run("rm /disk/job") end

config = fs.open("/disk/cfg","r")

y_spawn = readNum(config) -- global y of

x_grid = readNum(config) -- grid corner coords
y_grid = readNum(config)
z_grid = readNum(config)

w_grid = readNum(config) -- (z) width of desired area
l_grid = math.ceil(readNum(config)/5) -- (x) length of desired area

config.close()

-- write a list of dig spots in the grid area
for row = 1,w_grid do
	for col = l_grid,1,-1 do

		x = x_grid + 5*(col-1) + (2*(row-1)%5)
		z = z_grid + row-1

		h = fs.open("job","w")

		if x <= x_grid + l_grid and z <= z_grid + w_grid
			h.writeLine(tostring(x))
			h.writeLine(tostring(y_grid))
			h.writeLine(tostring(z))

			h.writeLine(tostring(y_spawn))

			h.close()

			while fs.exists("/disk/job") do sleep(0.5) end

			shell.run("mv /job /disk/job")
		end
	end
end
