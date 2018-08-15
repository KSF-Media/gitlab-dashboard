# Stage 1
FROM node:10.8 as yarnbuild

WORKDIR /data
COPY . /data/

RUN yarn install --pure-lockfile --cache-folder .yarn-cache

# Stage 2
FROM nginx:1.14-alpine

COPY --from=yarnbuild /data/index.html /data/app.js /usr/share/nginx/html/
COPY --from=yarnbuild /data/node_modules /usr/share/nginx/html/node_modules/

EXPOSE 80

