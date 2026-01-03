/**
 * Distance calculation tests (TDD - written first)
 */
import { describe, it, expect } from "vitest";
import {
  distanceInMiles,
  distanceInMeters,
  isWithinRadius,
} from "../../src/utils/distance";

describe("distanceInMiles", () => {
  it("returns 0 for same coordinates", () => {
    const result = distanceInMiles(37.7749, -122.4194, 37.7749, -122.4194);
    expect(result).toBe(0);
  });

  it("calculates distance between SF and LA correctly", () => {
    // SF: 37.7749, -122.4194
    // LA: 34.0522, -118.2437
    // Expected: ~347 miles
    const result = distanceInMiles(37.7749, -122.4194, 34.0522, -118.2437);
    expect(result).toBeGreaterThan(340);
    expect(result).toBeLessThan(355);
  });

  it("calculates distance between SF and NYC correctly", () => {
    // SF: 37.7749, -122.4194
    // NYC: 40.7128, -74.006
    // Expected: ~2565 miles
    const result = distanceInMiles(37.7749, -122.4194, 40.7128, -74.006);
    expect(result).toBeGreaterThan(2550);
    expect(result).toBeLessThan(2580);
  });

  it("calculates short distance accurately", () => {
    // Two points about 1 mile apart in SF
    // Using approximate conversion: 1 mile ≈ 0.0145 degrees latitude
    const lat1 = 37.7749;
    const lng1 = -122.4194;
    const lat2 = 37.7894; // ~1 mile north
    const lng2 = -122.4194;

    const result = distanceInMiles(lat1, lng1, lat2, lng2);
    expect(result).toBeGreaterThan(0.9);
    expect(result).toBeLessThan(1.1);
  });

  it("is symmetric (A to B equals B to A)", () => {
    const distAB = distanceInMiles(37.7749, -122.4194, 34.0522, -118.2437);
    const distBA = distanceInMiles(34.0522, -118.2437, 37.7749, -122.4194);
    expect(distAB).toBeCloseTo(distBA, 10);
  });
});

describe("distanceInMeters", () => {
  it("returns 0 for same coordinates", () => {
    const result = distanceInMeters(37.7749, -122.4194, 37.7749, -122.4194);
    expect(result).toBe(0);
  });

  it("returns approximately 1609.34 meters for 1 mile", () => {
    // 1 mile in latitude ≈ 0.0145 degrees
    const lat1 = 37.7749;
    const lat2 = 37.7894; // ~1 mile north
    const lng = -122.4194;

    const meters = distanceInMeters(lat1, lng, lat2, lng);
    const miles = distanceInMiles(lat1, lng, lat2, lng);

    // Check conversion ratio
    expect(meters / miles).toBeCloseTo(1609.34, 0);
  });
});

describe("isWithinRadius", () => {
  // SF downtown coordinates
  const sfLat = 37.7749;
  const sfLng = -122.4194;

  it("returns true for same location", () => {
    const result = isWithinRadius(sfLat, sfLng, sfLat, sfLng, 10);
    expect(result).toBe(true);
  });

  it("returns true for point within radius", () => {
    // Oakland is about 8 miles from SF downtown
    const oaklandLat = 37.8044;
    const oaklandLng = -122.2712;

    const result = isWithinRadius(oaklandLat, oaklandLng, sfLat, sfLng, 10);
    expect(result).toBe(true);
  });

  it("returns false for point outside radius", () => {
    // San Jose is about 42 miles from SF
    const sjLat = 37.3382;
    const sjLng = -121.8863;

    const result = isWithinRadius(sjLat, sjLng, sfLat, sfLng, 10);
    expect(result).toBe(false);
  });

  it("returns true for point exactly at radius boundary", () => {
    // Find a point approximately 10 miles away
    // 1 degree latitude ≈ 69 miles, so 10 miles ≈ 0.145 degrees
    // But we'll use 9.9 miles to ensure we're within the boundary
    const pointLat = sfLat - 0.143; // ~9.9 miles south
    const pointLng = sfLng;

    const result = isWithinRadius(pointLat, pointLng, sfLat, sfLng, 10);
    expect(result).toBe(true);
  });

  it("uses default radius of 10 miles when not specified", () => {
    // Oakland is about 8 miles from SF downtown - should be within default radius
    const oaklandLat = 37.8044;
    const oaklandLng = -122.2712;

    const result = isWithinRadius(oaklandLat, oaklandLng, sfLat, sfLng);
    expect(result).toBe(true);
  });

  it("respects custom radius", () => {
    // Oakland is about 8 miles from SF downtown
    const oaklandLat = 37.8044;
    const oaklandLng = -122.2712;

    // Should be within 10 miles
    expect(isWithinRadius(oaklandLat, oaklandLng, sfLat, sfLng, 10)).toBe(true);

    // Should be outside 5 miles
    expect(isWithinRadius(oaklandLat, oaklandLng, sfLat, sfLng, 5)).toBe(false);
  });
});
