from typing import Optional
from fastapi import APIRouter
from pydantic import BaseModel
from calculations.kundli import calculate_kundli
from calculations.avakahada import get_avakahada_chakra
from calculations.gochar import get_current_transits
from calculations.panchang import calculate_panchang
from calculations.milan import calculate_milan

router = APIRouter()

class KundliRequest(BaseModel):
    name: str
    date: str
    time: str
    lat: float
    lon: float
    # Optional partner details for single-hit Milan matching
    partner_name: Optional[str] = None
    partner_date: Optional[str] = None
    partner_time: Optional[str] = None
    partner_lat: Optional[float] = None
    partner_lon: Optional[float] = None

@router.post("/kundli/generate")
def generate(req: KundliRequest):
    try:
        # Calculate standard Kundli data
        data = calculate_kundli(req.date, req.time, req.lat, req.lon, req.name)
        
        # Inject Avakahada Chakra
        data['avakahada'] = get_avakahada_chakra(data['planets'], data['ascendant'], data['jd'])
        
        # Inject detailed Panchang calculated for the given date, time, and location
        data['panchang'] = calculate_panchang(req.date, req.time, req.lat, req.lon)
        
        # Inject current Transits (Gochar)
        data['gochar'] = get_current_transits()
        
        # Inject Milan matching if partner details are supplied in the request
        if req.partner_date and req.partner_time and req.partner_lat is not None and req.partner_lon is not None:
            milan_data = calculate_milan(
                req.date, req.time, req.lat, req.lon,
                req.partner_date, req.partner_time, req.partner_lat, req.partner_lon
            )
            milan_data['boy_name'] = req.name
            milan_data['girl_name'] = req.partner_name or "Partner"
            data['milan'] = milan_data
            
        return {"success": True, "data": data}
    except Exception as e:
        import traceback
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}

@router.post("/kundli/dasha")
def dasha_only(req: KundliRequest):
    try:
        data = calculate_kundli(req.date, req.time, req.lat, req.lon, req.name)
        return {"success": True, "data": {"dasha": data["dasha"], "name": data["name"]}}
    except Exception as e:
        return {"success": False, "error": str(e)}

@router.get("/kundli/gochar")
def gochar():
    """Returns current planet transits (Gochar) — no birth data needed."""
    try:
        data = get_current_transits()
        return {"success": True, "data": data}
    except Exception as e:
        import traceback
        return {"success": False, "error": str(e), "trace": traceback.format_exc()}

@router.post("/kundli/graha-sthiti")
def graha_sthiti(req: KundliRequest):
    """Detailed Graha Sthiti table with full planet positions."""
    try:
        data = calculate_kundli(req.date, req.time, req.lat, req.lon, req.name)
        planets = data['planets']
        ascendant = data['ascendant']
        # Build structured table
        rows = [{'name': 'Lagna', **ascendant}]
        planet_order = ['Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Rahu','Ketu']
        for p in planet_order:
            if p in planets:
                rows.append({'name': p, **planets[p]})
        return {"success": True, "data": {"rows": rows, "name": data["name"]}}
    except Exception as e:
        return {"success": False, "error": str(e)}
