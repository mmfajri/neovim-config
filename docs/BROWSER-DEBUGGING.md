# 🌐 Browser Debugging in Neovim

## Two-Step Workflow (Stable & Reliable!)

**No more infinite loading!** This workflow launches Chrome normally, then attaches the debugger.

---

## ⚡ Quick Start

```
F8 → Paste in PowerShell → Shift+F8 → Debug!
```

1. **`F8`** - Get Chrome launch command (auto-copied!)
2. **Paste in PowerShell** - Chrome opens normally
3. **`Shift+F8`** - Attach debugger
4. **Interact with app** - Breakpoints hit!

---

## ✨ Keybindings

| Key | Action |
|-----|--------|
| **F8** | Copy Chrome launch command to clipboard |
| **Shift+F8** | Attach debugger to Chrome |
| `<leader>b` | Toggle breakpoint |
| `F5` | Continue execution |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop debugging |

---

## 🚀 Complete Workflow

### Prerequisites
- Dev server running: `npm run dev`
- Chrome installed

### Step 1: Set Breakpoints

Open your file in Neovim:
```vim
:e src/lib/controllers/AuthController.ts
```

Set breakpoint:
- Move cursor to the line (e.g., `const response = await fetch(...)`)
- Press **`<leader>b`**
- Red dot appears in gutter

### Step 2: Get Chrome Command (F8)

Press **`F8`** in Neovim:
- Enter port when prompted (default: `5173`)
- Command is **automatically copied to clipboard**
- Notification shows instructions

### Step 3: Launch Chrome

Open PowerShell and paste (Ctrl+V):
```powershell
chrome --remote-debugging-port=9222 --user-data-dir="%TEMP%/chrome-debug" http://localhost:5173
```

Chrome opens and page loads **normally** - no infinite reload!

**If `chrome` not found:**
```powershell
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%TEMP%/chrome-debug" http://localhost:5173
```

### Step 4: Attach Debugger (Shift+F8)

Back in Neovim, press **`Shift+F8`**:
- DAP UI opens
- Debugger connects to Chrome
- Ready to debug!

### Step 5: Trigger Code

In the browser:
- Navigate to your app
- Click login button (or whatever triggers your code)
- **Execution pauses at breakpoint in Neovim!** 🎯

### Step 6: Debug!

Use debugging controls:
- **F10** - Step to next line
- **F11** - Step into function
- **Shift+F11** - Step out of function
- **F5** - Continue to next breakpoint
- **Hover** over variables to see values
- **DAP REPL** - Evaluate expressions

---

## 🆚 When to Use Browser Debugging

### Use F8 + Shift+F8 for:
✅ Client-side code (runs in browser)
- Event handlers (click, submit, etc.)
- UI controllers (`AuthController.ts`)
- Svelte component `<script>` blocks
- Browser APIs (`localStorage`, `fetch` from browser)
- Code with `window`, `document`

### Don't use for:
❌ Server-side code (use F5/F6 instead)
- API routes (`+server.ts`)
- Server load functions (`+page.server.ts`)
- Server hooks (`hooks.server.ts`)
- Database queries
- SSR code

**When in doubt:** If it runs when you click something in the browser, it's client-side!

---

## 🐛 Troubleshooting

### Chrome won't launch
**Problem:** `chrome: command not found`

**Solution:** Use full path:
```powershell
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%TEMP%/chrome-debug" http://localhost:5173
```

### Can't attach with Shift+F8
**Problem:** "Connection refused" or no connection

**Solutions:**
1. Make sure Chrome was launched with `--remote-debugging-port=9222`
2. Check port is not in use:
   ```powershell
   netstat -ano | findstr :9222
   ```
3. Close all Chrome instances and start fresh:
   ```powershell
   taskkill /F /IM chrome.exe
   ```

### Breakpoints not hitting
**Problem:** Code runs but doesn't pause

**Solutions:**
1. **Reload the page** in Chrome after setting breakpoints
2. Make sure breakpoint is in **client-side** code (not server)
3. Check source maps are working:
   - Look for your `.ts` files in DAP UI
   - If you only see `.js` files, source maps may be broken
4. Verify the code actually runs (add `console.log` to test)

### Wrong files shown in debugger
**Problem:** Debugger shows `.js` files instead of `.ts`

**Solution:**
- Make sure you're in the project root directory when you start Neovim
- Check Vite config has `sourcemap: true`
- Restart dev server

### Infinite loading / Page never loads
**Problem:** Chrome shows loading spinner forever

**This shouldn't happen with the new workflow!** If it does:
1. Close Chrome
2. Clear debug cache:
   ```powershell
   Remove-Item -Recurse "$env:TEMP\chrome-debug"
   ```
3. Try the workflow again (F8 → paste → Shift+F8)

### Dev server not running
**Problem:** F8 says "server not running"

**Solution:**
```powershell
cd your-project
npm run dev
```
Wait for: `➜  Local:   http://localhost:5173/`

---

## 💡 Pro Tips

### 1. Keep Chrome Window Open
After debugging, you can:
- Keep Chrome open and just close DAP UI (`F7`)
- Use Shift+F8 again later to re-attach
- No need to relaunch Chrome every time

### 2. Use Both DevTools and Neovim
The launched Chrome still has full DevTools (F12):
- Network tab - monitor requests
- Console - see logs
- Elements - inspect DOM

### 3. Debug Frontend + Backend Together
Want to debug both client and server in the same session?

**Terminal 1:**
```powershell
npm run dev-temp  # Start without --inspect
```

**Terminal 2:**
```powershell
# Start server with debugging
node --inspect node_modules/vite/bin/vite.js dev
```

**In Neovim:**
- `F6` → Attach to Node server
- `F8` → Get Chrome command → Paste
- `Shift+F8` → Attach to Chrome

Now you have both debuggers active!

### 4. Create PowerShell Alias
Add to your PowerShell profile (`$PROFILE`):
```powershell
function Start-ChromeDebug {
    param([string]$Port = "5173")
    & "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="$env:TEMP\chrome-debug" "http://localhost:$Port"
}
```

Then just run:
```powershell
Start-ChromeDebug 5173
```

---

## 📊 Workflow Comparison

### Old Way (One-Step F8)
- ❌ Chrome infinite reload
- ❌ "Unsafe attempt to load URL" errors
- ❌ Debugger interferes with page load
- ❌ Unreliable

### New Way (F8 + Shift+F8)
- ✅ Chrome loads normally
- ✅ No infinite reload
- ✅ Stable and reliable
- ✅ Debugger attaches cleanly
- ✅ Standard Chrome debugging workflow

---

## 🎮 Complete Example

**Scenario:** Debug login in `AuthController.ts`

```powershell
# Terminal 1: Start dev server
cd "C:\Users\900363\Documents\My Web Sites\pos-app\pos_web_app_sv"
npm run dev
```

```powershell
# Terminal 2: Open Neovim
nvim .
```

**In Neovim:**
```vim
:e src/lib/controllers/AuthController.ts
" Move to line with fetch()
<leader>b  " Set breakpoint
F8         " Get Chrome command
" Enter: 5173
```

**In PowerShell (Terminal 3):**
```powershell
# Paste the command (Ctrl+V, Enter)
chrome --remote-debugging-port=9222 --user-data-dir="%TEMP%/chrome-debug" http://localhost:5173
```

**Chrome opens → page loads**

**Back in Neovim:**
```vim
Shift+F8   " Attach debugger
" DAP UI opens - connected!
```

**In Chrome:**
- Go to login page
- Enter credentials
- Click "Login"

**In Neovim:**
- **Breakpoint hits!** 🎯
- Code pauses at `const response = await fetch(...)`
- F10 to step through
- Hover variables to inspect
- F5 to continue

**Success!** You're debugging client-side code in Neovim! 🎉

---

## 🔄 Alternative: Use Browser DevTools

If Neovim browser debugging feels too complex:

**Just use Chrome DevTools (F12):**
1. Open your app in Chrome normally
2. Press F12 → Sources tab
3. Find your `.ts` files in the tree
4. Click line numbers to set breakpoints
5. Interact with app → breakpoints hit
6. Debug in browser!

**Neovim browser debugging is powerful but optional.** Use whatever works best for you!

---

## 📚 Related Guides

- [Client vs Server Debugging](CLIENT-VS-SERVER-DEBUGGING.md) - When to use which tool
- [Quick Reference](QUICK-REFERENCE.md) - One-page cheat sheet
- [Simple Debug Guide](SIMPLE-DEBUG-GUIDE.md) - F5/F6 workflow for server

---

**Happy Debugging!** 🚀
