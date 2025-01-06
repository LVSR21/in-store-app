# Create base image
FROM node:16-alpine

# Create current working directory ('app')
WORKDIR '/app'

# Copy dependencies (packege.json) from the root of 'server' directory to the root of the current working directory ('app')
COPY ./package.json ./

# Install dependencies inside the container
RUN npm install

# Copy all the files and folder from the root of my 'server' directory to the root of the current working directory ('app')
COPY . .

# Configure the container to listen on port 5000
EXPOSE 5000

# Define default command to run when the container starts
CMD ["npm", "run", "start"]



# ------------------------- EXPLANATION ------------------------- #
# Dockerfile is a text document containing instructions to automatically build a Docker container image.
# Dockerfile ensures same environment for all developers and production servers.