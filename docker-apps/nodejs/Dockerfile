FROM node:12.16.3
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
RUN npm run lint && npm run test
CMD [ "npm", "start" ]