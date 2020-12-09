local args = {...}
local branch = "main"
local do_install = true

local function install(branch, remote, filename)
	if not filename then filename = remote end
	print("fetching "..filename.."...")
	local handle = fs.open("disk/"..filename,"w")
	local r = http.get("https://raw.githubusercontent.com/Arivias/cc-lua/"..branch.."/locust/"..remote)
	print(r.getResponseCode())
	handle.write(r.readAll())
	r.close()
	handle.close()
end

if #args > 0 then
	if args[1] == "update" then
		do_install = false
		print("Fetching latest version...")
		local remote = http.get("https://raw.githubusercontent.com/Arivias/cc-lua/main/locust/installer.lua")
		local h = fs.open("locust-installer.lua","w")
		r = remote.readAll()
		if #r > 10 then
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
	else
		print("Usage: locust-installer [update] [-b branchname]")
	end
end

if do_install then
	print("Installing locust to disk...")
	install(branch, "locust.lua", "startup.lua")
	install(branch, "dispatcher.lua")
	install(branch, "blacklist")
end