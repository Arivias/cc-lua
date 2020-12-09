local args = {...}
local branch = "main"

local function install(branch, remote, filename)
	if not filename then filename = remote end
	print("fetching "..filename.."...")
	local handle = fs.open("disk/"..filename,"w")
	local r = http.get("https://raw.githubusercontent.com/Arivias/cc-lua/"..branch.."/locust/"..remote)
	handle.write(r.readAll())
	r.close()
	handle.close()
end

if #args > 0 then
	if args[1] == "update" then
		print("Fetching latest version...")
		local remote = http.get("https://raw.githubusercontent.com/Arivias/cc-lua/main/locust/installer.lua")
		local h = fs.open("locust-installer.lua","w")
		h.write(remote.readAll())
		remote.close()
		h.close()
		print("Done!")
	else
		print("Fetching branch: "..args[1])
		branch = args[1]
	end
else
	print("Installing locust to disk...")
	install(branch, "locust.lua", "startup.lua")
	install(branch, "dispatcher.lua")
	install(branch, "blacklist")
end