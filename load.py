import os
import json
from pymongo import MongoClient
from bson import ObjectId

MONGO_URI = "mongodb://localhost:27017/"
DB_NAME = "SE-Marketplace"
DATA_FOLDER = "Database/sample_data"  # folder where JSON files live


client = MongoClient(MONGO_URI)
db = client[DB_NAME]


def convert_objectid(doc):
    """
    Recursively convert all {"$oid": "..."} to bson.ObjectId
    """
    if isinstance(doc, dict):
        new_doc = {}
        for k, v in doc.items():
            if isinstance(v, dict) and "$oid" in v:
                new_doc[k] = ObjectId(v["$oid"])
            elif isinstance(v, dict):
                new_doc[k] = convert_objectid(v)
            elif isinstance(v, list):
                new_doc[k] = [convert_objectid(i) for i in v]
            else:
                new_doc[k] = v
        return new_doc
    elif isinstance(doc, list):
        return [convert_objectid(d) for d in doc]
    else:
        return doc

def preprocess_doc(doc, collection_name):
    """
    Convert ObjectIds and numeric fields as needed for schema
    """
    doc = convert_objectid(doc)
    
    # Convert numeric fields to float where schema expects double
    if collection_name == "Products":
        if "price" in doc:
            doc["price"] = float(doc["price"])
    if collection_name == "Orders":
        if "total_amount" in doc:
            doc["total_amount"] = float(doc["total_amount"])
    return doc

collections_order = ["Users", "Categories", "Artisans", "Products", "Orders", "Reviews"]

for collection_name in collections_order:
    file_path = os.path.join(DATA_FOLDER, collection_name + ".json")
    if not os.path.exists(file_path):
        print(f"{file_path} not found, skipping")
        continue

    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not isinstance(data, list):
        print(f"Skipping {file_path}, JSON root must be a list")
        continue

    data = [preprocess_doc(doc, collection_name) for doc in data]

    db[collection_name].delete_many({})

    db[collection_name].insert_many(data)
    print(f"Loaded {len(data)} documents into '{collection_name}' collection")

print("\nAll data loaded successfully!")