<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'

interface Section {
  id: string
  title: string
}

const nav: { group: string; sections: Section[] }[] = [
  {
    group: 'Getting started',
    sections: [
      { id: 'introduction', title: 'Introduction' },
      { id: 'installation', title: 'Installation' },
      { id: 'quickstart', title: 'Quickstart' },
    ],
  },
  {
    group: 'Core concepts',
    sections: [
      { id: 'authentication', title: 'Authentication' },
      { id: 'workspaces', title: 'Workspaces' },
      { id: 'webhooks', title: 'Webhooks' },
    ],
  },
  {
    group: 'Reference',
    sections: [
      { id: 'api', title: 'API reference' },
      { id: 'errors', title: 'Errors' },
    ],
  },
]

const allSections = nav.flatMap((g) => g.sections)

// Scroll-spy: highlight the section currently in view
const active = ref(allSections[0]?.id)
let observer: IntersectionObserver | undefined

onMounted(() => {
  observer = new IntersectionObserver(
    (entries) => {
      const visible = entries.find((e) => e.isIntersecting)
      if (visible) active.value = visible.target.id
    },
    { rootMargin: '-80px 0px -70% 0px' },
  )
  allSections.forEach((s) => {
    const el = document.getElementById(s.id)
    if (el) observer?.observe(el)
  })
})

onBeforeUnmount(() => observer?.disconnect())
</script>

<template>
  <div class="mx-auto flex max-w-7xl gap-10 px-4 py-10 sm:px-6 lg:px-8">
    <!-- Sidebar -->
    <aside class="hidden w-56 flex-none lg:block">
      <nav class="sticky top-24 space-y-8 text-sm">
        <div v-for="group in nav" :key="group.group">
          <h3 class="font-semibold text-slate-900">{{ group.group }}</h3>
          <ul class="mt-3 space-y-2 border-l border-slate-200">
            <li v-for="s in group.sections" :key="s.id">
              <RouterLink
                :to="{ hash: `#${s.id}` }"
                class="-ml-px block border-l pl-4 transition"
                :class="
                  active === s.id
                    ? 'border-brand-600 font-medium text-brand-700'
                    : 'border-transparent text-slate-500 hover:border-slate-400 hover:text-slate-900'
                "
              >
                {{ s.title }}
              </RouterLink>
            </li>
          </ul>
        </div>
      </nav>
    </aside>

    <!-- Content -->
    <article class="min-w-0 flex-1">
      <p class="text-sm font-semibold text-brand-600">Documentation</p>
      <h1 class="mt-2 text-4xl font-bold tracking-tight text-slate-900">Acme Docs</h1>
      <p class="mt-4 text-lg text-slate-600">
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio praesent libero.
      </p>

      <!-- Mobile section picker -->
      <select
        class="mt-6 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm lg:hidden"
        aria-label="Jump to section"
        @change="$router.push({ hash: `#${($event.target as HTMLSelectElement).value}` })"
      >
        <optgroup v-for="group in nav" :key="group.group" :label="group.group">
          <option v-for="s in group.sections" :key="s.id" :value="s.id">{{ s.title }}</option>
        </optgroup>
      </select>

      <section
        v-for="s in allSections"
        :id="s.id"
        :key="s.id"
        class="mt-10 scroll-mt-24 border-t border-slate-200 pt-10 first-of-type:border-0"
      >
        <h2 class="text-2xl font-semibold text-slate-900">{{ s.title }}</h2>
        <p class="mt-4 leading-7">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt
          ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
          ullamco laboris nisi ut aliquip ex ea commodo consequat.
        </p>
        <pre
          class="mt-6 overflow-x-auto rounded-xl bg-slate-900 p-4 text-sm leading-6 text-slate-100"
        ><code>curl https://api.acme.dev/v1/{{ s.id }} \
  -H "Authorization: Bearer $ACME_API_KEY"</code></pre>
        <p class="mt-6 leading-7">
          Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat
          nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
          deserunt mollit anim id est laborum.
        </p>
        <div
          class="mt-6 rounded-lg border-l-4 border-brand-500 bg-brand-50 p-4 text-sm text-brand-700"
        >
          <strong>Note -</strong> Sed ut perspiciatis unde omnis iste natus error sit voluptatem.
        </div>
      </section>
    </article>
  </div>
</template>
