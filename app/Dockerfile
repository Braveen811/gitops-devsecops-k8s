# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci 
COPY . .

# Stage 2: Production
FROM node:20-alpine
WORKDIR /usr/src/app

# Run as non-root user for security (DevSecOps best practice)
USER node

COPY --from=builder --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=node:node /usr/src/app/package*.json ./
COPY --from=builder --chown=node:node /usr/src/app/src ./src

EXPOSE 3000
CMD ["npm", "start"]