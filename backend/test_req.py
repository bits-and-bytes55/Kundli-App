import json
import urllib.request

req = urllib.request.Request(
    'http://localhost:8000/api/kundli/generate',
    data=json.dumps({
        "name": "Anjali",
        "date": "1999-08-22",
        "time": "14:30",
        "lat": 28.6139,
        "lon": 77.2090,
        "gender": "Female"
    }).encode('utf-8'),
    headers={'Content-Type': 'application/json'}
)

try:
    res = urllib.request.urlopen(req)
    data = json.loads(res.read())
    print(json.dumps(data['data']['planet_significators'], indent=2))
except Exception as e:
    print(f"Error: {e}")
