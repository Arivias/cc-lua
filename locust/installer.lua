local VERSION="1.0"--REGEX MATCH THIS

local args = {...}

local function install(remote, filename)
	if not filename then filename = remote end
	print("fetching "..filename.."...")
	local handle = fs.open("disk/"..filename,"w")
	handle.write(http.get("https://raw.githubusercontent.com/Arivias/cc-lua/main/locust/"..remote))
	handle.close()
end

if #args > 0 then
	if args[1] == "update" then
		print("Fetching latest version...")
		local remote = http.get("https://raw.githubusercontent.com/Arivias/cc-lua/main/locust/installer.lua")
		local version = tonumber(string.gfind(remote,"local VERSION=\"(.*)\"--REGEX MATCH THIS"))
		if version > tonumber(VERSION) then
			print("Updating...")
			local h = fs.open("locust-installer.lua","w")
			h.write(remote)
			h.close()
			print("Done!")
		else
			print("No update available")
		end
	else
		print("Usage: locust-installer.lua [update]")
	end
else
	print("Installing locust to disk...")
	install("locust.lua", "startup.lua")
	install("dispatcher.lua")
	install("blacklist)
end