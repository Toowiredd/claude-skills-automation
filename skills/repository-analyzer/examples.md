# Repository Analysis Examples

Real-world examples of repository analysis across different project types.

## Example 1: React + Express Full-Stack App

### User Request
"Analyze this codebase - I just inherited it and need to understand what's here."

### Analysis Output

```markdown
# TaskManager - Repository Analysis

**Generated:** 2025-10-17 20:15:23
**Analyzed by:** Claude Code Repository Analyzer

---

## 📊 Overview

**Primary Language:** JavaScript (78%), TypeScript (22%)
**Framework:** React (frontend) + Express (backend)
**Architecture:** Layered Architecture with Feature-Based Frontend
**Total Files:** 147 files
**Lines of Code:** 12,450 LOC
**Last Updated:** 2 days ago

---

## 📁 Directory Structure

```
taskmanager/
├── client/                    # React frontend
│   ├── src/
│   │   ├── features/          # Feature-based components
│   │   │   ├── auth/
│   │   │   ├── tasks/
│   │   │   └── dashboard/
│   │   ├── shared/            # Shared utilities
│   │   └── App.jsx
│   └── package.json
├── server/                    # Express backend
│   ├── src/
│   │   ├── api/               # Routes & controllers
│   │   ├── services/          # Business logic
│   │   ├── repositories/      # Database access
│   │   └── models/            # Data structures
│   └── package.json
├── database/
│   └── migrations/
└── docker-compose.yml
```

---

## 🛠 Technologies

### Frontend
- React 18.2.0
- React Router 6.14.0
- Axios 1.4.0
- Tailwind CSS 3.3.3

### Backend
- Node.js 18.16.0
- Express 4.18.2
- PostgreSQL 15 (via pg 8.11.0)
- JWT authentication (jsonwebtoken 9.0.1)

### DevOps
- Docker & Docker Compose
- GitHub Actions CI/CD
- Jest (testing) - 29.6.1

---

## 📦 Dependencies

### Production Dependencies
**Frontend (12 packages):**
- react: 18.2.0
- react-router-dom: 6.14.0
- axios: 1.4.0
- tailwindcss: 3.3.3

**Backend (8 packages):**
- express: 4.18.2
- pg: 8.11.0
- jsonwebtoken: 9.0.1
- bcrypt: 5.1.0

### ⚠️ Outdated Packages (3)
- express: 4.18.2 → 4.19.0 (security patch available)
- axios: 1.4.0 → 1.5.1 (patch update)
- jest: 29.6.1 → 29.7.0 (patch update)

**Recommendation:** Run `npm update` in both client/ and server/

---

## 🏗 Architecture

**Pattern:** Layered Architecture (backend) + Feature-Based (frontend)

### Backend Layers
1. **API Layer** (`server/src/api/`): REST endpoints, request validation
2. **Service Layer** (`server/src/services/`): Business logic, authorization
3. **Repository Layer** (`server/src/repositories/`): Database queries
4. **Models** (`server/src/models/`): Data structures & validation

### Frontend Features
- **auth/**: Login, register, password reset
- **tasks/**: Create, edit, delete tasks
- **dashboard/**: Overview, analytics

**Data Flow:**
```
Client (React) → API (Express) → Service → Repository → PostgreSQL
```

---

## 🔍 Code Quality

**Metrics:**
- Average function length: 28 lines
- Cyclomatic complexity: 3.8 (low-medium)
- Test coverage: 65% (backend), 42% (frontend)
- Files > 200 lines: 8 (potential refactor targets)

**Strengths:**
- ✅ Clear separation of concerns (layered architecture)
- ✅ Feature-based frontend (easy to navigate)
- ✅ Authentication implemented with JWT
- ✅ Database migrations in place

**Areas for Improvement:**
- ⚠️ Low frontend test coverage (42%)
- ⚠️ No API documentation (consider Swagger/OpenAPI)
- ⚠️ Large component files in `dashboard/` (>300 lines)
- ⚠️ Missing error handling in some API routes

---

## 🐛 Technical Debt

### High Priority (5)
1. **FIXME** in `server/src/services/task.service.js:67`
   ```javascript
   // FIXME: This query is slow for users with 1000+ tasks
   // Need to add pagination and indexing
   ```

2. **TODO** in `server/src/api/auth.controller.js:45`
   ```javascript
   // TODO: Implement refresh token rotation for better security
   ```

3. **HACK** in `client/src/features/tasks/TaskList.jsx:123`
   ```javascript
   // HACK: Force re-render to fix stale data issue
   // Should use proper state management instead
   ```

4. **Security Issue** in `server/src/api/tasks.routes.js`
   - Missing rate limiting on POST endpoints
   - Vulnerable to brute force attacks

5. **Performance Issue** in `client/src/features/dashboard/Dashboard.jsx`
   - Fetches all data on every render
   - Should implement caching or pagination

### Medium Priority (8)
- TODO: Add input validation on frontend forms
- TODO: Implement websockets for real-time updates
- FIXME: Memory leak in dashboard component (useEffect cleanup)
- TODO: Add loading states for all async operations
- TODO: Implement proper error boundaries
- ...

### Low Priority (12)
- TODO: Update README with latest setup instructions
- TODO: Add TypeScript to frontend
- ...

---

## 🚀 Entry Points

### Development
```bash
# Start frontend
cd client && npm run dev

# Start backend
cd server && npm run dev

# Start full stack
docker-compose up
```

### Testing
```bash
# Backend tests
cd server && npm test

# Frontend tests
cd client && npm test
```

### Production
```bash
# Build frontend
cd client && npm run build

# Start backend
cd server && npm start
```

---

## 📋 Common Tasks

### Adding a New Feature
1. Create feature folder in `client/src/features/{feature-name}/`
2. Add component, hooks, and API calls
3. Create backend endpoint in `server/src/api/{feature-name}.routes.js`
4. Implement service logic in `server/src/services/{feature-name}.service.js`
5. Add repository methods in `server/src/repositories/{feature-name}.repository.js`
6. Create database migration if needed
7. Write tests

### Database Changes
1. Create migration: `npm run migrate:create {migration-name}`
2. Update models in `server/src/models/`
3. Run migration: `npm run migrate:up`

### Deploying
1. Run tests: `npm test`
2. Build frontend: `cd client && npm run build`
3. Push to main branch
4. GitHub Actions will deploy automatically

---

## 🔗 Integration Points

### External Services
- PostgreSQL database (localhost:5432)
- No other external dependencies

### API Endpoints
- `POST /api/auth/login` - User authentication
- `POST /api/auth/register` - User registration
- `GET /api/tasks` - List all tasks
- `POST /api/tasks` - Create task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `GET /api/dashboard` - Dashboard metrics

---

## 📚 Recommendations

### Immediate Actions
1. **Update outdated packages** (especially express for security patch)
2. **Add rate limiting** to auth endpoints (prevents brute force)
3. **Fix pagination** in task service (performance issue)
4. **Increase test coverage** to 80%+ (especially frontend)

### Short-term Improvements
1. **Add API documentation** (Swagger/OpenAPI)
2. **Implement refresh token rotation** (better security)
3. **Add TypeScript** to frontend (type safety)
4. **Refactor large dashboard component** (split into smaller components)

### Long-term Enhancements
1. **Add websockets** for real-time task updates
2. **Implement caching** (Redis) for frequently accessed data
3. **Add monitoring** (Sentry for errors, Analytics)
4. **Consider microservices** if app grows significantly

---

**Analysis complete!** This codebase is well-structured but needs attention to test coverage and security improvements. Start with updating packages and adding rate limiting.
```

### Key Insights
- **Quick identification**: User learned the entire stack in 2 minutes
- **Actionable**: Clear list of what needs fixing immediately
- **Prioritized**: Technical debt sorted by urgency
- **Practical**: Common tasks documented for daily work

---

## Example 2: Python Django Monolith

### User Request
"I need to understand this legacy Django app before refactoring it."

### Analysis Output

```markdown
# LegacyERP - Repository Analysis

**Generated:** 2025-10-17 20:30:45
**Analyzed by:** Claude Code Repository Analyzer

---

## 📊 Overview

**Primary Language:** Python (92%), JavaScript (5%), HTML (3%)
**Framework:** Django 3.2 (LTS)
**Architecture:** MVC (Django's MVT pattern)
**Total Files:** 287 files
**Lines of Code:** 42,380 LOC
**Last Updated:** 6 months ago ⚠️

---

## 📁 Directory Structure

```
legacy-erp/
├── apps/                      # Django apps
│   ├── accounts/
│   ├── inventory/
│   ├── sales/
│   ├── purchases/
│   └── reports/
├── static/                    # Static files
├── templates/                 # HTML templates
├── media/                     # User uploads
└── manage.py
```

---

## 🛠 Technologies

- Django 3.2.20 (LTS, but 3.2.23 available - security updates)
- PostgreSQL 12
- Celery 5.2.7 (async tasks)
- Redis 4.5.5 (caching, Celery broker)
- jQuery 3.6.0 (frontend)

---

## ⚠️ Critical Findings

### Security Vulnerabilities
1. **Django 3.2.20 → 3.2.23** - 3 security patches available
2. **DEBUG = True** in production settings (exposes sensitive data)
3. **No rate limiting** on API endpoints
4. **SQL injection risk** in `apps/reports/views.py:145` (raw SQL query)

### Performance Issues
1. **N+1 queries** in 12 different views
2. **No database indexing** on frequently queried fields
3. **Large template files** (>1000 lines) slow to render

### Technical Debt
- **67 TODOs** across codebase
- **23 FIXMEs** (including 5 critical database issues)
- **8 HACK comments** indicating workarounds

---

## 🐛 Technical Debt (Top 10)

1. **CRITICAL** - SQL injection vulnerability in reports
2. **CRITICAL** - Passwords stored with weak hashing (SHA-1)
3. **HIGH** - No input validation on 15 forms
4. **HIGH** - Missing CSRF protection on AJAX endpoints
5. **HIGH** - Celery tasks have no retry logic
6. **MEDIUM** - Large models (>500 lines each)
7. **MEDIUM** - No API versioning
8. **MEDIUM** - Deprecated Django functions used
9. **LOW** - Missing docstrings on 80% of functions
10. **LOW** - Inconsistent code style

---

## 🚀 Refactoring Recommendations

### Phase 1: Security (Immediate)
1. Update Django to 3.2.23
2. Fix SQL injection vulnerability
3. Add rate limiting
4. Fix password hashing
5. Set DEBUG = False in production

### Phase 2: Performance (1-2 weeks)
1. Add `select_related()` and `prefetch_related()` to fix N+1 queries
2. Add database indexes
3. Implement caching for expensive queries
4. Split large templates into components

### Phase 3: Modernization (1-2 months)
1. Migrate to Django 4.2 (current LTS)
2. Add API (Django REST Framework)
3. Replace jQuery with modern frontend (React/Vue)
4. Add comprehensive testing
5. Implement CI/CD

---

**Next Steps:** Start with Phase 1 security fixes immediately. The SQL injection and password hashing issues are critical.
```

### Key Insights
- **Security-first**: Immediately flagged critical vulnerabilities
- **Actionable roadmap**: Phased refactoring plan
- **Risk assessment**: Prioritized by severity
- **Legacy understanding**: Clear picture of technical debt

---

## Example 3: Go Microservices

### User Request
"Analyze our microservices architecture - I need to document the system."

### Analysis Output

```markdown
# PaymentPlatform - Repository Analysis

**Generated:** 2025-10-17 20:45:12
**Analyzed by:** Claude Code Repository Analyzer

---

## 📊 Overview

**Primary Language:** Go (95%), Dockerfile (3%), YAML (2%)
**Framework:** Microservices Architecture
**Architecture:** Domain-Driven Design per service
**Total Files:** 423 files across 8 services
**Lines of Code:** 67,200 LOC
**Last Updated:** 3 hours ago

---

## 📁 Directory Structure

```
payment-platform/
├── services/
│   ├── auth-service/          # Authentication & authorization
│   ├── user-service/          # User management
│   ├── payment-service/       # Payment processing
│   ├── billing-service/       # Billing & invoices
│   ├── notification-service/  # Email/SMS notifications
│   ├── analytics-service/     # Reporting & analytics
│   ├── webhook-service/       # External webhooks
│   └── admin-service/         # Admin dashboard API
├── api-gateway/               # Kong API Gateway config
├── shared/                    # Shared libraries
│   ├── proto/                 # gRPC protobuf definitions
│   ├── types/                 # Common data structures
│   └── utils/                 # Shared utilities
├── infrastructure/
│   ├── kubernetes/            # K8s manifests
│   ├── terraform/             # Infrastructure as code
│   └── monitoring/            # Prometheus, Grafana
└── docker-compose.yml         # Local development
```

---

## 🏗 Architecture

**Pattern:** Microservices with DDD per service + API Gateway

### Services Communication
```
Client
  ↓
API Gateway (Kong)
  ↓
┌─────────────────────────────────────┐
│  auth-service  →  user-service      │
│       ↓                              │
│  payment-service  →  billing-service│
│       ↓                              │
│  notification-service               │
└─────────────────────────────────────┘
```

### Technology per Service
- **Communication**: gRPC (internal), REST (external)
- **Databases**: PostgreSQL (6 services), MongoDB (analytics, notifications)
- **Message Queue**: RabbitMQ (events)
- **Caching**: Redis (all services)

---

## 🔍 Service Analysis

### auth-service
- **LOC:** 4,200
- **Dependencies:** JWT, bcrypt, Redis
- **Database:** PostgreSQL
- **API:** REST + gRPC
- **Health:** ✅ Good test coverage (82%)

### payment-service (⚠️ Needs attention)
- **LOC:** 12,800 (largest service - consider splitting)
- **Dependencies:** Stripe, PayPal, Braintree
- **Database:** PostgreSQL
- **API:** gRPC only
- **Health:** ⚠️ Low test coverage (45%)
- **Issues:**
  - 15 TODOs including webhook retry logic
  - No circuit breaker for external APIs
  - Missing idempotency keys

### notification-service
- **LOC:** 3,500
- **Dependencies:** SendGrid, Twilio
- **Database:** MongoDB
- **API:** gRPC + Event consumers
- **Health:** ✅ Good (78% test coverage)

(... analysis continues for all 8 services ...)

---

## 🐛 Technical Debt by Service

### High Priority Across Services
1. **payment-service**: Missing circuit breaker (risk of cascade failures)
2. **payment-service**: No idempotency (risk of duplicate charges)
3. **webhook-service**: No signature verification (security risk)
4. **All services**: Missing distributed tracing headers

### Medium Priority
1. **billing-service**: Inefficient PDF generation (slow)
2. **analytics-service**: No data retention policy
3. **admin-service**: Missing RBAC (role-based access control)

---

## 📊 Service Health Dashboard

| Service | LOC | Test Coverage | Complexity | Status |
|---------|-----|---------------|------------|--------|
| auth-service | 4.2K | 82% | Low | ✅ Healthy |
| user-service | 5.1K | 75% | Low | ✅ Healthy |
| payment-service | 12.8K | 45% | High | ⚠️ Needs work |
| billing-service | 6.3K | 68% | Medium | 🟡 OK |
| notification-service | 3.5K | 78% | Low | ✅ Healthy |
| analytics-service | 9.2K | 52% | Medium | 🟡 OK |
| webhook-service | 4.8K | 61% | Low | ⚠️ Security issue |
| admin-service | 7.1K | 70% | Low | ✅ Healthy |

---

## 🚀 Recommendations

### Immediate (This Week)
1. **Add circuit breaker** to payment-service (prevent cascade failures)
2. **Implement idempotency** in payment-service (prevent duplicate charges)
3. **Add webhook signature verification** (security)

### Short-term (This Month)
1. **Split payment-service** (too large - consider payment-processor-service)
2. **Add distributed tracing** (Jaeger/Zipkin) for better debugging
3. **Implement RBAC** in admin-service
4. **Increase test coverage** to 70%+ across all services

### Long-term (This Quarter)
1. **Add service mesh** (Istio/Linkerd) for better observability
2. **Implement event sourcing** for critical services
3. **Add chaos engineering** tests
4. **Consider CQRS** for analytics-service

---

**Architecture is solid overall, but payment-service needs immediate attention for reliability and security.**
```

### Key Insights
- **Service-by-service**: Clear breakdown of each microservice
- **Health dashboard**: Visual representation of service status
- **Architecture diagram**: Shows communication flow
- **Prioritized fixes**: Immediate security and reliability issues flagged

See main [SKILL.md](SKILL.md) for analysis workflow and [patterns.md](patterns.md) for pattern detection.
