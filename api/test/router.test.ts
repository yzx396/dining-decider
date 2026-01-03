/**
 * Router tests - API versioning (TDD - written first)
 */
import { describe, it, expect, beforeAll } from "vitest";
import { env } from "cloudflare:test";
import { handleRequest } from "../src/router";
import { HTTP_OK, HTTP_NOT_FOUND, HTTP_UNAUTHORIZED } from "../src/constants";

const TEST_API_KEY = "test-api-key-12345";

function createRequest(path: string, apiKey?: string): Request {
  const headers: Record<string, string> = {};
  if (apiKey) {
    headers["X-API-Key"] = apiKey;
  }
  return new Request(`http://localhost${path}`, { headers });
}

function createEnv() {
  return { ...env, API_KEY: TEST_API_KEY };
}

describe("API versioning", () => {
  beforeAll(async () => {
    // Seed test data
    await env.DB.batch([
      env.DB.prepare(
        `INSERT OR REPLACE INTO categories (id, name, vibe_mode, display_order) VALUES (1, 'Test Category', 'aesthetic', 1)`
      ),
    ]);
  });

  describe("v1 routes", () => {
    it("GET /v1/categories returns 200 with valid API key", async () => {
      const request = createRequest("/v1/categories", TEST_API_KEY);
      const response = await handleRequest(request, createEnv());

      expect(response.status).toBe(HTTP_OK);
    });

    it("GET /v1/categories returns categories data", async () => {
      const request = createRequest("/v1/categories", TEST_API_KEY);
      const response = await handleRequest(request, createEnv());
      const body = await response.json();

      expect(body).toHaveProperty("success", true);
      expect(body).toHaveProperty("data.categories");
    });

    it("GET /v1/restaurants returns 200 with valid API key", async () => {
      const request = createRequest("/v1/restaurants?lat=37.7749&lng=-122.4194&category=Test%20Category", TEST_API_KEY);
      const response = await handleRequest(request, createEnv());

      expect(response.status).toBe(HTTP_OK);
    });

    it("GET /v1/categories requires authentication", async () => {
      const request = createRequest("/v1/categories");
      const response = await handleRequest(request, createEnv());

      expect(response.status).toBe(HTTP_UNAUTHORIZED);
    });

    it("GET /v1/restaurants requires authentication", async () => {
      const request = createRequest("/v1/restaurants?lat=37.7749&lng=-122.4194&category=Test%20Category");
      const response = await handleRequest(request, createEnv());

      expect(response.status).toBe(HTTP_UNAUTHORIZED);
    });
  });

  describe("unversioned routes return 404", () => {
    it("GET /categories returns 404", async () => {
      const request = createRequest("/categories", TEST_API_KEY);
      const response = await handleRequest(request, createEnv());

      expect(response.status).toBe(HTTP_NOT_FOUND);
    });

    it("GET /restaurants returns 404", async () => {
      const request = createRequest("/restaurants?lat=37.7749&lng=-122.4194", TEST_API_KEY);
      const response = await handleRequest(request, createEnv());

      expect(response.status).toBe(HTTP_NOT_FOUND);
    });
  });

  describe("health endpoint stays unversioned", () => {
    it("GET /health returns 200", async () => {
      const request = createRequest("/health");
      const response = await handleRequest(request, createEnv());

      expect(response.status).toBe(HTTP_OK);
    });

    it("GET /health does not require authentication", async () => {
      const request = createRequest("/health");
      const response = await handleRequest(request, createEnv());
      const body = await response.json();

      expect(body).toHaveProperty("data.status", "healthy");
    });
  });
});
