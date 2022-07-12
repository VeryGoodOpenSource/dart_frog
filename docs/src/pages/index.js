import React, { Fragment } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';

export default function Home() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      description={`The official documentation site for Dart Frog. ${siteConfig.tagline} Built by Very Good Ventures.`}
    >
      <HomepageHeader />
      <main className={styles.main}>
        <HomepageFeatures />
        <HomepageVideos />
        <HomepageBlogs />
      </main>
    </Layout>
  );
}

function HomepageHeader() {
  return (
    <Fragment>
      <header className={clsx('hero', styles.heroBanner)}>
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
        <source
          media="(max-width: 479px)"
          srcSet="img/hero_image_dark_mobile.svg"
        />
        <source media="(min-width: 480px)" srcSet="img/hero_image_dark.svg" />
        <img src="img/hero_image_dark.svg" alt="Dart Frog Hero" />
      </picture>
    </div>
  );
}

function CTAs() {
  return (
    <div className={styles.width}>
      <Link className="button button--primary button--lg" to="/docs/overview">
        GET STARTED
      </Link>
      <Link
        className="button button--secondary button--lg"
        to="/docs/category/basics-"
      >
        LEARN MORE
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
        <h3>{title}</h3>
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
        <a href="https://pub.dev/packages/shelf">Shelf</a>,{' '}
        <a href="https://dart.dev/tools/dart-devtools">DevTools</a>,{' '}
        <a href="https://dart.dev/guides/testing">testing</a>, and more.
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

function HomepageVideos() {
  return (
    <div className={`${styles.section}`}>
      <iframe
        className="video"
        src="https://www.youtube.com/embed/N7l0b09c6DA"
        title="Very Good Livestream: Dart Frog Demo"
        frameBorder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      ></iframe>
    </div>
  );
}

function HomepageBlogs() {
  return (
    <div className={`${styles.section}`}>
      <div className={styles.width}>
        <div className={styles.column}>
          <img
            src="https://uploads-ssl.webflow.com/5ee12d8e99cde2e20255c16c/628d211e83529f3a59ce7854_Dart%20Frog%200.5.jpg"
            alt="Dart on the server with Dart Frog"
          />
        </div>
        <div className={styles.column}>
          <div className={styles.content}>
            <h2>Dart on the server with Dart Frog</h2>
            <p>
              Dart Frog can help Flutter and Dart developers maximize their
              productivity by having a unified tech stack that enables sharing
              tooling, models, and more! Here's how to get started.
            </p>
            <Link style={{ fontWeight: 'bold' }} to="/docs/overview">
              READ THE BLOG <ExternalLinkIcon />
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
