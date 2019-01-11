-- script_device_container.lua

-- DOMOTICZ
-- device based script container

-- VARIABELEN DEFINIEREN
local time = os.date("*t")

function timebetween(s,e)
	timenow = os.date("*t")
	year = timenow.year
	month = timenow.month
	day = timenow.day
	s = s .. ":00" 
	e = e .. ":00"
	shour = string.sub(s, 1, 2)
	sminutes = string.sub(s, 4, 5)
	sseconds = string.sub(s, 7, 8)
	ehour = string.sub(e, 1, 2)
	eminutes = string.sub(e, 4, 5)
	eseconds = string.sub(e, 7, 8)
	t1 = os.time()
	t2 = os.time{year=year, month=month, day=day, hour=shour, min=sminutes, sec=sseconds}
	t3 = os.time{year=year, month=month, day=day, hour=ehour, min=eminutes, sec=eseconds}
	sdifference = os.difftime (t1, t2)
	edifference = os.difftime (t1, t3)
	isbetween = false
	if sdifference >= 0 and edifference <= 0 then
		isbetween = true
	end
	return isbetween
end

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
    if otherdevices["lichtSlaapkamer"] == "Off" then 
      commandArray[#commandArray + 1] = {["lichtSlaapkamerOntspannen"] = "On"}
      commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
    elseif otherdevices["lichtSlaapkamer"] ~= "Off" then
      commandArray[#commandArray + 1] = {["lichtSlaapkamer"] = "Off"}
      commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
    end      
--  elseif otherdevices[xiaomiSwitch] == "Long Click Release" then 
--    if otherdevices["lichtSlaapkamer"] == "Off" then 
--      commandArray[#commandArray + 1] = {["lichtSlaapkamerOntspannen"] = "On"}
--      commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
--    elseif otherdevices["lichtSlaapkamer"] ~= "Off" then
--      commandArray[#commandArray + 1] = {["lichtSlaapkamer"] = "Off"}
--      commandArray[#commandArray + 1] = {[xiaomiSwitch] = "Off AFTER 10"}
--    end   
  end
end

-- 2) beweging: dummy motionsensor(s) aan zetten
function beweging(pir,sensor)
  if otherdevices[pir] == "On" then commandArray[sensor] = "On" end
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
    if otherdevices[lamp] == "Off" then commandArray[lamp] = "On" end
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

-- 7) verlichting op de overloop regelen
function lichtOverloop(lamp)
  if otherdevices["bewegingOverloop"] == "On" and otherdevices["nightTime"] == "On" and
          timebetween ("14:00:00","22:59:59") then
    commandArray["lichtOverloopOntspannen"] = "On FOR 10"
  elseif otherdevices["bewegingOverloop"] == "On" and otherdevices["nightTime"] == "On" and 
          timebetween ("06:30:00","10:59:59") then
    commandArray["lichtOverloopOntspannen"] = "On FOR 10"
  elseif otherdevices["bewegingOverloop"] == "Off" and otherdevices["nightTime"] == "On" then
    commandArray["lichtOverloopNachtlampje"] = "On FOR 10" 
  elseif otherdevices["bewegingOverloop"] == "Off" and otherdevices["nightTime"] == "Off" then
    commandArray["lichtOverloop"] = "Off"
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
-- als er bewging op de overloop gesignaleerd wordt
if devicechanged["pirOverloop1"] then
  local functie = beweging("pirOverloop1", "bewegingOverloop")
end
if devicechanged["pirOverloop2"] then
  local functie = beweging("pirOverloop2", "bewegingOverloop")
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
-- als er beweging is op de overloop
if devicechanged["bewegingOverloop"] then
  local functie = lichtOverloop("lichtOverloop")
end

return commandArray
