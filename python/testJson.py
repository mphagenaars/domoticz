#!/usr/bin/python3

import json, requests, datetime

toon_ip = '192.168.1.212' 

toon_url = 'http://%s/happ_thermstat?action=getThermostatInfo' % toon_ip
response = requests.get(toon_url)
thermostatInfo = json.loads(response.text)

print(thermostatInfo)
