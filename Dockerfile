FROM node:18-alpine

# Install git (required by some npm dependencies)
RUN apk add --no-cache git

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application source code
COPY . .

# Apply the required "hack" to aframe-extras (as per README)
RUN sed -i '5,6s/schema: {/schema: {\n        lookAtTarget: {default: true},/' node_modules/aframe-extras/src/pathfinding/nav-agent.js && \
    sed -i '83s/if (data.lookAtTarget)/if (data.lookAtTarget)/' node_modules/aframe-extras/src/pathfinding/nav-agent.js

# Expose the port used by webpack-dev-server
EXPOSE 8080

# Start the development server with host binding and allowed hosts
CMD ["npm", "start", "--", "--host", "0.0.0.0", "--allowed-hosts", "all"]
