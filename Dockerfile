# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install git (required for some dependencies)
RUN apk add --no-cache git

WORKDIR /.

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the source code
COPY . .

# Apply the required "hack" to aframe-extras
RUN sed -i '5,6s/schema: {/schema: {\n        lookAtTarget: {default: true},/' node_modules/aframe-extras/src/pathfinding/nav-agent.js && \
    sed -i '83s/if (data.lookAtTarget)/if (data.lookAtTarget)/' node_modules/aframe-extras/src/pathfinding/nav-agent.js

# Build the production bundle
RUN npm run build

# Stage 2: Serve static files with a minimal web server
FROM node:18-alpine

# Install a lightweight static server
RUN npm install -g serve

WORKDIR /app

# Copy the built files from the builder stage
COPY --from=builder /app/dist .

# Use the PORT environment variable provided by Cloud Run (default 8080)
ENV PORT=8080

# Expose the port
EXPOSE ${PORT}

# Start serve, binding to all interfaces, using the PORT
CMD serve -s . -l ${PORT}
