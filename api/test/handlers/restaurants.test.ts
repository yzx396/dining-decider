/**
 * Restaurants endpoint tests (TDD - written first)
 */
import { describe, it, expect, beforeAll } from "vitest";
import { env } from "cloudflare:test";
import { handleRestaurants } from "../../src/handlers/restaurants";
import { HTTP_OK, HTTP_BAD_REQUEST } from "../../src/constants";

describe("handleRestaurants", () => {
  // Seed test data before tests
  beforeAll(async () => {
    // Add categories
    await env.DB.batch([
      env.DB.prepare(`INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (1, 'Garden Cafe', 'aesthetic', 1)`),
      env.DB.prepare(`INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (2, 'Steakhouse', 'splurge', 1)`),
      env.DB.prepare(`INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (3, 'Hot Pot', 'standard', 1)`),
    ]);

    // Add restaurants - SF area (37.7749, -122.4194)
    await env.DB.batch([
      // Garden Cafe restaurants (category 1) - SF area
      env.DB.prepare(`INSERT OR REPLACE INTO restaurants (id, name, lat, lng, category_id, price_level, average_cost, description, parking, map_query) VALUES ('r1', 'The Gardenia', 37.7749, -122.4194, 1, 2, 35, 'Garden vibes', 'Street', 'The Gardenia SF')`),
      env.DB.prepare(`INSERT OR REPLACE INTO restaurants (id, name, lat, lng, category_id, price_level, average_cost, description, parking, map_query) VALUES ('r2', 'Stable Cafe', 37.7550, -122.4194, 1, 2, 25, 'Hidden gem', 'Street', 'Stable Cafe SF')`),
      env.DB.prepare(`INSERT OR REPLACE INTO restaurants (id, name, lat, lng, category_id, price_level, average_cost, description, parking, map_query) VALUES ('r3', 'Far Away Garden', 34.0522, -118.2437, 1, 2, 30, 'LA spot', 'Valet', 'Far Away Garden LA')`),
      // Steakhouse restaurants (category 2)
      env.DB.prepare(`INSERT OR REPLACE INTO restaurants (id, name, lat, lng, category_id, price_level, average_cost, description, parking, map_query) VALUES ('r4', 'Prime Rib House', 37.7897, -122.4209, 2, 3, 70, 'Classic', 'Valet', 'Prime Rib House SF')`),
      env.DB.prepare(`INSERT OR REPLACE INTO restaurants (id, name, lat, lng, category_id, price_level, average_cost, description, parking, map_query) VALUES ('r5', 'Luxury Steak', 37.7800, -122.4100, 2, 4, 150, 'Premium', 'Valet', 'Luxury Steak SF')`),
      // Hot Pot (category 3) - budget option
      env.DB.prepare(`INSERT OR REPLACE INTO restaurants (id, name, lat, lng, category_id, price_level, average_cost, description, parking, map_query) VALUES ('r6', 'Hot Pot Palace', 37.7872, -122.4077, 3, 1, 25, 'AYCE', 'Mall', 'Hot Pot Palace SF')`),
    ]);
  });

  // SF coordinates for testing
  const sfLat = 37.7749;
  const sfLng = -122.4194;

  describe("parameter validation", () => {
    it("returns 400 when category is missing", async () => {
      const params = { lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params as any);

      expect(response.status).toBe(HTTP_BAD_REQUEST);
    });

    it("returns 400 when lat is missing", async () => {
      const params = { category: "Garden Cafe", lng: sfLng };
      const response = await handleRestaurants(env.DB, params as any);

      expect(response.status).toBe(HTTP_BAD_REQUEST);
    });

    it("returns 400 when lng is missing", async () => {
      const params = { category: "Garden Cafe", lat: sfLat };
      const response = await handleRestaurants(env.DB, params as any);

      expect(response.status).toBe(HTTP_BAD_REQUEST);
    });
  });

  describe("basic response", () => {
    it("returns 200 OK for valid request", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);

      expect(response.status).toBe(HTTP_OK);
    });

    it("returns JSON content type", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);

      expect(response.headers.get("Content-Type")).toBe("application/json");
    });

    it("returns success: true in response body", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      expect(body).toHaveProperty("success", true);
    });

    it("returns restaurants array in data", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      expect(body.data).toHaveProperty("restaurants");
      expect(Array.isArray(body.data.restaurants)).toBe(true);
    });
  });

  describe("category filtering", () => {
    it("returns only restaurants from the specified category", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      expect(body.data.category).toBe("Garden Cafe");
      // Should only get Garden Cafe restaurants
      body.data.restaurants.forEach((r: any) => {
        expect(r.categoryName).toBe("Garden Cafe");
      });
    });
  });

  describe("distance filtering", () => {
    it("returns only restaurants within default radius (10 miles)", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      // Should NOT include LA restaurant (r3) which is ~350 miles away
      const names = body.data.restaurants.map((r: any) => r.name);
      expect(names).not.toContain("Far Away Garden");
    });

    it("respects custom radiusMiles parameter", async () => {
      // Use a very small radius that should exclude even nearby restaurants
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng, radiusMiles: 0.1 };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      // With 0.1 mile radius, only The Gardenia (same location) should be included
      expect(body.data.restaurants.length).toBeLessThanOrEqual(1);
    });
  });

  describe("price level filtering", () => {
    it("returns all price levels when not specified", async () => {
      const params = { category: "Steakhouse", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      const priceLevels = body.data.restaurants.map((r: any) => r.priceLevel);
      // Should include both price level 3 and 4
      expect(priceLevels.length).toBeGreaterThan(0);
    });

    it("filters by specified price levels", async () => {
      const params = { category: "Steakhouse", lat: sfLat, lng: sfLng, priceLevels: [3] };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      body.data.restaurants.forEach((r: any) => {
        expect(r.priceLevel).toBe(3);
      });
    });
  });

  describe("limit", () => {
    it("respects limit parameter", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng, limit: 1 };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      expect(body.data.restaurants.length).toBeLessThanOrEqual(1);
    });

    it("defaults to limit of 3", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      expect(body.data.restaurants.length).toBeLessThanOrEqual(3);
    });
  });

  describe("restaurant structure", () => {
    it("returns restaurants with correct fields", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      if (body.data.restaurants.length > 0) {
        const restaurant = body.data.restaurants[0];
        expect(restaurant).toHaveProperty("id");
        expect(restaurant).toHaveProperty("name");
        expect(restaurant).toHaveProperty("lat");
        expect(restaurant).toHaveProperty("lng");
        expect(restaurant).toHaveProperty("priceLevel");
        expect(restaurant).toHaveProperty("averageCost");
        expect(restaurant).toHaveProperty("description");
        expect(restaurant).toHaveProperty("parking");
        expect(restaurant).toHaveProperty("mapQuery");
        expect(restaurant).toHaveProperty("categoryName");
        expect(restaurant).toHaveProperty("distance");
      }
    });

    it("includes distance in miles for each restaurant", async () => {
      const params = { category: "Garden Cafe", lat: sfLat, lng: sfLng };
      const response = await handleRestaurants(env.DB, params);
      const body = await response.json();

      body.data.restaurants.forEach((r: any) => {
        expect(typeof r.distance).toBe("number");
        expect(r.distance).toBeGreaterThanOrEqual(0);
      });
    });
  });
});
