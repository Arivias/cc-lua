h=fs.open("locust-installer.lua","w")
h.write(http.get("https://raw.githubusercontent.com/Arivias/cc-lua/main/locust/installer.lua").readAll())
h.close()
shell.run("locust-installer.lua")