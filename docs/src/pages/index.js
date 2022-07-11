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
          <img
            src="img/hero_image_dark.svg"
            alt="Dart Frog Hero"
            width="656"
            height="412"
          />
        </div>
      </header>
    </Fragment>
  );
}

function HomepageCTA() {
  return (
    <Fragment>
      <div className={styles.cta}>
        <div className={styles.logo}>
          <img src="img/logo.svg" alt="Dart Frog Logo" width="58" height="58" />
          <h1 className={styles.heading}>Dart Frog</h1>
        </div>
        <Link className="button button--primary button--lg" to="/docs/overview">
          GET STARTED
        </Link>
      </div>
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
      <main>
        <HomepageCTA />
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
