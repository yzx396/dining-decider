/**
 * API key authentication middleware
 */

import { API_KEY_HEADER, HTTP_UNAUTHORIZED } from "../constants";

/**
 * Validates an API key against the expected value
 */
export function validateApiKey(
  providedKey: string | undefined | null,
  expectedKey: string
): boolean {
  if (!providedKey || typeof providedKey !== "string") {
    return false;
  }
  return providedKey === expectedKey;
}

/**
 * Creates an authentication middleware function
 * Returns null if authentication passes, or a 401 Response if it fails
 */
export function createAuthMiddleware(
  expectedApiKey: string
): (request: Request) => Response | null {
  return (request: Request): Response | null => {
    const providedKey = request.headers.get(API_KEY_HEADER);

    if (validateApiKey(providedKey, expectedApiKey)) {
      return null; // Authentication passed, continue to handler
    }

    // Authentication failed
    return new Response(
      JSON.stringify({
        success: false,
        error: {
          code: "UNAUTHORIZED",
          message: "Invalid or missing API key",
        },
      }),
      {
        status: HTTP_UNAUTHORIZED,
        headers: {
          "Content-Type": "application/json",
        },
      }
    );
  };
}
