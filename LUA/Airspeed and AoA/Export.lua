
--This Export.lua illustrates how to export multiple data. In this case IAS (Indicated Airspeed) and AoA (Angle of Attack)

function LuaExportStart()

	package.path  = package.path..";"..lfs.currentdir().."/LuaSocket/?.lua"
	package.cpath = package.cpath..";"..lfs.currentdir().."/LuaSocket/?.dll"

	socket = require("socket")
	IPAddress = "127.0.0.1"
	Port = 31090

	MySocket = socket.try(socket.connect(IPAddress, Port))
	MySocket:setoption("tcp-nodelay",true) 
end

function LuaExportBeforeNextFrame()
end

function LuaExportAfterNextFrame()

	--Both data are read:
	local IAS = LoGetIndicatedAirSpeed()
	local AoA = LoGetAngleOfAttack();
	--And then both data are being written into the formatted string:
	socket.try(MySocket:send(string.format("IAS: %.4f  AoA: %.4f \n",IAS,AoA)))
end

function LuaExportStop()

	if MySocket then 
		socket.try(MySocket:send("exit"))
		MySocket:close()
	end
end

function LuaExportActivityNextEvent(t)
end