# Use a specific Node.js version
FROM node:12.18.3 AS build

# Set the working directory
WORKDIR /srv

# Copy package.json separately for caching dependencies
COPY package.json .

# Install Node.js dependencies
RUN npm install

# Second Stage: Use a smaller Node.js Alpine image
FROM node:12.18.3-alpine

# Set the working directory in the second stage
WORKDIR /srv

# Copy from the build stage
COPY --from=build /srv .

# Add application files
ADD ./index.js index.js

# Expose port 80
EXPOSE 80

# Use a non-root user
USER node

# Start the Node.js application
CMD ["node", "index.js"]

