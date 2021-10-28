FROM node:14-alpine

ARG VERSION=1.0.0
WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 80
ENV VERSION=${VERSION}

ENTRYPOINT [ "npm", "start" ]