import json
import datetime
from datetime import timedelta
import numpy as np

fileName ="assets\data.json"
values = []

nbrOfValue = int(input('How many values do you want generate ?'))
interval = int(input('What is the interval between values ?'))

temperature = np.random.normal(loc=25, scale=2.5, size=nbrOfValue)
humidity = np.random.normal(loc=40, scale=5, size=nbrOfValue)

for i in range(0,nbrOfValue):
    value = {
    "date" : str(datetime.datetime.now() - timedelta(minutes = interval * (nbrOfValue-i))),
    "temperature": round(np.take(temperature,i),2),
    "humidity": round(np.take(humidity,i),2),
    }
    values.append(value)


y = json.dumps(values)

f = open(fileName, "w")
f.write(y)
f.close()

#open and read the file after the appending:
f = open(fileName, "r")
print(f.read())