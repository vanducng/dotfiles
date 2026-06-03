import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { docsSchema } from '@astrojs/starlight/schema';

// Keep authored content in the repo's top-level docs/ directory.
export const collections = {
  docs: defineCollection({
    loader: glob({ pattern: '**/[^_]*.{md,mdx}', base: './docs' }),
    schema: docsSchema(),
  }),
};
