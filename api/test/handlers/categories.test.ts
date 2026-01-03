/**
 * Categories endpoint tests (TDD - written first)
 */
import { describe, it, expect, beforeAll } from "vitest";
import { env } from "cloudflare:test";
import { handleCategories } from "../../src/handlers/categories";
import { HTTP_OK } from "../../src/constants";

describe("handleCategories", () => {
  // Seed test data before tests
  beforeAll(async () => {
    await env.DB.batch([
      env.DB.prepare(
        `INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (1, 'Garden Cafe', 'aesthetic', 1)`,
      ),
      env.DB.prepare(
        `INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (2, 'Rooftop', 'aesthetic', 2)`,
      ),
      env.DB.prepare(
        `INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (3, 'Steakhouse', 'splurge', 1)`,
      ),
      env.DB.prepare(
        `INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (4, 'Omakase', 'splurge', 2)`,
      ),
      env.DB.prepare(
        `INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (5, 'Hot Pot', 'standard', 1)`,
      ),
      env.DB.prepare(
        `INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (6, 'Dim Sum', 'standard', 2)`,
      ),
    ]);
  });

  it("returns 200 OK status", async () => {
    const response = await handleCategories(env.DB);

    expect(response.status).toBe(HTTP_OK);
  });

  it("returns JSON content type", async () => {
    const response = await handleCategories(env.DB);

    expect(response.headers.get("Content-Type")).toBe("application/json");
  });

  it("returns success: true in response body", async () => {
    const response = await handleCategories(env.DB);
    const body = await response.json();

    expect(body).toHaveProperty("success", true);
  });

  it("returns array of categories", async () => {
    const response = await handleCategories(env.DB);
    const body = await response.json();

    expect(body).toHaveProperty("data");
    expect(body.data).toHaveProperty("categories");
    expect(Array.isArray(body.data.categories)).toBe(true);
  });

  it("returns categories with correct structure", async () => {
    const response = await handleCategories(env.DB);
    const body = await response.json();

    const category = body.data.categories[0];
    expect(category).toHaveProperty("id");
    expect(category).toHaveProperty("name");
    expect(category).toHaveProperty("vibeMode");
    expect(category).toHaveProperty("displayOrder");
  });

  it("filters categories by vibeMode when provided", async () => {
    const response = await handleCategories(env.DB, "aesthetic");
    const body = await response.json();

    expect(body.data.categories.length).toBe(2);
    body.data.categories.forEach((cat: { vibeMode: string }) => {
      expect(cat.vibeMode).toBe("aesthetic");
    });
  });

  it("returns all categories when vibeMode not provided", async () => {
    const response = await handleCategories(env.DB);
    const body = await response.json();

    expect(body.data.categories.length).toBeGreaterThanOrEqual(6);
  });

  it("orders categories by display_order", async () => {
    const response = await handleCategories(env.DB, "aesthetic");
    const body = await response.json();

    const orders = body.data.categories.map(
      (c: { displayOrder: number }) => c.displayOrder,
    );
    const sorted = [...orders].sort((a, b) => a - b);
    expect(orders).toEqual(sorted);
  });
});
