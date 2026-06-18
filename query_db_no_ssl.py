import asyncio
import sys
import os
from motor.motor_asyncio import AsyncIOMotorClient

# Connection URL
mongo_url = "mongodb+srv://lokeshbaghel4104_db_user:kqAbtfiKG8jTxvQZ@cluster0.skhlmqi.mongodb.net/kundli_app?appName=Cluster0"

async def main():
    try:
        # Connect bypassing SSL validation
        client = AsyncIOMotorClient(mongo_url, tlsAllowInvalidCertificates=True)
        db = client["kundli_app"]
        kundlis_col = db["kundlis"]
        
        cursor = kundlis_col.find({})
        docs = await cursor.to_list(length=100)
        print(f"Found {len(docs)} documents:")
        for doc in docs:
            print(f"Name: {doc.get('name')}, Date: {doc.get('date')}, Time: {doc.get('time')}, Lat: {doc.get('lat')}, Lon: {doc.get('lon')}")
    except Exception as e:
        print("Error:", e)

asyncio.run(main())
