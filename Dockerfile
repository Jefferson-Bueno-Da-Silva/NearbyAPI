# Use uma imagem base oficial do Node.js
FROM node:18

# create a user with permissions to run the app
# -S -> create a system user
# -G -> add the user to a group
# This is done to avoid running the app as root
# If the app is run as root, any vulnerability in the app can be exploited to gain access to the host system
# It's a good practice to run the app as a non-root user
# RUN addgroup app && adduser --system --group app app

# set the user to run the app
# USER app

# set the working directory to /app
WORKDIR /app

# copy package.json and package-lock.json to the working directory
# This is done before copying the rest of the files to take advantage of Docker’s cache
# If the package.json and package-lock.json files haven’t changed, Docker will use the cached dependencies
COPY package*.json ./
COPY ./prisma prisma
COPY ./dev.db /app/dev.db

# sometimes the ownership of the files in the working directory is changed to root
# and thus the app can't access the files and throws an error -> EACCES: permission denied
# to avoid this, change the ownership of the files to the root user
USER root

# Ensure write permissions for the app directory and its contents
RUN chmod -R u+w .

# change the ownership of the /app directory to the app user
# chown -R <user>:<group> <directory>
# chown command changes the user and/or group ownership of for given file.
# RUN chown -R app:app .

# As root, change the ownership of dev.db to app user
RUN chown root:root dev.db

RUN apt-get update -y && apt-get install -y openssl

# change the user back to the app user
# USER app

# init prisma
# RUN npx prisma generate --schema=./prisma/schema.prisma

# install dependencies
RUN npm install

# copy the rest of the files to the working directory
COPY . .

# expose port 3000 to tell Docker that the container listens on the specified network ports at runtime
EXPOSE 3333

# command to run the app
CMD ["npm", "start"]