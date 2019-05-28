
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

	local NoseGear = LoGetAircraftDrawArgumentValue(1)
	local RightGear = LoGetAircraftDrawArgumentValue(4)
	local LeftGear = LoGetAircraftDrawArgumentValue(6)
	
	socket.try(MySocket:send(string.format("Left: %.4f \t Nose: %.4f \t Right: %.4f\n", LeftGear, NoseGear, RightGear)))
	
end

function LuaExportStop()

	if MySocket then 
		socket.try(MySocket:send("exit"))
		MySocket:close()
	end
end

function LuaExportActivityNextEvent(t)

end