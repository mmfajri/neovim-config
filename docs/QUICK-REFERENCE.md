# ⚡ Quick Debug Reference - No More Confusion!

## 🎯 Simple Rules:

### Want to debug **CLIENT-SIDE** (browser code)?
**`F8` → Paste in PowerShell → `Shift+F8`**

### Want to debug **SERVER-SIDE** (Node.js)?
**Press `F5`** (twice if server not running)

### Not sure which config to use?
**Press `Shift+F8`** to see all options

---

## 🎮 Complete Keyboard Map:

| Key | What It Does | Use For |
|-----|-------------|---------|
| **F8** | Copy Chrome launch command | Browser debugging setup |
| **Shift+F8** | Attach to Chrome / Show configs | Browser debugging attach |
| **F5** | Auto-start/attach server | SvelteKit API routes, +server.ts |
| **F6** | Attach to running server | If server already running |
| **F10** | Step over line | While debugging |
| **F11** | Step into function | While debugging |
| **Shift+F11** | Step out of function | While debugging |
| **Shift+F5** | Stop debugging | End debug session |
| **F7** | Toggle debug UI | Show/hide panels |
| **`<leader>b`** | Toggle breakpoint | Set/remove breakpoint |

---

## 📋 Workflows:

### Workflow 1: Debug Login (CLIENT-SIDE) 🌐

```
1. npm run dev                     (in terminal - start server)
2. nvim .                          (open project)
3. :e src/lib/controllers/AuthController.ts
4. <leader>b                       (set breakpoint on login line)
5. F8                              (get Chrome command - copies to clipboard!)
6. Enter port: 5173
7. Paste in PowerShell             (Chrome opens normally)
8. Shift+F8                        (attach debugger)
9. Click login in browser
10. Breakpoint hits in Neovim! ✅
```

**Two steps: F8 → paste → Shift+F8**

---

### Workflow 2: Debug API Route (SERVER-SIDE) ⚙️

```
1. nvim .                          (open project)
2. :e src/routes/api/users/+server.ts
3. <leader>b                       (set breakpoint)
4. F5                              (starts server if needed)
5. F5 again                        (attaches debugger)
6. Test API in browser/Postman
7. Breakpoint hits in Neovim! ✅
```

---

### Workflow 3: Debug .NET C# API 🏢

```
1. nvim .                          (open C# project)
2. :e Controllers/AuthController.cs
3. <leader>b                       (set breakpoint)
4. F5                              (shows C# debug options)
5. Select: "Launch - .NET Web (Development)"
6. Test API
7. Breakpoint hits! ✅
```

---

## ❓ FAQ

### Q: Why do I need F5 twice for server debugging?

**A:** 
- **First F5** = Starts the dev server (`npm run dev`)
- **Second F5** = Attaches the debugger to that server

If your server is already running, you only need F5 once!

---

### Q: F8 vs F12 (Browser DevTools) - which one?

**Both work!** Choose your preference:

**F8 (Debug in Neovim):**
- ✅ Stay in Neovim
- ✅ Use your Neovim keybindings
- ✅ Consistent interface

**F12 (Debug in Browser):**
- ✅ See the DOM visually
- ✅ Edit CSS live
- ✅ Network tab for API calls
- ✅ Console tab for logs

**Recommendation:** Use **F12** for UI/CSS/DOM stuff, **F8** for logic/code

---

### Q: Chrome isn't launching when I press F8?

**Checklist:**
1. ✅ Is dev server running? (`npm run dev` first!)
2. ✅ Did you restart Neovim? (to load new F8 keybinding)
3. ✅ Is port 9222 available? (close other debug sessions)
4. ✅ Is Chrome installed?

**Fix:**
```bash
# Kill any debugging Chrome instances
taskkill /F /IM chrome.exe

# Restart Neovim
nvim .

# Try F8 again
```

---

### Q: I want to see all debug options before choosing

**Press `Shift+F8`** - Shows you the full list to pick from!

---

## 🎯 Decision Tree:

```
What do you want to debug?
│
├─ Browser code (AuthController.ts, components)
│  └─ Press F8
│
├─ Server code (+server.ts, API routes)
│  └─ Press F5 (twice if server not running)
│
├─ .NET C# backend
│  └─ Press F5, select .NET config
│
└─ Not sure / want to choose
   └─ Press Shift+F8
```

---

## ✅ TL;DR - The Absolute Simplest Way:

### Debug Your Login:

1. **Start server:** `npm run dev`
2. **Open Neovim:** `nvim .`
3. **Open file:** `:e src/lib/controllers/AuthController.ts`
4. **Set breakpoint:** `<leader>b` on the login line
5. **Press `F8`** ← This is the magic button!
6. **Enter port:** `5173`
7. **Chrome opens, click login, done!** ✅

---

## 🆘 Still Having Issues?

### Common Problems:

| Problem | Solution |
|---------|----------|
| Chrome doesn't open | Make sure server is running first |
| Breakpoint not hitting | Check you're in the right file, refresh browser |
| Port 9222 error | `taskkill /F /IM chrome.exe` |
| F8 does nothing | Restart Neovim to load new config |
| Shows "No configuration" | Make sure you're in a .js/.ts/.svelte file |

---

**Remember:** 
- **F8** = Browser debugging (client-side)
- **F5** = Server debugging (Node.js/SvelteKit)
- **F5** also works for .NET C#

That's it! Choose the one you need! 🚀
