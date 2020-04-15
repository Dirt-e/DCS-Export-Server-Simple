-- This script illustrates the implementation of a Lowpass filter.
-- Vertical G-load is LP filtered and then exported

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

	--Get the data
	Accel = LoGetAccelerationUnits()
	G_vert = Accel.y
	
	--Set filter parameter
	LowPass.Alpha = 0.01
	
	--Push data
	LowPass.Push(G_vert)
	
	--Get the result
	FilteredValue = LowPass.Output
	
	--Send data out
	socket.try(MySocket:send(string.format("Vertical G (LP filtered): %.4f \n", FilteredValue)))
end

function LuaExportStop()

	if MySocket then 
		socket.try(MySocket:send("exit"))
		MySocket:close()
	end
end

function LuaExportActivityNextEvent(t)
end



------------------------LOW PASS---------------------
LowPass = 	{
				Alpha = 1,
				OldValue = 0,
				Output = 0,
				
				Push = function (NewValue)
					LowPass.Output = NewValue * LowPass.Alpha + LowPass.OldValue * (1-LowPass.Alpha)		--Generate Output
					LowPass.OldValue = LowPass.Output														--Remember for nex time
				
				end
			}






