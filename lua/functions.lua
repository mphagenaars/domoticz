-- GENERIEKE FUNCTIES OM TE GEBRUIKEN IN SCRIPT_DEVICE_CONTAINER & SCRIPT_TIME_CONTAINER

-- beweging, dummy motionsensor(s) aan zetten
function beweging(pir,sensor)
  if otherdevices[pir] == "On" then commandArray[sensor] = "On" end
end

-- generieke lichtschakelaar
function lichtSchakelaar(trigger,lamp)
  if otherdevices[trigger] == "On" then
    if otherdevices[lamp] == "Off" then commandArray[lamp] = "On" end
  elseif otherdevices[trigger] == "Off" then
    if otherdevices[lamp] ~= "Off" then commandArray[lamp] = "Off" end
  end
end

-- start- & eindtijd definieren
function tijdvak(s,e)
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