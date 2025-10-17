# Demo Guide - Creating Video/GIF Demonstrations

Guide for creating demonstration videos and GIFs for Claude Skills Automation.

## 📹 Demo Video Scenarios

### Demo 1: Installation (30 seconds)

**What to show**:
1. Clone repository
2. Run `bash scripts/install.sh`
3. Installation completes with success messages

**Script**:
```bash
# Terminal recording
cd ~/Downloads
git clone https://github.com/toowiredd/claude-skills-automation
cd claude-skills-automation
bash scripts/install.sh

# Wait for completion
# Show success messages
```

**Tools**:
- **asciinema**: For terminal recordings
  ```bash
  asciinema rec installation-demo.cast
  # Run commands
  # Ctrl+D to stop
  asciinema upload installation-demo.cast
  ```

- **Terminalizer**: For animated GIFs
  ```bash
  npm install -g terminalizer
  terminalizer record installation-demo
  # Run commands
  # Ctrl+D to stop
  terminalizer render installation-demo -o installation.gif
  ```

---

### Demo 2: Zero Context Loss (60 seconds)

**What to show**:
1. Start Claude Code session, make a decision
2. End session
3. Start new session
4. Context automatically restored with decision

**Script**:
```
Session 1:
You: "Let's build a REST API with Express and PostgreSQL"
Claude: "Great! I'll help you set that up..."
[Work for a bit]
You: "done for today"

Session 2 (next day):
You: [Start Claude Code]
Claude:
# Session Context Restored

**Recent Decisions:**
• Build REST API with Express and PostgreSQL (1 day ago)

Ready to continue!
```

**How to record**:
1. Use screen recorder (OBS Studio, QuickTime, or browser extension)
2. Show Claude Code interface
3. Demonstrate conversation flow
4. Highlight automatic context restoration

---

### Demo 3: Automatic Decision Extraction (45 seconds)

**What to show**:
1. Conversation with decisions
2. Open `~/.claude-memories/auto-extracted.log`
3. Show decision was automatically captured

**Script**:
```
You: "We decided to use React with TypeScript for the frontend"
Claude: "Excellent choice! TypeScript will help with..."

# In another terminal
tail -f ~/.claude-memories/auto-extracted.log

# See extraction happen in real-time
[2025-10-17T...] Extracted DECISION: use React with TypeScript
```

---

### Demo 4: Error Debugging with Tool Persistence (90 seconds)

**What to show**:
1. Error occurs
2. error-debugger tries multiple approaches
3. Solution found and applied
4. Test created automatically

**Script**:
```
You: "Getting error: Cannot read property 'map' of undefined"

Claude:
🔍 Trying 3 approaches...

Approach 1: Searching past solutions...
❌ No past solution found

Approach 2: GitHub Copilot CLI search...
✅ Found similar issue in react-components repo!

**Fix**: Add optional chaining
[Shows code fix]

Approach 3: Not needed - solution found!

Would you like me to apply this fix?
```

---

### Demo 5: Paid Subscriptions Integration (60 seconds)

**What to show**:
1. Jules CLI async task triggered
2. Copilot code review hook
3. Pieces auto-save hook
4. All working together

**Script**:
```bash
# Terminal 1: Main work
You: "Implement user authentication"

# Hook triggers Jules
🤖 Jules working on: Implement user authentication
📋 Task ID: jules-task-123
⏳ Monitoring in background...

# Terminal 2: Jules dashboard
jules /remote
# Shows task progress in real-time

# When complete
✅ Jules completed task. Review PR: https://github.com/.../pull/42
```

---

## 🎨 Creating GIFs

### Tools

**Option 1: Terminalizer** (Terminal only)
```bash
npm install -g terminalizer

# Record
terminalizer record my-demo
# ... commands ...
# Ctrl+D to stop

# Render
terminalizer render my-demo -o my-demo.gif

# Optimize
gifsicle -O3 my-demo.gif -o my-demo-optimized.gif
```

**Option 2: Kap** (macOS - Full screen)
- Download from: https://getkap.co/
- Select area to record
- Export as GIF (optimized)

**Option 3: Peek** (Linux - Screen recorder)
```bash
sudo add-apt-repository ppa:peek-developers/stable
sudo apt update
sudo apt install peek

# Launch and record
peek
```

**Option 4: ScreenToGif** (Windows)
- Download from: https://www.screentogif.com/
- Record screen
- Edit and export

---

## 🎥 Creating Videos

### Tools

**Option 1: OBS Studio** (All platforms)
```bash
# Install
sudo apt install obs-studio  # Linux
brew install obs-studio       # macOS
# Or download from obsproject.com

# Setup:
1. Add display capture source
2. Set resolution: 1920x1080
3. Set FPS: 30
4. Start recording
```

**Option 2: asciinema** (Terminal only)
```bash
# Install
pip install asciinema

# Record
asciinema rec demo.cast

# Upload and share
asciinema upload demo.cast
# Returns: https://asciinema.org/a/xxxxx

# Convert to GIF
npm install -g asciicast2gif
asciicast2gif demo.cast demo.gif
```

**Option 3: CloudApp/Loom** (Quick sharing)
- CloudApp: https://www.getcloudapp.com/
- Loom: https://www.loom.com/
- Record screen, instantly get shareable link

---

## 📐 Best Practices

### Recording Settings

**Resolution**: 1920x1080 or 1280x720
**Frame Rate**: 30 FPS
**Duration**: 30-90 seconds (attention span)
**File Size**: <10MB for GIFs, <50MB for videos

### Terminal Settings

```bash
# Increase font size for visibility
# In your terminal preferences:
Font Size: 14-16pt
Font: Monospace (e.g., Fira Code, JetBrains Mono)

# Use clear prompt
export PS1="\[\e[32m\]$ \[\e[0m\]"

# Slow down typing for readability
# Use 'pv' to simulate typing:
echo "command here" | pv -qL 20  # 20 chars/second
```

### Content Guidelines

1. **Start with title card** (3 seconds)
   - Show: "Claude Skills Automation Demo"
   - Subtitle: What this demo shows

2. **Clear, deliberate actions** (45-60 seconds)
   - Type slowly enough to read
   - Pause after important outputs
   - Highlight key information

3. **End with summary** (5 seconds)
   - Show result achieved
   - Call to action (GitHub link)

---

## 📝 Demo Scripts

### Script Template

```markdown
# Demo: [Feature Name]

## Duration: X seconds

## Prerequisites
- Thing 1
- Thing 2

## Steps

1. **Setup** (5s)
   - Commands:
     ```bash
     cd ~/project
     ```

2. **Action** (30s)
   - Commands:
     ```bash
     command 1
     command 2
     ```
   - Expected output:
     ```
     Output here
     ```

3. **Result** (5s)
   - Show final state
   - Highlight achievement

## Recording Notes
- Terminal size: 120x30
- Font size: 16pt
- Typing speed: Slow and deliberate
```

---

## 🚀 Publishing Demos

### Where to publish

1. **GitHub Repository**
   - Add GIFs to README.md
   - Create `/demos` directory with videos

2. **Social Media**
   - Twitter/X: Upload GIF/video directly
   - Reddit: Upload to Imgur, link in post
   - LinkedIn: Upload video directly

3. **YouTube**
   - Create unlisted video
   - Embed in documentation

4. **Asciinema**
   - Terminal recordings
   - Embed in GitHub markdown

---

## 📊 Example GIF Embed in README

```markdown
## Demo: Zero Context Loss

![Zero Context Loss Demo](demos/zero-context-loss.gif)

In this demo:
1. User makes a decision in Session 1
2. Session ends
3. Session 2 automatically restores context
4. User continues immediately without manual "hi-ai"
```

---

## 🎬 Quick Start Recording Checklist

- [ ] Clear terminal history
- [ ] Increase font size
- [ ] Set up clean prompt
- [ ] Prepare test data/environment
- [ ] Practice run-through once
- [ ] Start recorder
- [ ] Execute demo script
- [ ] Stop recorder
- [ ] Review and edit if needed
- [ ] Optimize file size
- [ ] Upload and share

---

## 🔗 Resources

- **Terminalizer**: https://terminalizer.com/
- **asciinema**: https://asciinema.org/
- **OBS Studio**: https://obsproject.com/
- **Kap**: https://getkap.co/
- **Peek**: https://github.com/phw/peek
- **GIF optimization**: https://www.lcdf.org/gifsicle/

---

## 💡 Tips

1. **Keep it simple**: One feature per demo
2. **Real-world scenarios**: Use realistic examples
3. **Show, don't tell**: Let the automation speak
4. **High contrast**: Use dark theme for better visibility
5. **Test playback**: Verify GIF loops correctly
6. **Accessibility**: Add captions/transcripts for videos

---

**Ready to record?** Start with the installation demo - it's the easiest and most impactful!
