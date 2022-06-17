import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Build Fast',
    Svg: require('@site/static/img/bolt.svg').default,
    description: (
      <>
        Create new endpoints in just a few lines and iterate blazingly fast with
        hot reload.
      </>
    ),
  },
  {
    title: 'Beginner Friendly',
    Svg: require('@site/static/img/heart.svg').default,
    description: (
      <>Minimize ramp-up time with our simple core and small API surface.</>
    ),
  },
  {
    title: 'Powered by Dart',
    Svg: require('@site/static/img/target.svg').default,
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

export default function HomepageFeatures() {
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
