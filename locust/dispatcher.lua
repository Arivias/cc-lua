function readNum(h)
	return tonumber(h.readLine())
end

config = fs.open("disk/cfg","r")

y_spawn = readNum(config) -- global y of

x_grid = readNum(config) -- grid corner coords
y_grid = readNum(config)
z_grid = readNum(config)

d_grid = readNum(config) -- (y) depth of desired area (should be negative)
w_grid = readNum(config) -- (z) width of desired area
l_grid = readNum(config) -- (x) length of desired area

config.close()

-- write a list of dig spots in the grid area
for row = 1,l_grid+1 do
	for col = 1,w_grid+1 do

		x = x_grid + 4*(col-1) + (2*(row - 1)%5)
		z = z_grid + col-1

		h = fs.open("job","w")

		h.writeLine(tostring(x))
		h.writeLine(tostring(y_grid))
		h.writeLine(tostring(z))

		h.writeLine(tostring(d_grid))
		h.writeLine(tostring(y_spawn))

		h.close()

		while fs.exists("disk/job") do sleep(0.5) end

		shell.run("mv ../job ../disk/job")

	end
end
