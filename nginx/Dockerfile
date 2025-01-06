# Create base image - in this case the official nginx image
FROM nginx

# Copy 'default.conf' file into the file system of this image and overwrite the existing 'default.conf' file
COPY ./default.conf /etc/nginx/conf.d/default.conf

# Configure the container to listen on port 80
EXPOSE 80



# ------------------------- EXPLANATION ------------------------- #
# Dockerfile is a text document containing instructions to automatically build a Docker container image.
# Dockerfile ensures same environment for all developers and production servers.