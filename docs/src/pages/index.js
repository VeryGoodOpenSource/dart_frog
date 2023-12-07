import React, { Fragment } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';
import { useColorMode } from '@docusaurus/theme-common';

export default function Home() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      description={`The official documentation site for Dart Frog. ${siteConfig.tagline} Built by Very Good Ventures.`}
    >
      <HomepageHeader />
      <main className={styles.main}>
        <HomepageFeatures />
        <HomepageBlogs />
      </main>
    </Layout>
  );
}

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  const { colorMode } = useColorMode();
  return (
    <Fragment>
      <header className={clsx('hero', styles.heroBanner)}>
        <div className="container">
          <img
            className={clsx(styles.heroLogo)}
            src={
              colorMode == 'dark'
                ? 'img/dart_frog_full_logo_dark.svg'
                : 'img/dart_frog_full_logo.svg'
            }
            alt="Very Good Workflows Logo"
          />
        </div>
        <HeroImage />
        <CTAs />
      </header>
    </Fragment>
  );
}

function HeroImage() {
  return (
    <div className="container">
      <picture>
        <source media="(min-width: 480px)" srcSet="img/hero_image_dark.svg" />
        <img
          src="img/hero_image_dark.svg"
          alt="Dart Frog Hero"
          width="688"
          height="428"
        />
      </picture>
    </div>
  );
}

function CTAs() {
  return (
    <div className={styles.width}>
      <Link className="button button--primary button--lg" to="/docs/overview">
        Get Started
      </Link>
      <Link
        className="button button--secondary button--lg"
        to="/docs/category/basics"
      >
        Learn More
      </Link>
    </div>
  );
}

function Feature({ Svg, title, description }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

const FeatureList = [
  {
    title: 'Built for Speed',
    Svg: require('@site/static/img/fast.svg').default,
    description: (
      <>
        Create new endpoints in just a few lines and iterate blazingly fast with
        hot reload.
      </>
    ),
  },
  {
    title: 'Lightweight',
    Svg: require('@site/static/img/lightweight.svg').default,
    description: (
      <>Minimize ramp-up time with our simple core and small API surface.</>
    ),
  },
  {
    title: 'Powered by Dart',
    Svg: require('@site/static/img/dart.svg').default,
    description: (
      <>
        Tap into the powerful Dart ecosystem with{' '}
        <Link to="https://pub.dev/packages/shelf">Shelf</Link>,{' '}
        <Link to="https://dart.dev/tools/dart-devtools">DevTools</Link>,{' '}
        <Link to="https://dart.dev/guides/testing">testing</Link>, and more.
      </>
    ),
  },
];

function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}

function HomepageBlogs() {
  return (
    <div className={`${styles.section}`}>
      <div className={styles.width}>
        <div className={styles.column}>
          <img
            style={{ height: 'auto' }}
            src="https://uploads-ssl.webflow.com/5ee12d8e99cde2e20255c16c/64c7f8b7022291aa80ec30bd_DF1.png"
            alt="Dart Frog 1.0 is here"
            width="452"
            height="254"
          />
        </div>
        <div className={styles.column}>
          <div className={styles.content}>
            <Heading as="h2">Dart Frog 1.0 is here! 🎉</Heading>
            <p>
              Announcing Dart Frog 1.0! Learn about the main features of this
              release, the history of Dart Frog, and why you should consider
              using it in your projects.
            </p>
            <Link
              style={{ fontWeight: 'bold' }}
              to="https://verygood.ventures/blog/dart-frog-1-0-release"
            >
              Read the Blog <ExternalLinkIcon />
            </Link>
          </div>
        </div>
      </div>
      <div style={{ padding: '1rem' }}></div>
      <div className={styles.width}>
        <div className={styles.column}>
          <img
            style={{ height: 'auto' }}
            src="https://uploads-ssl.webflow.com/5ee12d8e99cde2e20255c16c/63befc9d00bc927526667313_Full%20Stack%20DF.png"
            alt="Dart on the server with Dart Frog"
            width="452"
            height="254"
          />
        </div>
        <div className={styles.column}>
          <div className={styles.content}>
            <Heading as="h2">Dart Frog full stack tutorial</Heading>
            <p>
              Learn how to build a real-time Flutter counter app using
              WebSockets and Dart Frog.
            </p>
            <Link
              style={{ fontWeight: 'bold' }}
              to="https://verygood.ventures/blog/dart-frog-full-stack-tutorial"
            >
              Read the Blog <ExternalLinkIcon />
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

function ExternalLinkIcon() {
  return (
    <svg
      width="13.5"
      height="13.5"
      aria-hidden="true"
      viewBox="0 0 24 24"
      className="iconExternalLink_node_modules-@docusaurus-theme-classic-lib-theme-IconExternalLink-styles-module"
    >
      <path
        fill="currentColor"
        d="M21 13v10h-21v-19h12v2h-10v15h17v-8h2zm3-12h-10.988l4.035 4-6.977 7.07 2.828 2.828 6.977-7.07 4.125 4.172v-11z"
      ></path>
    </svg>
  );
}
