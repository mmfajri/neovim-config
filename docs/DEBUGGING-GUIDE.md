# 🐛 Neovim Debugging Guide - UPDATED FOR YOUR PROJECT

## ⚡ Quick Start (CHOOSE ONE METHOD)

### METHOD 1: ONE-CLICK (Easiest - Use This First!)

1. **Close Neovim and reopen** (to load the new config)

2. **Open your project folder in Neovim**
   ```bash
   cd C:\Users\900363\Documents\My Web Sites\pos-app\pos_web_app_sv
   nvim .
   ```

3. **Press `F5`**

4. **Select: `🌟 All-in-One: Start & Debug (RECOMMENDED)`** - This is option #1

5. **Wait 10-20 seconds** - watch the DAP-TERMINAL window at the bottom

6. **Look for this in the terminal:**
   ```
   VITE v5.x.x ready in xxx ms
   
   ➜ Local:   http://localhost:5173/
   ```

7. **Open `http://localhost:5173` in your browser** - the app should load!

8. **Set a breakpoint** in a `.svelte` file:
   - Open any `.svelte` file in your project
   - Put cursor on a line with actual code (not comments)
   - Press `<leader>b` (your leader key + b, usually `\b` or `Space+b`)
   - You'll see a red dot appear (●)

9. **Refresh the browser** - if that line of code runs, Neovim will pause there!

---

### METHOD 2: MANUAL (If Method 1 doesn't work)

**This is more reliable but requires 2 steps:**

1. **In Neovim, open a terminal:**
   ```vim
   :terminal
   ```

2. **In that terminal, start your dev server:**
   ```bash
   cd C:\Users\900363\Documents\My Web Sites\pos-app\pos_web_app_sv
   npm run dev
   ```

3. **Wait for the server to show you the URL:**
   ```
   ➜ Local:   http://localhost:5173/
   ```

4. **Open that URL in your browser** - verify app loads properly

5. **Leave the terminal open, press `F5` in Neovim**

6. **Select: `🔗 Attach Only: Port 9229`** - This is option #2

7. **You should see:** "Debugger attached successfully" notification

8. **Set breakpoints** with `<leader>b` and refresh browser

---

## 🔍 Troubleshooting - READ THIS IF IT'S NOT WORKING

### ❌ "404 Not Found" in browser?

**THIS IS YOUR CURRENT PROBLEM!** Here's why and how to fix:

**Problem:** The dev server isn't actually starting.

**Solution 1 - Check what you see in DAP-TERMINAL:**
- Look at the bottom terminal window in Neovim
- Do you see "VITE ready" and a URL? → Server started OK, use that URL
- Do you just see "debugger attached"? → Server didn't start! Use METHOD 2 above

**Solution 2 - Make sure you selected the RIGHT option:**
- When you press F5, you'll see a list of options
- Option #1 = "🌟 All-in-One" ← SELECT THIS ONE!
- Option #2 = "🔗 Attach Only" ← DON'T use this unless server already running

**Solution 3 - The nuklear option (always works):**
1. Close Neovim completely
2. Restart Neovim
3. Open terminal in Neovim: `:terminal`
4. Run: `cd "C:\Users\900363\Documents\My Web Sites\pos-app\pos_web_app_sv"`
5. Run: `npm run dev`
6. Wait for URL to appear
7. Open browser to that URL - verify it works
8. If it works, press F5 in Neovim
9. Select "🔗 Attach" and you're debugging!

### ❌ Terminal just says "debugger attached" but no server output?

**You selected the WRONG option!** You chose "Attach" instead of "All-in-One"

**Fix:**
1. Stop debugging (press F5, select Disconnect)
2. Press F5 again
3. This time select **option #1** (🌟 All-in-One)
4. Wait and watch for "VITE ready" message

### ❌ Server shows error about port already in use?

Another instance of your dev server is running.

**Fix:**
1. Press `Ctrl+C` in any terminal that's running `npm run dev`
2. Or open Task Manager and kill all "node.exe" processes
3. Try debugging again

## 🎮 Key Shortcuts (Once Debugging Works)

| Key | Action |
|-----|--------|
| `F5` | Start/Continue debugging |
| `<leader>b` | Toggle breakpoint on current line |
| `F7` | Toggle debug UI panels |
| `F10` | Step over (next line) |
| `F11` | Step into (go inside function) |
| `Shift+F11` | Step out (finish current function) |
| `<leader>dc` | Show help in Neovim |
| `<leader>dl` | Open debug logs |

## 📺 Understanding the Windows

When debugging starts (and works!), you'll see:

- **DAP-TERMINAL** (bottom) = Your dev server output (shows URL, errors, console.logs from server)
- **DAP-REPL** = Interactive console (type variable names to inspect them)
- **Variables panel** = Shows all variables in current scope
- **Call Stack** = Shows function call history
- **Breakpoints** = Lists all your breakpoints

Press `F7` to toggle these panels on/off.

## 💡 Important Notes

### What code can you debug in Neovim?

✅ **SERVER-SIDE CODE** (works in Neovim debugger):
- `+page.server.ts` - SvelteKit server load functions
- `+server.ts` - API routes
- Any code that runs on the Node.js server

❌ **CLIENT-SIDE CODE** (use Browser DevTools instead):
- `+page.svelte` - Component code that runs in browser
- DOM manipulation
- Click handlers (onClick, etc.)
- CSS/styling
- Anything that runs in the browser

**For client-side:** Press F12 in your browser and use the Sources tab.

### Where exactly is the dev server URL shown?

When debugging starts successfully, look at the BOTTOM of your Neovim window. You should see a terminal that says something like:

```
  VITE v6.2.6  ready in 842 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

If you DON'T see this, the server didn't start - use METHOD 2!

## 🚀 Quick Reference Card

**MOST COMMON WORKFLOW (copy this):**

```
1. nvim .                          (open project)
2. <F5>                           (start debug)
3. Select #1 (All-in-One)         (start server + debug)
4. Wait 15 seconds                 (watch terminal)
5. Open http://localhost:5173      (in browser)
6. <leader>b on code line         (set breakpoint)
7. Refresh browser                 (hit breakpoint)
8. F10/F11 to step through        (debug!)
```

---

**IF THAT DOESN'T WORK:**

```
1. :terminal                       (open terminal in nvim)
2. npm run dev                     (start server manually)
3. Wait for URL                    (note the URL)
4. Open URL in browser            (verify it works)
5. <F5>                           (start debug)
6. Select #2 (Attach)             (attach to running server)
7. <leader>b on code line         (set breakpoint)
8. Refresh browser                 (hit breakpoint)
```

---
- Check DAP-TERMINAL for the ACTUAL URL
- It might be `:5000`, `:3000`, or `:4200` instead of `:5173`
- Wait longer - server might still be starting

### "Server won't start" or "Port already in use"?
- A server is already running
- Kill it: find terminal with server and press `Ctrl+C`
- Or use the `🔗 Attach Only` option instead (second choice when pressing F5)

### Breakpoints not hitting?
- **Server-side code only**: +server.ts, load functions, API routes
- **Client-side**: Use Browser DevTools (F12) instead for DOM, CSS, click handlers

### Server starts but debugger doesn't connect?
- Make sure `vscode-js-debug` is built
- Press `<leader>dv` to verify/rebuild
- Restart Neovim

## 💡 Pro Tips

### What to debug where:
- **Debug in Neovim**: SvelteKit load(), +server.ts, API endpoints, backend logic
- **Debug in Browser**: DOM manipulation, CSS, onClick handlers, UI interactions

### Client-side debugging:
For HTML/CSS/DOM/click events, use Browser DevTools (F12):
1. Open browser to your app
2. Press F12 to open DevTools
3. Go to Sources tab
4. Set breakpoints there
5. Interact with your app

This is better for UI debugging because you can see the DOM, styles, network requests, etc.

### Restart debugging:
- Stop: Press `F5` while debugging, then select "Disconnect"
- Or close DAP-TERMINAL window
- Start again: `F5`

## 📦 .NET Core Debugging (C#)

Different workflow for your POS API:

1. **Press `F5`**
2. **Select environment**:
   - `🚀 Launch - .NET Web (Development)` - For development
   - `🏭 Launch - .NET Web (Production)` - For production testing
3. **Wait for server to start**
4. **Check console output** for URL (usually http://localhost:5000)
5. **Test your API** with Postman/browser/etc.
6. **Set breakpoints** in .cs files

## 🆘 Still Having Issues?

1. **Verify JS debugger is installed**:
   ```vim
   " In Neovim, press:
   <leader>dv
   ```

2. **Check debug logs**:
   ```vim
   " In Neovim, press:
   <leader>dl
   ```

3. **Try manually**:
   - Open terminal: `:terminal`
   - Run: `npm run dev`
   - Note the URL
   - Press F5, select `🔗 Attach Only`
   - Open browser to URL

4. **Restart Neovim** - Sometimes config needs a fresh start

---

**TL;DR**: Press `F5`, select first option (🌟 All-in-One), wait for URL in terminal, open browser, set breakpoints with `<leader>b`. Done! 🎉
