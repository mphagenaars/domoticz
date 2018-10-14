-- DOMOTICZ
-- time based script container 


commandArray = {}

-- 1. bewegingsdetectie
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

-- 2) verlichting: status "donker" bij lage lux waarden
if (tonumber(otherdevices["luxZithoek"]) < 100) or (tonumber(otherdevices["luxGateway"]) < 1000) then  
  if otherdevices["luxDonker"] == "Off" then 
    commandArray["luxDonker"] = "On"
  end
end


return commandArray
