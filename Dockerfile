# Source: https://github.com/ebidel/try-puppeteer/blob/master/backend/Dockerfile

FROM node:8-slim

# See https://crbug.com/795759
RUN apt-get update && apt-get -yq upgrade && apt-get install \
    && apt-get autoremove && apt-get autoclean

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
# https://www.ubuntuupdates.org/package/google_chrome/stable/main/base/google-chrome-unstable
RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

COPY fonts/liberation /usr/share/fonts/truetype/liberation
COPY fonts/msttcorefonts /usr/share/fonts/truetype/msttcorefonts

WORKDIR /app
COPY package.json package.json
RUN npm install
COPY dist dist

ENTRYPOINT ["npm", "start"]
