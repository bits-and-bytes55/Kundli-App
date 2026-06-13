from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
import os

load_dotenv()

mongo_url = os.getenv("MONGODB_URL")
if mongo_url and "user:pass" not in mongo_url:
    client = AsyncIOMotorClient(mongo_url)
    db = client[os.getenv("DB_NAME", "kundli_app")]
else:
    client = None
    db = None
    
if db is not None:
    users_col = db["users"]
    kundlis_col = db["kundlis"]
    bookmarks_col = db["bookmarks"]
