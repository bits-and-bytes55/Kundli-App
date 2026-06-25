from motor.motor_asyncio import AsyncIOMotorClient
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

async def test_mongo():
    mongo_url = os.getenv("MONGODB_URL")
    print(f"MongoDB URL: {mongo_url}")
    if not mongo_url or "user:pass" in mongo_url:
        print("Invalid URL")
        return
        
    client = AsyncIOMotorClient(mongo_url, serverSelectionTimeoutMS=5000)
    db = client[os.getenv("DB_NAME", "kundli_app")]
    
    print("Pinging db...")
    try:
        await client.admin.command('ping')
        print("Ping successful!")
        
        col = db["bookmarks"]
        print("Counting bookmarks...")
        count = await col.count_documents({})
        print(f"Total bookmarks: {count}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_mongo())
