# Use a lightweight base image with Node.js
FROM node:18-slim

# Set working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Expose the port (the same port your app runs on, e.g., 3000)
EXPOSE 3000

# Command to start the app
CMD ["npm", "start"]
