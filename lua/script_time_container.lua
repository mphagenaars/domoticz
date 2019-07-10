-- SCRIPT_TIME_CONTAINER.LUA

-- VARIABELEN DEFINIEREN
local time = os.date("*t")

-- functies ophalen uit extern lua-script
local Current_Path = debug.getinfo(1).source:match("@?(.*/)")
package.path = package.path .. ';' .. Current_Path .. '?.lua'
require "functions"


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

-- 2a. dummy device voor bepalen dag/nacht
if timeofday["Nighttime"] == true and otherdevices["nightTime"] == "Off" then 
   commandArray["nightTime"] = "On"
elseif timeofday["Nighttime"] == false and otherdevices["nightTime"] == "On" then
   commandArray["nightTime"] = "Off"  
end

-- 2b. dummy device gebaseerd op LUX metingen
schemerMinuten = tonumber(uservariables['schemerCounter'])
lichtMinuten = tonumber(uservariables['lichtCounter'])
lux = tonumber(otherdevices_svalues['luxSerre'])

if lux < 400 then 
   schemerMinuten = schemerMinuten + 1
   lichtMinuten = 0
   if schemerMinuten > 5 and otherdevices['schemerSensor'] == 'Off' then 
      commandArray['schemerSensor']='On'
   end
else 
   schemerMinuten = 0
   lichtMinuten = lichtMinuten + 1
   if lichtMinuten > 5 and otherdevices['schemerSensor'] == 'On' then 
      commandArray['schemerSensor']='Off'
   end
end

commandArray['Variable:schemerCounter'] = tostring(schemerMinuten)
commandArray['Variable:lichtCounter'] = tostring(lichtMinuten)


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

-- 4. bewegingsdetectie overloop
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
