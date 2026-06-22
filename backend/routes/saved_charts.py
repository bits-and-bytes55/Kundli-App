import os
from typing import Optional, List
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from bson import ObjectId

router = APIRouter()

# Try to import DB collections
try:
    from database import bookmarks_col
except ImportError:
    bookmarks_col = None

# In-memory store fallback (useful if Mongo is not running or client is None)
_in_memory_charts = []
_mem_id_counter = 1

class SavedChartModel(BaseModel):
    phone: str
    name: str
    date: str
    time: str
    lat: float
    lon: float
    gender: Optional[str] = 'Male'
    place: Optional[str] = ''

class SavedChartUpdateModel(BaseModel):
    name: Optional[str] = None
    date: Optional[str] = None
    time: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    gender: Optional[str] = None
    place: Optional[str] = None

@router.post("/charts")
async def save_chart(req: SavedChartModel):
    global _mem_id_counter
    try:
        doc = req.dict()
        if bookmarks_col is not None:
            result = await bookmarks_col.insert_one(doc)
            doc['id'] = str(result.inserted_id)
            if '_id' in doc:
                del doc['_id']
        else:
            doc['id'] = str(_mem_id_counter)
            _mem_id_counter += 1
            _in_memory_charts.append(doc)
        return {"success": True, "data": doc}
    except Exception as e:
        return {"success": False, "error": str(e)}

@router.get("/charts")
async def get_charts(phone: str = Query(...)):
    try:
        if bookmarks_col is not None:
            cursor = bookmarks_col.find({"phone": phone})
            charts = []
            async for doc in cursor:
                doc['id'] = str(doc['_id'])
                if '_id' in doc:
                    del doc['_id']
                charts.append(doc)
            return {"success": True, "data": charts}
        else:
            charts = [c for c in _in_memory_charts if c.get("phone") == phone]
            return {"success": True, "data": charts}
    except Exception as e:
        return {"success": False, "error": str(e)}

@router.put("/charts/{chart_id}")
async def edit_chart(chart_id: str, req: SavedChartUpdateModel):
    try:
        update_data = {k: v for k, v in req.dict().items() if v is not None}
        if bookmarks_col is not None:
            try:
                oid = ObjectId(chart_id)
            except Exception:
                result = await bookmarks_col.update_one(
                    {"id": chart_id},
                    {"$set": update_data}
                )
                if result.matched_count == 0:
                    raise HTTPException(status_code=404, detail="Chart not found")
                return {"success": True, "message": "Chart updated successfully"}
                
            result = await bookmarks_col.update_one(
                {"_id": oid},
                {"$set": update_data}
            )
            if result.matched_count == 0:
                result2 = await bookmarks_col.update_one(
                    {"id": chart_id},
                    {"$set": update_data}
                )
                if result2.matched_count == 0:
                    raise HTTPException(status_code=404, detail="Chart not found")
            return {"success": True, "message": "Chart updated successfully"}
        else:
            found = False
            for c in _in_memory_charts:
                if c.get("id") == chart_id:
                    c.update(update_data)
                    found = True
                    break
            if not found:
                raise HTTPException(status_code=404, detail="Chart not found")
            return {"success": True, "message": "Chart updated successfully"}
    except Exception as e:
        return {"success": False, "error": str(e)}

@router.delete("/charts/{chart_id}")
async def delete_chart(chart_id: str):
    try:
        if bookmarks_col is not None:
            try:
                oid = ObjectId(chart_id)
            except Exception:
                result = await bookmarks_col.delete_one({"id": chart_id})
                if result.deleted_count == 0:
                    raise HTTPException(status_code=404, detail="Chart not found")
                return {"success": True, "message": "Chart deleted successfully"}
                
            result = await bookmarks_col.delete_one({"_id": oid})
            if result.deleted_count == 0:
                result2 = await bookmarks_col.delete_one({"id": chart_id})
                if result2.deleted_count == 0:
                    raise HTTPException(status_code=404, detail="Chart not found")
            return {"success": True, "message": "Chart deleted successfully"}
        else:
            initial_len = len(_in_memory_charts)
            _in_memory_charts[:] = [c for c in _in_memory_charts if c.get("id") != chart_id]
            if len(_in_memory_charts) == initial_len:
                raise HTTPException(status_code=404, detail="Chart not found")
            return {"success": True, "message": "Chart deleted successfully"}
    except Exception as e:
        return {"success": False, "error": str(e)}
