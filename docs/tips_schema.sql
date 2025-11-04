-- SQLite schema for GreenWise tips
CREATE TABLE tips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  text TEXT NOT NULL,
  category TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  why TEXT,
  isActive INTEGER DEFAULT 1
);
