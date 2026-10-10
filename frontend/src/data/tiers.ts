export interface Tier {
  id: string
  name: string
  description: string
  /** USD per month; null = custom pricing */
  monthly: number | null
  /** USD per month when billed annually */
  annual: number | null
  features: string[]
  cta: string
  featured?: boolean
}

export const tiers: Tier[] = [
  {
    id: 'starter',
    name: 'Starter',
    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    monthly: 0,
    annual: 0,
    features: ['1 workspace', 'Up to 3 users', '1 GB storage', 'Community support'],
    cta: 'Get started',
  },
  {
    id: 'pro',
    name: 'Pro',
    description: 'Sed do eiusmod tempor incididunt ut labore et dolore magna.',
    monthly: 29,
    annual: 24,
    features: [
      'Unlimited workspaces',
      'Up to 25 users',
      '100 GB storage',
      'Advanced analytics',
      'Email support',
    ],
    cta: 'Start free trial',
    featured: true,
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    description: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco.',
    monthly: null,
    annual: null,
    features: [
      'Unlimited users',
      'Unlimited storage',
      'SSO & SCIM',
      'Audit logs',
      '99.99% uptime SLA',
      'Dedicated support',
    ],
    cta: 'Contact sales',
  },
]
