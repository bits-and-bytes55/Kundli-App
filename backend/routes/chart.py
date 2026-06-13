from fastapi import APIRouter
from pydantic import BaseModel
from calculations.kundli import calculate_kundli

router = APIRouter()

class KundliRequest(BaseModel):
    name: str
    date: str
    time: str
    lat: float
    lon: float

@router.post("/kundli/generate")
def generate(req: KundliRequest):
    try:
        data = calculate_kundli(req.date, req.time, req.lat, req.lon, req.name)
        return {"success": True, "data": data}
    except Exception as e:
        return {"success": False, "error": str(e)}
