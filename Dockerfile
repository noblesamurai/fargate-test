FROM node:12-slim

# Create working dir
RUN mkdir /app
WORKDIR /app

# Install our app
COPY index.js /app/

# Add random big file
RUN head -c 500M < /dev/urandom > bigfile

# Setup a non root user
RUN useradd -m app
USER app

# Default command to run
CMD ["node", "."]
