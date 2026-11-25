# The EPFL institution folder as an image.
#
# Why this exists: a cluster and a Docker Compose host get the folder
# with a version, and with no git on the host.
#
# Docker Compose, or a cluster with image volumes, mounts /institution of
# the image directly, read-only. The command is for an init container: it
# copies the folder into the volume at /out, then stops.
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
