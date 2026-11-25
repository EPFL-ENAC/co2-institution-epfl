# The EPFL institution folder as an image.
#
# Why this exists: a Docker Compose host gets the folder with no git and
# no Helm. A cluster uses the Helm chart of this repository.
#
# Docker Compose mounts /institution of the image directly, read-only. The
# command is for a cluster that uses the image in place of the chart: an
# init container copies the folder into the volume at /out, then stops.
#
# busybox, not scratch: the copy needs sh, rm and cp. No RUN line, so the
# image builds for every platform without an emulator.
FROM busybox:1.37-musl

COPY institution/ /institution/

# Any user can run the copy: the files are world-readable, and a cluster
# gives its own user.
USER 65534

# Empty the volume first: a file removed from the folder must not stay
# after an upgrade.
CMD ["sh", "-c", "rm -rf /out/* && cp -R /institution/. /out/"]
