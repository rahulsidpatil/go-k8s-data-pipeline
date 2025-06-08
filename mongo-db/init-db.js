db = db.getSiblingDB("etl_db");

try {
    db.createUser({
        user: "etluser",
        pwd: "etlp@ss123",
        roles: [{ role: "readWrite", db: "etl_db" }]
    });
    print("✅ Created user etluser");
} catch (e) {
    if (e.codeName === "DuplicateKey") {
        print("ℹ️  User etluser already exists");
    } else {
        print("❌ Error creating user:", e);
    }
}

try {
    db.createCollection("messages");
    print("✅ Created collection messages");
} catch (e) {
    if (e.codeName === "NamespaceExists") {
        print("ℹ️  Collection messages already exists");
    } else {
        print("❌ Error creating collection:", e);
    }
}

try {
    if (!db.messages.findOne({ id: 0 })) {
        db.messages.insertOne({ id: 0, name: "init", timestamp: new Date() });
        print("✅ Inserted initial message");
    } else {
        print("ℹ️  Initial message already present");
    }
} catch (e) {
    print("⚠️  Insert may have failed:", e);
}

quit(0); // ✅ Ensures mongosh exits with status code 0
