# 📚 Neovim Debugging Documentation

Complete guides for debugging in Neovim with DAP (Debug Adapter Protocol).

---

## 🚀 Quick Start

**New to debugging?** Start here:

1. **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** ⭐⭐⭐ **SIMPLEST GUIDE!**
   - Just one page with everything you need
   - Clear keyboard shortcuts
   - Simple decision tree
   - **Start here if confused!**

2. **[SIMPLE-DEBUG-GUIDE.md](SIMPLE-DEBUG-GUIDE.md)** ⭐ For server-side debugging
   - F5 workflow for SvelteKit/Node.js
   - Recommended for backend code

3. **[BROWSER-DEBUGGING.md](BROWSER-DEBUGGING.md)** 🌐 For client-side debugging  
   - **Just press F8!**
   - Debug AuthController.ts, components, etc. in Neovim
   - No more Browser DevTools needed!

4. **[QUICK-START.md](QUICK-START.md)** - Ultra-quick walkthrough

---

## 📖 Detailed Guides

### **[BROWSER-DEBUGGING.md](BROWSER-DEBUGGING.md)** 🌐 **NEW!**
Debug client-side JavaScript **in Neovim** instead of Browser DevTools!
- Launch Chrome/Edge from Neovim
- Set breakpoints in Neovim
- Debug your AuthController.ts, components, etc. in Neovim
- No need to switch to Browser DevTools!

### **[DEBUGGING-GUIDE.md](DEBUGGING-GUIDE.md)**
Comprehensive debugging guide covering:
- Complete setup instructions
- Keyboard shortcuts
- Understanding DAP windows
- Troubleshooting common issues
- Pro tips and workflows

### **[CLIENT-VS-SERVER-DEBUGGING.md](CLIENT-VS-SERVER-DEBUGGING.md)** 🔑 **IMPORTANT!**
Essential guide explaining:
- **When to use Browser DevTools (F12)** vs **Neovim debugger**
- Client-side vs Server-side code
- Why your login code doesn't debug in Neovim
- Which files run where
- Clear examples and visual diagrams

### **[FIX-DEBUGGER-ATTACHED.md](FIX-DEBUGGER-ATTACHED.md)**
Troubleshooting guide for:
- "Debugger attached" but nothing happens
- Config not reloading issues
- Manual debugging methods
- Cache clearing steps

---

## 🎯 Which Guide Should I Use?

### **I want to debug my Svelte/React/Vue app:**

**NEW!** You have 3 options now:

1. **Debug in Neovim (NEW!)** → **[BROWSER-DEBUGGING.md](BROWSER-DEBUGGING.md)**
   - Press F5 → Select "🌐 Launch Chrome"
   - Set breakpoints in Neovim, debug in Neovim!

2. **Debug in Browser (Classic)** → **[CLIENT-VS-SERVER-DEBUGGING.md](CLIENT-VS-SERVER-DEBUGGING.md)**
   - Press F12 in browser
   - Use Browser DevTools

**Choose whichever you prefer!** Both work great!

### **I want to debug SvelteKit server routes (+server.ts):**
→ Use **[SIMPLE-DEBUG-GUIDE.md](SIMPLE-DEBUG-GUIDE.md)**

Press F5 → F6 → Set breakpoints → Debug!

### **I'm debugging .NET/C# code:**
→ Use **[DEBUGGING-GUIDE.md](DEBUGGING-GUIDE.md)** - Check the .NET section

### **Something's not working:**
→ Check **[FIX-DEBUGGER-ATTACHED.md](FIX-DEBUGGER-ATTACHED.md)**

---

## ⚡ Super Quick Reference

### **TypeScript/JavaScript/Svelte:**

**Frontend (UI) code:**
- Use Browser DevTools (F12)
- All `.svelte` components
- `src/lib/` code
- Client-side logic

**Backend (SvelteKit) code:**
- Press `F5` to start server
- Press `F6` to attach debugger
- Files: `+server.ts`, `+page.server.ts`

### **.NET/C#:**

**Development mode:**
- Press `F5`
- Select: "🚀 Launch - .NET Web (Development)"
- Set breakpoints with `<leader>b`

**Production mode:**
- Press `F5`
- Select: "🏭 Launch - .NET Web (Production)"

---

## 🎮 Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `F5` | Start server / Continue debugging |
| `F6` | Attach debugger (for JS/TS projects) |
| `F7` | Toggle debug UI panels |
| `F10` | Step over (next line) |
| `F11` | Step into function |
| `Shift+F11` | Step out of function |
| `<leader>b` | Toggle breakpoint |
| `<leader>dc` | Show debugging help |
| `<leader>dv` | Verify/rebuild JS debugger |

---

## 💡 Key Takeaways

1. **Frontend debugging** → Always use Browser DevTools (F12)
2. **Backend debugging** → Use Neovim (F5, F6)
3. **When in doubt** → Press F12 in browser first!

---

## 📂 File Organization

```
nvim/
├── docs/
│   ├── README.md (you are here)
│   ├── SIMPLE-DEBUG-GUIDE.md ⭐ Start here!
│   ├── DEBUGGING-GUIDE.md
│   ├── CLIENT-VS-SERVER-DEBUGGING.md 🔑 Important!
│   ├── QUICK-START.md
│   └── FIX-DEBUGGER-ATTACHED.md
└── lua/
    └── kickstart/
        └── plugins/
            └── debug.lua (actual debug config)
```

---

## 🆘 Need Help?

1. Check **[CLIENT-VS-SERVER-DEBUGGING.md](CLIENT-VS-SERVER-DEBUGGING.md)** - explains the most common confusion
2. Review **[SIMPLE-DEBUG-GUIDE.md](SIMPLE-DEBUG-GUIDE.md)** - follow the exact steps
3. Try **[FIX-DEBUGGER-ATTACHED.md](FIX-DEBUGGER-ATTACHED.md)** - common issues & fixes

Happy debugging! 🐛🔨
