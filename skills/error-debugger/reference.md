# Error Pattern Library

Comprehensive error patterns and solutions for common programming errors.

## JavaScript/TypeScript Errors

### Cannot read property 'X' of undefined

**Pattern**: `TypeError: Cannot read property 'X' of undefined`

**Root Cause**: Trying to access property on undefined/null object

**Common In**: API responses, component props, array operations

**Fix**:
```javascript
// ❌ Don't
const value = obj.nested.property;

// ✅ Do
const value = obj?.nested?.property || defaultValue;
```

**Prevention**: Always validate data structure before accessing

---

### X is not a function

**Pattern**: `TypeError: X is not a function`

**Root Cause**: Variable is not a function or function doesn't exist

**Common In**: Callbacks, async operations, event handlers

**Fix**:
```javascript
// ❌ Don't
callback();

// ✅ Do
if (typeof callback === 'function') {
  callback();
}
```

**Prevention**: Validate function exists before calling

---

### Cannot find module 'X'

**Pattern**: `Error: Cannot find module 'X'`

**Root Cause**: Missing dependency or wrong import path

**Common In**: Import statements, require calls

**Fix**:
```bash
# Install missing dependency
npm install X

# Or fix import path
import X from './correct/path/to/X';
```

**Prevention**: Check package.json for dependencies, verify import paths

---

## Network Errors

### ECONNREFUSED

**Pattern**: `Error: connect ECONNREFUSED 127.0.0.1:PORT`

**Root Cause**: Service not running or wrong port

**Common In**: Database connections, API calls, microservices

**Fix**:
```bash
# Check service is running
docker ps  # or
ps aux | grep service-name

# Verify port matches
echo $PORT  # check environment variable

# Restart service if needed
docker restart service-name
```

**Prevention**: Use environment variables for ports, add health checks

---

### CORS error

**Pattern**: `Access to fetch at 'X' from origin 'Y' has been blocked by CORS policy`

**Root Cause**: Cross-origin request blocked by browser

**Common In**: Frontend calling backend API

**Fix**:
```javascript
// Fix: Configure CORS (Express example)
const cors = require('cors');
app.use(cors({
  origin: ['http://localhost:3000'],
  credentials: true
}));

// Or use proxy in development
// package.json
{
  "proxy": "http://localhost:5000"
}
```

**Prevention**: Configure CORS early in development, whitelist origins

---

### Timeout errors

**Pattern**: `Error: Timeout of Xms exceeded`

**Root Cause**: Operation takes longer than allowed time

**Common In**: API calls, database queries, file operations

**Fix**:
```javascript
// ❌ Don't use default timeout
const response = await fetch(url);

// ✅ Increase timeout or add retry
const response = await fetch(url, {
  signal: AbortSignal.timeout(30000)  // 30 seconds
});

// Or add retry logic
const fetchWithRetry = async (url, retries = 3) => {
  for (let i = 0; i < retries; i++) {
    try {
      return await fetch(url, { signal: AbortSignal.timeout(10000) });
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(r => setTimeout(r, 1000 * (i + 1)));
    }
  }
};
```

**Prevention**: Set appropriate timeouts, implement retry logic, optimize slow operations

---

## Database Errors

### Connection refused

**Pattern**: `Error: Connection refused` or `ECONNREFUSED`

**Root Cause**: Database not running or wrong credentials

**Common In**: Database connections on app startup

**Fix**:
```bash
# Check database running
docker ps | grep postgres  # or mysql, mongodb, etc.

# Verify connection string
echo $DATABASE_URL

# Check credentials
psql -U username -d database  # for PostgreSQL

# Restart database if needed
docker restart database-container
```

**Prevention**: Use health checks, validate connection on startup, use connection pooling

---

### Syntax error in query

**Pattern**: SQL syntax error at or near "X"

**Root Cause**: Invalid SQL syntax

**Common In**: Raw SQL queries, string concatenation

**Fix**:
```javascript
// ❌ Don't use string concatenation
db.query(`SELECT * FROM users WHERE id = ${id}`);

// ✅ Use parameterized queries
db.query('SELECT * FROM users WHERE id = $1', [id]);

// Or use query builder
db('users').where({ id }).first();

// Or use ORM
await User.findOne({ where: { id } });
```

**Prevention**: Always use parameterized queries or ORM, never concatenate user input

---

### Unique constraint violation

**Pattern**: `duplicate key value violates unique constraint "X"`

**Root Cause**: Attempting to insert duplicate value in unique field

**Common In**: User registration, data import

**Fix**:
```javascript
// Check before insert
const existing = await db.users.findOne({ where: { email } });
if (existing) {
  throw new Error('Email already exists');
}
await db.users.create({ email });

// Or handle error
try {
  await db.users.create({ email });
} catch (error) {
  if (error.code === '23505') {  // PostgreSQL unique violation
    throw new Error('Email already exists');
  }
  throw error;
}
```

**Prevention**: Check for existence before insert, use upsert operations, handle constraint errors

---

## React Errors

### Too many re-renders

**Pattern**: `Error: Too many re-renders. React limits the number of renders to prevent an infinite loop.`

**Root Cause**: State update in render causing infinite loop

**Common In**: Event handlers, useEffect dependencies

**Fix**:
```javascript
// ❌ Don't set state in render
function Component() {
  const [count, setCount] = useState(0);
  setCount(count + 1);  // Infinite loop!
  return <div>{count}</div>;
}

// ✅ Use callbacks with stable references
function Component() {
  const [count, setCount] = useState(0);
  const handleClick = useCallback(() => {
    setCount(c => c + 1);
  }, []);  // Stable reference
  return <button onClick={handleClick}>{count}</button>;
}
```

**Prevention**: Never call setState in render, use useCallback for handlers, check useEffect dependencies

---

### Hook called conditionally

**Pattern**: `Error: Rendered more hooks than during the previous render`

**Root Cause**: Hooks called inside conditions, loops, or nested functions

**Common In**: Conditional logic before hooks

**Fix**:
```javascript
// ❌ Don't call hooks conditionally
function Component({ isLoggedIn }) {
  if (isLoggedIn) {
    const [user, setUser] = useState(null);  // Wrong!
  }
  return <div>Content</div>;
}

// ✅ Always call hooks at top level
function Component({ isLoggedIn }) {
  const [user, setUser] = useState(null);

  if (isLoggedIn) {
    // Use state here
  }

  return <div>Content</div>;
}
```

**Prevention**: Always call hooks at component top level, never inside conditions

---

### Cannot update component while rendering

**Pattern**: `Warning: Cannot update a component while rendering a different component`

**Root Cause**: State update during render phase

**Common In**: Passing setState to child components incorrectly

**Fix**:
```javascript
// ❌ Don't update parent state during render
function Child({ setParentState }) {
  setParentState(value);  // Wrong!
  return <div>Child</div>;
}

// ✅ Use useEffect for side effects
function Child({ setParentState, value }) {
  useEffect(() => {
    setParentState(value);
  }, [value, setParentState]);
  return <div>Child</div>;
}
```

**Prevention**: Use useEffect for side effects, don't call setState during render

---

## Additional Patterns

See main [SKILL.md](SKILL.md) for integration patterns and debugging workflow.

For real-world examples, see [examples.md](examples.md).
