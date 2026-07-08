"""
Test PostgreSQL Neon database connection
"""
import sys
from sqlalchemy import text
from db.database import engine, create_tables
from core.config import settings

def test_connection():
    print(f"Testing connection to: {settings.DATABASE_URL[:50]}...")
    
    try:
        # Test basic connection
        with engine.connect() as conn:
            result = conn.execute(text("SELECT version()"))
            version = result.scalar()
            print(f"✓ Connection successful!")
            print(f"✓ PostgreSQL version: {version[:80]}...")
            
        # Test table creation
        print("\n✓ Creating tables...")
        create_tables()
        print("✓ Tables created/verified successfully!")
        
        # List tables
        with engine.connect() as conn:
            result = conn.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """))
            tables = [row[0] for row in result]
            print(f"\n✓ Found {len(tables)} tables:")
            for table in tables:
                print(f"  - {table}")
        
        print("\n✅ Migration to PostgreSQL Neon completed successfully!")
        return True
        
    except Exception as e:
        print(f"\n❌ Connection failed: {e}")
        return False

if __name__ == "__main__":
    success = test_connection()
    sys.exit(0 if success else 1)
