/**
 * Authentication Middleware
 * Validates Bearer token for API access
 */

const AUTH_TOKEN = process.env.GATEWAY_AUTH_TOKEN;

/**
 * Middleware to require authentication via Bearer token
 * Usage: Add to routes that need protection
 */
const requireAuth = (req, res, next) => {
  // Skip auth check if no token configured (development only)
  if (!AUTH_TOKEN) {
    console.warn('⚠️  WARNING: GATEWAY_AUTH_TOKEN not set - authentication disabled!');
    console.warn('⚠️  This is INSECURE for production deployments!');
    return next();
  }

  // Get token from Authorization header
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required',
      message: 'Missing Authorization header'
    });
  }

  // Check Bearer token format
  const [type, token] = authHeader.split(' ');

  if (type !== 'Bearer') {
    return res.status(401).json({
      success: false,
      error: 'Invalid authentication',
      message: 'Authorization header must use Bearer scheme'
    });
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      error: 'Invalid authentication',
      message: 'Missing authentication token'
    });
  }

  // Validate token (constant-time comparison to prevent timing attacks)
  if (!constantTimeCompare(token, AUTH_TOKEN)) {
    return res.status(401).json({
      success: false,
      error: 'Authentication failed',
      message: 'Invalid authentication token'
    });
  }

  // Authentication successful
  next();
};

/**
 * Constant-time string comparison to prevent timing attacks
 */
function constantTimeCompare(a, b) {
  if (a.length !== b.length) {
    return false;
  }

  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }

  return result === 0;
}

/**
 * Optional auth middleware - warns but doesn't block if no auth provided
 * Useful for gradual migration
 */
const optionalAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    req.authenticated = false;
    return next();
  }

  const [type, token] = authHeader.split(' ');

  if (type === 'Bearer' && token && AUTH_TOKEN && constantTimeCompare(token, AUTH_TOKEN)) {
    req.authenticated = true;
  } else {
    req.authenticated = false;
  }

  next();
};

module.exports = {
  requireAuth,
  optionalAuth
};
