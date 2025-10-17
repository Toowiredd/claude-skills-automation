---
name: error-debugger
description: Analyzes errors, searches past solutions in memory, provides immediate fixes with code examples, and saves solutions for future reference. Use when user says "debug this", "fix this error", "why is this failing", or when error messages appear like TypeError, ECONNREFUSED, CORS, 404, 500, etc.
---

# Error Debugger

## Purpose

Context-aware debugging that learns from past solutions. When an error occurs:
1. Searches memory for similar past errors
2. Analyzes error message and stack trace
3. Provides immediate fix with code examples
4. Creates regression test via testing-builder
5. Saves solution to memory for future

**For ADHD users**: Eliminates debugging frustration - instant, actionable fixes.
**For SDAM users**: Recalls past solutions you've already found.
**For all users**: Gets smarter over time as it learns from your codebase.

## Activation Triggers

- User says: "debug this", "fix this error", "why is this failing"
- Error messages containing: TypeError, ReferenceError, SyntaxError, ECONNREFUSED, CORS, 404, 500, etc.
- Stack traces pasted into conversation
- "Something's broken" or similar expressions

## Core Workflow

### 1. Parse Error

Extract key information:

```javascript
{
  error_type: "TypeError|ReferenceError|ECONNREFUSED|...",
  message: "Cannot read property 'map' of undefined",
  stack_trace: [...],
  file: "src/components/UserList.jsx",
  line: 42,
  context: "Rendering user list"
}
```

### 2. Search Past Solutions

Query context-manager:

```
search memories for:
- error_type match
- similar message (fuzzy match)
- same file/component if available
- related tags (if previously tagged)
```

**If match found**:
```
🔍 Found similar past error!

📝 3 months ago: TypeError in UserList component
✅ Solution: Added null check before map
⏱️ Fixed in: 5 minutes
🔗 Memory: procedures/{uuid}.md

Applying the same solution...
```

**If no match**:
```
🆕 New error - analyzing...
(Will save solution after fix)
```

### 3. Analyze Error

**Common patterns**:

**TypeError: Cannot read property 'X' of undefined**
- Root cause: Trying to access property on undefined/null
- Common in: API responses, component props, array operations
- Fix pattern: Add null checks, optional chaining, default values

**ECONNREFUSED**
- Root cause: Service not running or wrong port
- Common in: Database connections, API calls, microservices
- Fix pattern: Check service status, verify ports, check environment variables

**CORS errors**
- Root cause: Cross-origin request blocked
- Common in: Frontend calling backend API
- Fix pattern: Configure CORS headers, use proxy, check origin whitelist

**404 Not Found**
- Root cause: Route doesn't exist or incorrect path
- Common in: API endpoints, file paths, routing
- Fix pattern: Verify route definition, check path spelling, review route order

**500 Internal Server Error**
- Root cause: Unhandled exception in server code
- Common in: API endpoints, database queries, file operations
- Fix pattern: Check server logs, add error handling, verify inputs

### 4. Provide Fix

**Format**:
```
🔧 Error Analysis

**Type**: {error_type}
**Location**: {file}:{line}
**Cause**: {root_cause_explanation}

**Fix**:

{before_code}
```javascript
// ❌ Current code
const users = data.users;
return users.map(user => <div>{user.name}</div>);
```

{after_code}
```javascript
// ✅ Fixed code
const users = data?.users || [];
return users.map(user => <div>{user.name}</div>);
```

**Explanation**: Added optional chaining and default empty array to handle case where data or data.users is undefined.

**Prevention**: Always validate API response structure before using.

**Next steps**:
1. Apply the fix
2. Test manually
3. I'll create a regression test
```

### 5. Save Solution

After fix confirmed working:

```bash
# Save to context-manager as PROCEDURE
remember: Fix for TypeError in map operations
Type: PROCEDURE
Tags: error, typescript, array-operations
Content: When getting "Cannot read property 'map' of undefined",
         add optional chaining and default empty array:
         data?.users || []
```

**Memory structure**:
```markdown
# PROCEDURE: Fix TypeError in map operations

**Error Type**: TypeError
**Message Pattern**: Cannot read property 'map' of undefined
**Context**: Array operations on potentially undefined data

## Solution

Use optional chaining and default values:

```javascript
// Before
const items = data.items;
return items.map(...)

// After
const items = data?.items || [];
return items.map(...)
```

## When to Apply

- API responses that might be undefined
- Props that might not be passed
- Array operations on uncertain data

## Tested

✅ Fixed in UserList component (2025-10-17)
✅ Regression test: tests/components/UserList.test.jsx

## Tags

error, typescript, array-operations, undefined-handling
```

### 6. Create Regression Test

Automatically invoke testing-builder:

```
create regression test for this fix:
- Test that component handles undefined data
- Test that component handles empty array
- Test that component works with valid data
```

## Error Pattern Library

### JavaScript/TypeScript Errors

**Cannot read property 'X' of undefined**
```javascript
// Fix: Optional chaining + defaults
const value = obj?.nested?.property || defaultValue;
```

**X is not a function**
```javascript
// Fix: Validate function exists
if (typeof callback === 'function') {
  callback();
}
```

**Cannot find module 'X'**
```bash
# Fix: Install dependency
npm install X
# Or fix import path
import X from './correct/path/to/X';
```

### Network Errors

**ECONNREFUSED**
```bash
# Fix: Check service is running
docker ps  # or
ps aux | grep service-name
# Verify port matches
echo $PORT  # check environment variable
```

**CORS error**
```javascript
// Fix: Configure CORS (Express example)
const cors = require('cors');
app.use(cors({
  origin: ['http://localhost:3000'],
  credentials: true
}));
```

**Timeout errors**
```javascript
// Fix: Increase timeout or add retry
const response = await fetch(url, {
  signal: AbortSignal.timeout(30000)  // 30 seconds
});
```

### Database Errors

**Connection refused**
```bash
# Fix: Check database running and credentials
docker ps | grep postgres
# Verify connection string
echo $DATABASE_URL
```

**Syntax error in query**
```javascript
// Fix: Use parameterized queries
// ❌ Don't
db.query(`SELECT * FROM users WHERE id = ${id}`);
// ✅ Do
db.query('SELECT * FROM users WHERE id = $1', [id]);
```

**Unique constraint violation**
```javascript
// Fix: Check before insert or handle error
try {
  await db.users.create({ email });
} catch (error) {
  if (error.code === '23505') {  // Unique violation
    throw new Error('Email already exists');
  }
  throw error;
}
```

### React Errors

**Too many re-renders**
```javascript
// Fix: Move handler to useCallback or fix dependency
const handleClick = useCallback(() => {
  setCount(c => c + 1);
}, []);  // Stable reference
```

**Hook called conditionally**
```javascript
// ❌ Don't
if (condition) {
  useState(...);
}
// ✅ Do
const [state, setState] = useState(...);
if (condition) {
  // Use state here
}
```

**Cannot update component while rendering**
```javascript
// Fix: Use useEffect for side effects
useEffect(() => {
  setParentState(value);
}, [value]);
```

## Context Integration

### Query Past Solutions

Before analyzing new error:

```javascript
// Search context-manager
const pastSolutions = searchMemories({
  type: 'PROCEDURE',
  tags: [errorType, language, framework],
  content: errorMessage,
  fuzzyMatch: true
});

if (pastSolutions.length > 0) {
  // Show user the past solution
  // Ask if they want to apply it
  // If yes, apply and test
  // If no, analyze fresh
}
```

### Learning Over Time

Track which solutions work:

```javascript
{
  solution_id: "uuid",
  error_pattern: "TypeError.*map.*undefined",
  times_applied: 5,
  success_rate: 100%,
  last_used: "2025-10-15",
  avg_fix_time: "2 minutes"
}
```

Sort solutions by success rate when multiple matches found.

### Project-Specific Patterns

Some errors are project-specific:

```javascript
// BOOSTBOX-specific
Error: "Boost ID not found"
→ Solution: Check boost exists before processing

// Tool Hub-specific
Error: "Tool not installed"
→ Solution: Run tool installer first

// Save these as PROJECT-specific procedures
```

## Integration with Other Skills

### Testing Builder

After providing fix:
```
Automatically invoke: testing-builder
Create regression test for: {error_scenario}
Ensure test fails without fix, passes with fix
```

### Context Manager

Query for similar errors:
```
search memories for:
- PROCEDURE type
- Error tag
- Similar message
- Same file/component
```

Save new solutions:
```
Save as PROCEDURE:
- Error pattern
- Solution
- Code examples
- Tested timestamp
```

### Rapid Prototyper

For complex fixes:
```
If fix requires significant refactoring:
→ Invoke rapid-prototyper
→ Create isolated example showing fix
→ User validates before applying to codebase
```

## Debugging Workflow Examples

### Example 1: Simple TypeError

**User**: "Getting error: Cannot read property 'map' of undefined"

**Debugger**:
```
🔍 Searching past solutions...
✅ Found solution from 2 weeks ago!

This is a common pattern in your codebase. You've fixed this 3 times before:

**Solution**: Add optional chaining and default array
```javascript
const items = data?.items || [];
return items.map(item => ...)
```

Apply this fix? (yes/no)
```

**User**: "yes"

**Debugger**:
```
✅ Fix applied
🧪 Creating regression test...
📝 Solution saved to memory

**Regression test**: tests/components/ItemList.test.jsx
```

### Example 2: New Error

**User**: "Error: ENOTFOUND api.example.com"

**Debugger**:
```
🆕 New error pattern

**Type**: DNS resolution failure
**Cause**: Cannot resolve hostname api.example.com

**Possible causes**:
1. Typo in hostname
2. Service is down
3. Network connectivity issue
4. DNS server problem

**Troubleshooting steps**:
1. Check hostname spelling
2. Ping the hostname: `ping api.example.com`
3. Check if service is accessible: `curl -I https://api.example.com`
4. Verify network: `ping 8.8.8.8`

What's the result of these checks?
```

**User**: "typo - should be api.myapp.com"

**Debugger**:
```
✅ Root cause: Hostname typo

**Fix**: Update API endpoint
```javascript
// ❌ Wrong
const API_URL = 'https://api.example.com';

// ✅ Correct
const API_URL = 'https://api.myapp.com';
```

💾 Saving solution...
🧪 Creating test to verify API endpoint...

**Test created**: tests/api/connection.test.js
(Verifies correct hostname is used)
```

### Example 3: Complex Error

**User**: "Getting 500 error from /api/users endpoint"

**Debugger**:
```
🔍 500 Internal Server Error - need more info

**What I need**:
1. Server logs (most recent error)
2. Request payload
3. Database connection status

Can you provide server logs?
```

**User**: [pastes logs showing SQL syntax error]

**Debugger**:
```
✅ Found root cause: SQL syntax error in query

**Error**: Invalid SQL syntax - missing comma in column list

**Location**: src/api/users.js:42

**Fix**:
```javascript
// ❌ Current
const query = `
  SELECT id name email
  FROM users
  WHERE active = true
`;

// ✅ Fixed
const query = `
  SELECT id, name, email
  FROM users
  WHERE active = true
`;
```

**Prevention**: Use query builder or ORM to avoid SQL syntax errors

**Recommended**: Switch to parameterized queries with a library like `pg` or use an ORM like Prisma

💾 Saving solution...
🧪 Creating API test...
```

## Quick Reference

### Common Error Patterns

| Error | Quick Fix |
|-------|-----------|
| `undefined.map` | `data?.array || []` |
| `X is not a function` | Check function exists |
| `ECONNREFUSED` | Check service running |
| `CORS` | Configure CORS headers |
| `404` | Verify route exists |
| `500` | Check server logs |
| `Timeout` | Increase timeout value |
| `Cannot find module` | Install dependency |

### Trigger Phrases

- "debug this"
- "fix this error"
- "why is this failing"
- "something's broken"
- [paste error message]
- [paste stack trace]

### File Locations

- **Past solutions**: `/home/toowired/.claude-memories/procedures/`
- **Error patterns**: Tagged with "error" in memory index

### Success Criteria

✅ Common errors fixed instantly (<30 seconds)
✅ Past solutions automatically recalled
✅ All fixes include code examples
✅ Regression tests created automatically
✅ Solutions saved for future reference
✅ Debugging gets faster over time
