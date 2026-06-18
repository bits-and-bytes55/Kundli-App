import urllib.request
import json

url = "https://api.github.com/repos/bits-and-bytes55/Kundli-App/actions/runs"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        for run in data.get('workflow_runs', [])[:5]:
            print(f"Run #{run.get('run_number')}: {run.get('name')} | Commit: {run.get('head_commit', {}).get('message')} | Status: {run.get('status')} | Conclusion: {run.get('conclusion')}")
except Exception as e:
    print("Error:", e)
