-- This Export.lua file will show you the lift and drag forces (not coefficients!) acting on the airframe.
-- AFAICT lift is correct. Drag in the context of this file depicts the thrust surplus/deficit only.
-- To get valid results in regard to the drag of the airframe, thrust should be set to idle.

--Conversions. Don't change!!!
local r2d 		= 57.295779513082323		--converts Rad into Degrees 
local d2r		= 1.0/r2d					--converts Degrees into radians 
local m2k 		= 1.94384					--converts m/s into Knots
local C2K 		= 273.15					--converts between C and Kelvin 
local Lbs2Kg 	= 0.453592					--converts Kgs into Lbs
local Kg2Lbs	= 1.0/Lbs2Kg				--converts lbs into Kg
local G2mss		= 9.80665					--converts G into m/s^2
local mss2G		= 1.0/G2mss					--converts m/s^2 into G

--Enter the total grossweight of the aircraft. (Caution: Disable fuelburn to get consistent results over the duration of the flight!)
local Mass = 9500.0 * Lbs2Kg

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
	
	local L = GetLiftForce(Mass)	--[N]
	local D = GetDragForce(Mass)	--[N]
	
	socket.try(MySocket:send(string.format("Lift[N]: %.4f \t Drag[N]: %.4f \n",L , D)))
	
end

function LuaExportStop()

	if MySocket then 
		socket.try(MySocket:send("exit"))
		MySocket:close()
	end
end

function LuaExportActivityNextEvent(t)
end




--//////////////////////////////////////////////////////////////////
--///////////////////// Helper functions ///////////////////////////
--//////////////////////////////////////////////////////////////////

-----------------------Atmospheric-----------------------------
GetAtmosphericPressure = function()
--returns the ambient atmospheric pressure [Pa] at present location

	local PressureAltitude = LoGetAltitudeAboveSeaLevel()
 
	return ISA_HPaFromAltitude(PressureAltitude)
end

GetAtmosphericDensity = function()
--returns the ambient atmospheric density [Kg/m^3] at present location

	local PressureAltitude = LoGetAltitudeAboveSeaLevel()
 
	return ISA_RohFromAlt(PressureAltitude)
end

GetAtmosphericTemperature = function(Celsius)
--returns the ambient atmospheric temperature in [K] or [C] at present location.
--Result will be Celsius if argument is true
--Result will be Kelvin by default

	local PressureAltitude = LoGetAltitudeAboveSeaLevel()
	
	if (Celsius == true) then
		return ISA_TempFromAlt_C(PressureAltitude)
	else
		return ISA_TempFromAlt_K(Press)
	end
end

GetDynamicPressure = function()
--Returns dynamic pressure in [Pa].

	local IAS = LoGetIndicatedAirSpeed()
	local Pdyn = math.pow(IAS,2)/2
	
	return Pdyn
end

ISA_HPaFromAltitude = function(h) 
--returns the atmospheric pressure in [Pascal] as a function of barometric altitude

	local e = 2.7182818284		--Eulers number
	local P_Null = 101325		--Pressure at sea level
	local g = 9.80665			--Earth acceleration
	local M = 0.0289644			--[Kg/Mol]
	local R_Null = 8.31447		--[J/Mol*Kg]
	local T_Null = 288.15		--Temp at seal level [K]
	local Rs = 287.058			--[J/Kg*K]

	local exponent = -(g * M * h)/( R_Null * T_Null)
	local P = P_Null * math.pow(e, exponent)
	
	return P
end

ISA_TempFromAlt_K = function(h)
--returns the ambient temperature in [K] according to the ICAO Standart Atmosphere (ISA)

	--constants:
	local C2K = 273.15					--converts between C and Kelvin 
	
	--ISA Temperature profile
	local Temp_Null = 15.0 + C2K
	local Temp_11k = -56.5 + C2K
	local Temp_20K = -56.5 + C2K
	local Temp_32K = -44.5 + C2K
	
	
	if  (h < 11000) then
		return Temp_Null + (h/11000) * (Temp_11k - Temp_Null)
	else
		return Temp_11k
	end
end

ISA_TempFromAlt_C = function(h)
--returns the ambient temperature in [C] according to the ICAO Standart Atmosphere (ISA)
	local C2K = 273.15					--converts between C and Kelvin 
	
	return ISA_TempFromAlt_K - C2K
end

ISA_RohFromAlt = function(h)
--returns the air density as a function of barometric altitude
	local M = 0.0289644			--[Kg/Mol]
	local R_Null = 8.31447		--[J/Mol*Kg]
	
	-- Roh = (p*M)/(R*T)
	local Denominator = ISA_HPaFromAltitude(h) * M
	local Divisor = R_Null * ISA_TempFromAlt_K(h)
	
	return Denominator/Divisor
end


--------------------AirData----------------------------------------
GetLiftForce = function(Mass)
--returns the lift force acting on the airframe in [N]
	local A = LoGetAccelerationUnits()
	local AoA = LoGetAngleOfAttack() * d2r
	
	local Lift =  Mass * (A.y * math.cos(AoA) + A.x * math.sin(AoA)) * G2mss
	
	return Lift
end

GetDragForce = function(Mass)
--returns the drag force acting on the airframe in [N]
	local A = LoGetAccelerationUnits()
	local AoA = LoGetAngleOfAttack() * d2r
	
	local Drag =  Mass * (A.x * math.cos(AoA) - A.y * math.sin(AoA)) * G2mss
	
	return Drag
end
