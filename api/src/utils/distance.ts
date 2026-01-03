/**
 * Distance calculation utilities using Haversine formula
 * Ported from iOS DiningDeciderCore/DistanceCalculator.swift
 */

import {
  EARTH_RADIUS_MILES,
  DEGREES_TO_RADIANS,
  DEFAULT_RADIUS_MILES,
} from "../constants";

/** Meters per mile conversion factor */
const METERS_PER_MILE = 1609.34;

/** Earth's radius in meters (mean radius) */
const EARTH_RADIUS_METERS = 6_371_000;

/**
 * Calculates the distance in miles between two coordinates using Haversine formula
 */
export function distanceInMiles(
  fromLat: number,
  fromLng: number,
  toLat: number,
  toLng: number
): number {
  const meters = distanceInMeters(fromLat, fromLng, toLat, toLng);
  return meters / METERS_PER_MILE;
}

/**
 * Calculates the distance in meters between two coordinates using Haversine formula
 */
export function distanceInMeters(
  fromLat: number,
  fromLng: number,
  toLat: number,
  toLng: number
): number {
  const lat1 = fromLat * DEGREES_TO_RADIANS;
  const lat2 = toLat * DEGREES_TO_RADIANS;
  const deltaLat = (toLat - fromLat) * DEGREES_TO_RADIANS;
  const deltaLng = (toLng - fromLng) * DEGREES_TO_RADIANS;

  const a =
    Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
    Math.cos(lat1) *
      Math.cos(lat2) *
      Math.sin(deltaLng / 2) *
      Math.sin(deltaLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return EARTH_RADIUS_METERS * c;
}

/**
 * Checks if a point is within a radius of a center point
 */
export function isWithinRadius(
  pointLat: number,
  pointLng: number,
  centerLat: number,
  centerLng: number,
  radiusMiles: number = DEFAULT_RADIUS_MILES
): boolean {
  const distance = distanceInMiles(centerLat, centerLng, pointLat, pointLng);
  return distance <= radiusMiles;
}
