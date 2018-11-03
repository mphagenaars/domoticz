-- script_device_container.lua

-- DOMOTICZ
-- device based script container

-- VARIABELEN DEFINIEREN
local time = os.date("*t")

-- FUNCTIES DEFINIEREN
-- index
-- 1) verlichting: handmatige bediening met xiaomi-buttons
-- 2) beweging: dummy motionsensor(s) aan zetten
-- 3) verlichting: licht uit wanneer er geen beweging is in de woonkamer
-- 4) verlichting: verlichting uitschakelen wanneer er genoeg daglicht is
-- 5) verlichting: licht aan in de hal wanneer er beweging is

-- 1) handmatig licht aan/uit met Xiaomi schakelaars op de slaapkamer
function lichtXiaomi(xiaomiSwitch)
  if otherdevices[xiaomiSwitch] == "Click" then 
    commandArray[#commandArray + 1] = {["lichtWoonkamer"] = "On"}
    commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
  elseif otherdevices[xiaomiSwitch] == "Double Click" then 
    commandArray[#commandArray + 1] = {["lichtWoonkamer"] = "Off"}
    commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
  elseif otherdevices[xiaomiSwitch] == "Long Click" then 
    commandArray[#commandArray + 1] = {["lichtWoonkamer"] = "Off"}
    commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
  elseif otherdevices[xiaomiSwitch] == "Long Click Release" then 
    commandArray[#commandArray + 1] = {["lichtWoonkamer"] = "Off"}
    commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
  end
end

-- 2) beweging: dummy motionsensor(s) aan zetten
function beweging(pir,sensor)
  if otherdevices[pir] == "On" then
    commandArray[sensor] = "On"
  end
end

-- 3) verlichting: licht uit wanneer er geen beweging is in de woonkamer
function lichtUit(lichtknop)
  if otherdevices["bewegingZithoek"] == "Off" then
    commandArray[lichtknop] = "Off"
  end
end

-- 4) verlichting: verlichting uitschakelen wanneer er genoeg daglicht is
function dagLicht(lichtknop)
  if otherdevices["luxDonker"] == "Off" then
    commandArray[lichtknop] = "Off"
  end
end

-- 5) verlichting: licht aan in de hal wanneer er beweging is
function lichtHal(lamp)
  if otherdevices["pirHal"] == "On" then
    commandArray[#commandArray + 1] = {[lamp] = "Set Level 55"}
    commandArray[#commandArray + 1] = {[lamp] = "Off AFTER 450"}
  end
end

-- vanaf hier regelen dat alles wordt geschakeld zoals gedefinieerd
commandArray = {}
-- xiaomi knoppen ivm bedienen van het licht
if devicechanged["xiaomiSwitchJasmijn"] then 
  local functie = lichtXiaomi("xiaomiSwitchJasmijn")
end  
if devicechanged["xiaomiSwitchMatthijs"] then 
  local functie = lichtXiaomi("xiaomiSwitchMatthijs")
end
-- beweging zithoek
if devicechanged["pirZithoek"] then
  local functie = beweging("pirZithoek", "bewegingWoonkamer")
end
-- beweging eethoek
if devicechanged["pirEethoek"] then
  local functie = beweging("pirEethoek", "bewegingWoonkamer")
end
-- verlichting Woonkamer
if devicechanged["bewegingWoonkamer"] then 
  local functie = lichtUit("lichtWoonkamer")
end
if devicechanged["luxDonker"] then 
  local functie = dagLicht("lichtWoonkamer")
end
-- verlichting Hal
if devicechanged["pirHal"] then  
  local functie = lichtHal("lichtHal")
end

return commandArray
