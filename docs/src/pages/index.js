import React, { Fragment } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';

import styles from './index.module.css';

function HomepageHeader() {
  return (
    <Fragment>
      <header className={clsx('hero', styles.heroBanner)}>
        <div className="container">
          <picture>
            <source
              media="(max-width: 479px)"
              srcSet="img/hero_image_dark_mobile.svg"
            />
            <source
              media="(min-width: 480px)"
              srcSet="img/hero_image_dark.svg"
            />
            <img src="img/hero_image_dark.svg" alt="Dart Frog Hero" />
          </picture>
        </div>
        <div className={styles.width}>
          <Link
            className="button button--primary button--lg"
            to="/docs/overview"
          >
            GET STARTED
          </Link>
          <Link
            className="button button--secondary button--lg"
            to="/docs/category/basics-"
          >
            LEARN MORE
          </Link>
        </div>
      </header>
    </Fragment>
  );
}

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
