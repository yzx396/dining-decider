/**
 * Health endpoint tests (TDD - written first)
 */
import { describe, it, expect } from "vitest";
import { handleHealth } from "../../src/handlers/health";
import { HTTP_OK } from "../../src/constants";

describe("handleHealth", () => {
  it("returns 200 OK status", async () => {
    const response = await handleHealth();

    expect(response.status).toBe(HTTP_OK);
  });

  it("returns JSON content type", async () => {
    const response = await handleHealth();

    expect(response.headers.get("Content-Type")).toBe("application/json");
  });

  it("returns success: true in response body", async () => {
    const response = await handleHealth();
    const body = await response.json();

    expect(body).toHaveProperty("success", true);
  });

  it("returns health data with status", async () => {
    const response = await handleHealth();
    const body = await response.json();

    expect(body).toHaveProperty("data");
    expect(body.data).toHaveProperty("status", "healthy");
  });

  it("returns health data with version", async () => {
    const response = await handleHealth();
    const body = await response.json();

    expect(body.data).toHaveProperty("version");
    expect(typeof body.data.version).toBe("string");
  });

  it("returns health data with timestamp", async () => {
    const response = await handleHealth();
    const body = await response.json();

    expect(body.data).toHaveProperty("timestamp");
    // Verify it's a valid ISO date string
    const timestamp = new Date(body.data.timestamp);
    expect(timestamp.getTime()).not.toBeNaN();
  });
});
