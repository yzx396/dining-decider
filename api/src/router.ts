/**
 * Request router for DiningDecider API
 */

import { HTTP_NOT_FOUND, HTTP_BAD_REQUEST } from "./constants";
import { createAuthMiddleware } from "./middleware/auth";
import { handleHealth } from "./handlers/health";
import { handleCategories } from "./handlers/categories";
import { handleRestaurants } from "./handlers/restaurants";
import type { Env, VibeMode, RestaurantsQueryParams } from "./types";

/**
 * Parses URL search params into RestaurantsQueryParams
 */
function parseRestaurantsParams(
  searchParams: URLSearchParams
): Partial<RestaurantsQueryParams> {
  const category = searchParams.get("category") ?? undefined;
  const lat = searchParams.get("lat");
  const lng = searchParams.get("lng");
  const radiusMiles = searchParams.get("radiusMiles");
  const priceLevels = searchParams.get("priceLevels");
  const limit = searchParams.get("limit");
  const shuffle = searchParams.get("shuffle");

  return {
    category,
    lat: lat ? parseFloat(lat) : undefined,
    lng: lng ? parseFloat(lng) : undefined,
    radiusMiles: radiusMiles ? parseFloat(radiusMiles) : undefined,
    priceLevels: priceLevels
      ? priceLevels.split(",").map((p) => parseInt(p, 10))
      : undefined,
    limit: limit ? parseInt(limit, 10) : undefined,
    shuffle: shuffle ? shuffle === "true" : undefined,
  };
}

/**
 * Creates a JSON error response
 */
function errorResponse(status: number, code: string, message: string): Response {
  return new Response(
    JSON.stringify({
      success: false,
      error: { code, message },
    }),
    {
      status,
      headers: { "Content-Type": "application/json" },
    }
  );
}

/**
 * Routes requests to appropriate handlers
 */
export async function handleRequest(
  request: Request,
  env: Env
): Promise<Response> {
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;

  // Health endpoint - no auth required
  if (path === "/health" && method === "GET") {
    return handleHealth();
  }

  // All other endpoints require authentication
  const authMiddleware = createAuthMiddleware(env.API_KEY);
  const authResponse = authMiddleware(request);
  if (authResponse) {
    return authResponse;
  }

  // v1 Categories endpoint
  if (path === "/v1/categories" && method === "GET") {
    const vibeMode = url.searchParams.get("vibeMode") as VibeMode | null;
    return handleCategories(env.DB, vibeMode ?? undefined);
  }

  // v1 Restaurants endpoint
  if (path === "/v1/restaurants" && method === "GET") {
    const params = parseRestaurantsParams(url.searchParams);
    return handleRestaurants(env.DB, params as RestaurantsQueryParams);
  }

  // 404 for unknown routes
  return errorResponse(HTTP_NOT_FOUND, "NOT_FOUND", `Route ${method} ${path} not found`);
}
