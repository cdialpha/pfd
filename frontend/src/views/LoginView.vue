<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const form = reactive({ email: '', password: '', remember: true })
const loading = ref(false)
const error = ref<string | null>(null)

async function onSubmit() {
  error.value = null
  loading.value = true
  try {
    await auth.login(form.email, form.password)
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/'
    router.push(redirect)
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Something went wrong.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex min-h-[calc(100dvh-4rem)] items-center justify-center bg-slate-50 px-4 py-12">
    <div class="w-full max-w-sm">
      <div class="text-center">
        <span
          class="mx-auto grid size-10 place-items-center rounded-xl bg-brand-600 font-bold text-white"
          >A</span
        >
        <h1 class="mt-6 text-2xl font-bold tracking-tight text-slate-900">
          Log in to your account
        </h1>
        <p class="mt-2 text-sm text-slate-500">
          Or
          <RouterLink
            :to="{ name: 'home', hash: '#pricing' }"
            class="font-medium text-brand-600 hover:text-brand-700"
            >start a free trial</RouterLink
          >
        </p>
      </div>

      <form
        class="mt-8 space-y-5 rounded-2xl bg-white p-8 shadow-sm ring-1 ring-slate-200"
        @submit.prevent="onSubmit"
      >
        <div
          v-if="error"
          class="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 ring-1 ring-red-200"
          role="alert"
        >
          {{ error }}
        </div>

        <div>
          <label for="email" class="block text-sm font-medium text-slate-900">Email</label>
          <input
            id="email"
            v-model.trim="form.email"
            type="email"
            autocomplete="email"
            required
            placeholder="you@example.com"
            class="mt-2 block w-full rounded-lg border border-slate-300 px-3 py-2 text-sm shadow-xs placeholder:text-slate-400 focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 focus:outline-none"
          />
        </div>

        <div>
          <div class="flex items-center justify-between">
            <label for="password" class="block text-sm font-medium text-slate-900">Password</label>
            <a href="#" class="text-sm font-medium text-brand-600 hover:text-brand-700"
              >Forgot password?</a
            >
          </div>
          <input
            id="password"
            v-model="form.password"
            type="password"
            autocomplete="current-password"
            required
            minlength="8"
            placeholder="••••••••"
            class="mt-2 block w-full rounded-lg border border-slate-300 px-3 py-2 text-sm shadow-xs placeholder:text-slate-400 focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 focus:outline-none"
          />
        </div>

        <label class="flex items-center gap-2 text-sm text-slate-600">
          <input
            v-model="form.remember"
            type="checkbox"
            class="size-4 rounded border-slate-300 accent-brand-600"
          />
          Remember me
        </label>

        <button
          type="submit"
          :disabled="loading"
          class="flex w-full justify-center rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {{ loading ? 'Signing in…' : 'Sign in' }}
        </button>

        <div class="relative text-center text-xs text-slate-400">
          <span class="absolute inset-x-0 top-1/2 h-px bg-slate-200" />
          <span class="relative bg-white px-2">or continue with</span>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <button
            type="button"
            class="rounded-lg px-4 py-2 text-sm font-medium text-slate-700 ring-1 ring-slate-300 hover:bg-slate-50"
          >
            Google
          </button>
          <button
            type="button"
            class="rounded-lg px-4 py-2 text-sm font-medium text-slate-700 ring-1 ring-slate-300 hover:bg-slate-50"
          >
            GitHub
          </button>
        </div>
      </form>

      <p class="mt-6 text-center text-xs text-slate-400">
        Mock auth - any email + 8+ char password works.
      </p>
    </div>
  </div>
</template>
