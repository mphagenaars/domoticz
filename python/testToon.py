#!/usr/bin/python3

# Rooted Toon uitlezen
# november 2018
import json, requests, datetime

# instellingen
toon_ip = '192.168.1.211' 
domoticz_ip = '192.168.1.105:8080'
# devices (idx)
toonTemp = 107
toonSetpoint = 106
toonSelector = 108
toonPower = 105
toonGas = 104

# debug?
debug = 0

# get thermostat info
toon_url = 'http://%s/happ_thermstat?action=getThermostatInfo' % toon_ip
response = requests.get(toon_url)
thermostatInfo = json.loads(response.text)

# only proceed if Toon is online and ok
if thermostatInfo['result'] == "ok":
    # extract temerature, setpoint & program
    temp = (float(thermostatInfo['currentTemp'])/float(100))
    setpoint = (float(thermostatInfo['currentSetpoint'])/float(100)) 
    # transform to match my selector switch
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

    # additionally get p1 (power & gas) info
    toon_url = 'http://%s/hdrv_zwave?action=getDevices' % toon_ip
    response = requests.get(toon_url)
    p1Info = json.loads(response.text)
    powerUsage1 = round(p1Info['dev_2.5']['profileInfo']['CurrentElectricityQuantity'])
    powerUsage2 = round(p1Info['dev_2.3']['profileInfo']['CurrentElectricityQuantity'])
    if p1Info['dev_2.5']['profileInfo']['CurrentElectricityFlow'] == 0:
        cons = round(p1Info['dev_2.3']['profileInfo']['CurrentElectricityFlow'])
    else: 
        cons = round(p1Info['dev_2.5']['profileInfo']['CurrentElectricityFlow'])
    gasUsage = round(p1Info['dev_2.1']['profileInfo']['CurrentGasQuantity'])

    # updating Domoticz 
    # temp
    domoticz_url = 'http://%s/json.htm' % domoticz_ip
    data = {'type':'command', 'param':'udevice','idx':'%s' % toonTemp,'nvalue':0,'svalue':temp} 
    resp = requests.get(url=domoticz_url, params=data)
    if debug == 1: print('update temp: %s' % json.loads(resp.text)['status'])
    # setpoint
    data = {'type':'command', 'param':'udevice','idx':'%s' % toonSetpoint,'nvalue':0,'svalue':setpoint}
    resp = requests.get(url=domoticz_url, params=data)
    if debug == 1: print('update setpoint: %s' % json.loads(resp.text)['status'])
    # selector / programma
    data = {'type':'command', 'param':'switchlight', 'idx':'%s' % toonSelector, 'switchcmd':'Set Level', 'level':state}
    resp = requests.get(url=domoticz_url, params=data)
    if debug == 1: print('update programma: %s' % json.loads(resp.text)['status'])
    # p1: power
    sval = '{};{};0;0;{};0'.format(powerUsage1,powerUsage2,cons)
    data = {'type':'command','param':'udevice','idx':'%s' % toonPower,'nvalue':'0','svalue':'%s' % sval}
    resp = requests.get(url=domoticz_url, params=data)
    if debug == 1: print('update power: %s' % json.loads(resp.text)['status'])
    #p1: gas
    data = {'type':'command','param':'udevice','idx':'{}'.format(toonGas),'nvalue':'0','svalue':'{}'.format(gasUsage)}
    resp = requests.get(url=domoticz_url, params=data)
    if debug == 1: print('update gas: %s' % json.loads(resp.text)['status'])


