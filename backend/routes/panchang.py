from fastapi import APIRouter
from pydantic import BaseModel
from calculations.panchang import calculate_panchang

router = APIRouter()

class PanchangRequest(BaseModel):
    date: str  # YYYY-MM-DD
    time: str  # HH:MM
    lat: float
    lon: float

@router.post("/panchang")
def get_panchang(req: PanchangRequest):
    try:
        data = calculate_panchang(req.date, req.time, req.lat, req.lon)
        return {"success": True, "data": data}
    except Exception as e:
        import traceback
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}
