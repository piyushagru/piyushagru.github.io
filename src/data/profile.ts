/**
 * Single source of truth for every fact shown on the site.
 * Only verified facts from raw/04-CONTENT-AND-FACTS.md belong here.
 */
export const profile = {
  name: 'Piyush Aggarwal',
  monogram: 'PA',
  role: 'Software Development Engineer II',
  company: 'Amazon Now',
  location: 'Bengaluru, India',
  focus: ['Distributed systems', 'Search', 'Quick commerce'],
  hero: {
    headline: ['I build systems that', 'make complexity feel'],
    accent: 'simple.',
    support:
      'Software engineer at Amazon Now. I own services end to end: search, ads and savings systems for quick commerce in India.',
  },
  contact: {
    email: 'piyushnoida14@gmail.com',
    github: 'https://github.com/piyushagru',
  },
} as const;

export const navigation = [
  { label: 'About', href: '#top' },
  { label: 'Engineering', href: '#engineering' },
  { label: 'Work', href: '#work' },
  { label: 'Experience', href: '#experience' },
  { label: 'Beyond', href: '#beyond' },
] as const;

export const ctas = {
  primary: { label: 'Explore my work', href: '#work' },
  secondary: { label: 'Get in touch', href: `mailto:${profile.contact.email}` },
  connect: { label: "Let's connect", href: `mailto:${profile.contact.email}` },
} as const;
