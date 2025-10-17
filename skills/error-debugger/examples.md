# Debugging Workflow Examples

Step-by-step debugging scenarios showing the error-debugger skill in action.

## Example 1: Simple TypeError

### Scenario

User is getting a TypeError when rendering a user list component.

---

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

The test verifies:
- Component handles undefined data gracefully
- Component handles empty array
- Component works with valid data

Test output:
✅ renders with undefined data
✅ renders with empty array
✅ renders with valid user data
```

### Key Takeaways

- Past solution was found instantly (< 2 seconds)
- User confirmed application without needing explanation
- Regression test auto-generated prevents future occurrences
- Solution saved for next time it happens

---

## Example 2: New Error Pattern

### Scenario

User encounters a DNS resolution error for the first time.

---

**User**: "Error: ENOTFOUND api.example.com"

**Debugger**:
```
🆕 New error pattern

**Type**: DNS resolution failure
**Error Code**: ENOTFOUND
**Cause**: Cannot resolve hostname api.example.com

**Possible causes**:
1. Typo in hostname
2. Service is down
3. Network connectivity issue
4. DNS server problem

**Troubleshooting steps**:
1. Check hostname spelling in your code
2. Ping the hostname: `ping api.example.com`
3. Check if service is accessible: `curl -I https://api.example.com`
4. Verify network: `ping 8.8.8.8`

What's the result of these checks?
```

**User**: "typo - should be api.myapp.com"

**Debugger**:
```
✅ Root cause identified: Hostname typo

**Location**: Let me search your codebase for "api.example.com"...

Found in:
- src/config/api.js:5
- .env.example:2

**Fix**: Update API endpoint

```javascript
// ❌ Wrong (src/config/api.js:5)
const API_URL = 'https://api.example.com';

// ✅ Correct
const API_URL = 'https://api.myapp.com';
```

```bash
# ❌ Wrong (.env.example:2)
API_URL=https://api.example.com

# ✅ Correct
API_URL=https://api.myapp.com
```

Would you like me to apply these changes?
```

**User**: "yes"

**Debugger**:
```
✅ Changes applied to 2 files

💾 Saving solution to memory...

**Memory saved**: PROCEDURE - Fix DNS ENOTFOUND errors
Tags: error, network, dns, api

🧪 Creating test to verify API endpoint...

**Test created**: tests/api/connection.test.js
```javascript
describe('API Connection', () => {
  it('uses correct API endpoint', () => {
    expect(API_URL).toBe('https://api.myapp.com');
    expect(API_URL).not.toContain('example.com');
  });

  it('can resolve API hostname', async () => {
    const url = new URL(API_URL);
    // Verify hostname is resolvable
    await expect(fetch(API_URL, { method: 'HEAD' })).resolves.toBeDefined();
  });
});
```

**Next time** you get ENOTFOUND, I'll remember to check for typos first!
```

### Key Takeaways

- Unknown error → systematic troubleshooting
- User provided key info (typo)
- Multiple files updated at once
- Test prevents hostname typos in future
- Solution saved for pattern recognition

---

## Example 3: Complex Server Error

### Scenario

User getting 500 error from API endpoint, needs deeper investigation.

---

**User**: "Getting 500 error from /api/users endpoint"

**Debugger**:
```
🔍 500 Internal Server Error - need more information

**What I need**:
1. Server logs (most recent error)
2. Request payload
3. Database connection status

500 errors are server-side, so I need to see what's happening on the backend.

Can you provide server logs?
```

**User**: [pastes logs]
```
Error: syntax error at or near "name"
  at Connection.parseE (/app/node_modules/pg/lib/connection.js:614:13)
  at Connection.parseMessage (/app/node_modules/pg/lib/connection.js:413:19)
Query: SELECT id name email FROM users WHERE active = true
```

**Debugger**:
```
✅ Found root cause: SQL syntax error in query

**Error**: Invalid SQL syntax - missing commas in column list
**Location**: Based on stack trace, checking src/api/users.js...

Found the issue at src/api/users.js:42:

```javascript
// ❌ Current (line 42)
const query = `
  SELECT id name email
  FROM users
  WHERE active = true
`;
```

**Problem**: Missing commas between column names in SELECT statement

**Fix**:
```javascript
// ✅ Corrected
const query = `
  SELECT id, name, email
  FROM users
  WHERE active = true
`;
```

**Prevention**: This is a common error with raw SQL queries.

**Recommendations**:
1. Use a query builder (knex.js) or ORM (Prisma, TypeORM)
2. If using raw SQL, use parameterized queries
3. Add SQL linting to your editor

Would you like me to:
a) Apply the fix now
b) Refactor to use a query builder
c) Both
```

**User**: "c - both"

**Debugger**:
```
✅ Excellent choice! This will prevent future SQL syntax errors.

**Step 1**: Applying immediate fix to src/api/users.js:42
✅ Done

**Step 2**: Refactoring to use query builder

I'll use Prisma since it's type-safe and prevents SQL injection.

First, let me check if Prisma is already installed...
Found package.json but no Prisma dependency.

**Installation needed**:
```bash
npm install @prisma/client
npm install --save-dev prisma
```

**Setting up Prisma**:
```bash
npx prisma init
```

**Refactored code** (src/api/users.js):
```javascript
// ❌ Old way
const { rows } = await db.query(`
  SELECT id, name, email
  FROM users
  WHERE active = true
`);

// ✅ New way with Prisma
const users = await prisma.user.findMany({
  where: { active: true },
  select: { id: true, name: true, email: true }
});
```

**Benefits**:
- ✅ Type safety (compile-time error checking)
- ✅ No SQL injection vulnerabilities
- ✅ Auto-completion in your editor
- ✅ Automatic migrations
- ✅ No syntax errors

Would you like me to:
1. Create the Prisma schema
2. Set up the migration
3. Refactor all your SQL queries to Prisma
```

**User**: "yes, all of it"

**Debugger**:
```
🚀 Refactoring to Prisma...

**Created**: prisma/schema.prisma
**Migrated**: 5 database tables
**Refactored**: 12 SQL queries across 4 files

💾 Saving comprehensive solution to memory...

**Memory saved**: PROCEDURE - Migrating raw SQL to Prisma ORM
Tags: database, sql, prisma, refactoring, best-practices

🧪 Creating integration tests...

**Test created**: tests/api/users.integration.test.js
- Tests user retrieval
- Tests data integrity
- Tests error handling

**Summary**:
✅ Immediate fix applied
✅ Long-term solution implemented
✅ 12 SQL queries refactored
✅ Type safety added
✅ Tests created

**Time saved in future**: ~2 hours (preventing similar errors)

This refactoring prevents an entire class of errors:
- SQL syntax errors
- SQL injection vulnerabilities
- Type mismatches
- Missing migrations
```

### Key Takeaways

- Complex error required systematic investigation
- Debugger asked for specific information (logs)
- Immediate fix + long-term solution offered
- User chose comprehensive approach
- Complete refactoring with migration
- Future errors prevented at architectural level

---

## Example 4: Using Tool Persistence Pattern

### Scenario

Error occurs where multiple debugging approaches are needed.

---

**User**: "Getting auth error when pushing to GitHub"

**Debugger**:
```
🔍 Authentication error with GitHub

Following tool persistence pattern - trying 3 approaches:

**Approach 1**: Checking local Git credentials...
```

```bash
git config user.name
git config user.email
```

```
✅ Git credentials configured:
- Name: toowiredd
- Email: lewistys420@gmail.com

**Approach 2**: Checking GitHub CLI authentication...
```

```bash
gh auth status
```

```
✅ GitHub CLI is authenticated!
- Logged in to github.com as toowiredd
- Token: gho_**** (valid)
- Protocol: https

**Approach 3**: Not needed - found the solution!

**Root cause**: You're using HTTPS but might need SSH, or token expired.

Since `gh` CLI is authenticated, let's use it instead:

```bash
# Instead of manual git push
gh repo view  # Verify repo access
git push origin main  # This should work now
```

If still getting errors, try:
```bash
gh auth refresh  # Refresh token
```

✅ This follows our "try 3 approaches" principle.
❌ OLD me would have given up after the first git config check.
✅ NEW me persisted and found `gh` CLI works!
```

### Key Takeaways

- Multiple approaches tried systematically
- Each approach provided useful information
- Solution found on second approach
- Meta-learning principle applied successfully
- Explicit acknowledgment of improvement from past mistakes

---

## Pattern Recognition

After these examples, the error-debugger has learned:

| Error Type | Recognition | Auto-Fix Available |
|------------|-------------|-------------------|
| TypeError (undefined.map) | Instant | ✅ Yes |
| DNS ENOTFOUND | Instant | ⚠️ With confirmation |
| SQL Syntax | Fast (5s) | ✅ Yes + refactor option |
| Git Auth | Systematic | ✅ Yes (tool hierarchy) |

**Future behaviors**:
- Similar TypeErrors → instant fix (80%+ success rate remembered)
- DNS errors → check for typos first
- SQL errors → suggest ORM migration
- Auth errors → try 3 tools before giving up

See main [SKILL.md](SKILL.md) for complete debugging workflow.
See [reference.md](reference.md) for error pattern library.
