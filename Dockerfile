# Base Image
FROM node:14-alpine

WORKDIR /usr/app

ENV PORT=3000

EXPOSE 3000

COPY ./package.json ./
RUN npm install
COPY ./src/app.js ./app.js

CMD ["node", "app.js"]