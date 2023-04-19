# Stage 1
FROM node:16 as yarnbuild

WORKDIR /data
COPY . /data/

RUN npm install -g spago
RUN yarn install --pure-lockfile --cache-folder .yarn-cache
RUN yarn build

# Stage 2
FROM nginx:1.14-alpine

COPY --from=yarnbuild /data/index.html /data/index.js /usr/share/nginx/html/
COPY --from=yarnbuild /data/node_modules /usr/share/nginx/html/node_modules/

EXPOSE 80

