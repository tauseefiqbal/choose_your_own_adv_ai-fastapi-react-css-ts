// API configuration
// In development: uses proxy defined in vite.config.ts (/api -> http://localhost:8000/api)
// In production: can override with VITE_API_URL environment variable
const VITE_API_URL = import.meta.env.VITE_API_URL as string | undefined;

export const API_BASE_URL = VITE_API_URL 
  ? `${VITE_API_URL}/api`  // Production: full URL from environment
  : '/api';                 // Development: relative path with proxy
