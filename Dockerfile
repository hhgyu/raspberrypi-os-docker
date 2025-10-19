ARG BASE_CONTAINER
FROM $BASE_CONTAINER

COPY image/ /

RUN set -e && dpkg --add-architecture armhf && . /etc/os-release && CODENAME="$VERSION_CODENAME" \
 && echo "deb http://archive.raspberrypi.org/debian/ ${CODENAME} main" > /etc/apt/sources.list.d/raspi.list \
 && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
 && PKGS="" \
 && case "$CODENAME" in \
      bullseye) PKGS="libraspberrypi0 libraspberrypi-bin" ;; \
      bookworm|trixie|sid) PKGS="raspi-utils-core raspi-utils-dt" ;; \
      *) echo "Unknown codename: ${CODENAME} → skipping Raspberry Pi packages." ;; \
    esac \
 && if [ -n "$PKGS" ]; then \
      TO_INSTALL=""; \
      for p in $PKGS; do \
        if apt-cache show "$p" >/dev/null 2>&1; then TO_INSTALL="$TO_INSTALL $p"; \
        else echo "Package not found: $p (skipped)"; fi; \
      done; \
      if [ -n "$TO_INSTALL" ]; then \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $TO_INSTALL; \
      else \
        echo "No valid Raspberry Pi packages to install. Skipping."; \
      fi; \
    fi \
 && rm -rf /var/lib/apt/lists/*