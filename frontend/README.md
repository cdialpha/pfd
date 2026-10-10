# saas-frontend

Vue 3 SaaS frontend starter - navbar, product/pricing page, docs page, login page.

## Stack

- **Vue 3.5** (`<script setup>` + TypeScript) on **Vite 8**
- **Vue Router 5** - lazy-loaded routes, hash scrolling, per-route `<title>`, guest-only guard
- **Pinia 4** - mock `auth` store (persists to `localStorage`)
- **Tailwind CSS v4** via `@tailwindcss/vite` - brand tokens in `src/assets/main.css` (`@theme`)
- **Heroicons** - `@heroicons/vue`
- **ESLint + Oxlint + Prettier** (w/ `prettier-plugin-tailwindcss` class sorting)
- **Vue DevTools** Vite plugin (dev only)

## Quickstart

Requires Node `^22.18` or `>=24.12`.

```sh
npm install
npm run dev        # http://localhost:5173
npm run build      # type-check + production build -> dist/
npm run preview    # serve dist/
npm run lint       # oxlint + eslint (autofix)
npm run format     # prettier
```

## Structure

```
src/
├── assets/main.css          # Tailwind import + @theme tokens
├── components/
│   ├── AppNavbar.vue        # sticky, responsive, auth-aware
│   ├── AppFooter.vue
│   └── PricingCard.vue
├── data/tiers.ts            # mock service tiers (edit pricing here)
├── router/index.ts          # routes, scroll + title + guard
├── stores/auth.ts           # mock login/logout
├── views/
│   ├── HomeView.vue         # hero, features, pricing (monthly/annual toggle), CTA
│   ├── DocsView.vue         # sidebar nav w/ scroll-spy, sections
│   ├── LoginView.vue        # email/password form, error + loading states
│   └── NotFoundView.vue
├── App.vue                  # layout shell
└── main.ts
```

## Mock auth

Any email + a password of 8+ chars logs in. Replace `login()` in `src/stores/auth.ts` with a real API call.

## Rebranding

- Name/logo - `AppNavbar.vue`, `LoginView.vue`, `index.html`
- Colors - `--color-brand-*` in `src/assets/main.css` (generates `bg-brand-600`, `text-brand-700`, etc.)
- Font - `--font-sans` in `main.css` + Google Fonts link in `index.html`
