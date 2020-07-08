-- SCRIPT_DEVICE_CONTAINER.LUA

-- DOMOTICZ
-- device based script container

-- VARIABELEN DEFINIEREN
local time = os.date("*t")


-- functies ophalen uit extern lua-script
local Current_Path = debug.getinfo(1).source:match("@?(.*/)")
package.path = package.path .. ';' .. Current_Path .. '?.lua'
require "functions"

-------------------------------------------------------------------------------------------------------------------
-- INDEX
-- 0) generieke functies --> allemaal naar functions.lua

-- 1) FYSIEKE SWITCHES EN SENSORS
-- 1.001) bewegingWoonkamer --> idx 48
-- 1.002) bewegingOverloop --> idx 156
-- 1.003) bewegingVliering --> idx 99
-- 1.004) pirHal --> idx 54
-- 1.005) switchHal --> idx 31
-- 1.006) switchSlaapkamerMulti --> idx 35
-- 1.007) switchSlaapkamerUni --> idx 182
-- 1.008) schemerSensor --> idx 360
-- 1.009) switchSlaapkamerMuur --> idx 138
-- 1.010) google chromecast --> idx 373 & 376
-- 1.011) powerplugKerstboom --> 344

-- 2) VIRTUELE SWITCHES / SOFTWARE / APP
-- 2.1) Toon selector switch


-------------------------------------------------------------------------------------------------------------------
-- FUNCTIES DEFINIEREN


-- 1) FYSIEKE SWITCHES EN SENSORS
-- 1.001) switch(bewegingWoonkamer): 
--        a) licht uit wanneer er geen beweging is in de woonkamer
--        b) licht aan wanneer het donker is en er iemand in de kamer is
function bewegingWoonkamer(lichtknop)
  if otherdevices["bewegingWoonkamer"] == "Off" then
    if otherdevices[lichtknop] ~= "Off" then commandArray[lichtknop] = "Off" end
  elseif otherdevices["bewegingWoonkamer"] == "On" and otherdevices["schemerSensor"] == "On" then
    if otherdevices[lichtknop] == "Off" then commandArray[lichtknop] = "On" end
  end
end

-- 1.002) switch(bewegingOverloop): verlichting op de overloop regelen
function bewegingOverloop(lamp)
  -- tot 23:00 uur het licht wat feller 
  if otherdevices["bewegingOverloop"] == "On" and otherdevices["schemerSensor"] == "On" and
    otherdevices_svalues["lichtOverloop"] ~= 57 and tijdvak("14:00:00","22:59:59") then
      commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "On"}
      commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "Off AFTER 10"}
  -- vanaf 6:30 uur het licht wat feller 
  elseif otherdevices["bewegingOverloop"] == "On" and otherdevices["schemerSensor"] == "On" and 
    otherdevices_svalues["lichtOverloop"] ~= 57 and tijdvak("06:30:00","10:59:59") then
      commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "On"}
      commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "Off AFTER 10"}
  -- als het donker is en er is geen beweging op de overloop dan terug naar een nachtlampje
  elseif otherdevices["bewegingOverloop"] == "Off" and otherdevices["schemerSensor"] == "On" and
    otherdevices_svalues["lichtOverloop"] ~= 1 then
      commandArray[#commandArray + 1] = {["lichtOverloopNachtlampje"] = "On"}
      commandArray[#commandArray + 1] = {["lichtOverloopNachtlampje"] = "Off AFTER 10"}
  -- als het buiten licht is dan kan het licht op de overloop uit
  elseif otherdevices["bewegingOverloop"] == "Off" and otherdevices["schemerSensor"] == "Off" and
    otherdevices["lichtOverloop"] ~= "Off" then
      commandArray[#commandArray + 1] = {["lichtOverloopOntspannen"] = "Off"}
      commandArray[#commandArray + 1] = {["lichtOverloopNachtlampje"] = "Off"}
      commandArray[#commandArray + 1] = {["lichtOverloop"] = "Off"}
  end 
end

-- 1.003) switch(bewegingVliering): licht op de vliering boven de garage schakelen op beweging
function bewegingVliering(lamp)
  if otherdevices["bewegingVliering"] == "On" and otherdevices[lamp] == "Off" then
    commandArray[#commandArray + 1] = {[lamp] = "Set Level 55"}
  elseif otherdevices["bewegingVliering"] == "Off" and otherdevices[lamp] ~= "Off" then
    commandArray[#commandArray + 1] = {[lamp] = "Off"}
  end
end

-- 1.004) switch(pirHal):  licht in de hal schakelen op beweging
function pirHal(lamp)
  if otherdevices["pirHal"] == "On" then
    commandArray[#commandArray + 1] = {[lamp] = "Set Level 55"}
    commandArray[#commandArray + 1] = {[lamp] = "Off AFTER 450"}
  end
end

-- 1.005) switchHal: handmatig licht aan/uit met schakelaar
function switchHal(switch)
  if otherdevices[switch] == "Click" and otherdevices["lichtWoonkamer"] == "Off" then 
    commandArray[#commandArray + 1] = {["lichtWoonkamer"] = "On"}
    commandArray[#commandArray + 1] = {[switch] = "Off AFTER 10"}
  elseif otherdevices[switch] == "Double Click" and otherdevices["lichtWoonkamer"] ~= "Off" then 
    commandArray[#commandArray + 1] = {["lichtWoonkamer"] = "Off"}
    commandArray[#commandArray + 1] = {[switch] = "Off AFTER 10"}
  end
end

-- 1.006) switchSlaapkamerMulti
  function switchSlaapkamerMulti(switch)
    if otherdevices[switch] == "Click" and otherdevices_svalues["lichtSlaapkamer"] ~= "57" then
      commandArray[#commandArray + 1] = {["lichtSlaapkamer"] = "Set Level 57"}
      commandArray[#commandArray + 1] = {[switch] = "Off AFTER 10"}
    elseif otherdevices[switch] == "Double Click" and otherdevices_svalues["lichtSlaapkamer"] ~= "1" then 
      commandArray[#commandArray + 1] = {["lichtSlaapkamer"] = "Set Level 1"}
      commandArray[#commandArray + 1] = {[switch] = "Off AFTER 10"}
    elseif otherdevices[switch] == "Long Click" and otherdevices["lichtSlaapkamer"] ~= "Off" then
      commandArray[#commandArray + 1] = {["lichtSlaapkamer"] = "Off"}
      commandArray[#commandArray + 1] = {[switch] = "Off AFTER 10"}    
    elseif otherdevices[switch] == "Long Click Release" then
      if otherdevices["lichtSlaapkamer"] ~= "Off" then 
        commandArray[#commandArray + 1] = {["lichtSlaapkamer"] = "Off"}
        commandArray[#commandArray + 1] = {[switch] = "Off AFTER 10"}
      end 
    end
  end

-- 1.007) switchSlaapkamerUni --> idx 182
function switchSlaapkamerUni()
  if otherdevices["lichtSlaapkamer"] == "Off" then 
    commandArray[#commandArray + 1] = {["lichtSlaapkamerOntspannen"] = "On"}
    commandArray[#commandArray + 1] = {["lichtSlaapkamerOntspannen"] = "Off AFTER 10"}
  elseif otherdevices["lichtSlaapamer"] ~= "Off" then 
    commandArray["lichtSlaapkamer"] = "Off"
  end
end

-- 1.008) schemerSensor --> idx 360
function schemerSensor()
  if otherdevices["schemerSensor"] == "Off" then
    commandArray[#commandArray + 1] = {["lichtOverloop"] = "Off"}
    commandArray[#commandArray + 1] = {["lichtWoonkamer"] = "Off"}
  end
end

-- 1.009) switchSlaapkamerMuur --> idx 138
function switchSlaapkamerMuur()
  if otherdevices["switchSlaapkamerMuur"] == "Off" then
    if otherdevices ["lichtSlaapkamer"] == "Off" then 
      commandArray[#commandArray + 1] = {["lichtSlaapkamerOntspannen"] = "On"}
      commandArray[#commandArray + 1] = {["lichtSlaapkamerOntspannen"] = "Off AFTER 10"}
      commandArray[#commandArray + 1] = {["switchSlaapkamerMuur"] = "On"}
    elseif otherdevices["lichtSlaapamer"] ~= "Off" then 
      commandArray[#commandArray + 1] = {["lichtSlaapkamer"] = "Off"}
      commandArray[#commandArray + 1] = {["switchSlaapkamerMuur"] = "On"}
    end
  end
end

-- 1.010) google chromecast --> idx 373 & 376
function googleCast(status, volume)
  if otherdevices[status] ~= "Sleeping" and 
        (otherdevices["versterkerPower"] ~= "On" or otherdevices["versterkerInput"] ~= "STRM BOX")  then
    commandArray[#commandArray + 1] = {["versterkerPower"] = "On"}
    commandArray[#commandArray + 2] = {["versterkerInput"] = "Set Level 40 AFTER 5"}
    commandArray[#commandArray + 3] = {[volume] = "On"}
  end
end

-- 1.011) powerplugKerstboom
function kerstboom(trigger)
  if otherdevices[trigger] ~= "Off" and tijdvak("05:30:00","21:29:59") then
    commandArray[#commandArray + 1] = {["powerPlugKerstboom"] = "On"}
  elseif otherdevices[trigger] == "Off" and (tijdvak("21:30:00","23:59:59") or tijdvak("00:00:00","05:29:29")) then
    commandArray[#commandArray + 1] = {["powerPlugKerstboom"] = "Off"}
  end
end 



-- vanaf hier regelen dat alles wordt geschakeld zoals gedefinieerd
commandArray = {}
-- 0) 
-- als er beweging in de zithoek gesignaleerd wordt
if devicechanged["pirZithoek"] then
  local functie = beweging("pirZithoek", "bewegingWoonkamer")
end
-- als er beweging in de eethoek gesignaleerd wordt
if devicechanged["pirEethoek"] then
  local functie = beweging("pirEethoek", "bewegingWoonkamer")
end
-- als er beweging op de overloop gesignaleerd wordt
if devicechanged["pirOverloop1"] then
  local functie = beweging("pirOverloop1", "bewegingOverloop")
end
if devicechanged["pirOverloop2"] then
  local functie = beweging("pirOverloop2", "bewegingOverloop")
end
-- als er beweging op de vliering gesignaleerd wordt
if devicechanged["pirVliering"] then
  local functie = beweging("pirVliering", "bewegingVliering")
end

-- 1) bewegingWoonkamer
-- als de aanwezigheidsdetectie in de woonkamer verandert
if devicechanged["bewegingWoonkamer"] then 
  local functie = bewegingWoonkamer("lichtWoonkamer")
end

-- 2) bewegingOverloop
-- als de aanwezigheidsdetectie op de overloop verandert
if devicechanged["bewegingOverloop"] then
  local functie = bewegingOverloop("lichtOverloop")
end

-- 3) bewegingVliering
-- als er beweging is op de vliering
if devicechanged["bewegingVliering"] then  
  local functie = bewegingVliering("lichtVliering")
end

-- 4) pirHal
-- als er beweging is in de hal
if devicechanged["pirHal"] then  
  local functie = pirHal("lichtHal")
end

-- 5) switchHal
-- multifuncionele (xiaomi) schakelaar gebruiken voor het bedienen van het licht in de woonkamer
if devicechanged["switchHal"] then 
  local functie = switchHal("switchHal")
end  

-- 6) switchSlaapkamerJH / switchSlaapkamerMH
if devicechanged["switchSlaapkamerJH"] then 
  local functie = switchSlaapkamerMulti("switchSlaapkamerJH")
end
if devicechanged["switchSlaapkamerMH"] then 
  local functie = switchSlaapkamerMulti("switchSlaapkamerMH")
end

-- 7) switchSlaapkamerUni
if devicechanged["switchSlaapkamerUni"] then 
  local functie = switchSlaapkamerUni()
end

-- 8) schemerSensor
if devicechanged["schemerSensor"] then
  local functie = schemerSensor()
end

-- 9) switchSlaapkamerMuur
if devicechanged["switchSlaapkamerMuur"] then 
  local functie = switchSlaapkamerMuur()
end

-- licht in het portiek automatisch aan en uit schakelen
if devicechanged["schemerSensor"] then 
  local functie = lichtSchakelaar("schemerSensor", "lichtPortiek")
end

-- versterker aan zetten als chromecast bij versterker gaat spelen
if devicechanged["castHomeCinemaStatus"] then 
  local functie = googleCast("castHomeCinemaStatus", "castHomeCinemaVolume")
end

-- verlichting kerstboom aan- en uitschakelen
if devicechanged["lichtWoonkamer"] then
  local functie = kerstboom("lichtWoonkamer")
end


-- test
if devicechanged["testSwitch"] then
  if otherdevices["versterkerPower"] == "On" 
      and otherdevices["castSpeakersWoonkamerStatus"] ~= "Audio" then 
    commandArray["versterkerPower"] = "Off"
  end
end

return commandArray
