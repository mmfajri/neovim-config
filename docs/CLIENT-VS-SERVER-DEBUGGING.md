# 🐛 CLIENT-SIDE vs SERVER-SIDE DEBUGGING

## ⚠️ IMPORTANT: Your Login Code Runs in the BROWSER!

Your `AuthController.ts` file runs **client-side** (in the browser), **NOT** on the Node.js server.

### Why Neovim Debugger Doesn't Work Here:

```typescript
// This is in AuthController.ts - runs in BROWSER
export async function login(credentials: LoginRequest) {
    debugger;  // ← This pauses in BROWSER DevTools, not Neovim!
    const response = await fetch(`${API_BASE_URL}${API_ENDPOINTS.AUTH}/Login`, {
        // Calls external API from browser
    });
}
```

**Neovim DAP debugger = Server-side (Node.js) code only**  
**Browser DevTools = Client-side (browser) code**

---

## ✅ HOW TO DEBUG YOUR LOGIN (3 Methods)

### **Method 1: Browser DevTools (Easiest - Use This!)**

Your code already has `debugger;` statement - perfect!

#### Steps:

1. **Make sure dev server is running:**
   - In Neovim: Press F5 (wait for server to start)
   - Or run manually: `npm run dev`

2. **Open browser to http://localhost:5173**

3. **Press F12** (opens DevTools)

4. **Go to "Sources" tab** in DevTools

5. **Click login button** in your app

6. **Code pauses at the `debugger;` line automatically!**

7. **Now you can:**
   - Hover over variables to see values
   - Press F10 to step over
   - Press F11 to step into functions
   - See Network tab for API calls
   - Check Console for logs

**This is the BEST way to debug client-side code!**

---

### **Method 2: Use console.log() Instead**

Sometimes simpler is better!

```typescript
export async function login(credentials: LoginRequest) {
    console.log('🔐 Login attempt:', credentials);
    
    const response = await fetch(`${API_BASE_URL}${API_ENDPOINTS.AUTH}/Login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(credentials),
    });
    
    console.log('📡 Response status:', response.status);
    
    const result = await response.json();
    console.log('✅ Login result:', result);
    
    return result;
}
```

Then:
1. Open browser
2. Press F12 → Console tab
3. Click login
4. See all the logs!

---

### **Method 3: Create Server-Side API (Debug in Neovim)**

If you REALLY want to debug in Neovim, move the API call to the server:

#### Create: `src/routes/api/auth/login/+server.ts`

```typescript
import type { RequestHandler } from './$types';
import { json } from '@sveltejs/kit';

export const POST: RequestHandler = async ({ request }) => {
	// ✅ THIS CODE RUNS ON SERVER - Neovim debugger works here!
	
	const credentials = await request.json();
	
	// Set breakpoint HERE - will work in Neovim!
	console.log('Server-side login:', credentials);
	
	const response = await fetch('http://localhost:5000/api/Auth/Login', {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(credentials),
	});
	
	const result = await response.json();
	return json(result);
};
```

#### Update AuthController.ts to call YOUR server:

```typescript
export async function login(credentials: LoginRequest) {
	// Now calls YOUR SvelteKit server, not external API directly
	const response = await fetch('/api/auth/login', {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify(credentials),
	});
	
	return await response.json();
}
```

Now:
1. Set breakpoint in `+server.ts` in Neovim
2. Press F5, F6 to debug
3. Click login in browser
4. Breakpoint hits in Neovim! ✅

---

## 📊 Quick Reference: Where to Debug

| Code Location | Runs Where? | Debug With |
|---------------|-------------|------------|
| `src/lib/controllers/*.ts` | Browser | Browser DevTools (F12) |
| `src/lib/components/*.svelte` | Browser | Browser DevTools (F12) |
| `src/routes/**/+page.svelte` | Browser | Browser DevTools (F12) |
| `src/routes/**/+page.server.ts` | **SERVER** | **Neovim (F5, F6)** ✅ |
| `src/routes/**/+server.ts` | **SERVER** | **Neovim (F5, F6)** ✅ |
| `src/hooks.server.ts` | **SERVER** | **Neovim (F5, F6)** ✅ |

---

## 🎯 Bottom Line

**For your current login code in `AuthController.ts`:**

→ **Use Browser DevTools (F12) - It's already set up with `debugger;`!**

**For server-side SvelteKit code:**

→ **Use Neovim debugger (F5, F6)**

---

## 💡 Pro Tip

Keep Browser DevTools open all the time when developing:
- F12 to open
- Dock it to the side
- Console tab shows all logs
- Network tab shows all API calls
- Sources tab for debugging

You'll use it 90% of the time for web development!
