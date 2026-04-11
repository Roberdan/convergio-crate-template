//! HTTP API routes for convergio-CRATE_NAME.

use axum::Router;

/// Returns the router for this crate's API endpoints.
pub fn routes() -> Router {
    Router::new()
    // .route("/api/CRATE_NAME/health", get(health))
}
