// MongoDB Initialization Script
// Creates application user and database

// Use admin database for authentication
db = db.getSiblingDB('admin');

// Authenticate as root
db.auth(
  process.env.MONGO_INITDB_ROOT_USERNAME,
  process.env.MONGO_INITDB_ROOT_PASSWORD
);

// Create application database
db = db.getSiblingDB(process.env.MONGO_DATABASE || 'openclaw');

// Create application user with readWrite permissions
db.createUser({
  user: process.env.MONGO_USER || 'openclaw_user',
  pwd: process.env.MONGO_PASSWORD || 'change_me',
  roles: [
    {
      role: 'readWrite',
      db: process.env.MONGO_DATABASE || 'openclaw'
    }
  ]
});

// Create initial collections
db.createCollection('users');
db.createCollection('sessions');
db.createCollection('workflows');
db.createCollection('events');

// Create indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ createdAt: 1 });
db.sessions.createIndex({ userId: 1 });
db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });
db.workflows.createIndex({ userId: 1 });
db.workflows.createIndex({ createdAt: -1 });
db.events.createIndex({ timestamp: -1 });
db.events.createIndex({ userId: 1, timestamp: -1 });

print('MongoDB initialization completed successfully');
print('Database: ' + process.env.MONGO_DATABASE);
print('User: ' + process.env.MONGO_USER);
