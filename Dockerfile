FROM node:12-slim

ENV DEBIAN_FRONTEND noninteractive

# Install Xvfb
RUN apt-get update && apt-get upgrade -y && apt-get install -y xvfb

# Create working dir
RUN mkdir /app
WORKDIR /app

# Install Tini @see https://github.com/krallin/tini
# Note: xvfb-run forks the real Xvfb binary so we need to use something like tini
# as an entry point, otherwise xvfb-run hangs.
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /app/tini
RUN chmod +x /app/tini

# Install our app
COPY index.js /app/

# Add random big file
RUN head -c 500M < /dev/urandom > bigfile

# Setup a non root user
RUN useradd -m app
USER app

# Tiny entrypoint
ENTRYPOINT ["/app/tini", "--", "xvfb-run", "-s", "-ac -screen 0 1280x1024x24", "--", "exec"]

# Default command to run
CMD ["node", "."]
