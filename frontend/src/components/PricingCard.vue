<script setup lang="ts">
import { computed } from 'vue'
import { CheckIcon } from '@heroicons/vue/20/solid'
import type { Tier } from '@/data/tiers'

const props = defineProps<{ tier: Tier; annual: boolean }>()

const price = computed(() => (props.annual ? props.tier.annual : props.tier.monthly))
</script>

<template>
  <div
    class="relative flex flex-col rounded-2xl p-8"
    :class="
      tier.featured
        ? 'bg-slate-900 text-white shadow-xl ring-1 ring-slate-900 lg:-my-4 lg:py-12'
        : 'bg-white ring-1 ring-slate-200'
    "
  >
    <p
      v-if="tier.featured"
      class="absolute -top-3 left-8 rounded-full bg-brand-500 px-3 py-1 text-xs font-semibold text-white"
    >
      Most popular
    </p>

    <h3 class="text-lg font-semibold" :class="tier.featured ? 'text-white' : 'text-slate-900'">
      {{ tier.name }}
    </h3>
    <p class="mt-2 text-sm" :class="tier.featured ? 'text-slate-300' : 'text-slate-500'">
      {{ tier.description }}
    </p>

    <p class="mt-6 flex items-baseline gap-1">
      <template v-if="price !== null">
        <span
          class="text-4xl font-bold tracking-tight"
          :class="tier.featured ? 'text-white' : 'text-slate-900'"
          >${{ price }}</span
        >
        <span class="text-sm" :class="tier.featured ? 'text-slate-400' : 'text-slate-500'"
          >/user/mo</span
        >
      </template>
      <span
        v-else
        class="text-4xl font-bold tracking-tight"
        :class="tier.featured ? 'text-white' : 'text-slate-900'"
        >Custom</span
      >
    </p>
    <p class="mt-1 h-5 text-xs" :class="tier.featured ? 'text-slate-400' : 'text-slate-500'">
      <template v-if="annual && price">Billed annually</template>
    </p>

    <ul class="mt-6 flex-1 space-y-3 text-sm">
      <li v-for="feature in tier.features" :key="feature" class="flex gap-3">
        <CheckIcon
          class="size-5 flex-none"
          :class="tier.featured ? 'text-brand-100' : 'text-brand-600'"
        />
        <span :class="tier.featured ? 'text-slate-200' : 'text-slate-600'">{{ feature }}</span>
      </li>
    </ul>

    <RouterLink
      :to="{ name: 'login' }"
      class="mt-8 block rounded-lg px-4 py-2.5 text-center text-sm font-semibold transition"
      :class="
        tier.featured
          ? 'bg-brand-500 text-white hover:bg-brand-600'
          : 'bg-brand-50 text-brand-700 hover:bg-brand-100'
      "
    >
      {{ tier.cta }}
    </RouterLink>
  </div>
</template>
