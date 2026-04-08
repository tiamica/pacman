FROM node:18-alpine

WORKDIR /.

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application source code
COPY . .

# Apply the required "hack" to aframe-extras (as per README)
RUN sed -i '5,6s/schema: {/schema: {\n        lookAtTarget: {default: true},/' node_modules/aframe-extras/src/pathfinding/nav-agent.js && \
    sed -i '83s/if (data.lookAtTarget)/if (data.lookAtTarget)/' node_modules/aframe-extras/src/pathfinding/nav-agent.js

# Expose the port used by webpack-dev-server (default 8080)
EXPOSE 8080

# Start the development server, binding to 0.0.0.0 to allow external access
CMD ["npm", "start", "--", "--host", "0.0.0.0"]
