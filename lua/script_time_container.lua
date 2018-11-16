-- DOMOTICZ
-- time based script container 


commandArray = {}

-- 1. bewegingsdetectie woonkamer
no_motion_minutes = tonumber(uservariables["nomotionCounterWoonkamer"])
 
if (otherdevices["pirZithoek"] == "Off" and otherdevices["pirEethoek"] == "Off") then
   no_motion_minutes = no_motion_minutes + 1
else 
   no_motion_minutes = 0	
end 

commandArray["Variable:nomotionCounterWoonkamer"] = tostring(no_motion_minutes)

if otherdevices["bewegingWoonkamer"] == "On" and no_motion_minutes > 1 then
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


return commandArray
