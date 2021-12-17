ARG BUILD_FROM=ghcr.io/hassio-addons/base/aarch64:11.0.0
FROM ${BUILD_FROM}

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG LIBRESPOT_JAVA_VERSION=1.6.2
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION


# Install openjdk and librespot-player
RUN apk add --no-cache openjdk11 && \
    wget https://github.com/librespot-org/librespot-java/releases/download/v${LIBRESPOT_JAVA_VERSION}/librespot-player-${LIBRESPOT_JAVA_VERSION}.jar -O /bin/librespot-player.jar

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Alex Babel <alexander.babel@icloud.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="AlexanderBabel Addons" \
    org.opencontainers.image.authors="Alex Babel <alexander.babel@icloud.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
