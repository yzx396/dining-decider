/**
 * TypeScript types for DiningDecider API
 * Matches iOS models in DiningDeciderCore
 */

import { VIBE_MODES } from "../constants";

// ============ Environment ============

export interface Env {
  DB: D1Database;
  CACHE: KVNamespace;
  API_KEY: string;
  ENVIRONMENT: string;
}

// ============ Domain Models ============

export type VibeMode = (typeof VIBE_MODES)[number];

export interface Category {
  id: number;
  name: string;
  vibeMode: VibeMode;
  displayOrder: number;
}

export interface Restaurant {
  id: string;
  name: string;
  lat: number;
  lng: number;
  priceLevel: 1 | 2 | 3 | 4;
  averageCost: number;
  description: string;
  parking: string;
  mapQuery: string;
  categoryId: number;
  categoryName: string;
  distance?: number;
}

// ============ Database Row Types ============

export interface CategoryRow {
  id: number;
  name: string;
  vibe_mode: string;
  display_order: number;
}

export interface RestaurantRow {
  id: string;
  name: string;
  lat: number;
  lng: number;
  category_id: number;
  price_level: number;
  average_cost: number;
  description: string;
  parking: string;
  map_query: string;
  category_name: string;
}

// ============ API Request Types ============

export interface RestaurantsQueryParams {
  category: string;
  lat: number;
  lng: number;
  radiusMiles?: number;
  priceLevels?: number[];
  limit?: number;
  shuffle?: boolean;
}

export interface CategoriesQueryParams {
  vibeMode?: VibeMode;
}

// ============ API Response Types ============

export interface ApiResponse<T> {
  success: true;
  data: T;
}

export interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
}

export interface HealthData {
  status: "healthy" | "degraded" | "unhealthy";
  version: string;
  timestamp: string;
}

export interface CategoriesData {
  categories: Category[];
}

export interface RestaurantsData {
  category: string;
  restaurants: Restaurant[];
  total: number;
}
