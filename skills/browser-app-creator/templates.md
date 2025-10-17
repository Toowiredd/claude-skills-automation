# Browser App Templates

Complete working examples for common app types.

## Template 1: Habit Tracker

**Use case**: Track daily habits with visual feedback

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Habit Tracker</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #1a1a1a;
      color: #e0e0e0;
      padding: 20px;
      max-width: 800px;
      margin: 0 auto;
    }
    h1 { margin-bottom: 30px; font-size: 32px; }
    .add-habit {
      display: flex;
      gap: 10px;
      margin-bottom: 30px;
    }
    input {
      flex: 1;
      padding: 15px;
      font-size: 16px;
      border: 2px solid #333;
      border-radius: 6px;
      background: #2a2a2a;
      color: #e0e0e0;
    }
    button {
      min-height: 60px;
      padding: 15px 30px;
      font-size: 18px;
      font-weight: 600;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      background: #4a9eff;
      color: white;
      transition: all 0.2s;
    }
    button:hover {
      background: #357abd;
      transform: translateY(-2px);
    }
    .habit-list { display: flex; flex-direction: column; gap: 15px; }
    .habit-item {
      background: #2a2a2a;
      padding: 20px;
      border-radius: 8px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .habit-name { font-size: 20px; font-weight: 500; }
    .habit-count { color: #4a9eff; font-weight: 600; }
    .habit-actions { display: flex; gap: 10px; }
    .check-btn {
      min-height: 50px;
      padding: 10px 20px;
      background: #44ff88;
      color: #000;
    }
    .delete-btn {
      min-height: 50px;
      padding: 10px 20px;
      background: #ff4444;
    }
  </style>
</head>
<body>
  <h1>Habit Tracker</h1>

  <div class="add-habit">
    <input type="text" id="habitInput" placeholder="Enter new habit..." />
    <button onclick="addHabit()">Add Habit</button>
  </div>

  <div class="habit-list" id="habitList"></div>

  <script>
    const Storage = {
      key: 'habit-tracker-data',
      save(data) {
        localStorage.setItem(this.key, JSON.stringify(data));
      },
      load() {
        const data = localStorage.getItem(this.key);
        return data ? JSON.parse(data) : { habits: [] };
      }
    };

    let appData = Storage.load();

    function addHabit() {
      const input = document.getElementById('habitInput');
      const name = input.value.trim();
      if (!name) return;

      appData.habits.push({
        id: Date.now(),
        name,
        count: 0,
        created: new Date().toISOString()
      });

      Storage.save(appData);
      input.value = '';
      render();
    }

    function checkHabit(id) {
      const habit = appData.habits.find(h => h.id === id);
      if (habit) {
        habit.count++;
        habit.lastChecked = new Date().toISOString();
        Storage.save(appData);
        render();
      }
    }

    function deleteHabit(id) {
      appData.habits = appData.habits.filter(h => h.id !== id);
      Storage.save(appData);
      render();
    }

    function render() {
      const list = document.getElementById('habitList');
      list.innerHTML = appData.habits.map(habit => `
        <div class="habit-item">
          <div>
            <div class="habit-name">${habit.name}</div>
            <div class="habit-count">${habit.count} times</div>
          </div>
          <div class="habit-actions">
            <button class="check-btn" onclick="checkHabit(${habit.id})">✓ Done</button>
            <button class="delete-btn" onclick="deleteHabit(${habit.id})">Delete</button>
          </div>
        </div>
      `).join('');
    }

    // Initial render
    render();

    // Allow Enter key to add habit
    document.getElementById('habitInput').addEventListener('keypress', (e) => {
      if (e.key === 'Enter') addHabit();
    });
  </script>
</body>
</html>
```

---

## Template 2: Dashboard

**Use case**: Display metrics and status

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Project Dashboard</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #1a1a1a;
      color: #e0e0e0;
      padding: 20px;
    }
    h1 { margin-bottom: 30px; font-size: 32px; }
    .dashboard {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
    }
    .card {
      background: #2a2a2a;
      padding: 25px;
      border-radius: 12px;
      border-left: 4px solid #4a9eff;
    }
    .card-title {
      font-size: 14px;
      text-transform: uppercase;
      color: #888;
      margin-bottom: 10px;
    }
    .card-value {
      font-size: 36px;
      font-weight: 700;
      color: #4a9eff;
    }
    .card-subtitle {
      font-size: 14px;
      color: #aaa;
      margin-top: 5px;
    }
    .status-indicator {
      display: inline-block;
      width: 12px;
      height: 12px;
      border-radius: 50%;
      margin-right: 8px;
    }
    .status-online { background: #44ff88; }
    .status-offline { background: #ff4444; }
  </style>
</head>
<body>
  <h1>Project Dashboard</h1>

  <div class="dashboard">
    <div class="card">
      <div class="card-title">Total Tasks</div>
      <div class="card-value" id="totalTasks">0</div>
      <div class="card-subtitle">Last updated: <span id="lastUpdate">Never</span></div>
    </div>

    <div class="card">
      <div class="card-title">Completed</div>
      <div class="card-value" id="completedTasks">0</div>
      <div class="card-subtitle"><span id="completionRate">0%</span> completion rate</div>
    </div>

    <div class="card">
      <div class="card-title">System Status</div>
      <div class="card-value">
        <span class="status-indicator status-online"></span> Online
      </div>
      <div class="card-subtitle">All systems operational</div>
    </div>

    <div class="card">
      <div class="card-title">Active Users</div>
      <div class="card-value" id="activeUsers">0</div>
      <div class="card-subtitle">Currently online</div>
    </div>
  </div>

  <script>
    // Simulate dashboard data
    function updateDashboard() {
      const total = Math.floor(Math.random() * 50) + 10;
      const completed = Math.floor(Math.random() * total);
      const users = Math.floor(Math.random() * 20) + 1;

      document.getElementById('totalTasks').textContent = total;
      document.getElementById('completedTasks').textContent = completed;
      document.getElementById('completionRate').textContent =
        Math.round((completed / total) * 100) + '%';
      document.getElementById('activeUsers').textContent = users;
      document.getElementById('lastUpdate').textContent =
        new Date().toLocaleTimeString();
    }

    // Update immediately and every 5 seconds
    updateDashboard();
    setInterval(updateDashboard, 5000);
  </script>
</body>
</html>
```

---

## Template 3: Pomodoro Timer

**Use case**: Time management tool

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pomodoro Timer</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #1a1a1a;
      color: #e0e0e0;
      padding: 20px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
    }
    h1 { margin-bottom: 50px; font-size: 32px; }
    .timer-display {
      font-size: 120px;
      font-weight: 700;
      color: #4a9eff;
      margin-bottom: 50px;
      font-variant-numeric: tabular-nums;
    }
    .controls {
      display: flex;
      gap: 20px;
      margin-bottom: 30px;
    }
    button {
      min-height: 70px;
      padding: 20px 40px;
      font-size: 20px;
      font-weight: 600;
      border: none;
      border-radius: 12px;
      cursor: pointer;
      background: #4a9eff;
      color: white;
      transition: all 0.2s;
    }
    button:hover {
      background: #357abd;
      transform: translateY(-2px);
    }
    .reset-btn { background: #ff4444; }
    .reset-btn:hover { background: #cc0000; }
    .sessions {
      font-size: 18px;
      color: #888;
    }
    .sessions span {
      color: #44ff88;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <h1>Pomodoro Timer</h1>
  <div class="timer-display" id="timer">25:00</div>
  <div class="controls">
    <button id="startBtn" onclick="toggleTimer()">Start</button>
    <button class="reset-btn" onclick="resetTimer()">Reset</button>
  </div>
  <div class="sessions">
    Sessions completed: <span id="sessionCount">0</span>
  </div>

  <script>
    let timeLeft = 25 * 60; // 25 minutes in seconds
    let isRunning = false;
    let timerInterval = null;
    let sessions = parseInt(localStorage.getItem('pomodoro-sessions') || '0');

    document.getElementById('sessionCount').textContent = sessions;

    function toggleTimer() {
      isRunning = !isRunning;
      const btn = document.getElementById('startBtn');
      btn.textContent = isRunning ? 'Pause' : 'Start';

      if (isRunning) {
        timerInterval = setInterval(tick, 1000);
      } else {
        clearInterval(timerInterval);
      }
    }

    function tick() {
      timeLeft--;
      updateDisplay();

      if (timeLeft <= 0) {
        clearInterval(timerInterval);
        isRunning = false;
        sessions++;
        localStorage.setItem('pomodoro-sessions', sessions);
        document.getElementById('sessionCount').textContent = sessions;
        document.getElementById('startBtn').textContent = 'Start';
        alert('Pomodoro complete! Take a break.');
        resetTimer();
      }
    }

    function resetTimer() {
      clearInterval(timerInterval);
      isRunning = false;
      timeLeft = 25 * 60;
      updateDisplay();
      document.getElementById('startBtn').textContent = 'Start';
    }

    function updateDisplay() {
      const minutes = Math.floor(timeLeft / 60);
      const seconds = timeLeft % 60;
      document.getElementById('timer').textContent =
        `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
  </script>
</body>
</html>
```

---

## Template 4: Todo List

**Use case**: Task management

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Todo List</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #1a1a1a;
      color: #e0e0e0;
      padding: 20px;
      max-width: 800px;
      margin: 0 auto;
    }
    h1 { margin-bottom: 30px; font-size: 32px; }
    .add-todo {
      display: flex;
      gap: 10px;
      margin-bottom: 30px;
    }
    input {
      flex: 1;
      padding: 15px;
      font-size: 16px;
      border: 2px solid #333;
      border-radius: 6px;
      background: #2a2a2a;
      color: #e0e0e0;
    }
    button {
      min-height: 60px;
      padding: 15px 30px;
      font-size: 18px;
      font-weight: 600;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      background: #4a9eff;
      color: white;
      transition: all 0.2s;
    }
    button:hover {
      background: #357abd;
      transform: translateY(-2px);
    }
    .todo-list { display: flex; flex-direction: column; gap: 10px; }
    .todo-item {
      background: #2a2a2a;
      padding: 15px 20px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      gap: 15px;
    }
    .todo-item.completed {
      opacity: 0.5;
    }
    .todo-item.completed .todo-text {
      text-decoration: line-through;
    }
    .todo-checkbox {
      width: 24px;
      height: 24px;
      cursor: pointer;
    }
    .todo-text {
      flex: 1;
      font-size: 18px;
    }
    .delete-btn {
      min-height: 40px;
      padding: 10px 20px;
      font-size: 14px;
      background: #ff4444;
    }
  </style>
</head>
<body>
  <h1>Todo List</h1>

  <div class="add-todo">
    <input type="text" id="todoInput" placeholder="What needs to be done?" />
    <button onclick="addTodo()">Add</button>
  </div>

  <div class="todo-list" id="todoList"></div>

  <script>
    const Storage = {
      key: 'todo-list-data',
      save(data) {
        localStorage.setItem(this.key, JSON.stringify(data));
      },
      load() {
        const data = localStorage.getItem(this.key);
        return data ? JSON.parse(data) : { todos: [] };
      }
    };

    let appData = Storage.load();

    function addTodo() {
      const input = document.getElementById('todoInput');
      const text = input.value.trim();
      if (!text) return;

      appData.todos.push({
        id: Date.now(),
        text,
        completed: false,
        created: new Date().toISOString()
      });

      Storage.save(appData);
      input.value = '';
      render();
    }

    function toggleTodo(id) {
      const todo = appData.todos.find(t => t.id === id);
      if (todo) {
        todo.completed = !todo.completed;
        Storage.save(appData);
        render();
      }
    }

    function deleteTodo(id) {
      appData.todos = appData.todos.filter(t => t.id !== id);
      Storage.save(appData);
      render();
    }

    function render() {
      const list = document.getElementById('todoList');
      list.innerHTML = appData.todos.map(todo => `
        <div class="todo-item ${todo.completed ? 'completed' : ''}">
          <input
            type="checkbox"
            class="todo-checkbox"
            ${todo.completed ? 'checked' : ''}
            onchange="toggleTodo(${todo.id})"
          />
          <div class="todo-text">${todo.text}</div>
          <button class="delete-btn" onclick="deleteTodo(${todo.id})">Delete</button>
        </div>
      `).join('');
    }

    // Initial render
    render();

    // Allow Enter key to add todo
    document.getElementById('todoInput').addEventListener('keypress', (e) => {
      if (e.key === 'Enter') addTodo();
    });
  </script>
</body>
</html>
```

---

## Template 5: Calculator

**Use case**: Simple calculator tool

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Calculator</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #1a1a1a;
      color: #e0e0e0;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
    }
    .calculator {
      background: #2a2a2a;
      border-radius: 20px;
      padding: 20px;
      box-shadow: 0 10px 50px rgba(0,0,0,0.5);
      max-width: 400px;
      width: 100%;
    }
    .display {
      background: #1a1a1a;
      padding: 30px;
      border-radius: 12px;
      margin-bottom: 20px;
      text-align: right;
      font-size: 48px;
      font-weight: 700;
      color: #4a9eff;
      min-height: 100px;
      display: flex;
      align-items: center;
      justify-content: flex-end;
      word-break: break-all;
    }
    .buttons {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 15px;
    }
    button {
      height: 70px;
      font-size: 24px;
      font-weight: 600;
      border: none;
      border-radius: 12px;
      cursor: pointer;
      background: #333;
      color: #e0e0e0;
      transition: all 0.2s;
    }
    button:hover {
      background: #444;
      transform: scale(1.05);
    }
    button:active {
      transform: scale(0.95);
    }
    .btn-operator {
      background: #4a9eff;
      color: white;
    }
    .btn-operator:hover {
      background: #357abd;
    }
    .btn-equals {
      background: #44ff88;
      color: #000;
      grid-column: span 2;
    }
    .btn-equals:hover {
      background: #33dd77;
    }
    .btn-clear {
      background: #ff4444;
      grid-column: span 2;
    }
    .btn-clear:hover {
      background: #cc0000;
    }
  </style>
</head>
<body>
  <div class="calculator">
    <div class="display" id="display">0</div>
    <div class="buttons">
      <button class="btn-clear" onclick="clearDisplay()">C</button>
      <button onclick="appendToDisplay('/')" class="btn-operator">÷</button>
      <button onclick="appendToDisplay('*')" class="btn-operator">×</button>

      <button onclick="appendToDisplay('7')">7</button>
      <button onclick="appendToDisplay('8')">8</button>
      <button onclick="appendToDisplay('9')">9</button>
      <button onclick="appendToDisplay('-')" class="btn-operator">−</button>

      <button onclick="appendToDisplay('4')">4</button>
      <button onclick="appendToDisplay('5')">5</button>
      <button onclick="appendToDisplay('6')">6</button>
      <button onclick="appendToDisplay('+')" class="btn-operator">+</button>

      <button onclick="appendToDisplay('1')">1</button>
      <button onclick="appendToDisplay('2')">2</button>
      <button onclick="appendToDisplay('3')">3</button>
      <button onclick="deleteLastChar()">←</button>

      <button onclick="appendToDisplay('0')">0</button>
      <button onclick="appendToDisplay('.')">.</button>
      <button class="btn-equals" onclick="calculate()">=</button>
    </div>
  </div>

  <script>
    let currentDisplay = '0';

    function updateDisplay() {
      document.getElementById('display').textContent = currentDisplay;
    }

    function clearDisplay() {
      currentDisplay = '0';
      updateDisplay();
    }

    function appendToDisplay(value) {
      if (currentDisplay === '0' && value !== '.') {
        currentDisplay = value;
      } else {
        currentDisplay += value;
      }
      updateDisplay();
    }

    function deleteLastChar() {
      currentDisplay = currentDisplay.slice(0, -1) || '0';
      updateDisplay();
    }

    function calculate() {
      try {
        currentDisplay = eval(currentDisplay).toString();
        updateDisplay();
      } catch (error) {
        currentDisplay = 'Error';
        updateDisplay();
        setTimeout(() => {
          currentDisplay = '0';
          updateDisplay();
        }, 1500);
      }
    }
  </script>
</body>
</html>
```

See main [SKILL.md](SKILL.md) for usage patterns and [styling.md](styling.md) for CSS guidelines.
