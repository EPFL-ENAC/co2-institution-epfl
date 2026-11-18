# EPFL institution folder for the CO2 Calculator

The [CO2 Calculator](https://github.com/EPFL-ENAC/co2-calculator) is the
same image for each institution. One folder, given at startup, makes it
the calculator of one institution. This repository holds the folder of
EPFL, and a small Helm chart that installs it on a cluster.

## The folder

The folder is `institution/`. The frontend reads it at startup.

| File                     | Content                                |
| ------------------------ | -------------------------------------- |
| `values.env`             | the public values: name, labels, links |
| `theme.conf`             | the accent color and the font URLs     |
| `logo.svg`, `favicon*`   | the EPFL logo and browser icons        |
| `login-illustration.svg` | the image behind the login card        |

The frontend stops at startup for three kinds of error:

- a file name that it does not know
- an empty required value
- a theme value with a wrong shape

The full rules are in the
[guide for a new institution](https://github.com/EPFL-ENAC/co2-calculator/blob/dev/docs/src/infra/08-new-institution.md).

> CAUTION: Do not put a secret in `values.env`. The frontend sends each
> `APP_*` value to each browser.

## Use the folder on your machine

1. Clone this repository next to `co2-calculator`.
2. Add this line to `co2-calculator/frontend/.env.local`.
3. Start the frontend dev server again.

```sh
INSTITUTION_DIR=../../co2-institution-epfl/institution
```

The path is relative to `co2-calculator/frontend/`. Off the EPFL network,
the font server does not answer, and the app shows the fallback font.

## Use the folder on a cluster

The chart makes one ConfigMap from the folder. Install it next to the
`co2-calculator` chart, and give its name to that chart.

```yaml
helmCharts:
  - name: co2-institution-epfl
    releaseName: co2-institution-epfl
    repo: oci://ghcr.io/epfl-enac/co2-institution-epfl/helm
    version: 1.0.1
  - name: co2-calculator
    valuesInline:
      frontend:
        institutionAssets:
          volume:
            configMap:
              name: co2-institution-epfl

replacements:
  - source:
      kind: ConfigMap
      name: co2-institution-epfl
      fieldPath: metadata.labels.[app.kubernetes.io/version]
    targets:
      - select:
          kind: Deployment
          name: co2-calculator-frontend
        fieldPaths:
          - spec.template.metadata.annotations.[co2-calculator/institution-version]
        options:
          create: true
```

The frontend reads the folder only at startup, and a change of a
ConfigMap does not restart a pod. The `replacements` block copies the
chart version into an annotation of the frontend pods. So a new chart
version changes the pods, and the cluster restarts them. You change one
line for a new version: `version`.

A value of the pod environment wins over a line of `values.env`. Thus
each cluster keeps its own values in its overlay: `APP_ENVIRONMENT`,
`APP_SENTRY_DSN`, `APP_MATOMO_*` and `APP_OPS_*`.

## Fonts

EPFL gives its fonts as URLs in `theme.conf`, because the license of the
brand font does not allow the files in a repository.

The folder is flat, because a ConfigMap key cannot contain `/`. To give
font files in place of URLs, put them at the top of `institution/` with
these names: `font-regular.woff2`, `font-medium.woff2` and
`font-bold.woff2`. A ConfigMap holds 1 MiB at most. If the fonts are
larger, use a font server and URLs.

## Change a value, a color or the logo

1. Change the file in `institution/`.
2. Increase `version` in `Chart.yaml`.
3. Open a pull request. The CI job renders the chart.
4. After the merge, push the tag of the new version, for example
   `v1.0.1`. The CI job publishes the chart.
5. In the operations repository, set the new chart version in each
   overlay.

If the tag and `Chart.yaml` give different versions, the CI job stops.

## Rights

The EPFL logo and name belong to EPFL. This repository gives no license
to use them. The values and the theme file have no creative content.
