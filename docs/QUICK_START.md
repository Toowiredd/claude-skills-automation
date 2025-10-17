# Claude Skills - Quick Start Guide

**Version:** 1.0.0
**For:** Neurodivergent developers (ADHD, SDAM, aphantasia optimized)
**Setup Time:** < 5 minutes
**First Results:** < 60 seconds

---

## 🚀 INSTANT START (30 seconds)

### Step 1: Say "hi-ai"
```
hi-ai
```

That's it. SESSION_LAUNCHER activates and:
- ✅ Searches your past conversations
- ✅ Loads your saved memories
- ✅ Restores your previous session
- ✅ Shows you a visual dashboard
- ✅ Makes you immediately productive

**Result:** Zero context loss, instant continuation

---

## 💾 MEMORY SETUP (Optional but Recommended)

Your memory storage is already set up at:
```
/home/toowired/.claude-memories/
```

To verify it's working, try:
```
remember we're using React for the frontend
```

Check your memory:
```bash
cat /home/toowired/.claude-memories/index.json
```

You should see your decision saved!

---

## 🎯 COMMON WORKFLOWS

### Workflow 1: Daily Development

**Morning:**
```
hi-ai
```
→ SESSION_LAUNCHER restores everything from yesterday

**Making Decisions:**
```
remember we're using PostgreSQL not MongoDB
```
→ MEMORY_MANAGER saves it permanently

**Creating Tools:**
```
create a task tracker app
```
→ BROWSER_APP_CREATOR generates complete HTML app

**Automating:**
```
automate the backup process
```
→ AUTOMATION_SCRIPTER creates production script

---

### Workflow 2: Bug Fixing

**When Error Occurs:**
```
debug this: TypeError: Cannot read property 'map' of undefined
```

**What Happens:**
1. ERROR_DEBUGGER analyzes the error
2. Searches MEMORY_MANAGER for similar past issues
3. Provides immediate fix with code
4. TESTING_BUILDER creates regression test
5. MEMORY_MANAGER saves solution for future

**Result:** Bug fixed, tested, and memorized in < 5 minutes

---

### Workflow 3: Feature Development

**Request Feature:**
```
add user authentication with JWT
```

**What Happens:**
1. RAPID_PROTOTYPER creates working prototype
2. You review: "Looks good, build it properly"
3. API_INTEGRATION_BUILDER makes production version
4. TESTING_BUILDER generates comprehensive tests
5. CODE_QUALITY_AUDITOR reviews code
6. DEPLOYMENT_ORCHESTRATOR deploys it
7. DOCUMENTATION_GENERATOR creates docs
8. MEMORY_MANAGER saves all decisions

**Result:** Feature fully implemented, tested, deployed, documented

---

### Workflow 4: Code Review

**Review Code:**
```
review this code for quality
```

**What Happens:**
1. CODE_QUALITY_AUDITOR analyzes code
2. Identifies smells and complexity issues
3. Provides refactoring suggestions
4. TESTING_BUILDER adds missing tests
5. DOCUMENTATION_GENERATOR updates docs

**Result:** High-quality, well-tested, documented code

---

## 🔧 SKILL ACTIVATION CHEAT SHEET

### Critical Skills (Use Daily)

| Say This | Skill Activates | Result |
|----------|----------------|--------|
| `hi-ai` | SESSION_LAUNCHER | Context restored |
| `remember [X]` | MEMORY_MANAGER | Saved permanently |
| `create [tool]` | BROWSER_APP_CREATOR | Working app generated |

### Development Skills

| Say This | Skill Activates | Result |
|----------|----------------|--------|
| `debug this` | ERROR_DEBUGGER | Error analyzed + fixed |
| `write tests` | TESTING_BUILDER | Test suite generated |
| `automate [task]` | AUTOMATION_SCRIPTER | Script created |
| `prototype [idea]` | RAPID_PROTOTYPER | Working prototype |
| `review code` | CODE_QUALITY_AUDITOR | Quality report |

### Deployment Skills

| Say This | Skill Activates | Result |
|----------|----------------|--------|
| `deploy to production` | DEPLOYMENT_ORCHESTRATOR | Full CI/CD pipeline |
| `integrate [API]` | API_INTEGRATION_BUILDER | API client generated |
| `analyze codebase` | REPOSITORY_ANALYZER | Complete analysis |
| `document this` | DOCUMENTATION_GENERATOR | Docs created |

### Specialized Skills

| Say This | Skill Activates | Result |
|----------|----------------|--------|
| `build MCP server` | MCP_SERVER_BUILDER | MCP server generated |
| `optimize desktop` | LINUX_DESKTOP_OPTIMIZER | Workspace optimized |

---

## 📁 FILE SYSTEM GUIDE

Everything is organized in your home directory:

```
/home/toowired/
├── .claude-memories/              # Your permanent memory
│   ├── index.json                 # Memory index
│   ├── decisions/                 # Architecture decisions
│   ├── blockers/                  # Current obstacles
│   ├── procedures/                # How-to procedures
│   └── sessions/                  # Session history
│
├── .claude-artifacts/             # Generated outputs
│   ├── browser-apps/             # Web apps created
│   ├── scripts/                  # Automation scripts
│   ├── tests/                    # Test suites
│   ├── docs/                     # Documentation
│   └── debug-reports/            # Debug analyses
│
└── .claude-sessions/              # Active sessions
    └── current.json              # Current state
```

### Quick Commands

**View your memories:**
```bash
cat /home/toowired/.claude-memories/index.json | jq .
```

**See recent outputs:**
```bash
ls -lt /home/toowired/.claude-artifacts/
```

**Check session state:**
```bash
cat /home/toowired/.claude-sessions/current.json
```

---

## 🎯 TIPS FOR SUCCESS

### For ADHD Users

1. **Start every session with "hi-ai"**
   - Eliminates "where was I?" anxiety
   - Immediate context = immediate action

2. **Use "remember" liberally**
   - No need to remember anything yourself
   - Let MEMORY_MANAGER handle it

3. **Create visual tools for tracking**
   - "create a habit tracker"
   - "create a task dashboard"
   - External visual = executive function support

### For SDAM Users (No Episodic Memory)

1. **Trust the memory system**
   - SESSION_LAUNCHER restores EVERYTHING
   - MEMORY_MANAGER remembers ALL decisions
   - You never have to remember "what we decided"

2. **Time-anchor everything**
   - All memories include timestamps
   - "what did we decide about the database?" → Gets full context with dates

3. **Review dashboards**
   - Visual summaries of all past work
   - No reliance on personal memory

### For Time-Blind Users (Dyschronometria)

1. **Trust the timestamps**
   - Every memory shows "3 days ago"
   - Every action shows "Last worked: Tuesday"
   - External time tracking built-in

2. **Use automation for scheduling**
   - "automate daily backups"
   - Scripts handle timing for you

### For Aphantasia Users

1. **Always request visual outputs**
   - "create a dashboard" → Get actual interface
   - "show me the architecture" → Get diagram
   - Never just descriptions, always concrete results

2. **Use BROWSER_APP_CREATOR often**
   - Makes abstract concepts tangible
   - Visual interfaces for everything

---

## 🔄 INTEGRATION EXAMPLES

### Example 1: Complete Bug Fix

**You:** "Getting 'Connection refused' error"

**Skills Activate:**
```
ERROR_DEBUGGER analyzes
    ↓
MEMORY_MANAGER checks past issues
    ↓
CODE_QUALITY_AUDITOR reviews related code
    ↓
RAPID_PROTOTYPER creates fix
    ↓
TESTING_BUILDER generates test
    ↓
MEMORY_MANAGER saves solution
```

**Result:** Fixed, tested, memorized for future

---

### Example 2: New Feature

**You:** "Add user authentication"

**Skills Activate:**
```
MEMORY_MANAGER checks auth decisions
    ↓
RAPID_PROTOTYPER creates prototype
    ↓
[You approve]
    ↓
API_INTEGRATION_BUILDER makes production version
    ↓
TESTING_BUILDER creates test suite
    ↓
CODE_QUALITY_AUDITOR reviews
    ↓
DEPLOYMENT_ORCHESTRATOR deploys
    ↓
DOCUMENTATION_GENERATOR creates docs
    ↓
MEMORY_MANAGER records everything
```

**Result:** Feature complete, end-to-end

---

### Example 3: Context Switch

**You:** "hi-ai, let's work on BOOSTBOX"

**Skills Activate:**
```
SESSION_LAUNCHER saves current project
    ↓
MEMORY_MANAGER loads BOOSTBOX memories
    ↓
REPOSITORY_ANALYZER scans BOOSTBOX code
    ↓
BROWSER_APP_CREATOR generates dashboard
```

**Result:** Instant context switch, zero loss

---

## ⚠️ TROUBLESHOOTING

### Skills Not Activating?

**Problem:** Skill doesn't respond to trigger phrase

**Solutions:**
1. Be more specific: "create a React app" vs "create app"
2. Use alternative triggers: "debug this" vs "fix this"
3. Mention skill explicitly: "use BROWSER_APP_CREATOR to..."

### Memory Not Working?

**Problem:** Memories not being saved or recalled

**Check:**
```bash
# Verify memory directory exists
ls -la /home/toowired/.claude-memories/

# Check index
cat /home/toowired/.claude-memories/index.json

# Check permissions
ls -ld /home/toowired/.claude-memories/
```

**Fix:** Should be writable by your user

### Context Not Restoring?

**Problem:** "hi-ai" doesn't restore context

**Solutions:**
1. Use "hi-ai" explicitly (not just "hi")
2. Check `/home/toowired/.claude-sessions/current.json`
3. Mention project name: "hi-ai, continue with BOOSTBOX"

---

## 🎓 ADVANCED USAGE

### Combining Skills

You can activate multiple skills in one request:

```
debug this error, create tests, and document the fix
```

**Result:**
- ERROR_DEBUGGER fixes bug
- TESTING_BUILDER creates tests
- DOCUMENTATION_GENERATOR updates docs

### Custom Workflows

Save custom workflows as procedures:

```
remember: my deployment workflow is:
1. run tests with TESTING_BUILDER
2. review code with CODE_QUALITY_AUDITOR
3. deploy with DEPLOYMENT_ORCHESTRATOR
4. document with DOCUMENTATION_GENERATOR
```

Now just say:
```
run my deployment workflow
```

---

## 📊 SUCCESS METRICS

You'll know the skills are working when:

✅ **"hi-ai" instantly restores context** - No explaining needed
✅ **Memories are recalled automatically** - No manual searching
✅ **Tools are generated in seconds** - Working apps immediately
✅ **Bugs are fixed with examples** - Copy-paste solutions
✅ **Tests are created automatically** - No testing friction
✅ **Deployment is one command** - No multi-step procedures

---

## 🎉 YOU'RE READY!

That's it! You now have a complete, integrated development environment optimized for your neurodivergent cognitive style.

**Start your first session:**
```
hi-ai
```

**Or jump straight to building:**
```
create a pomodoro timer
```

**Or save something important:**
```
remember we're using Tailwind CSS for styling
```

---

## 📚 FURTHER READING

- **SKILL_INTEGRATION_MAP.md** - Complete integration details
- **README.md** - Full skill reference
- **Individual SKILL.md files** - Deep dives into each skill

---

## 💡 PRO TIPS

### 1. Morning Routine
```bash
# Start every day
hi-ai

# Review yesterday's decisions
what did we decide yesterday?

# Check blockers
any blockers?
```

### 2. End of Day
```bash
# Save important work
remember today we implemented user auth

# Create next-day context
remember tomorrow: finish deployment testing

# Session will auto-save
```

### 3. Project Switch
```bash
# Instant context switch
hi-ai, let's work on [project-name]

# System handles everything
# No manual state management
```

---

**Your neurodivergent-optimized development environment is ready. Say "hi-ai" and start building!** 🚀
