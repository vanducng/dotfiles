// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import remarkGfm from 'remark-gfm';

export default defineConfig({
  site: 'https://dotfiles.vanducng.dev',
  markdown: { remarkPlugins: [remarkGfm] },
  integrations: [
    starlight({
      title: 'dotfiles',
      description:
        'AI-enhanced macOS development environment — tiling window management, terminal workflows, and integrated AI coding.',
      customCss: ['./src/styles/theme.css'],
      components: {
        ThemeSelect: './src/components/ThemeSelect.astro',
        SocialIcons: './src/components/SocialIcons.astro',
      },
      lastUpdated: true,
      sidebar: [
        { label: 'Overview', link: '/' },
        {
          label: 'Getting Started',
          items: ['installation', 'quick-reference'],
        },
        {
          label: 'Core Tools',
          items: ['neovim', 'tmux', 'atuin', 'skhd', 'zen-mode'],
        },
        {
          label: 'AI Tools',
          items: ['ai', 'ai/codex', 'ai/workflows', 'ai/best-practices'],
        },
        {
          label: 'Workflows',
          items: ['workflows', 'workflows/coding', 'workflows/database', 'workflows/review'],
        },
        {
          label: 'Troubleshooting',
          items: [
            'troubleshooting',
            'troubleshooting/window-management',
            'troubleshooting/terminal',
            'troubleshooting/neovim',
            'troubleshooting/ai-tools',
            'troubleshooting/performance',
          ],
        },
        {
          label: 'Reference',
          items: ['codebase-summary'],
        },
      ],
    }),
  ],
});
