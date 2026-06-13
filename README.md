# E-commerce API

A simple e-commerce API built with Rails 8, MongoDB, and Mongoid. This application provides endpoints for browsing products and processing checkouts.

## Technology Stack

- **Ruby**: 3.4.4
- **Rails**: 8.1.3
- **MongoDB**: 8.0
- **Mongoid**: 9.1.0
- **Docker**: For containerized deployment

## Prerequisites

- Docker and Docker Compose
- Node.js (for running the verification script)

## Quick Start

### 1. Start the Application

```bash
docker compose up
```

This will:
- Start MongoDB 8.0 in a container
- Build and start the Rails application
- Make the API available at `http://localhost:3000`

### 2. Seed the Database

In a new terminal, run:

```bash
docker compose exec web rails db:seed
```

This creates 28 sample products across 5 categories (electronics, books, clothing, home, sports).

## API Endpoints

#### List Products
```
GET /products
```

Query parameters:
- `page` (integer, default: 1) - Page number for pagination
- `limit` (integer, default: 25, max: 100) - Items per page
- `category` (string) - Filter by category (e.g., "electronics", "books")
- `query` (string) - Search by product name (case-insensitive)

Response:
```json
{
  "products": [
    {
      "id": "507f1f77bcf86cd799439011",
      "name": "Wireless Bluetooth Headphones",
      "category": "electronics",
      "description": "Premium noise-canceling headphones",
      "price_cents": 12999,
      "inventory_count": 50
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 25,
    "total_count": 28
  }
}
```

#### Get Single Product
```
GET /products/:id
```

Response:
```json
{
  "id": "507f1f77bcf86cd799439011",
  "name": "Wireless Bluetooth Headphones",
  "category": "electronics",
  "description": "Premium noise-canceling headphones",
  "price_cents": 12999,
  "inventory_count": 50
}
```

### Checkout

#### Get Cart Quote
```
POST /checkouts/quote
```

Request body:
```json
{
  "items": [
    {
      "product_id": "507f1f77bcf86cd799439011",
      "quantity": 2
    }
  ]
}
```

Response:
```json
{
  "items": [
    {
      "product_id": "507f1f77bcf86cd799439011",
      "name": "Wireless Bluetooth Headphones",
      "quantity": 2,
      "unit_price_cents": 12999,
      "total_cents": 25998
    }
  ],
  "subtotal_cents": 25998,
  "tax_cents": 2080,
  "total_cents": 28078
}
```

#### Complete Checkout
```
POST /checkouts/complete
```

Request body:
```json
{
  "email": "customer@example.com",
  "items": [
    {
      "product_id": "507f1f77bcf86cd799439011",
      "quantity": 2
    }
  ]
}
```

Response (201 Created):
```json
{
  "order_id": "507f1f77bcf86cd799439012",
  "total_cents": 28078
}
```

## Error Handling

The API returns appropriate HTTP status codes and JSON error responses:

- **400 Bad Request** - Invalid request (empty cart, invalid quantity, insufficient inventory)
- **404 Not Found** - Resource not found
- **422 Unprocessable Entity** - Validation error (invalid email format)
- **500 Internal Server Error** - Server error

Error response format:
```json
{
  "error": "Bad request",
  "message": "Cart is empty"
}
```

## Running Tests

The application includes integration tests for both Products and Checkouts endpoints.

```bash
# Run all tests
docker compose exec web rails test

# Run specific test file
docker compose exec web rails test test/integration/products_test.rb
docker compose exec web rails test test/integration/checkouts_test.rb
```

## TypeScript Verification Script

TypeScript verification script is included to test all API endpoints.

### Setup and Run

```bash
cd src
npm install
npm run verify
```

The script will:
- Test all product endpoints (list, filter, show)
- Test checkout quote and complete endpoints
- Validate response shapes with TypeScript interfaces
- Verify error handling
- Exit with code 0 on success, non-zero on failure

**Note**: Ensure the API is running and seeded before running the verification script.

## Assumptions

### Business Logic Assumptions

1. **Tax Calculation**: Fixed at 8% on all orders (line 62 in `app/controllers/checkouts_controller.rb`)
2. **Currency Handling**: All prices stored and returned in cents (integer) to avoid floating-point precision issues
3. **Payment Processing**: No actual payment gateway integration - orders are immediately marked as "completed"
4. **Customer Identity**: Email address is the only customer identifier; no user accounts or authentication
5. **Inventory Management**:
   - Inventory is decremented synchronously after order creation
   - No atomic transactions between order creation and inventory updates
   - Inventory checks happen at quote time, but could change before completion
   - No inventory reservation system
6. **Product Availability**: Only products with `active: true` are visible and purchasable
7. **Pricing**:
   - No discounts, promotions, or bulk pricing
   - Line item totals calculated as `quantity × unit_price`
   - Prices are static (no dynamic pricing)
8. **Order Lifecycle**:
   - No refund or cancellation functionality
   - Orders are immediately "completed" with no intermediate states
   - No order modification after creation
9. **Cart Behavior**: Cart data is stateless (provided with each request, not stored server-side)

### Technical Assumptions

1. **Database**:
   - MongoDB 8.0 as the primary database
   - No database transactions used (inventory updates not atomic)
   - Indexes created on commonly queried fields (name, category, active, email, status)

2. **Security**:
   - No authentication or authorization required
   - No API rate limiting
   - No CORS restrictions configured
   - Email validation uses Ruby standard library (`URI::MailTo::EMAIL_REGEXP`)
   - No input sanitization beyond Rails parameter filtering

3. **Search & Filtering**:
   - Product search uses case-insensitive regex matching (not full-text search)
   - Pagination defaults: page 1, limit 25, max limit 100
   - Products ordered alphabetically by name

4. **Error Handling**:
   - Standard HTTP status codes (400, 404, 422, 500)
   - JSON error responses with `error` and `message` keys

5. **Data Integrity**:
   - No soft deletes (products can be marked inactive via `active` field)
   - No audit trail for order or inventory changes
   - No idempotency keys for order creation

### Implementation Assumptions

1. **Framework & Libraries**:
   - Rails 8.1.3 with Mongoid ODM (not ActiveRecord)
   - Ruby 3.4.4
   - No additional gems for serialization (using plain hash-to-JSON conversion)
   - No background job framework (Sidekiq, Resque, etc.)

2. **Error Handling**:
   - Custom `ErrorHandler` module for consistent error responses
   - Exceptions raised and caught at application controller level

3. **Code Organization**:
   - Standard Rails MVC structure
   - Models contain only validations and field definitions
   - Controllers handle both business logic and presentation
   - No concern modules or mixins (except Mongoid includes)

4. **Data Access**:
   - Mongoid ODM for MongoDB queries
   - No query optimization (N+1 prevention, eager loading concerns with NoSQL)
   - Index-aware queries for common filters (category, active status)
   - In-memory collection operations (`.index_by`, `.sum`) for cart calculations

5. **Testing Strategy**:
   - Integration tests for end-to-end API behavior
   - No unit tests for models or services
   - TypeScript verification script for additional validation

6. **Serialization**:
   - Manual JSON serialization in controllers
   - No serializer gems (ActiveModel::Serializers, Blueprinter, etc.)
   - Simple hash-to-JSON conversion
   - IDs converted to strings for MongoDB BSON ObjectIds

7. **Validation**:
   - Model-level validations using ActiveModel
   - Controller-level parameter filtering with Strong Parameters
   - Email validation using `URI::MailTo::EMAIL_REGEXP`
   - Business rule validation in controllers (inventory checks, quantity validation)

8. **Configuration**:
   - Environment-based configuration for MongoDB connection
   - Docker entrypoint script handles database setup

9. **Deployment**:
    - Docker Compose for local development
    - No database migration strategy (beyond Rails migrations)

10. **Dependencies**:
    - Minimal external dependencies
    - No third-party API integrations

## Development

### Accessing the Rails Console

```bash
docker compose exec web rails console
```

### Viewing Logs

```bash
docker compose logs -f web
```

### Stopping the Application

```bash
docker compose down
```

### Rebuilding After Changes

```bash
docker compose down
docker compose build
docker compose up
```
