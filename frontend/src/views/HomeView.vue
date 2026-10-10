<script setup lang="ts">
import { ref } from 'vue'
import {
  BoltIcon,
  ChartBarIcon,
  CloudArrowUpIcon,
  LockClosedIcon,
  PuzzlePieceIcon,
  UsersIcon,
} from '@heroicons/vue/24/outline'
import PricingCard from '@/components/PricingCard.vue'
import { tiers } from '@/data/tiers'

const annual = ref(true)

const features = [
  { name: 'Lorem ipsum', icon: BoltIcon },
  { name: 'Dolor sit amet', icon: CloudArrowUpIcon },
  { name: 'Consectetur', icon: LockClosedIcon },
  { name: 'Adipiscing elit', icon: ChartBarIcon },
  { name: 'Sed do eiusmod', icon: UsersIcon },
  { name: 'Tempor incididunt', icon: PuzzlePieceIcon },
]
</script>

<template>
  <!-- Hero -->
  <section class="relative overflow-hidden">
    <div
      class="absolute inset-x-0 -top-40 -z-10 h-[32rem] bg-gradient-to-b from-brand-50 to-white"
      aria-hidden="true"
    />
    <div class="mx-auto max-w-4xl px-4 pt-24 pb-20 text-center sm:px-6 sm:pt-32 lg:px-8">
      <p
        class="mx-auto inline-flex items-center gap-2 rounded-full bg-white px-3 py-1 text-xs font-medium text-brand-700 ring-1 ring-brand-100"
      >
        <span class="size-1.5 rounded-full bg-brand-500" />
        New - lorem ipsum v2 is live
      </p>
      <h1 class="mt-6 text-4xl font-bold tracking-tight text-balance text-slate-900 sm:text-6xl">
        Lorem ipsum dolor sit amet, consectetur
      </h1>
      <p class="mx-auto mt-6 max-w-2xl text-lg text-pretty text-slate-600">
        Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque
        laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.
      </p>
      <div class="mt-10 flex flex-wrap items-center justify-center gap-4">
        <RouterLink
          :to="{ hash: '#pricing' }"
          class="rounded-lg bg-brand-600 px-5 py-3 text-sm font-semibold text-white shadow-sm hover:bg-brand-700"
        >
          Start for free
        </RouterLink>
        <RouterLink
          :to="{ name: 'docs' }"
          class="rounded-lg px-5 py-3 text-sm font-semibold text-slate-900 ring-1 ring-slate-200 hover:bg-slate-50"
        >
          Read the docs &rarr;
        </RouterLink>
      </div>
    </div>
  </section>

  <!-- Features -->
  <section class="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-2xl text-center">
      <h2 class="text-sm font-semibold text-brand-600">Features</h2>
      <p class="mt-2 text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">
        Nemo enim ipsam voluptatem
      </p>
      <p class="mt-4 text-slate-600">
        Quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos.
      </p>
    </div>
    <dl class="mt-16 grid gap-10 sm:grid-cols-2 lg:grid-cols-3">
      <div v-for="feature in features" :key="feature.name" class="flex gap-4">
        <div class="grid size-10 flex-none place-items-center rounded-lg bg-brand-600 text-white">
          <component :is="feature.icon" class="size-5" />
        </div>
        <div>
          <dt class="font-semibold text-slate-900">{{ feature.name }}</dt>
          <dd class="mt-1 text-sm text-slate-600">
            Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur.
          </dd>
        </div>
      </div>
    </dl>
  </section>

  <!-- Pricing -->
  <section id="pricing" class="scroll-mt-20 bg-slate-50 py-20">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-sm font-semibold text-brand-600">Pricing</h2>
        <p class="mt-2 text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">
          Plans for teams of every size
        </p>
        <p class="mt-4 text-slate-600">
          Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore.
        </p>
      </div>

      <!-- Billing toggle -->
      <div class="mt-10 flex justify-center">
        <div
          class="grid grid-cols-2 gap-1 rounded-full bg-white p-1 text-sm font-semibold ring-1 ring-slate-200"
          role="radiogroup"
          aria-label="Billing period"
        >
          <button
            v-for="opt in [
              { label: 'Monthly', value: false },
              { label: 'Annual (-20%)', value: true },
            ]"
            :key="opt.label"
            role="radio"
            :aria-checked="annual === opt.value"
            class="rounded-full px-4 py-1.5 transition"
            :class="annual === opt.value ? 'bg-brand-600 text-white' : 'text-slate-500'"
            @click="annual = opt.value"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <div class="mx-auto mt-12 grid max-w-md gap-8 lg:max-w-none lg:grid-cols-3 lg:items-center">
        <PricingCard v-for="tier in tiers" :key="tier.id" :tier="tier" :annual="annual" />
      </div>
    </div>
  </section>

  <!-- CTA -->
  <section class="mx-auto max-w-7xl px-4 py-20 sm:px-6 lg:px-8">
    <div class="rounded-3xl bg-brand-600 px-6 py-16 text-center sm:px-16">
      <h2 class="text-3xl font-bold tracking-tight text-white">Ready to lorem ipsum?</h2>
      <p class="mx-auto mt-4 max-w-xl text-brand-100">
        Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt.
      </p>
      <RouterLink
        :to="{ name: 'login' }"
        class="mt-8 inline-block rounded-lg bg-white px-5 py-3 text-sm font-semibold text-brand-700 hover:bg-brand-50"
      >
        Get started today
      </RouterLink>
    </div>
  </section>
</template>
