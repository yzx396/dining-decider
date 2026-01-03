/**
 * Named constants - no magic numbers in codebase
 */

// Distance calculation
export const EARTH_RADIUS_MILES = 3958.8;
export const DEGREES_TO_RADIANS = Math.PI / 180;

// API defaults
export const DEFAULT_RADIUS_MILES = 10;
export const DEFAULT_LIMIT = 3;
export const MAX_LIMIT = 20;

// Cache TTLs (in seconds)
export const CACHE_TTL_RESTAURANTS = 300; // 5 minutes
export const CACHE_TTL_CATEGORIES = 3600; // 1 hour

// Price levels
export const MIN_PRICE_LEVEL = 1;
export const MAX_PRICE_LEVEL = 4;
export const ALL_PRICE_LEVELS = [1, 2, 3, 4] as const;

// Vibe modes
export const VIBE_MODES = ["aesthetic", "splurge", "standard"] as const;
export type VibeMode = (typeof VIBE_MODES)[number];

// HTTP status codes
export const HTTP_OK = 200;
export const HTTP_BAD_REQUEST = 400;
export const HTTP_UNAUTHORIZED = 401;
export const HTTP_NOT_FOUND = 404;
export const HTTP_INTERNAL_ERROR = 500;

// Headers
export const API_KEY_HEADER = "X-API-Key";
