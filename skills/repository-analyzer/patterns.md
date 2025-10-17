# Architecture Pattern Library

Common software architecture patterns and how to detect them in codebases.

## Pattern 1: MVC (Model-View-Controller)

###

 Detection Signs
```
project/
├── models/          # Data structures
├── views/           # UI templates
├── controllers/     # Request handlers
└── routes/          # URL routing
```

### Characteristics
- **Separation of concerns**: Data, presentation, logic separated
- **Common in**: Ruby on Rails, Django, Laravel, ASP.NET MVC
- **Flow**: User → Controller → Model → View → User

### Example Structure (Rails)
```
app/
├── models/
│   ├── user.rb
│   └── post.rb
├── views/
│   ├── users/
│   └── posts/
├── controllers/
│   ├── users_controller.rb
│   └── posts_controller.rb
```

### Analysis Notes
- **Strengths**: Clear separation, easy to understand
- **Weaknesses**: Can become bloated in large apps
- **Refactoring suggestion**: Consider service layer for complex business logic

---

## Pattern 2: Layered Architecture

### Detection Signs
```
project/
├── api/             # HTTP layer
├── services/        # Business logic
├── repositories/    # Data access
└── models/          # Data structures
```

### Characteristics
- **Horizontal layers**: Each layer depends only on layer below
- **Common in**: Enterprise applications, microservices
- **Flow**: API → Service → Repository → Database

### Example Structure (Node.js)
```
src/
├── api/
│   ├── routes/
│   └── controllers/
├── services/
│   ├── user.service.js
│   └── auth.service.js
├── repositories/
│   ├── user.repository.js
│   └── auth.repository.js
└── models/
    └── user.model.js
```

### Analysis Notes
- **Strengths**: Testable, maintainable, scalable
- **Weaknesses**: Can be over-engineered for simple apps
- **Refactoring suggestion**: Add DTOs (Data Transfer Objects) between layers

---

## Pattern 3: Feature-Based (Vertical Slices)

### Detection Signs
```
project/
├── features/
│   ├── authentication/
│   │   ├── auth.controller.js
│   │   ├── auth.service.js
│   │   └── auth.test.js
│   ├── users/
│   │   ├── user.controller.js
│   │   ├── user.service.js
│   │   └── user.test.js
```

### Characteristics
- **Organized by feature**: Each feature is self-contained
- **Common in**: Modern frontend apps, domain-driven design
- **Flow**: Feature folder contains everything for that feature

### Example Structure (React)
```
src/
├── features/
│   ├── dashboard/
│   │   ├── Dashboard.jsx
│   │   ├── dashboard.hooks.js
│   │   ├── dashboard.api.js
│   │   └── dashboard.test.js
│   ├── profile/
│   │   ├── Profile.jsx
│   │   ├── profile.hooks.js
│   │   └── profile.test.js
└── shared/          # Shared utilities
```

### Analysis Notes
- **Strengths**: High cohesion, easy to navigate, easy to delete features
- **Weaknesses**: Shared code can be tricky
- **Refactoring suggestion**: Create `shared/` folder for cross-cutting concerns

---

## Pattern 4: Domain-Driven Design (DDD)

### Detection Signs
```
project/
├── domain/          # Business logic
├── application/     # Use cases
├── infrastructure/  # External concerns
└── interfaces/      # API/UI
```

### Characteristics
- **Domain-centric**: Business logic is central
- **Common in**: Complex enterprise applications
- **Flow**: Interface → Application → Domain

### Example Structure
```
src/
├── domain/
│   ├── user/
│   │   ├── user.entity.js
│   │   ├── user.repository.interface.js
│   │   └── user.service.js
│   └── order/
│       ├── order.entity.js
│       └── order.service.js
├── application/
│   ├── create-user.usecase.js
│   └── place-order.usecase.js
├── infrastructure/
│   ├── database/
│   └── email/
└── interfaces/
    ├── http/
    └── cli/
```

### Analysis Notes
- **Strengths**: Models complex business domains accurately
- **Weaknesses**: High learning curve, can be overkill for simple apps
- **Refactoring suggestion**: Start simple, add DDD patterns as complexity grows

---

## Pattern 5: Microservices

### Detection Signs
```
project/
├── services/
│   ├── auth-service/
│   ├── user-service/
│   ├── payment-service/
│   └── notification-service/
├── api-gateway/
└── shared/
```

### Characteristics
- **Distributed**: Each service is independent
- **Common in**: Large-scale applications, cloud-native apps
- **Flow**: API Gateway → Service A/B/C → Database A/B/C

### Example Structure
```
monorepo/
├── services/
│   ├── auth/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
│   ├── users/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
├── api-gateway/
│   └── src/
├── shared/
│   └── types/
└── docker-compose.yml
```

### Analysis Notes
- **Strengths**: Scalable, independent deployment, technology flexibility
- **Weaknesses**: Complexity, distributed system challenges, debugging harder
- **Refactoring suggestion**: Start with modular monolith, extract services as needed

---

## Pattern 6: Monorepo

### Detection Signs
```
project/
├── packages/
│   ├── frontend/
│   ├── backend/
│   └── shared/
├── package.json      # Workspace root
└── lerna.json or pnpm-workspace.yaml
```

### Characteristics
- **Single repository**: Multiple packages/apps in one repo
- **Common in**: Organizations with multiple related projects
- **Flow**: Shared code lives in `packages/shared`

### Example Structure (pnpm workspaces)
```
monorepo/
├── apps/
│   ├── web/
│   │   └── package.json
│   └── mobile/
│       └── package.json
├── packages/
│   ├── ui/
│   │   └── package.json
│   └── utils/
│       └── package.json
├── package.json
└── pnpm-workspace.yaml
```

### Analysis Notes
- **Strengths**: Code sharing, atomic commits across projects, easier refactoring
- **Weaknesses**: Large repo size, CI/CD complexity
- **Refactoring suggestion**: Use build caching (Turborepo, Nx)

---

## Pattern 7: Clean Architecture (Hexagonal/Ports & Adapters)

### Detection Signs
```
project/
├── core/            # Business logic (no dependencies)
├── adapters/        # External integrations
│   ├── http/
│   ├── database/
│   └── messaging/
└── ports/           # Interfaces
```

### Characteristics
- **Dependency inversion**: Core doesn't depend on external concerns
- **Common in**: Applications with complex external integrations
- **Flow**: Adapter → Port → Core

### Example Structure
```
src/
├── core/
│   ├── domain/
│   │   └── user.entity.js
│   ├── usecases/
│   │   └── create-user.usecase.js
│   └── ports/
│       ├── user.repository.port.js
│       └── email.service.port.js
└── adapters/
    ├── http/
    │   └── user.controller.js
    ├── database/
    │   └── user.repository.postgres.js
    └── email/
        └── email.service.sendgrid.js
```

### Analysis Notes
- **Strengths**: Highly testable, technology-agnostic core, easy to swap implementations
- **Weaknesses**: Many files and abstractions, can be over-engineered
- **Refactoring suggestion**: Use for apps with many external dependencies

---

## Pattern 8: JAMstack

### Detection Signs
```
project/
├── public/          # Static assets
├── src/
│   ├── pages/       # Pre-rendered pages
│   └── components/
├── api/             # Serverless functions
└── netlify.toml or vercel.json
```

### Characteristics
- **JavaScript + APIs + Markup**: Pre-rendered static site + serverless functions
- **Common in**: Static sites, marketing sites, blogs
- **Flow**: Static HTML + Client-side JS → Serverless API

### Example Structure (Next.js)
```
project/
├── pages/
│   ├── index.jsx
│   ├── about.jsx
│   └── api/
│       └── contact.js  # Serverless function
├── components/
├── public/
└── next.config.js
```

### Analysis Notes
- **Strengths**: Fast, secure, scalable, cheap hosting
- **Weaknesses**: Limited real-time features, build times for large sites
- **Refactoring suggestion**: Use ISR (Incremental Static Regeneration) for frequently updated content

---

## Pattern 9: Event-Driven Architecture

### Detection Signs
```
project/
├── events/
│   ├── user.created.event.js
│   ├── order.placed.event.js
├── handlers/
│   ├── send-welcome-email.handler.js
│   ├── update-inventory.handler.js
└── infrastructure/
    └── event-bus/
```

### Characteristics
- **Asynchronous**: Components communicate via events
- **Common in**: Real-time systems, distributed systems
- **Flow**: Event Producer → Event Bus → Event Consumers

### Example Structure
```
src/
├── events/
│   ├── user-registered.event.js
│   └── payment-completed.event.js
├── publishers/
│   └── event.publisher.js
├── subscribers/
│   ├── email.subscriber.js
│   └── analytics.subscriber.js
└── infrastructure/
    └── rabbitmq/
```

### Analysis Notes
- **Strengths**: Decoupled, scalable, resilient
- **Weaknesses**: Debugging harder, eventual consistency, message ordering
- **Refactoring suggestion**: Add event versioning and schema validation

---

## Pattern 10: CQRS (Command Query Responsibility Segregation)

### Detection Signs
```
project/
├── commands/        # Write operations
│   ├── create-user.command.js
│   └── update-profile.command.js
├── queries/         # Read operations
│   ├── get-user.query.js
│   └── list-users.query.js
├── write-model/     # Write database
└── read-model/      # Read database (denormalized)
```

### Characteristics
- **Separate read/write**: Different models for queries vs commands
- **Common in**: High-performance systems, event-sourced systems
- **Flow**: Command → Write DB → Event → Read DB (projection)

### Example Structure
```
src/
├── commands/
│   ├── handlers/
│   │   └── create-order.handler.js
│   └── validators/
├── queries/
│   ├── handlers/
│   │   └── get-order-details.handler.js
│   └── projections/
├── write-store/
│   └── postgres/
└── read-store/
    └── elasticsearch/
```

### Analysis Notes
- **Strengths**: Optimized reads and writes independently, scalable
- **Weaknesses**: Complexity, eventual consistency, data duplication
- **Refactoring suggestion**: Use only when read/write patterns are very different

---

## Detection Decision Tree

```
Has models/, views/, controllers/? → MVC
Has api/, services/, repositories/? → Layered Architecture
Has features/ with self-contained modules? → Feature-Based
Has domain/, application/, infrastructure/? → DDD
Has multiple services/ with Dockerfiles? → Microservices
Has packages/ or workspaces? → Monorepo
Has core/ and adapters/? → Clean Architecture
Has static pages/ and api/ serverless? → JAMstack
Has events/ and handlers/? → Event-Driven
Has separate commands/ and queries/? → CQRS
```

See main [SKILL.md](SKILL.md) for analysis workflow and [examples.md](examples.md) for real-world examples.
