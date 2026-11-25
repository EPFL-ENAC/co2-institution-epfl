# EPFL institution folder for the CO2 Calculator

The [CO2 Calculator](https://github.com/EPFL-ENAC/co2-calculator) is the
same image for each institution. One folder, given at startup, makes it
the calculator of one institution. This repository holds the folder of
EPFL, and the files that publish it as an image.

## The folder

The folder is `institution/`. The frontend reads it at startup.

| File                     | Content                                |
| ------------------------ | -------------------------------------- |
| `values.env`             | the public values: name, labels, links |
| `theme.conf`             | the accent color and the font URLs     |
| `logo.svg`, `favicon*`   | the EPFL logo and browser icons        |
| `login-illustration.svg` | the image behind the login card        |
| `offnet.html`            | the page for clients off the network   |

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

## The image

The image carries the folder to a cluster and to Docker Compose. The
folder is at `/institution` in the image. The command of the image copies
it into the volume at `/out`, then stops.

The image is `ghcr.io/epfl-enac/co2-institution-epfl`. Its tag is the
git tag, for example `v1.1.0`.

The image needs a `co2-calculator` version that knows `offnet.html`: the
first release after v1.5.3. An older frontend stops at startup on a file
name that it does not know. Change the app version and the image in the
same change.

### On a cluster

Give the image to the `co2-calculator` chart:

```yaml
helmCharts:
  - name: co2-calculator
    valuesInline:
      frontend:
        institutionAssets:
          image: ghcr.io/epfl-enac/co2-institution-epfl:v1.1.0
```

An init container runs the image before the frontend starts. A new tag
changes the pod template, so the cluster restarts the frontend pods. You
change one line for a new version.

A value of the pod environment wins over a line of `values.env`. Thus
each cluster keeps its own values in its overlay: `APP_ENVIRONMENT`,
`APP_SENTRY_DSN`, `APP_MATOMO_*` and `APP_OPS_*`.

### With Docker Compose

Set the image for `docker-compose.deploy.yml` of `co2-calculator`. The
frontend mounts the folder of the image directly, read-only:

```sh
INSTITUTION_IMAGE=ghcr.io/epfl-enac/co2-institution-epfl:v1.1.0
```

### The Helm chart of version 1.0.1

Versions up to 1.0.1 were a Helm chart that made one ConfigMap from the
folder. That chart stays in the registry for the overlays that still use
it. New versions are images only.

## The page for clients off the network

`offnet.html` is the page that a client outside the EPFL network gets.
That client gets no other file of the calculator. So the texts, the CSS,
the script, the logo and the background are all inside the file. Only
the font comes from the font server.

If you change `logo.svg` or `login-illustration.svg`, change the copy
inside `offnet.html` too. The background is the illustration as a
base64 `data:` URL.

## Fonts

EPFL gives its fonts as URLs in `theme.conf`, because the license of the
brand font does not allow the files in a repository.

The folder is flat. To give font files in place of URLs, put them at
the top of `institution/` with these names: `font-regular.woff2`,
`font-medium.woff2` and `font-bold.woff2`.

## Change a value, a color or the logo

1. Change the file in `institution/`.
2. Open a pull request. The CI job builds the image and runs its copy.
3. After the merge, push the tag of the new version, for example
   `v1.1.0`. The CI job publishes the image with that tag.
4. In the operations repository, set the new image tag in each overlay.

## Rights

The EPFL logo and name belong to EPFL. This repository gives no license
to use them. The values and the theme file have no creative content.
