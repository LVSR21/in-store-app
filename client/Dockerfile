# Build Stage - Use Node.js 16 Alpine as base image for building
FROM node:16-alpine as builder

# Set working directory for build stage
WORKDIR '/app'

# Copy package.json first to leverage Docker layer caching
COPY ./package.json ./

# Install dependencies
RUN npm install

# Copy all source files
COPY . .

# Build the React application
RUN npm run build

# Production Stage - Use nginx as production server
FROM nginx

# Configure the container to listen on port 3000
EXPOSE 3000

# Copy custom nginx configuration
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy built files from builder stage to nginx web root
COPY --from=builder /app/build /usr/share/nginx/html



# ------------------------- EXPLANATION ------------------------- #
# Dockerfile is a text document containing instructions to automatically build a Docker container image.
# Dockerfile ensures same environment for all developers and production servers.

# Dockerfile with 'as builder' is a multi-stage build used for production.
# It has two stages: 'builder' and 'nginx'.
# The 'builder' stage is used to build the React application and the 'nginx' stage is used to serve the built files.
# The Dockerfile without the 'builder' is a single stage build used for development.