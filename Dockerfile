FROM node:18

WORKDIR /app

COPY package*.json ./
COPY ./prisma prisma
COPY ./dev.db /app/dev.db

USER root

RUN chmod -R u+w .

RUN chown root:root dev.db

RUN apt-get update -y && apt-get install -y openssl

RUN npm install

COPY . .

EXPOSE 3333

CMD ["npm", "start"]