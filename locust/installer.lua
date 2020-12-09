local args = {...}
local version = "1.43"

local branch = "main"
local do_install = true

local function cb(url)
	return url..("?cb=%x"):format(math.random(0, 2^30))
end

local function install(branch, remote, filename)
	if not filename then filename = remote end
	print("fetching "..filename.."...")
	local handle = fs.open("disk/"..filename,"w")
	local r = http.get(cb("https://raw.githubusercontent.com/Arivias/cc-lua/"..branch.."/locust/"..remote))
	if not r then
		print("File(or branch) does not exist.")
		return
	end
	handle.write(r.readAll())
	r.close()
	handle.close()
end

if #args > 0 then
	if args[1] == "update" then
		do_install = false
		print("Fetching latest version...")
		local remote = http.get(cb("https://raw.githubusercontent.com/Arivias/cc-lua/main/locust/installer.lua"))
		local h = fs.open("locust-installer.lua","w")
		r = remote.readAll()
		if r then
			h.write(r)
			remote.close()
			h.close()
			print("Done!")
		else
			print("Something went wrong. Aborting update.")
		end
	elseif args[1] == "branch" or args[1] == "-b" then
		print("Fetching branch: "..args[2])
		branch = args[2]
	elseif args[1] == "version" then
		print("Version: "..version)
		do_install = false
	else
		print("Usage: locust-installer [args]\n\n\targs:\n\t\t-b branch | Install from a specific branch\n\n\thelp | Display this info\n\tversion | get the version("..version..")\n\tupdate | Update this installer to the latest version\n")
		do_install = false
	end
end

if do_install then
	print("Installing locust to disk...")
	install(branch, "locust.lua", "startup.lua")
	install(branch, "dispatcher.lua")
	install(branch, "blacklist")
	if not fs.exists("disk/cfg") then
		h = fs.open("disk/cfg","w")
		h.write("[Y_VAL]\n[X]\n[Y]\n[Z]\n1\n[WIDTH]\n[LENGTH]")
		h.close()
	end
end