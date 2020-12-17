
state = {}
blacklist = {}

--state keys
pos = {} -- vector of coordinates
rot = {} -- rotation, 0 = toward +x, 1 = toward +z, 2 = toward -x, 3 = toward -z (right turn is rot=(rot+1)%3)
mode = {} -- harvest state
target = {} -- position to begin harvest
y_offset = {} -- how high the local origin is above world origin, used for computing fuel cost
at_bedrock = {} -- if we have completed a down dig
rot_dir = {} -- spin dig direction
level_spin_count = {}
block_reset = {}

--Load the blacklist from storage
function loadBlacklist()
	if fs.exists("blacklist") then
		h = fs.open("blacklist","r")
		line = h.readLine()
		while line ~= nil do
			blacklist[line] = true
			line = h.readLine()
		end
		h.close()
	end
end

--Load the state from storage, or initialize if empty
function readNum(handle)
	return tonumber(handle.readLine())
end
function loadState()
	if fs.exists("state") then
		handle = fs.open("state","r")
		state[pos] = vector.new(readNum(handle),readNum(handle),readNum(handle))
		state[rot] = readNum(handle)
		state[mode] = handle.readLine()
		state[target] = vector.new(readNum(handle),readNum(handle),readNum(handle))
		state[y_offset] = readNum(handle)
		state[at_bedrock] = readNum(handle)
		state[rot_dir] = handle.readLine()
		state[level_spin_count] = readNum(handle)
		state[block_reset] = readNum(handle)
		handle.close()
	else
		state[pos] = vector.new(0,0,0)
		state[rot] = 0
		state[y_offset] = 0
		state[mode] = "awaiting_instructions"
		state[at_bedrock] = 0
		state[rot_dir] = "r"
		state[level_spin_count] = 0
		state[block_reset] = 0

		--first time install
		shell.run("cp disk/startup.lua startup.lua")
		shell.run("cp disk/blacklist blacklist")
	end
end

--save the current state to memory in case of reset
function saveState()
	handle = fs.open("state","w")
	handle.writeLine(tostring(state[pos].x).."\n"..tostring(state[pos].y).."\n"..tostring(state[pos].z))
	handle.writeLine(tostring(state[rot]))
	handle.writeLine(state[mode])
	handle.writeLine(tostring(state[target].x).."\n"..tostring(state[target].y).."\n"..tostring(state[target].z))
	handle.writeLine(tostring(state[y_offset]))
	handle.writeLine(tostring(state[at_bedrock]))
	handle.writeLine(state[rot_dir])
	handle.writeLine(tostring(state[level_spin_count]))
	handle.writeLine(tostring(state[block_reset]))
	handle.close()
end

function up()
	while not turtle.up() do sleep(0.5) end
	state[pos].y = state[pos].y+1
	saveState()
end
function down()
	while not turtle.down() do sleep(0.5) end
	state[pos].y = state[pos].y-1
	saveState()
end
function forward()
	while not turtle.forward() do sleep(0.5) end
	state[pos].x = state[pos].x+({1,0,-1,0})[state[rot]+1]
	state[pos].z = state[pos].z+({0,1,0,-1})[state[rot]+1]
	saveState()
end
function back()
	while not turtle.back() do sleep(0.5) end
	state[pos].x = state[pos].x+({-1,0,1,0})[state[rot]+1]
	state[pos].z = state[pos].z+({0,-1,0,1})[state[rot]+1]
	saveState()
end

function turnLeft()
	turtle.turnLeft()
	state[rot] = ((state[rot]-1)%4)
	saveState()
end
function turnRight()
	turtle.turnRight()
	state[rot] = ((state[rot]+1)%4)
	saveState()
end

--Remove blacklisted blocks from inventory to save space
function dropBlacklistedBlocks()
	for i=1,16 do
		turtle.select(i)
		item = turtle.getItemDetail()
		if item and blacklist[item.name] then turtle.dropDown() end
	end
end

--Move downward. dig down if movement is obstructed. return false if an impassible block is reached
function mineDown()
	while true do
		if turtle.down() then
			state[pos].y = state[pos].y-1
			saveState()
			return true
		elseif turtle.inspectDown() then
			success = turtle.digDown()
			if success then
				if turtle.down() then
					state[pos].y = state[pos].y-1
					saveState()
				end
			end
			return success
		else
			turtle.attackDown()
		end
	end
end
function mineForward() -- move forward eventually hopefully
	while true do
		if turtle.forward() then
			state[pos].x = state[pos].x+({1,0,-1,0})[state[rot]+1]
			state[pos].z = state[pos].z+({0,1,0,-1})[state[rot]+1]
			saveState()
			return
		end
		turtle.dig()
	end
end
function mineUp() -- move upward eventually hopefully
	while true do
		if turtle.up() then
			state[pos].y = state[pos].y+1
			saveState()
			return
		end
		turtle.digUp()
	end
end

--compute the fuel required for a given job
function computeFuelCost()
	cost = 0
	cost = cost + math.abs(state[target].x)*2
	cost = cost + math.abs(state[target].y)*2
	cost = cost + math.abs(state[target].z)*2
	cost = cost + (state[target].y+state[y_offset])*2
	return cost + 10 -- add a little wiggle room
end

function targetDesired()
	b,v = turtle.inspect()
	return b and blacklist[v.name] == nil
end

function harvest()
	turtle.dig()
end


--------
--MAIN--
--------
if not turtle then
	shell.run("disk/dispatcher.lua")
	crash()
end

loadState()
loadBlacklist()

while true do
	if state[mode] == "awaiting_instructions" then -- await instructions from dispatcher
		while not fs.exists("/disk/job") do sleep(0.1) end
		handle = fs.open("/disk/job","r")
		state[target] = vector.new(readNum(handle),readNum(handle),readNum(handle))
		state[y_offset] = readNum(handle)
		handle.close()
		shell.run("rm /disk/job")
		state[mode] = "loading_fuel"
		saveState()

	elseif state[mode] == "loading_fuel" then -- fueling
		required_fuel = computeFuelCost()
		print("fuel cost: "..tostring(required_fuel))
		required_fuel_count = math.ceil(required_fuel/80.0) -- convert to coal
		while turtle.getFuelLevel() < required_fuel do
			turtle.suckUp(64)
			cycle = math.min(required_fuel_count, turtle.getItemCount())
			required_fuel_count = required_fuel_count - cycle
			turtle.refuel(cycle)
			turtle.dropUp(64)
		end
		forward()
		state[mode] = "enroute_y"
		saveState()

	elseif state[mode] == "enroute_y" then
		while state[pos].y < state[target].y + 1 do -- get one above the dig zone
			up()
		end
		state[mode] = "enroute_z"
		saveState()

	elseif state[mode] == "enroute_z" then
		if state[pos].z == state[target].z then
			state[mode] = "enroute_x"
			saveState()
		else
			if state[rot] == 0 then turnRight()
			elseif state[rot] == 1 then
				if state[pos].z < state[target].z then forward() else back() end
			elseif state[rot] == 2 then turnLeft()
			else
				if state[pos].z > state[target].z then forward() else back() end
			end
		end

	elseif state[mode] == "enroute_x" then
		if state[pos].x == state[target].x and state[rot] == 0 then
			state[mode] = "mining_down"
			down() -- saves state
		else
			if state[rot] == 0 then forward()
			elseif state[rot] == 1 then turnLeft()
			elseif state[rot] == 2 then turnLeft()
			else turnRight()
			end
		end

	elseif state[mode] == "mining_down" then
		if mineDown() then state[at_bedrock] = 0 else state[at_bedrock] = 1 end
		state[level_spin_count] = 0
		state[mode] = "mining_down_a"
		saveState()

	elseif state[mode] == "mining_down_a" then
		if state[level_spin_count] == 0 and targetDesired() then harvest() end
		turnRight()
		if targetDesired() then harvest() end
		state[level_spin_count] = (state[level_spin_count] + 1) % 3
		if state[level_spin_count] == 0 then
			if state[at_bedrock] == 1 then
				state[mode] = "return_to_surface"
			else
				state[mode] = "mining_down"
			end
		end

	elseif state[mode] == "return_to_surface" then
		if state[pos].y < state[target].y+2 then
			up()
		else
			state[mode] = "return_x"
			saveState()
		end

	elseif state[mode] == "return_x" then
		if state[pos].x == -3 then
			state[mode] = "return_z"
			saveState()
		else
			if state[rot] == 2 then forward()
			elseif state[rot] == 1 then turnRight()
			elseif state[rot] == 0 then turnRight()
			else turnLeft()
			end
		end
		
	elseif state[mode] == "return_z" then
		if state[pos].z == 0 then
			state[mode] = "return_y"
			saveState()
		else
			if state[rot] == 1 then
				if state[pos].z < 0 then forward() else back() end
			elseif state[rot] == 2 then turnRight()
			elseif state[rot] == 0 then turnRight()
			else
				if state[pos].z < 0 then back() else forward() end
			end
		end
	
	elseif state[mode] == "return_y" then
		if state[pos].y <= 0 then
			state[mode] = "end_dump"
			saveState()
		else
			down()
		end

	elseif state[mode] == "end_dump" then
		for i=1,16 do
			turtle.select(i)
			turtle.dropDown()
		end
		state[mode] = "end_reorient"
		saveState()
	
	elseif state[mode] == "end_reorient" then
		if state[rot] == 0 then
			state[mode] = "end_return_home" -- todo: drop stuff
			saveState()
		elseif state[rot] == 1 then
			turnLeft()
		else turnRight() end

	elseif state[mode] == "end_return_home" then
		if state[pos].x < 0 then
			forward()
		else
			if state[block_reset] == 0 then
				shell.run("rm /state")
				shell.run("rm /blacklist")
				shell.run("rm /startup.lua")
				shell.run("reboot")
			else
				state[mode] = "loading_fuel"
				saveState()
			end
		end

	elseif state[mode] == "DONE" then
		break

	end
end
print("GG routines finished")