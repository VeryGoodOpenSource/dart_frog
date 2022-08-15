// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/vsLight');
const darkCodeTheme = require('prism-react-renderer/themes/vsDark');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Dart Frog',
  tagline: 'A fast, minimalistic backend framework for Dart 🎯',
  url: 'https://dartfrog.vgv.dev',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',

  // GitHub pages deployment config.
  organizationName: 'VeryGoodOpenSource',
  projectName: 'dart_frog',
  trailingSlash: false,

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/meta/open-graph.png',
      navbar: {
        title: 'Dart Frog',
        logo: {
          alt: 'Dart Frog Logo',
          src: 'img/logo.svg',
          width: 32,
          height: 32,
        },
        items: [
          {
            label: 'Overview',
            to: '/docs/overview',
          },
          {
            label: 'Basics',
            to: '/docs/category/basics',
          },
          {
            label: 'Tutorials',
            to: '/docs/category/tutorials',
          },
          {
            label: 'Deploy',
            to: '/docs/category/deploy',
          },
          {
            label: 'Advanced',
            to: '/docs/category/advanced',
          },
          {
            label: 'Roadmap',
            to: '/docs/roadmap',
          },
          {
            to: 'https://github.com/VeryGoodOpenSource/dart_frog',
            position: 'right',
            className: 'navbar-github-icon',
            'aria-label': 'GitHub repository',
          },
          {
            to: 'https://verygood.ventures?utm_source=dartfrog&utm_medium=docs&utm_campaign=df',
            position: 'right',
            className: 'navbar-vgv-icon',
            'aria-label': 'Very Good Ventures',
          },
        ],
      },
      footer: {
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Overview',
                to: '/docs/overview',
              },
              {
                label: 'Basics',
                to: '/docs/category/basics',
              },
              {
                label: 'Tutorials',
                to: '/docs/category/tutorials',
              },
              {
                label: 'Deploy',
                to: '/docs/category/deploy',
              },
              {
                label: 'Advanced',
                to: '/docs/category/advanced',
              },
              {
                label: 'Roadmap',
                to: '/docs/roadmap',
              },
            ],
          },
          {
            title: 'Resources',
            items: [
              {
                label: 'Blog Post',
                href: 'https://verygood.ventures/blog/dart-frog?utm_source=dartfrog&utm_medium=docs&utm_campaign=df_blog',
              },
              {
                label: 'Livestream Demo',
                href: 'https://youtu.be/N7l0b09c6DA',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Open an Issue',
                href: 'https://github.com/verygoodopensource/dart_frog/issues/new/choose',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/verygoodopensource/dart_frog',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Very Good Ventures.<br/>Built with 💙 by <a target="_blank" rel="noopener" aria-label="Very Good Ventures" href="https://verygood.ventures">Very Good Ventures</a>.`,
      },
      prism: {
        additionalLanguages: ['bash', 'dart', 'yaml'],
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
