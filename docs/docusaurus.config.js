// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Dart Frog',
  tagline: 'A fast, minimalistic backend framework for Dart 🎯',
  url: 'https://VeryGoodOpenSource.github.io',
  baseUrl: '/dart_frog/',
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
            'https://github.com/verygoodventures/dart_frog/tree/main/docs/',
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
            type: 'doc',
            docId: 'overview',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/verygoodopensource/dart_frog',
            label: 'GitHub',
            position: 'right',
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
            ],
          },
          {
            title: 'Resources',
            items: [
              {
                label: 'Blog Post',
                href: 'https://verygood.ventures/blog/dart-frog',
              },
              {
                label: 'Livestream Demo',
                href: 'https://youtu.be/N7l0b09c6DA',
              },
              {
                label: 'Roadmap',
                href: 'https://github.com/VeryGoodOpenSource/dart_frog/blob/main/ROADMAP.md',
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
        copyright: `Copyright © ${new Date().getFullYear()} Very Good Ventures.<br/>Built with 💙 by Very Good Ventures.`,
      },
      prism: {
        additionalLanguages: ['dart'],
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
