<script setup lang="ts">
const year = new Date().getFullYear()
</script>

<template>
  <footer class="border-t border-slate-200 bg-slate-50">
    <div
      class="mx-auto flex max-w-7xl flex-col items-center justify-between gap-4 px-4 py-8 text-sm text-slate-500 sm:flex-row sm:px-6 lg:px-8"
    >
      <p>&copy; {{ year }} Acme, Inc. All rights reserved.</p>
      <div class="flex gap-6">
        <RouterLink :to="{ name: 'docs' }" class="hover:text-slate-900">Docs</RouterLink>
        <a href="#" class="hover:text-slate-900">Privacy</a>
        <a href="#" class="hover:text-slate-900">Terms</a>
      </div>
    </div>
  </footer>
</template>
