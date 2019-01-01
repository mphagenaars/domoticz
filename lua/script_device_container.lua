-- script_device_container.lua

-- DOMOTICZ
-- device based script container

-- VARIABELEN DEFINIEREN
local time = os.date("*t")

-- FUNCTIES DEFINIEREN
-- index
-- 1) handmatig licht aan/uit met Xiaomi schakelaars op de slaapkamer
-- 2) beweging: dummy motionsensor(s) aan zetten
-- 3) verlichting: licht uit wanneer er geen beweging is in de woonkamer
-- 4) verlichting: verlichting uitschakelen wanneer er genoeg daglicht is
-- 5) verlichting: licht aan in de hal schakelen op beweging
-- 6) verlichting: licht op de vliering boven de garage schakelen op beweging

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
    if otherdevices[sensor] == "Off" then commandArray[sensor] = "On" end
  end
end

-- 3) verlichting: licht uit wanneer er geen beweging is in de woonkamer
function lichtUit(lichtknop)
  if otherdevices["bewegingWoonkamer"] == "Off" then
    if otherdevices[lichtknop] ~= "Off" then commandArray[lichtknop] = "Off" end
  end
end

-- 4) verlichting: generieke aan/uit schakelaar voor verlichting
function lichtSchakelaar(trigger,lamp)
  if otherdevices[trigger] == "On" then
    if otherdevices[lamp] = "Off" then commandArray[lamp] = "On" end
  elseif otherdevices[trigger] == "Off" then
    if otherdevices[lamp] ~= "Off" then commandArray[lamp] = "Off" end
  end
end

-- 5) verlichting: licht aan in de hal schakelen op beweging
function lichtHal(lamp)
  if otherdevices["pirHal"] == "On" then
    commandArray[#commandArray + 1] = {[lamp] = "Set Level 55"}
    commandArray[#commandArray + 1] = {[lamp] = "Off AFTER 450"}
  end
end

-- 6) verlichting: licht op de vliering boven de garage schakelen op beweging
function lichtVliering(lamp)
  if otherdevices["bewegingVliering"] == "On" then
    commandArray[#commandArray + 1] = {[lamp] = "Set Level 55"}
  elseif otherdevices["bewegingVliering"] == "Off" then
    commandArray[#commandArray + 1] = {[lamp] = "Off"}
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
-- als er beweging in de zithoek gesignaleerd wordt
if devicechanged["pirZithoek"] then
  local functie = beweging("pirZithoek", "bewegingWoonkamer")
end
-- als er beweging in de eethoek gesignaleerd wordt
if devicechanged["pirEethoek"] then
  local functie = beweging("pirEethoek", "bewegingWoonkamer")
end
-- als de aanwezigheidsdetectie in de woonkamer verandert
if devicechanged["bewegingWoonkamer"] then 
  local functie = lichtUit("lichtWoonkamer")
end
-- licht in het portiek automatisch aan en uit schakelen
if devicechanged["nightTime"] then 
  local functie = lichtSchakelaar("nightTime", "lichtPortiek")
end
-- als er beweging is in de hal
if devicechanged["pirHal"] then  
  local functie = lichtHal("lichtHal")
end
-- als er beweging is op de vliering
if devicechanged["pirVliering"] == "On" then 
  commandArray["bewegingVliering"] = "On"
end
if devicechanged["bewegingVliering"] then  
  local functie = lichtVliering("lichtVliering")
end

return commandArray
