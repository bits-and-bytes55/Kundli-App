from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import swisseph as swe

app = FastAPI(title="Kundli API")

app.add_middleware(CORSMiddleware,
    allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

try:
    swe.set_ephe_path('./ephe')
except Exception:
    pass

from routes.chart import router as chart_router
from routes.milan import router as milan_router

app.include_router(chart_router, prefix="/api")
app.include_router(milan_router, prefix="/api")

@app.get("/")
def root():
    return {"status": "Kundli API running ✓"}
