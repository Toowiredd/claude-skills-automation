# Skill Conflict Resolution Guide

When multiple skills could handle a user request, use this decision tree.

## Conflict #1: browser-app-creator vs rapid-prototyper

**User says**: "create a [thing]"

### Decision Tree:
1. Does user mention "prototype", "quick", "test", "MVP"?
   → **Use rapid-prototyper**

2. Does user mention "app", "tool", "complete", "production"?
   → **Use browser-app-creator**

3. Does user want ADHD optimization, offline support?
   → **Use browser-app-creator**

4. Still ambiguous?
   → **Ask user**: "Would you like a complete app or quick prototype?"

### Examples:
- "create a quick prototype" → rapid-prototyper
- "create a habit tracker app" → browser-app-creator
- "create a prototype tracker" → ASK USER (ambiguous)

### Key Differentiators:

| Feature | browser-app-creator | rapid-prototyper |
|---------|---------------------|------------------|
| **Priority** | HIGH | MEDIUM |
| **Output** | Single polished HTML file | Minimal working code |
| **ADHD optimization** | Yes (60px+ buttons, auto-save) | No |
| **Offline support** | Yes (localStorage) | Maybe |
| **Polish** | Production-ready | Functional only |
| **Use case** | Complete tool to use daily | Test an idea quickly |

### Decision Examples:

**Scenario 1**: "Create a todo list"
- Analysis: "todo list" = app, no mention of prototype
- Decision: **browser-app-creator**

**Scenario 2**: "Create a quick prototype of a todo list"
- Analysis: "prototype" + "quick" = validation
- Decision: **rapid-prototyper**

**Scenario 3**: "Create a simple tracker"
- Analysis: "tracker" = app, "simple" is ambiguous
- Decision: **ASK USER** - "Would you like a complete tracker app or a quick prototype?"

## Conflict #2: repository-analyzer vs Explore agent

**User says**: "analyze this codebase"

### Decision Tree:
1. Does user want DOCUMENTATION saved to file?
   → **Use repository-analyzer**

2. Does user want to FIND specific code?
   → **Use Explore agent**

3. Does user want QUICK ANSWER?
   → **Use Explore agent**

4. Still ambiguous?
   → **Ask user**: "Do you want comprehensive documentation or answers to specific questions?"

### Examples:
- "analyze this repo and document it" → repository-analyzer
- "find all API endpoints" → Explore agent
- "understand this codebase" → repository-analyzer
- "where is the authentication code?" → Explore agent
- "how does the auth flow work?" → Explore agent

### Key Differentiators:

| Feature | repository-analyzer | Explore agent |
|---------|---------------------|---------------|
| **Priority** | MEDIUM | N/A (built-in tool) |
| **Output** | Comprehensive markdown file | Direct answers |
| **Use case** | Onboarding, documentation | Finding code, quick answers |
| **Time** | 1-5 minutes | Seconds |
| **Saves file** | Yes (artifacts) | No |

### Decision Examples:

**Scenario 1**: "Analyze this repository"
- Analysis: No specific question, "analyze" = comprehensive
- Decision: **repository-analyzer**

**Scenario 2**: "Find where user authentication is implemented"
- Analysis: Specific code search
- Decision: **Explore agent**

**Scenario 3**: "How does this codebase work?"
- Analysis: General understanding = documentation
- Decision: **repository-analyzer**

**Scenario 4**: "What framework is this using?"
- Analysis: Quick specific answer
- Decision: **Explore agent** (or just read package.json)

## General Guidelines

### When to Ask for Clarification:
- Multiple skills match with equal priority
- User's intent is genuinely ambiguous
- Context doesn't provide clear hints
- Keywords from both skills are present

### What NOT to Do:
- Don't use both skills simultaneously
- Don't guess if truly ambiguous
- Don't default to higher priority without reason
- Don't over-analyze simple requests

### Clarification Prompt Templates:

**For app vs prototype conflict**:
```
I can help you with that! Would you like:
1. A complete, polished app (ADHD-optimized, offline-ready)
2. A quick prototype to test the idea

Which would you prefer?
```

**For analyze vs explore conflict**:
```
I can help you with that! Would you like:
1. Comprehensive documentation of the entire codebase (saved as markdown)
2. Quick answers to specific questions about the code

Which would be more useful?
```

## Additional Conflicts

### browser-app-creator vs rapid-prototyper: Edge Cases

**User says: "Create a dashboard"**
- Default: **browser-app-creator** (dashboards are typically complete apps)
- Unless: User adds "quick" or "prototype"

**User says: "Build something to track my habits"**
- Default: **browser-app-creator** (tracking = persistent data = complete app)
- Unless: User says "test if this would work"

**User says: "Make a simple form"**
- Ambiguous: "simple" could mean minimal prototype OR simple complete app
- Decision: **ASK USER**

### Priority Override Rules

**Priority does NOT always win**:
- HIGH priority skill is NOT always chosen
- Choose based on user intent, not just priority
- Priority only matters when intent is equally matched

**Example**: User says "quick prototype dashboard"
- browser-app-creator = HIGH priority
- rapid-prototyper = MEDIUM priority
- But "quick prototype" = clear intent
- **Decision: rapid-prototyper** (intent overrides priority)

## Conflict Resolution Flowchart

```
User Request
    |
    v
Parse keywords and intent
    |
    v
Single skill matches? --> YES --> Use that skill
    |
    NO
    v
Multiple skills match?
    |
    v
Intent clearly favors one? --> YES --> Use that skill
    |
    NO
    v
Context provides clues? --> YES --> Use context to decide
    |
    NO
    v
Ask user for clarification
```

## Common Keywords Reference

### browser-app-creator keywords:
- app, tool, dashboard, tracker, calculator
- complete, polished, production
- ADHD, offline, downloadable
- dark mode, auto-save

### rapid-prototyper keywords:
- prototype, MVP, proof of concept
- quick, fast, simple, basic
- test, validate, demo
- idea, experiment

### repository-analyzer keywords:
- analyze, document, understand
- repository, codebase, project
- structure, architecture, patterns
- technical debt, overview

### Explore agent keywords:
- find, where, locate, search
- how does [specific thing] work
- show me [specific code]
- what is [specific detail]

## Testing Your Decision

Before invoking a skill, ask yourself:

1. **What does the user ultimately want?**
   - A tool to use? → browser-app-creator
   - To test an idea? → rapid-prototyper
   - Documentation? → repository-analyzer
   - Specific code? → Explore agent

2. **What's the time expectation?**
   - "Quick" = rapid-prototyper or Explore agent
   - "Complete" = browser-app-creator or repository-analyzer

3. **What's the output format?**
   - Saved file? → browser-app-creator or repository-analyzer
   - Direct response? → rapid-prototyper or Explore agent

4. **When in doubt, ASK!**
   - Better to clarify than deliver wrong solution
   - Users appreciate being asked
   - Shows attention to their needs

## Success Metrics

A good conflict resolution:
- Delivers what user actually wanted
- Doesn't require rework
- Feels natural and intuitive
- User doesn't notice the decision was made

A bad conflict resolution:
- User says "no, I wanted [other thing]"
- Requires switching to different skill
- Wastes user's time
- Breaks flow

## Summary

**Golden Rule**: User intent > Keywords > Priority

1. Listen to user's intent first
2. Look for explicit keywords second
3. Consider priority last
4. When ambiguous, ask for clarification

**Remember**: These skills complement each other. Sometimes the best solution is to use one skill, then offer the other:
- "I created a quick prototype. Would you like me to build the full app?"
- "I analyzed the repository. Would you like me to find specific code?"
