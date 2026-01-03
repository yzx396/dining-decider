-- DiningDecider API - Initial Schema
-- Categories and Restaurants tables

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    vibe_mode TEXT NOT NULL CHECK (vibe_mode IN ('aesthetic', 'splurge', 'standard')),
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

-- Restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    lat REAL NOT NULL,
    lng REAL NOT NULL,
    category_id INTEGER NOT NULL,
    price_level INTEGER NOT NULL CHECK (price_level BETWEEN 1 AND 4),
    average_cost INTEGER NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    parking TEXT NOT NULL DEFAULT '',
    map_query TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_restaurants_location ON restaurants(lat, lng);
CREATE INDEX IF NOT EXISTS idx_restaurants_category ON restaurants(category_id);
CREATE INDEX IF NOT EXISTS idx_restaurants_price ON restaurants(price_level);
CREATE INDEX IF NOT EXISTS idx_restaurants_category_price ON restaurants(category_id, price_level);
CREATE INDEX IF NOT EXISTS idx_categories_vibe ON categories(vibe_mode);

-- Seed categories based on iOS VibeMode definitions

-- Aesthetic mode categories (8 sectors)
INSERT OR IGNORE INTO categories (name, vibe_mode, display_order) VALUES
    ('Garden Cafe', 'aesthetic', 1),
    ('Floral Brunch', 'aesthetic', 2),
    ('Rooftop', 'aesthetic', 3),
    ('Tea Room', 'aesthetic', 4),
    ('Minimalist', 'aesthetic', 5),
    ('Patio', 'aesthetic', 6),
    ('Retro Vibe', 'aesthetic', 7),
    ('Cute Bakery', 'aesthetic', 8);

-- Splurge mode categories (6 sectors)
INSERT OR IGNORE INTO categories (name, vibe_mode, display_order) VALUES
    ('Seafood', 'splurge', 1),
    ('Steakhouse', 'splurge', 2),
    ('Omakase', 'splurge', 3),
    ('Fine Dining', 'splurge', 4),
    ('French', 'splurge', 5),
    ('Italian', 'splurge', 6);

-- Standard mode categories (8 sectors)
INSERT OR IGNORE INTO categories (name, vibe_mode, display_order) VALUES
    ('Hot Pot', 'standard', 1),
    ('Tea / Cafe', 'standard', 2),
    ('Noodles', 'standard', 3),
    ('Dessert', 'standard', 4),
    ('Dim Sum', 'standard', 5),
    ('Skewers', 'standard', 6),
    ('Korean BBQ', 'standard', 7),
    ('Bakery', 'standard', 8);
