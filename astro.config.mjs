import { defineConfig } from 'astro/config';

// GitHub Pages serves this repo at the apex user site, so base stays "/".
export default defineConfig({
  site: 'https://piyushagru.github.io',
  output: 'static',
  build: { inlineStylesheets: 'auto' },
  vite: {
    build: { target: 'es2022' },
  },
});
