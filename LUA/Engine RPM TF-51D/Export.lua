-- This Export.lua works ONLY for the TF-51D!!!
-- Other aircraft can be supported by findig the right number to put into "MainPanel:get_argument_value(?)"

MainPanel = GetDevice(0)

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
	
	local RPM = MainPanel:get_argument_value(23) * 4500
	
	socket.try(MySocket:send(string.format("RPM: %.4f \n",RPM)))
end

function LuaExportStop()

	if MySocket then 
		socket.try(MySocket:send("exit"))
		MySocket:close()
	end
end

function LuaExportActivityNextEvent(t)
end
