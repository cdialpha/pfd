<template>
  <div class="grid min-h-[60vh] place-items-center px-4 text-center">
    <div>
      <p class="text-sm font-semibold text-brand-600">404</p>
      <h1 class="mt-2 text-3xl font-bold tracking-tight text-slate-900">Page not found</h1>
      <p class="mt-4 text-slate-600">Lorem ipsum - the page you're looking for doesn't exist.</p>
      <RouterLink
        :to="{ name: 'home' }"
        class="mt-8 inline-block rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-700"
      >
        Go home
      </RouterLink>
    </div>
  </div>
</template>
