<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Bars3Icon, XMarkIcon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '@/stores/auth'

interface NavLink {
  label: string
  to: { name: string; hash?: string }
}

const links: NavLink[] = [
  { label: 'Product', to: { name: 'home' } },
  { label: 'Pricing', to: { name: 'home', hash: '#pricing' } },
  { label: 'Docs', to: { name: 'docs' } },
]

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()
const open = ref(false)

// Hash-aware active state (router's built-in active classes ignore the hash)
const isActive = (link: NavLink) =>
  route.name === link.to.name && (link.to.hash ?? '') === route.hash

// Close the mobile menu on navigation
watch(
  () => route.fullPath,
  () => (open.value = false),
)

function logout() {
  auth.logout()
  router.push({ name: 'home' })
}
</script>

<template>
  <header class="sticky top-0 z-40 border-b border-slate-200 bg-white/80 backdrop-blur">
    <nav class="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
      <!-- Brand -->
      <RouterLink :to="{ name: 'home' }" class="flex items-center gap-2">
        <span
          class="grid size-8 place-items-center rounded-lg bg-brand-600 text-sm font-bold text-white"
          >A</span
        >
        <span class="text-lg font-semibold text-slate-900">Acme</span>
      </RouterLink>

      <!-- Desktop links -->
      <div class="hidden items-center gap-8 md:flex">
        <RouterLink
          v-for="link in links"
          :key="link.label"
          :to="link.to"
          class="text-sm font-medium transition hover:text-slate-900"
          :class="isActive(link) ? 'text-slate-900' : 'text-slate-500'"
        >
          {{ link.label }}
        </RouterLink>
      </div>

      <!-- Desktop auth -->
      <div class="hidden items-center gap-3 md:flex">
        <template v-if="auth.isAuthenticated">
          <span class="text-sm text-slate-500">{{ auth.user?.email }}</span>
          <button
            class="rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-100"
            @click="logout"
          >
            Log out
          </button>
        </template>
        <template v-else>
          <RouterLink
            :to="{ name: 'login' }"
            class="rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-100"
          >
            Log in
          </RouterLink>
          <RouterLink
            :to="{ name: 'home', hash: '#pricing' }"
            class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-brand-700"
          >
            Get started
          </RouterLink>
        </template>
      </div>

      <!-- Mobile toggle -->
      <button
        class="-mr-2 rounded-lg p-2 text-slate-700 hover:bg-slate-100 md:hidden"
        :aria-expanded="open"
        aria-controls="mobile-menu"
        @click="open = !open"
      >
        <span class="sr-only">Toggle menu</span>
        <XMarkIcon v-if="open" class="size-6" />
        <Bars3Icon v-else class="size-6" />
      </button>
    </nav>

    <!-- Mobile menu -->
    <div v-show="open" id="mobile-menu" class="border-t border-slate-200 bg-white md:hidden">
      <div class="space-y-1 px-4 py-3">
        <RouterLink
          v-for="link in links"
          :key="link.label"
          :to="link.to"
          class="block rounded-lg px-3 py-2 text-base font-medium text-slate-700 hover:bg-slate-50"
        >
          {{ link.label }}
        </RouterLink>
      </div>
      <div class="border-t border-slate-200 px-4 py-3">
        <button
          v-if="auth.isAuthenticated"
          class="block w-full rounded-lg px-3 py-2 text-left text-base font-medium text-slate-700 hover:bg-slate-50"
          @click="logout"
        >
          Log out ({{ auth.user?.email }})
        </button>
        <RouterLink
          v-else
          :to="{ name: 'login' }"
          class="block rounded-lg bg-brand-600 px-3 py-2 text-center text-base font-semibold text-white hover:bg-brand-700"
        >
          Log in
        </RouterLink>
      </div>
    </div>
  </header>
</template>
