import { computed, ref, watch } from 'vue'
import { defineStore } from 'pinia'

export interface User {
  email: string
  name: string
}

const STORAGE_KEY = 'acme.user'

function loadUser(): User | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? (JSON.parse(raw) as User) : null
  } catch {
    return null
  }
}

/**
 * Mock auth store. Replace `login` w/ a real API call
 * (e.g. POST /api/auth/login) when a backend exists.
 */
export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(loadUser())
  const isAuthenticated = computed(() => user.value !== null)

  watch(user, (u) => {
    try {
      if (u) localStorage.setItem(STORAGE_KEY, JSON.stringify(u))
      else localStorage.removeItem(STORAGE_KEY)
    } catch {
      /* storage unavailable - keep in-memory only */
    }
  })

  async function login(email: string, password: string): Promise<void> {
    await new Promise((r) => setTimeout(r, 600)) // simulate network latency
    if (password.length < 8) throw new Error('Invalid email or password.')
    user.value = { email, name: email.split('@')[0] ?? email }
  }

  function logout() {
    user.value = null
  }

  return { user, isAuthenticated, login, logout }
})
