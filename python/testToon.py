import json, requests

toon_ip = '192.168.1.211' 
domoticz_ip = '192.168.1.105:8080'

# ophalen van de temperatuur uit Toon
toon_url = 'http://%s/happ_thermstat?action=getThermostatInfo' % toon_ip
response = requests.get(toon_url)
thermostatInfo = json.loads(response.text)
#print(thermostatInfo)
temp = (float(thermostatInfo['currentTemp'])/float(100))
setpoint = (float(thermostatInfo['currentSetpoint'])/float(100))
if thermostatInfo['activeState'] == '1':
    state = 10
elif thermostatInfo['activeState'] == '0':
    state = 20
elif thermostatInfo['activeState'] == '2':
    state = 30
elif thermostatInfo['activeState'] == '3':
    state = 40
else:
    state = 50

# updaten van temperatuur
domoticz_url = 'http://%s/json.htm' % domoticz_ip
data = {'type':'command', 'param':'udevice','idx':'107','nvalue':0,'svalue':temp}
resp = requests.get(url=domoticz_url, params=data)
print('update temp: %s' % json.loads(resp.text)['status'])

# updaten van setpoint
data = {'type':'command', 'param':'udevice','idx':'106','nvalue':0,'svalue':setpoint}
resp = requests.get(url=domoticz_url, params=data)
print('update setpoint: %s' % json.loads(resp.text)['status'])

# updaten van selector / programma
data = {'type':'command', 'param':'switchlight', 'idx':'108', 'switchcmd':'Set Level', 'level':state}
resp = requests.get(url=domoticz_url, params=data)
print('update programma: %s' % json.loads(resp.text)['status'])

