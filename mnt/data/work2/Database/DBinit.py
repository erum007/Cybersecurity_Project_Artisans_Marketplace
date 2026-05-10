import pymongo

def initialize_marketplace_db(client, db):
    # 1. Connect to local MongoDB instance
    
    

    # 3. List of collections to ensure exist
    required_collections = [
        "Artisans", 
        "Categories", 
        "Orders", 
        "Products", 
        "Reviews", 
        "Users"
    ]

    # 4. Get current collections to avoid re-defining
    current_collections = db.list_collection_names()

    for col_name in required_collections:
        if col_name in current_collections:
            print(f"✔️  Collection '{col_name}' already exists. Skipping.")
        else:
            # Create the collection safely
            # We use a placeholder insert/delete to force physical creation
            temp_doc = db[col_name].insert_one({"init": True})
            db[col_name].delete_one({"_id": temp_doc.inserted_id})
            print(f"✅ Created new collection: {col_name}")

    print("\nInitialization check complete.")

def apply_marketplace_schemas(db):
    """Applies strict 'attribute' rules to the SE-Marketplace collections."""
    
    # Define the rules for each collection
    schemas = {
        "Artisans": {
            "required": ["name", "location", "is_verified"],
            "properties": {
                "name": {"bsonType": "string"},
                "bio": {"bsonType": "string"},
                "location": {"bsonType": "string"},
                "is_verified": {"bsonType": "bool"}
            }
        },
        "Products": {
            "required": ["name", "price", "stock", "category_id"],
            "properties": {
                "name": {"bsonType": "string"},
                "price": {"bsonType": "double", "minimum": 0},
                "stock": {"bsonType": "int", "minimum": 0},
                "category_id": {"bsonType": "objectId"},
                "artisan_id": {"bsonType": "objectId"}
            }
        },
        "Users": {
            "required": ["username", "email", "password_hash"],
            "properties": {
                "username": {"bsonType": "string"},
                "email": {"bsonType": "string", "pattern": "^.+@.+$"},
                "password_hash": {"bsonType": "string"}
            }
        },
        "Orders": {
            "required": ["user_id", "total_amount", "status"],
            "properties": {
                "user_id": {"bsonType": "objectId"},
                "total_amount": {"bsonType": "double"},
                "status": {"enum": ["Processing", "Shipped", "Delivered"]}
            }
        }
    }

    for coll_name, schema_details in schemas.items():
        validator = {
            "$jsonSchema": {
                "bsonType": "object",
                "required": schema_details["required"],
                "properties": schema_details["properties"]
            }
        }
        
        try:
            # Apply the validator to the collection
            db.command("collMod", coll_name, validator=validator)
            print(f"🛠️  Validation applied to: {coll_name}")
        except Exception as e:
            print(f"❌ Error applying schema to {coll_name}: {e}")

# Usage inside your main initialization script:
# client = pymongo.MongoClient("mongodb://localhost:27017/")
# db = client["SE-Marketplace"]
# apply_marketplace_schemas(db)

if __name__ == "__main__":
    client = pymongo.MongoClient("mongodb://localhost:27017/")
    db_name = "SE-Marketplace"

        # 2. Check if Database already exists
    existing_dbs = client.list_database_names()
    if db_name in existing_dbs:
        print(f"⚠️  Database '{db_name}' already exists. Skipping creation.")
    else:
        print(f"🆕 Creating Database: {db_name}")

    db = client[db_name]

    initialize_marketplace_db(client, db)

    apply_marketplace_schemas(db)
