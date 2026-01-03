/**
 * Auth middleware tests (TDD - written first)
 */
import { describe, it, expect } from "vitest";
import {
  validateApiKey,
  createAuthMiddleware,
} from "../../src/middleware/auth";
import { HTTP_UNAUTHORIZED } from "../../src/constants";
import type { ApiError } from "../../src/types";

describe("validateApiKey", () => {
  const validApiKey = "test-api-key-12345";

  it("returns true for valid API key", () => {
    const result = validateApiKey("test-api-key-12345", validApiKey);
    expect(result).toBe(true);
  });

  it("returns false for invalid API key", () => {
    const result = validateApiKey("wrong-key", validApiKey);
    expect(result).toBe(false);
  });

  it("returns false for empty API key", () => {
    const result = validateApiKey("", validApiKey);
    expect(result).toBe(false);
  });

  it("returns false for undefined API key", () => {
    const result = validateApiKey(undefined, validApiKey);
    expect(result).toBe(false);
  });

  it("returns false for null API key", () => {
    const result = validateApiKey(null as unknown as string, validApiKey);
    expect(result).toBe(false);
  });

  it("is case-sensitive", () => {
    const result = validateApiKey("TEST-API-KEY-12345", validApiKey);
    expect(result).toBe(false);
  });
});

describe("createAuthMiddleware", () => {
  const validApiKey = "test-api-key-12345";

  function createMockRequest(apiKey?: string): Request {
    const headers = new Headers();
    if (apiKey !== undefined) {
      headers.set("X-API-Key", apiKey);
    }
    return new Request("https://api.example.com/test", { headers });
  }

  it("returns null for valid API key (request passes through)", () => {
    const middleware = createAuthMiddleware(validApiKey);
    const request = createMockRequest(validApiKey);

    const result = middleware(request);
    expect(result).toBeNull();
  });

  it("returns 401 response for missing API key header", () => {
    const middleware = createAuthMiddleware(validApiKey);
    const request = createMockRequest();

    const result = middleware(request);
    expect(result).toBeInstanceOf(Response);
    expect(result?.status).toBe(HTTP_UNAUTHORIZED);
  });

  it("returns 401 response for invalid API key", () => {
    const middleware = createAuthMiddleware(validApiKey);
    const request = createMockRequest("wrong-key");

    const result = middleware(request);
    expect(result).toBeInstanceOf(Response);
    expect(result?.status).toBe(HTTP_UNAUTHORIZED);
  });

  it("returns 401 response for empty API key", () => {
    const middleware = createAuthMiddleware(validApiKey);
    const request = createMockRequest("");

    const result = middleware(request);
    expect(result).toBeInstanceOf(Response);
    expect(result?.status).toBe(HTTP_UNAUTHORIZED);
  });

  it("includes error message in 401 response body", async () => {
    const middleware = createAuthMiddleware(validApiKey);
    const request = createMockRequest("wrong-key");

    const result = middleware(request);
    expect(result).not.toBeNull();

    const body = (await result!.json()) as ApiError;
    expect(body).toHaveProperty("success", false);
    expect(body).toHaveProperty("error");
    expect(body.error).toHaveProperty("code", "UNAUTHORIZED");
    expect(body.error).toHaveProperty("message");
  });

  it("returns JSON content type for error response", () => {
    const middleware = createAuthMiddleware(validApiKey);
    const request = createMockRequest("wrong-key");

    const result = middleware(request);
    expect(result?.headers.get("Content-Type")).toBe("application/json");
  });
});
