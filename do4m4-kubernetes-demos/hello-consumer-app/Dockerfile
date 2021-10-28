FROM node:14-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 80

ENTRYPOINT [ "npm", "start" ]