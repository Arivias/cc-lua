local args = {...}

local function install(remote, filename)
	if not filename then filename = remote end
	print("fetching "..filename.."...")
	local handle = fs.open("disk/"..filename,"w")
	local r = http.get("https://raw.githubusercontent.com/Arivias/cc-lua/main/locust/"..remote)
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
		print("Usage: locust-installer.lua [update]")
	end
else
	print("Installing locust to disk...")
	install("locust.lua", "startup.lua")
	install("dispatcher.lua")
	install("blacklist")
end