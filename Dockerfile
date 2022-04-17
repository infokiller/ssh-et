ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}-slim
# We must declare the ARG again so we can use it after the FROM
ARG DEBIAN_VERSION
# Install ssh, curl, and gpg (required for apt-key).
RUN DEBIAN_FRONTEND=noninteractive apt-get \
    -o DPkg::options::="--force-confdef" \
    -o DPkg::options::="--force-confold" \
    update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get \
      -o DPkg::options::="--force-confdef" \
      -o DPkg::options::="--force-confold" \
      install --no-install-recommends -y ssh curl ca-certificates
# Install ET
# https://eternalterminal.dev/download/
RUN echo "deb [signed-by=/usr/share/keyrings/et.gpg] https://mistertea.github.io/debian-et/debian-source/ ${DEBIAN_VERSION} main" > /etc/apt/sources.list.d/et-${DEBIAN_VERSION}.list \
  && curl -fsSL https://mistertea.github.io/debian-et/et.gpg -o /tmp/et.gpg \
  && install -o root -g root -m 644 /tmp/et.gpg /usr/share/keyrings/ \
  && DEBIAN_FRONTEND=noninteractive apt-get \
    -o DPkg::options::="--force-confdef" \
    -o DPkg::options::="--force-confold" \
    update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get \
      -o DPkg::options::="--force-confdef" \
      -o DPkg::options::="--force-confold" \
      install --no-install-recommends -y et \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
# Create an unprivileged user
RUN useradd --create-home --user-group user
WORKDIR /home/user
USER user
COPY --chown=user ssh-et test-ssh-et-from-docker ./
ENTRYPOINT ["/home/user/test-ssh-et-from-docker"]
