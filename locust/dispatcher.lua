function readNum(h)
	return tonumber(h.readLine())
end

config = fs.open("disk/cfg","r")

y_pos = readNum(config)
x_offset = readNum(config)
y_offset = readNum(config)
z_offset = readNum(config)
rows = readNum(config)
seg_size = readNum(config)
seg_count = readNum(config)

config.close()

for row = 1,rows do

	for seg = seg_count,1,-1 do

		x = x_offset + (seg-1)*4*seg_size + row%2*2
		z = z_offset + (row - 1) * 2

		h = fs.open("job","w")
		
		h.writeLine(tostring(x))
		h.writeLine(tostring(y_offset))
		h.writeLine(tostring(z))
		
		h.writeLine(tostring(seg_size))
		h.writeLine(tostring(y_pos))

		h.close()

		while fs.exists("disk/job") do sleep(0.5) end

		shell.run("mv ../job ../disk/job")

	end

end