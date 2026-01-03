/**
 * Health check endpoint handler
 */

import { HTTP_OK } from "../constants";
import type { ApiResponse, HealthData } from "../types";

const API_VERSION = "1.0.0";

/**
 * Handles GET /health requests
 * Returns current API health status
 */
export async function handleHealth(): Promise<Response> {
  const data: HealthData = {
    status: "healthy",
    version: API_VERSION,
    timestamp: new Date().toISOString(),
  };

  const response: ApiResponse<HealthData> = {
    success: true,
    data,
  };

  return new Response(JSON.stringify(response), {
    status: HTTP_OK,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
