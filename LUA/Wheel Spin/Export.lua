-- This script calculates the wheel speed. It uses Groundspeed and OnGround

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
	NoseGear = LoGetAircraftDrawArgumentValue(1)
	RightGear = LoGetAircraftDrawArgumentValue(4)
	LeftGear = LoGetAircraftDrawArgumentValue(6)
	vv = LoGetVectorVelocity()
	GS = math.sqrt( math.pow(vv.x,2) + math.pow(vv.z,2))
	
	--OnGround status is determined by the compression of ANY gear strut
	if (LeftGear > 0 or NoseGear > 0 or RightGear > 0)
		then
			OnGround = 1
		else
			OnGround = 0
	end
	
	--Ground roll
	WheelSpin = 0										--default value
		if (OnGround == 1) then
			WheelSpin = GS
		end	
	
	--Send data out
	socket.try(MySocket:send(string.format("Wheels spinning at: %.4f \n", WheelSpin)))
end

function LuaExportStop()

	if MySocket then 
		socket.try(MySocket:send("exit"))
		MySocket:close()
	end
end

function LuaExportActivityNextEvent(t)
end
