/**
 * Seed database with restaurant data from iOS app's JSON
 *
 * Usage:
 *   npx tsx scripts/seed-database.ts --local    # Local D1
 *   npx tsx scripts/seed-database.ts            # Remote D1
 */

import { readFileSync, writeFileSync } from "fs";
import { execSync } from "child_process";
import { randomUUID } from "crypto";

interface RawRestaurant {
  name: string;
  lat: number;
  lng: number;
  locs: string[];
  query: string;
  price: number;
  aesthetic: boolean;
  avgCost: number;
  note: string;
  parking: string;
}

type RestaurantData = Record<string, RawRestaurant[]>;

// Category to vibe mode mapping (matches iOS VibeMode.swift)
const CATEGORY_VIBE_MAP: Record<string, string> = {
  // Aesthetic mode (8 categories)
  "Garden Cafe": "aesthetic",
  "Floral Brunch": "aesthetic",
  Rooftop: "aesthetic",
  "Tea Room": "aesthetic",
  Minimalist: "aesthetic",
  Patio: "aesthetic",
  "Retro Vibe": "aesthetic",
  "Cute Bakery": "aesthetic",
  // Splurge mode (6 categories)
  Seafood: "splurge",
  Steakhouse: "splurge",
  Omakase: "splurge",
  "Fine Dining": "splurge",
  French: "splurge",
  Italian: "splurge",
  // Standard mode (8 categories)
  "Hot Pot": "standard",
  "Tea / Cafe": "standard",
  Noodles: "standard",
  Dessert: "standard",
  "Dim Sum": "standard",
  Skewers: "standard",
  "Korean BBQ": "standard",
  Bakery: "standard",
};

function escapeSql(str: string): string {
  return str.replace(/'/g, "''");
}

function generateInsertStatements(data: RestaurantData): string[] {
  const statements: string[] = [];

  // Get category IDs by querying existing categories
  // We'll use a subquery approach for each restaurant

  for (const [categoryName, restaurants] of Object.entries(data)) {
    if (!CATEGORY_VIBE_MAP[categoryName]) {
      console.warn(`Unknown category: ${categoryName}, skipping...`);
      continue;
    }

    for (const r of restaurants) {
      const id = randomUUID();
      const stmt = `
INSERT INTO restaurants (id, name, lat, lng, category_id, price_level, average_cost, description, parking, map_query)
SELECT
    '${id}',
    '${escapeSql(r.name)}',
    ${r.lat},
    ${r.lng},
    c.id,
    ${r.price},
    ${r.avgCost},
    '${escapeSql(r.note)}',
    '${escapeSql(r.parking)}',
    '${escapeSql(r.query)}'
FROM categories c
WHERE c.name = '${escapeSql(categoryName)}';`;

      statements.push(stmt);
    }
  }

  return statements;
}

async function main() {
  const isLocal = process.argv.includes("--local");
  const flag = isLocal ? "--local" : "--remote";

  console.log(`Seeding database (${isLocal ? "local" : "remote"})...`);

  // Read restaurant data from iOS app
  const jsonPath = "../DiningDecider/Data/restaurants.json";
  const rawData: RestaurantData = JSON.parse(readFileSync(jsonPath, "utf-8"));

  // Generate SQL statements
  const statements = generateInsertStatements(rawData);

  console.log(`Generated ${statements.length} insert statements`);

  // Write to temp file and execute
  const tempSql = "/tmp/seed-restaurants.sql";
  const allSql = statements.join("\n");
  writeFileSync(tempSql, allSql);

  try {
    execSync(
      `wrangler d1 execute dining-decider-db ${flag} --file=${tempSql}`,
      {
        stdio: "inherit",
        cwd: process.cwd(),
      },
    );
    console.log("Seeding complete!");
  } catch (error) {
    console.error("Seeding failed:", error);
    process.exit(1);
  }
}

main();
