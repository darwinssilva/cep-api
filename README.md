# CEP API

A Ruby on Rails API project that provides Brazilian postal code (CEP) lookup services, integrating with external APIs to fetch and cache address information.

## 🛠 Tech Stack

- **Ruby** 3.2.2
- **Rails** 7.1.5 (API-only)
- **PostgreSQL** (Database)
- **Puma** (Web server)
- **RSpec** (Testing framework)
- **WebMock** (HTTP request mocking)
- **Rack::Attack** (Rate limiting)

## 📋 Prerequisites

Make sure you have the following installed:

- Ruby 3.2.2
- PostgreSQL 12+
- Bundler
- Git

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/darwinssilva/cep-api.git
cd cep-api
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Database setup

```bash
# Configure your database credentials in config/database.yml
# Then run:
rails db:create
rails db:migrate
```

### 4. Start the server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## 🧪 Running Tests

### Run all tests
```bash
bundle exec rspec
```

### Run specific test types
```bash
# Model tests only
bundle exec rspec spec/models/

# Service tests only
bundle exec rspec spec/services/

# Controller/Request tests only
bundle exec rspec spec/requests/

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/address_spec.rb
```

### Test Coverage
```bash
# Run tests with coverage (if configured)
COVERAGE=true bundle exec rspec
```

## 📖 API Documentation

### Base URL
```
http://localhost:3000
```

### Endpoints

#### Create/Fetch Address by CEP

**POST** `/addresses`

Creates a new address or returns an existing one based on the provided CEP.

**Request Body:**
```json
{
  "cep": "01310-100"
}
```

**Success Response (201 - Created):**
```json
{
  "id": 1,
  "cep": "01310-100",
  "state": "SP",
  "city": "São Paulo",
  "neighborhood": "Bela Vista",
  "street": "Avenida Paulista",
  "longitude": -46.6564,
  "latitude": -23.5613,
  "created_at": "2026-03-11T10:30:00.000Z",
  "updated_at": "2026-03-11T10:30:00.000Z"
}
```

**Success Response (200 - Existing):**
Returns the same structure when address already exists in database.

**Error Responses:**

- **400 Bad Request** - Invalid CEP format
```json
{
  "error": "Invalid CEP format. Expected format: 12345-678 or 12345678."
}
```

- **404 Not Found** - CEP not found
```json
{
  "error": "CEP not found: 99999-999"
}
```

- **500 Internal Server Error** - External API error
```json
{
  "error": "Error fetching address data for CEP 99999-999"
}
```

### CEP Format
Accepts CEP in both formats:
- With dash: `01310-100`
- Without dash: `01310100`

### Rate Limiting

Configured in `config/initializers/rack_attack.rb`:
- Global: 100 requests per minute
- Per IP: 30 requests per minute for `/addresses`

### Code Style

This project uses RuboCop for code style enforcement:

```bash
# Check style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```
