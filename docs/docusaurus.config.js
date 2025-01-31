// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer').themes.vsLight;
const darkCodeTheme = require('prism-react-renderer').themes.vsDark;

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
            to: '/docs/overview',
            label: 'Get Started',
            position: 'right',
            className: 'button nav-button',
          },
          {
            label: 'VGV Dev Tools',
            to: 'https://verygood.ventures/dev',
            position: 'right',
          },
          {
            href: 'https://verygood.ventures',
            position: 'right',
            className: 'navbar-vgv-icon',
            'aria-label': 'VGV website',
          },
          {
            to: 'https://github.com/VeryGoodOpenSource/dart_frog',
            position: 'right',
            className: 'navbar-github-icon',
            'aria-label': 'GitHub repository',
          },
        ],
      },
      footer: {
        copyright: `Built with 💙 by <a target="_blank" rel="noopener" aria-label="Very Good Ventures" href="https://verygood.ventures"><b>Very Good Ventures</b>.</a><br/>Copyright © ${new Date().getFullYear()} Very Good Ventures.`,
      },
      prism: {
        additionalLanguages: ['bash', 'dart', 'docker', 'yaml'],
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
