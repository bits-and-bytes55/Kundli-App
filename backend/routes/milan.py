from fastapi import APIRouter
from pydantic import BaseModel
from calculations.milan import calculate_milan

router = APIRouter()

class MilanRequest(BaseModel):
    boy_name: str
    boy_date: str
    boy_time: str
    boy_lat: float
    boy_lon: float
    girl_name: str
    girl_date: str
    girl_time: str
    girl_lat: float
    girl_lon: float

@router.post("/kundli/milan")
def match(req: MilanRequest):
    try:
        data = calculate_milan(
            req.boy_date, req.boy_time, req.boy_lat, req.boy_lon,
            req.girl_date, req.girl_time, req.girl_lat, req.girl_lon
        )
        data['boy_name'] = req.boy_name
        data['girl_name'] = req.girl_name
        return {"success": True, "data": data}
    except Exception as e:
        import traceback
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}
