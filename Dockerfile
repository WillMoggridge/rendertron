FROM ubuntu:xenial

# System dependencies
RUN apt-get update && apt-get install --yes curl xz-utils

# Get nodejs
RUN mkdir /usr/lib/nodejs && \
    curl https://nodejs.org/dist/v8.9.1/node-v8.9.1-linux-x64.tar.xz | tar -xJ -C /usr/lib/nodejs && \
    mv /usr/lib/nodejs/node-v8.9.1-linux-x64 /usr/lib/nodejs/node-v8.9.1

# Set nodejs paths
ENV NODEJS_HOME=/usr/lib/nodejs/node-v8.9.1
ENV PATH=$NODEJS_HOME/bin:$PATH

# Node dependencies
RUN npm install --global yarn

LABEL name="bot-render" \
      version="0.1" \
      description="Renders a webpage for bot consumption (not production ready)"

RUN apt-get update && apt-get install -y \
  wget \
  --no-install-recommends \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update && apt-get install -y \
  google-chrome-stable \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

COPY . /app/
WORKDIR /app/

# Add botrender as a user
RUN groupadd -r botrender && useradd -r -g botrender -G audio,video botrender \
    && mkdir -p /home/botrender && chown -R botrender:botrender /home/botrender \
    && chown -R botrender:botrender /app

# Run botrender non-privileged
USER botrender

EXPOSE 8080
ENV PORT=8080

RUN npm install || \
  ((if [ -f npm-debug.log ]; then \
      cat npm-debug.log; \
    fi) && false)


ENTRYPOINT [ "npm" ]
CMD ["run", "start"]
