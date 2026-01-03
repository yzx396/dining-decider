/**
 * Categories endpoint handler
 */

import { HTTP_OK } from "../constants";
import type {
  ApiResponse,
  CategoriesData,
  Category,
  CategoryRow,
  VibeMode,
} from "../types";

/**
 * Maps database row to Category domain model
 */
function mapRowToCategory(row: CategoryRow): Category {
  return {
    id: row.id,
    name: row.name,
    vibeMode: row.vibe_mode as VibeMode,
    displayOrder: row.display_order,
  };
}

/**
 * Handles GET /categories requests
 * Returns list of categories, optionally filtered by vibeMode
 */
export async function handleCategories(
  db: D1Database,
  vibeMode?: VibeMode
): Promise<Response> {
  let sql = `
    SELECT id, name, vibe_mode, display_order
    FROM categories
  `;

  const params: string[] = [];

  if (vibeMode) {
    sql += ` WHERE vibe_mode = ?`;
    params.push(vibeMode);
  }

  sql += ` ORDER BY display_order ASC`;

  const result = await db.prepare(sql).bind(...params).all<CategoryRow>();

  const categories = (result.results ?? []).map(mapRowToCategory);

  const response: ApiResponse<CategoriesData> = {
    success: true,
    data: {
      categories,
    },
  };

  return new Response(JSON.stringify(response), {
    status: HTTP_OK,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
