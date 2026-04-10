# 🎯 SUPER SIMPLE DEBUGGING - UPDATED

## ⚡ Two easy methods!

### METHOD 1: F5 Twice (Auto-detect)

1. **Press `F5`** → Opens terminal, starts `npm run dev`
2. **Wait for:** `➜  Local:   http://localhost:5173/`
3. **Press `F5` again** → Attaches debugger + opens DAP UI

### METHOD 2: F5 + F6 (More reliable!)  

1. **Press `F5`** → Opens terminal, starts `npm run dev`
2. **Wait for:** `➜  Local:   http://localhost:5173/`
3. **Press `F6`** → **Attaches debugger + opens DAP UI** ✅

**Use F6 if F5 doesn't attach the debugger!**

---

## 📋 COMPLETE WALKTHROUGH:

### 1. Open your Svelte project in Neovim
```bash
cd "C:\Users\900363\Documents\My Web Sites\pos-app\pos_web_app_sv"
nvim .
```

### 2. Press `F5` 
- A terminal opens at the bottom
- Server starts automatically: `npm run dev`
- Watch for:
```
VITE v6.x.x  ready in xxx ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

### 3. Open browser to http://localhost:5173
- Verify your Svelte app loads!

### 4. Press `F6` (or try F5 again)
- **DAP UI opens** (panels on the sides)
- Message: "✅ Debugger attached successfully"
- You'll see windows labeled:
  - **DAP-TERMINAL** (bottom left)
  - **DAP-REPL** (bottom right)  
  - **Variables** (sidebar)
  - **Call Stack** (sidebar)

### 5. Set a breakpoint
- Open a `.svelte` or `.ts` file
- Put cursor on a line with code
- Press `<leader>b` (usually `\b` or `Space b`)
- **Red dot appears** = breakpoint set! ●

### 6. Trigger the breakpoint
- Refresh browser or click something in your app
- **Neovim pauses when code runs!**
- Line highlights in yellow
- Variables panel shows current values

### 7. Debug!
- **F10** = Step over (next line)
- **F11** = Step into (go inside function)
- **Shift+F11** = Step out
- Type variable names in **DAP-REPL** to inspect them
- **F5** = Continue to next breakpoint

---

## 🎮 Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **F5** | Start server / Continue debugging |
| **F6** | **Attach debugger (use after server starts!)** |
| `<leader>b` | Toggle breakpoint |
| **F7** | Toggle debug UI panels on/off |
| **F10** | Step over (next line) |
| **F11** | Step into function |
| **Shift+F11** | Step out of function |
| `<leader>dc` | Show debugging help |

---

## ❓ FAQ

### Q: What's the difference between F5 and F6?

**F5** = Smart button:
- If no server running → Starts server
- If server running → Tries to attach debugger

**F6** = Always attaches debugger
- Simpler, more reliable
- Use this after server starts!

**Recommended:** Use F5 to start server, then F6 to attach debugger

---

### Q: DAP UI didn't open?

Press **F7** to toggle it manually!

Or press **F6** again - it forces DAP UI to open.

---

### Q: I see "Connection refused" or "ECONNREFUSED"?

Server isn't running yet. Wait a bit longer, or check the terminal for errors.

Make sure you see `➜  Local:   http://localhost:5173/` before pressing F6.

---

### Q: Breakpoints not hitting?

**Remember:** Only **SERVER-SIDE** code!

✅ Works in Neovim debugger:
- `+page.server.ts` - Server load functions
- `+server.ts` - API routes  
- Any backend code

❌ Use Browser DevTools (F12) instead:
- `+page.svelte` - UI components
- Click handlers
- DOM manipulation
- CSS/styling

---

### Q: How do I stop debugging?

- Press `F5` then select "Disconnect"
- Or press **F7** to close DAP UI
- Or close the terminal with server (Ctrl+C in it)

---

## 🚀 Quick Reference Card

**Start debugging:**
```
F5  (starts server)
F6  (attaches debugger + opens UI)
```

**While debugging:**
```
<leader>b   = Set/remove breakpoint
F10         = Step over
F11         = Step into  
F7          = Toggle debug panels
```

**That's it!** 🎉

---

## 💡 Pro Tips:

1. **Server already running?**
   - Just press F6 to attach
   - Skip the F5 step

2. **Debug not working?**
   - Press F7 to make sure DAP UI is visible
   - Check terminal for errors
   - Make sure you're in a .ts or .svelte file when setting breakpoints

3. **Want to restart?**
   - Stop: Ctrl+C in server terminal
   - Start: F5 → F6 again

