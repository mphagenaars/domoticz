-- SCRIPT_TIME_CONTAINER.LUA

-- VARIABELEN DEFINIEREN
local time = os.date("*t")

commandArray = {}

-- 1. bewegingsdetectie woonkamer
no_motion_minutes = tonumber(uservariables["nomotionCounterWoonkamer"])
 
if (otherdevices["pirZithoek"] == "Off" and otherdevices["pirEethoek"] == "Off") then
   no_motion_minutes = no_motion_minutes + 1
else 
   no_motion_minutes = 0	
end 

commandArray["Variable:nomotionCounterWoonkamer"] = tostring(no_motion_minutes)

if otherdevices["bewegingWoonkamer"] == "On" and no_motion_minutes > 30 then
   commandArray["bewegingWoonkamer"] = "Off"
end


-- 2) verlichting: dusksensor aan/uit schakelen afhankelijk van lux in woonkamer
timerDonker = tonumber(uservariables["dusksensorCounterDark"])
timerLicht = tonumber(uservariables["dusksensorCounterLight"])
if (tonumber(otherdevices["luxZithoek"]) < 100) or (tonumber(otherdevices["luxGateway"]) < 1000) then  
   timerDonker = timerDonker + 1
   timerLicht = 0
else 
   timerDonker = 0
   timerLicht = timerLicht + 1
end

commandArray["Variable:dusksensorCounterDark"] = tostring(timerDonker)
commandArray["Variable:dusksensorCounterLight"] = tostring(timerLicht)

if timerDonker > 4 and otherdevices['luxDonker'] == "Off" then 
   commandArray["luxDonker"] = "On"
elseif timerLicht > 4 and otherdevices["luxDonker"] == "On" then 
   commandArray["luxDonker"] = "Off"
end


-- 3. bewegingsdetectie Vliering
no_motion_minutes = tonumber(uservariables["nomotionCounterVliering"])
 
if otherdevices["pirVliering"] == "Off" then
   no_motion_minutes = no_motion_minutes + 1
else 
   no_motion_minutes = 0	
end 

commandArray["Variable:nomotionCounterVliering"] = tostring(no_motion_minutes)

if otherdevices["bewegingVliering"] == "On" and no_motion_minutes > 10 then
   commandArray["bewegingVliering"] = "Off"
end


-- 4. dummy device voor bepalen dag/nacht
if timeofday["Nighttime"] == true and otherdevices["nightTime"] == "Off" then 
   commandArray["nightTime"] = "On"
elseif timeofday["Nighttime"] == false and otherdevices["nightTime"] == "On" then
   commandArray["nightTime"] = "Off"  
end


-- 5. bewegingsdetectie overloop
no_motion_minutes = tonumber(uservariables["nomotionCounterOverloop"])
 
if (otherdevices["pirOverloop1"] == "Off" and otherdevices["pirOverloop2"] == "Off") then
   no_motion_minutes = no_motion_minutes + 1
else 
   no_motion_minutes = 0	
end 

commandArray["Variable:nomotionCounterOverloop"] = tostring(no_motion_minutes)

if otherdevices["bewegingOverloop"] == "On" and no_motion_minutes > 10 then
   commandArray["bewegingOverloop"] = "Off"
end


-- 6. verlichting op de overloop aansturen (tot PIRS binnen zijn voorlopig tijdschakelaar gebruiken)
--if (time.hour == 17 and time.min == 00) then 
   --commandArray[#commandArray + 1] = {["lichtOverloopNachtlampje"] = "Off"}
--   commandArray[#commandArray + 1] = {["lichtOverloop"] = "On"}
--   commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "On"}
--elseif (time.hour == 20 and time.min == 00) then 
   --commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "Off"}
--   commandArray[#commandArray + 1] = {["lichtOverloop"] = "On"}
--   commandArray[#commandArray + 1] = {["lichtOverloopNachtlampje"] = "On"}
--end

--if timeofday['Daytime'] == true and otherdevices["lichtOverloop"] ~= "Off" then 
--   commandArray[#commandArray + 1] = {["lichtOverloopNachtlampje"] = "Off"}
--   commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "Off"}  
--   commandArray[#commandArray + 1] = {["lichtOverloop"] = "Off"}
--end

return commandArray
