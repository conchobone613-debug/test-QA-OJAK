export interface UserLocation {
  latitude: number;
  longitude: number;
}

export interface UserProfile {
  uid: string;
  birthDate: { year: number; month: number; day: number; hour: number };
  gender: "male" | "female";
  age: number;
  height?: number;
  location?: UserLocation;
  preferences?: {
    minAge?: number;
    maxAge?: number;
    minHeight?: number;
    maxHeight?: number;
    maxDistance?: number; // km
    preferredGender?: "male" | "female";
  };
}

// Haversine 공식으로 두 좌표 간 거리(km) 계산
export function calculateDistance(a: UserLocation, b: UserLocation): number {
  const R = 6371;
  const dLat = toRad(b.latitude - a.latitude);
  const dLon = toRad(b.longitude - a.longitude);
  const lat1 = toRad(a.latitude);
  const lat2 = toRad(b.latitude);

  const aVal =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
  const c = 2 * Math.atan2(Math.sqrt(aVal), Math.sqrt(1 - aVal));
  return R * c;
}

function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

export function filterByAge(
  candidate: UserProfile,
  minAge?: number,
  maxAge?: number
): boolean {
  if (minAge !== undefined && candidate.age < minAge) return false;
  if (maxAge !== undefined && candidate.age > maxAge) return false;
  return true;
}

export function filterByHeight(
  candidate: UserProfile,
  minHeight?: number,
  maxHeight?: number
): boolean {
  if (!candidate.height) return true;
  if (minHeight !== undefined && candidate.height < minHeight) return false;
  if (maxHeight !== undefined && candidate.height > maxHeight) return false;
  return true;
}

export function filterByDistance(
  userLoc: UserLocation,
  candidateLoc: UserLocation | undefined,
  maxDistance?: number
): boolean {
  if (!maxDistance || !candidateLoc) return true;
  return calculateDistance(userLoc, candidateLoc) <= maxDistance;
}

export function filterCandidate(
  user: UserProfile,
  candidate: UserProfile
): boolean {
  const prefs = user.preferences;
  if (!prefs) return true;

  if (prefs.preferredGender && candidate.gender !== prefs.preferredGender) return false;
  if (!filterByAge(candidate, prefs.minAge, prefs.maxAge)) return false;
  if (!filterByHeight(candidate, prefs.minHeight, prefs.maxHeight)) return false;
  if (user.location && !filterByDistance(user.location, candidate.location, prefs.maxDistance)) return false;

  return true;
}