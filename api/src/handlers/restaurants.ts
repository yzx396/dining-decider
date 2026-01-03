/**
 * Restaurants endpoint handler
 */

import {
  HTTP_OK,
  HTTP_BAD_REQUEST,
  DEFAULT_RADIUS_MILES,
  DEFAULT_LIMIT,
  ALL_PRICE_LEVELS,
} from "../constants";
import { distanceInMiles, isWithinRadius } from "../utils/distance";
import type {
  ApiResponse,
  ApiError,
  RestaurantsData,
  Restaurant,
  RestaurantRow,
  RestaurantsQueryParams,
} from "../types";

/**
 * Validates request parameters
 */
function validateParams(
  params: Partial<RestaurantsQueryParams>
): { valid: true } | { valid: false; message: string } {
  if (!params.category) {
    return { valid: false, message: "category is required" };
  }
  if (params.lat === undefined || params.lat === null) {
    return { valid: false, message: "lat is required" };
  }
  if (params.lng === undefined || params.lng === null) {
    return { valid: false, message: "lng is required" };
  }
  return { valid: true };
}

/**
 * Maps database row to Restaurant domain model
 */
function mapRowToRestaurant(row: RestaurantRow, distance: number): Restaurant {
  return {
    id: row.id,
    name: row.name,
    lat: row.lat,
    lng: row.lng,
    priceLevel: row.price_level as 1 | 2 | 3 | 4,
    averageCost: row.average_cost,
    description: row.description,
    parking: row.parking,
    mapQuery: row.map_query,
    categoryId: row.category_id,
    categoryName: row.category_name,
    distance,
  };
}

/**
 * Shuffles array in place using Fisher-Yates algorithm
 */
function shuffleArray<T>(array: T[]): T[] {
  const shuffled = [...array];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

/**
 * Handles GET /restaurants requests
 */
export async function handleRestaurants(
  db: D1Database,
  params: RestaurantsQueryParams
): Promise<Response> {
  // Validate parameters
  const validation = validateParams(params);
  if (!validation.valid) {
    const error: ApiError = {
      success: false,
      error: {
        code: "INVALID_PARAMS",
        message: validation.message,
      },
    };
    return new Response(JSON.stringify(error), {
      status: HTTP_BAD_REQUEST,
      headers: { "Content-Type": "application/json" },
    });
  }

  const radiusMiles = params.radiusMiles ?? DEFAULT_RADIUS_MILES;
  const limit = params.limit ?? DEFAULT_LIMIT;
  const priceLevels = params.priceLevels ?? [...ALL_PRICE_LEVELS];
  const shouldShuffle = params.shuffle !== false;

  // Build SQL query
  const placeholders = priceLevels.map(() => "?").join(",");
  const sql = `
    SELECT
      r.id,
      r.name,
      r.lat,
      r.lng,
      r.category_id,
      r.price_level,
      r.average_cost,
      r.description,
      r.parking,
      r.map_query,
      c.name as category_name
    FROM restaurants r
    JOIN categories c ON r.category_id = c.id
    WHERE c.name = ?
      AND r.price_level IN (${placeholders})
  `;

  const result = await db
    .prepare(sql)
    .bind(params.category, ...priceLevels)
    .all<RestaurantRow>();

  // Filter by distance and map to domain model
  const restaurants: Restaurant[] = [];
  for (const row of result.results ?? []) {
    if (isWithinRadius(row.lat, row.lng, params.lat, params.lng, radiusMiles)) {
      const distance = distanceInMiles(params.lat, params.lng, row.lat, row.lng);
      restaurants.push(mapRowToRestaurant(row, distance));
    }
  }

  // Shuffle and limit results
  const shuffled = shouldShuffle ? shuffleArray(restaurants) : restaurants;
  const limited = shuffled.slice(0, limit);

  const response: ApiResponse<RestaurantsData> = {
    success: true,
    data: {
      category: params.category,
      restaurants: limited,
      total: restaurants.length,
    },
  };

  return new Response(JSON.stringify(response), {
    status: HTTP_OK,
    headers: { "Content-Type": "application/json" },
  });
}
