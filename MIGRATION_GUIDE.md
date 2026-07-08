# PostgreSQL Neon Migration Guide

## Migration Completed ✅

Your app has been successfully migrated from SQLite to PostgreSQL Neon!

## What Changed

### 1. Configuration Updates
- **`backend/core/config.py`**: Updated to respect full PostgreSQL connection strings in `DATABASE_URL`
- **`backend/.env`**: Now uses PostgreSQL Neon connection string
- **`backend/.env.example`**: Updated to document both SQLite and PostgreSQL options

### 2. Database Setup
- **`backend/db/database.py`**: Added model imports to ensure all tables are created
- **`backend/models/__init__.py`**: Added exports for all models (Story, StoryNode, StoryJob)

### 3. Tables Created in PostgreSQL Neon
- ✓ `stories` - Main story records
- ✓ `story_nodes` - Individual story nodes with content and options
- ✓ `story_jobs` - Background job tracking for story generation

## Testing Performed

✓ Database connection verified  
✓ All 3 tables created successfully  
✓ Backend server starts without errors  
✓ FastAPI running on http://127.0.0.1:8000  

## Data Migration (If Needed)

If you have existing data in `backend/database.db` that you want to migrate:

### Option 1: Manual Export/Import (Recommended for small datasets)

```powershell
# 1. Install SQLite browser or use Python
pip install pandas sqlalchemy

# 2. Create migration script (see below)
python migrate_data.py
```

### Option 2: Use SQLAlchemy Migration Script

Create `backend/migrate_data.py`:

```python
from sqlalchemy import create_engine, MetaData
from sqlalchemy.orm import sessionmaker

# Source (SQLite)
source_engine = create_engine('sqlite:///./database.db')
SourceSession = sessionmaker(bind=source_engine)

# Destination (PostgreSQL - from .env)
from core.config import settings
from db.database import SessionLocal
from models import Story, StoryNode, StoryJob

def migrate_data():
    source_session = SourceSession()
    dest_session = SessionLocal()
    
    try:
        # Migrate jobs
        jobs = source_session.query(StoryJob).all()
        for job in jobs:
            dest_session.merge(job)
        
        # Migrate stories
        stories = source_session.query(Story).all()
        for story in stories:
            dest_session.merge(story)
        
        # Migrate story nodes
        nodes = source_session.query(StoryNode).all()
        for node in nodes:
            dest_session.merge(node)
        
        dest_session.commit()
        print(f"✓ Migrated {len(jobs)} jobs, {len(stories)} stories, {len(nodes)} nodes")
    
    except Exception as e:
        dest_session.rollback()
        print(f"❌ Migration failed: {e}")
    finally:
        source_session.close()
        dest_session.close()

if __name__ == "__main__":
    migrate_data()
```

Then run:
```powershell
cd backend
python migrate_data.py
```

## Configuration Options

### Development (SQLite)
```env
DATABASE_URL=sqlite:///./database.db
DEBUG=True
```

### Production (PostgreSQL Neon)
```env
DATABASE_URL=postgresql://user:password@host:port/database?sslmode=require
DEBUG=True  # or False for production
```

## Verification Steps

1. **Test the connection**:
   ```powershell
   cd backend
   python test_db_connection.py
   ```

2. **Start the server**:
   ```powershell
   cd backend
   python -m uvicorn main:app --reload --port 8000
   ```

3. **Check API docs**: Visit http://127.0.0.1:8000/docs

## Benefits of PostgreSQL Neon

✓ **Production-ready**: Better performance and reliability  
✓ **Scalability**: Handles multiple concurrent users  
✓ **Automatic backups**: Built-in backup and recovery  
✓ **Serverless**: Pay only for what you use  
✓ **SSL/TLS**: Secure connections by default  

## Rollback (If Needed)

To switch back to SQLite:

1. Update `backend/.env`:
   ```env
   DATABASE_URL=sqlite:///./database.db
   ```

2. Restart the backend server

## Support

- PostgreSQL Neon Docs: https://neon.tech/docs
- SQLAlchemy Docs: https://docs.sqlalchemy.org/
- FastAPI Docs: https://fastapi.tiangolo.com/
