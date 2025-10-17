# API Integration Reference

Best practices, patterns, and guidelines for API client generation.

## Authentication Patterns

### Pattern 1: API Key (Bearer Token)

**When to use**: Most SaaS APIs (Stripe, SendGrid, Twilio)

```typescript
// Simple bearer token in Authorization header
headers: {
  'Authorization': `Bearer ${apiKey}`
}
```

**Variants**:
- Custom header: `X-API-Key: ${apiKey}`
- Query parameter: `?api_key=${apiKey}` (less secure, avoid if possible)

---

### Pattern 2: OAuth 2.0 Client Credentials

**When to use**: Server-to-server authentication (GitHub Apps, Google APIs)

```typescript
// Step 1: Get access token
const tokenResponse = await axios.post('https://oauth.provider.com/token', {
  grant_type: 'client_credentials',
  client_id: clientId,
  client_secret: clientSecret,
  scope: 'read write'
});

const accessToken = tokenResponse.data.access_token;
const expiresIn = tokenResponse.data.expires_in; // seconds

// Step 2: Use access token
headers: {
  'Authorization': `Bearer ${accessToken}`
}

// Step 3: Refresh before expiry
if (Date.now() > tokenExpiry) {
  // Fetch new token
}
```

---

### Pattern 3: OAuth 2.0 Authorization Code

**When to use**: User authentication (Sign in with Google, GitHub)

```typescript
// Step 1: Redirect user to authorization URL
const authUrl = `https://oauth.provider.com/authorize?
  client_id=${clientId}&
  redirect_uri=${redirectUri}&
  response_type=code&
  scope=read write`;

// Step 2: Exchange authorization code for access token
const tokenResponse = await axios.post('https://oauth.provider.com/token', {
  grant_type: 'authorization_code',
  code: authorizationCode,
  client_id: clientId,
  client_secret: clientSecret,
  redirect_uri: redirectUri
});

const accessToken = tokenResponse.data.access_token;
const refreshToken = tokenResponse.data.refresh_token;

// Step 3: Refresh access token when expired
const refreshResponse = await axios.post('https://oauth.provider.com/token', {
  grant_type: 'refresh_token',
  refresh_token: refreshToken,
  client_id: clientId,
  client_secret: clientSecret
});
```

---

### Pattern 4: Basic Authentication

**When to use**: Legacy APIs, internal services

```typescript
// Username:password encoded as Base64
const credentials = Buffer.from(`${username}:${password}`).toString('base64');

headers: {
  'Authorization': `Basic ${credentials}`
}

// Or use Axios built-in
axios.create({
  auth: {
    username: username,
    password: password
  }
});
```

---

### Pattern 5: JWT (JSON Web Token)

**When to use**: Custom authentication systems

```typescript
import jwt from 'jsonwebtoken';

// Create JWT
const token = jwt.sign(
  { userId: '123', email: 'user@example.com' },
  secret,
  { expiresIn: '1h' }
);

// Use JWT
headers: {
  'Authorization': `Bearer ${token}`
}

// Verify JWT
const decoded = jwt.verify(token, secret);
```

---

## Retry Strategies

### Strategy 1: Exponential Backoff

**Best for**: Temporary failures, rate limits

```typescript
const delay = initialDelay * Math.pow(backoffFactor, attemptNumber);

// Example:
// Attempt 1: 1s delay
// Attempt 2: 2s delay
// Attempt 3: 4s delay
// Attempt 4: 8s delay
```

**Implementation**:
```typescript
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  initialDelay: number = 1000,
  backoffFactor: number = 2
): Promise<T> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries - 1) throw error;

      const delay = initialDelay * Math.pow(backoffFactor, attempt);
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
  throw new Error('Max retries exceeded');
}
```

---

### Strategy 2: Jittered Backoff

**Best for**: Distributed systems (prevents thundering herd)

```typescript
const baseDelay = initialDelay * Math.pow(backoffFactor, attemptNumber);
const jitter = Math.random() * 1000; // 0-1000ms random jitter
const delay = baseDelay + jitter;
```

---

### Strategy 3: Fixed Delay

**Best for**: Known intermittent issues

```typescript
async function retryWithFixedDelay<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries - 1) throw error;
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
  throw new Error('Max retries exceeded');
}
```

---

### Retryable vs Non-Retryable Errors

**Retryable** (retry makes sense):
- Network errors (ECONNREFUSED, ETIMEDOUT)
- 408 Request Timeout
- 429 Too Many Requests
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable
- 504 Gateway Timeout

**Non-retryable** (don't retry):
- 400 Bad Request (fix the request)
- 401 Unauthorized (fix credentials)
- 403 Forbidden (permission issue)
- 404 Not Found (resource doesn't exist)
- 422 Unprocessable Entity (validation error)

```typescript
function isRetryableError(error: AxiosError): boolean {
  if (!error.response) return true; // Network error

  const status = error.response.status;
  return [408, 429, 500, 502, 503, 504].includes(status);
}
```

---

## Rate Limiting Patterns

### Pattern 1: Token Bucket

**Best for**: Smooth rate limiting

```typescript
class TokenBucket {
  private tokens: number;
  private lastRefill: number;

  constructor(
    private capacity: number,
    private refillRate: number, // tokens per second
  ) {
    this.tokens = capacity;
    this.lastRefill = Date.now();
  }

  async consume(tokens: number = 1): Promise<void> {
    this.refill();

    if (this.tokens < tokens) {
      const waitTime = ((tokens - this.tokens) / this.refillRate) * 1000;
      await new Promise((resolve) => setTimeout(resolve, waitTime));
      this.refill();
    }

    this.tokens -= tokens;
  }

  private refill(): void {
    const now = Date.now();
    const elapsedSeconds = (now - this.lastRefill) / 1000;
    const tokensToAdd = elapsedSeconds * this.refillRate;

    this.tokens = Math.min(this.capacity, this.tokens + tokensToAdd);
    this.lastRefill = now;
  }
}
```

---

### Pattern 2: Sliding Window

**Best for**: Strict rate limits (X requests per Y seconds)

```typescript
class SlidingWindow {
  private timestamps: number[] = [];

  constructor(
    private limit: number,
    private windowMs: number
  ) {}

  async wait(): Promise<void> {
    const now = Date.now();

    // Remove timestamps outside the window
    this.timestamps = this.timestamps.filter((ts) => now - ts < this.windowMs);

    if (this.timestamps.length >= this.limit) {
      const oldestTimestamp = this.timestamps[0];
      const waitTime = oldestTimestamp + this.windowMs - now;

      if (waitTime > 0) {
        await new Promise((resolve) => setTimeout(resolve, waitTime));
        return this.wait(); // Recursive call
      }
    }

    this.timestamps.push(now);
  }
}
```

---

### Pattern 3: Respect Server Rate Limit Headers

**Best for**: APIs that provide rate limit info in headers

```typescript
axios.interceptors.response.use(
  (response) => {
    // Read rate limit headers
    const remaining = parseInt(response.headers['x-ratelimit-remaining'] || '0');
    const reset = parseInt(response.headers['x-ratelimit-reset'] || '0');

    if (remaining === 0) {
      const waitTime = reset * 1000 - Date.now();
      // Pause requests until reset
    }

    return response;
  },
  async (error) => {
    if (error.response?.status === 429) {
      const retryAfter = error.response.headers['retry-after'];
      const waitTime = parseInt(retryAfter) * 1000 || 60000; // Default 1 minute

      await new Promise((resolve) => setTimeout(resolve, waitTime));
      return axios.request(error.config); // Retry request
    }

    throw error;
  }
);
```

---

## Error Handling Patterns

### Pattern 1: Typed Error Classes

```typescript
export class APIError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public response?: any
  ) {
    super(message);
    this.name = 'APIError';
  }
}

export class ValidationError extends APIError {
  constructor(
    message: string,
    public fields: Record<string, string[]>
  ) {
    super(message, 400);
    this.name = 'ValidationError';
  }
}

export class RateLimitError extends APIError {
  constructor(
    message: string,
    public retryAfter?: number
  ) {
    super(message, 429);
    this.name = 'RateLimitError';
  }
}

// Usage
try {
  await client.createUser(data);
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Validation failed:', error.fields);
  } else if (error instanceof RateLimitError) {
    console.error(`Rate limited. Retry after ${error.retryAfter}s`);
  } else {
    console.error('Unknown error:', error);
  }
}
```

---

### Pattern 2: Error Response Parsing

```typescript
function parseAPIError(error: AxiosError): APIError {
  // Parse Stripe errors
  if (error.response?.data?.error) {
    const { message, type, code, param } = error.response.data.error;
    return new APIError(`${type}: ${message} (${code})`, error.response.status);
  }

  // Parse RFC 7807 Problem Details
  if (error.response?.data?.title) {
    const { title, detail, status } = error.response.data;
    return new APIError(`${title}: ${detail}`, status);
  }

  // Parse standard { message, error } format
  if (error.response?.data?.message) {
    return new APIError(error.response.data.message, error.response.status);
  }

  // Generic error
  return new APIError('Unknown API error', error.response?.status);
}
```

---

## Pagination Patterns

### Pattern 1: Offset-Based

**Format**: `?offset=20&limit=10`

```typescript
async function* paginateOffset<T>(
  fetchFn: (offset: number, limit: number) => Promise<T[]>,
  limit: number = 100
): AsyncGenerator<T> {
  let offset = 0;
  let hasMore = true;

  while (hasMore) {
    const items = await fetchFn(offset, limit);

    for (const item of items) {
      yield item;
    }

    hasMore = items.length === limit;
    offset += limit;
  }
}

// Usage
for await (const user of paginateOffset(client.listUsers, 50)) {
  console.log(user);
}
```

---

### Pattern 2: Cursor-Based

**Format**: `?cursor=abc123&limit=10`

```typescript
async function* paginateCursor<T>(
  fetchFn: (cursor?: string, limit?: number) => Promise<{ data: T[]; nextCursor?: string }>,
  limit: number = 100
): AsyncGenerator<T> {
  let cursor: string | undefined;
  let hasMore = true;

  while (hasMore) {
    const response = await fetchFn(cursor, limit);

    for (const item of response.data) {
      yield item;
    }

    cursor = response.nextCursor;
    hasMore = !!cursor;
  }
}
```

---

### Pattern 3: Page-Based

**Format**: `?page=2&perPage=10`

```typescript
async function* paginatePage<T>(
  fetchFn: (page: number, perPage: number) => Promise<{ data: T[]; totalPages: number }>,
  perPage: number = 100
): AsyncGenerator<T> {
  let page = 1;
  let totalPages = Infinity;

  while (page <= totalPages) {
    const response = await fetchFn(page, perPage);
    totalPages = response.totalPages;

    for (const item of response.data) {
      yield item;
    }

    page++;
  }
}
```

---

## Request/Response Transformation

### Pattern 1: Camel Case ↔ Snake Case

```typescript
import { camelCase, snakeCase } from 'lodash';

// Transform request (JS camelCase → API snake_case)
function toSnakeCase(obj: any): any {
  if (Array.isArray(obj)) {
    return obj.map(toSnakeCase);
  }
  if (obj !== null && typeof obj === 'object') {
    return Object.keys(obj).reduce((acc, key) => {
      acc[snakeCase(key)] = toSnakeCase(obj[key]);
      return acc;
    }, {} as any);
  }
  return obj;
}

// Transform response (API snake_case → JS camelCase)
function toCamelCase(obj: any): any {
  if (Array.isArray(obj)) {
    return obj.map(toCamelCase);
  }
  if (obj !== null && typeof obj === 'object') {
    return Object.keys(obj).reduce((acc, key) => {
      acc[camelCase(key)] = toCamelCase(obj[key]);
      return acc;
    }, {} as any);
  }
  return obj;
}

// Use in interceptors
axios.interceptors.request.use((config) => {
  if (config.data) {
    config.data = toSnakeCase(config.data);
  }
  return config;
});

axios.interceptors.response.use((response) => {
  response.data = toCamelCase(response.data);
  return response;
});
```

---

### Pattern 2: Date Parsing

```typescript
function parseAPIResponse(data: any): any {
  if (Array.isArray(data)) {
    return data.map(parseAPIResponse);
  }

  if (data !== null && typeof data === 'object') {
    const parsed = {} as any;

    for (const [key, value] of Object.entries(data)) {
      // Parse ISO date strings
      if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(value)) {
        parsed[key] = new Date(value);
      }
      // Parse Unix timestamps
      else if (key.endsWith('_at') && typeof value === 'number') {
        parsed[key] = new Date(value * 1000);
      } else {
        parsed[key] = parseAPIResponse(value);
      }
    }

    return parsed;
  }

  return data;
}

axios.interceptors.response.use((response) => {
  response.data = parseAPIResponse(response.data);
  return response;
});
```

---

## Testing Patterns

### Pattern 1: Mock Client

```typescript
export class MockStripeClient {
  private mockData: Map<string, any> = new Map();

  async createCustomer(data: CreateCustomerData): Promise<Customer> {
    const customer: Customer = {
      id: `cus_${Date.now()}`,
      email: data.email,
      name: data.name,
      created: Date.now(),
    };

    this.mockData.set(customer.id, customer);
    return customer;
  }

  async getCustomer(customerId: string): Promise<Customer> {
    const customer = this.mockData.get(customerId);
    if (!customer) {
      throw new Error('Customer not found');
    }
    return customer;
  }
}

// Usage in tests
const mockClient = new MockStripeClient();
const customer = await mockClient.createCustomer({ email: 'test@example.com' });
expect(customer.id).toMatch(/^cus_/);
```

---

### Pattern 2: Nock (HTTP Mocking)

```typescript
import nock from 'nock';

describe('StripeClient', () => {
  it('creates a customer', async () => {
    nock('https://api.stripe.com')
      .post('/v1/customers')
      .reply(200, {
        id: 'cus_test123',
        email: 'test@example.com',
        name: 'Test User',
        created: 1234567890,
      });

    const client = new StripeClient({ apiKey: 'sk_test_123' });
    const customer = await client.createCustomer({
      email: 'test@example.com',
      name: 'Test User',
    });

    expect(customer.id).toBe('cus_test123');
  });
});
```

---

## Best Practices

### 1. Always Use HTTPS
```typescript
// ✅ Good
baseURL: 'https://api.example.com'

// ❌ Bad
baseURL: 'http://api.example.com'
```

### 2. Set Timeouts
```typescript
axios.create({
  timeout: 30000, // 30 seconds
});
```

### 3. Use TypeScript
```typescript
// Define types for all API responses
interface User {
  id: string;
  email: string;
  name: string;
}

async function getUser(id: string): Promise<User> {
  const response = await axios.get<User>(`/users/${id}`);
  return response.data;
}
```

### 4. Handle Errors Properly
```typescript
try {
  await client.createUser(data);
} catch (error) {
  if (axios.isAxiosError(error)) {
    console.error('API error:', error.response?.data);
  } else {
    console.error('Unknown error:', error);
  }
}
```

### 5. Never Hardcode Secrets
```typescript
// ✅ Good
const apiKey = process.env.API_KEY;

// ❌ Bad
const apiKey = 'sk_live_abc123';
```

### 6. Log Requests (Development Only)
```typescript
if (process.env.NODE_ENV === 'development') {
  axios.interceptors.request.use((config) => {
    console.log(`${config.method?.toUpperCase()} ${config.url}`);
    return config;
  });
}
```

See main [SKILL.md](SKILL.md) for generation workflow and [examples.md](examples.md) for complete examples.
