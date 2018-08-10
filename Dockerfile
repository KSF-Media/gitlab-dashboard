FROM node:10.6.0

WORKDIR /data
COPY . /data/

RUN npm install
RUN npm run install
RUN npm install http-server -g

EXPOSE 80
CMD http-server -p 80
