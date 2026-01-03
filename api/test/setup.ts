/**
 * Test setup - runs before all tests
 * Creates database schema for D1 tests
 */
import { env } from "cloudflare:test";
import { beforeAll } from "vitest";

beforeAll(async () => {
  // Create schema using batch for multi-line SQL
  await env.DB.batch([
    env.DB.prepare(
      `CREATE TABLE IF NOT EXISTS categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, vibe_mode TEXT NOT NULL CHECK (vibe_mode IN ('aesthetic', 'splurge', 'standard')), display_order INTEGER NOT NULL DEFAULT 0)`,
    ),
    env.DB.prepare(
      `CREATE TABLE IF NOT EXISTS restaurants (id TEXT PRIMARY KEY, name TEXT NOT NULL, lat REAL NOT NULL, lng REAL NOT NULL, category_id INTEGER NOT NULL, price_level INTEGER NOT NULL CHECK (price_level BETWEEN 1 AND 4), average_cost INTEGER NOT NULL, description TEXT NOT NULL DEFAULT '', parking TEXT NOT NULL DEFAULT '', map_query TEXT NOT NULL, FOREIGN KEY (category_id) REFERENCES categories(id))`,
    ),
    env.DB.prepare(
      `CREATE INDEX IF NOT EXISTS idx_restaurants_category ON restaurants(category_id)`,
    ),
    env.DB.prepare(
      `CREATE INDEX IF NOT EXISTS idx_restaurants_price ON restaurants(price_level)`,
    ),
    env.DB.prepare(
      `CREATE INDEX IF NOT EXISTS idx_categories_vibe ON categories(vibe_mode)`,
    ),
  ]);
});
