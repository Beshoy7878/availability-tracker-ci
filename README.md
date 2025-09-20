# Availability Tracker CI/CD Project

This repository contains my internship project to build a local CI/CD pipeline for the **Availability Tracker** application.

---

# Step 1 – Project Setup
- Cloned the repository and explored the structure.
- Identified that the project is **Node.js** (because of `server.js` and `package.json`).
- Installed Node.js and npm on my RedHat VM.
- Installed dependencies using:
  `npm install`
Successfully ran the app locally using:
  `npm start`
Opened the browser and verified the app works.

---

# Step 2 – CI Script (ci.sh)
-Created a Bash script to simulate a CI pipeline locally.

-The script does the following:

1- Checks if node and npm are installed.

2-Installs dependencies (npm ci or npm install).

3-Runs lint if defined in package.json.

4-Runs tests if defined (skips the default stub).

5-Builds Docker image if Dockerfile exists.

6-Runs services with docker-compose if config exists.

Script is fully commented to explain every line.

---

# Step 3 – Dockerize the Application (Dockerfile)

To containerize the Node.js application, I created a `Dockerfile` with the following content:

`dockerfile
FROM node:18-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]`

 Explanation of Each Line:
 
1-FROM node:18-slim : Use a lightweight and stable Node.js 18 base image.

2-WORKDIR /usr/src/app : Set the working directory inside the container.

3-COPY package.json ./* : Copy only dependency files first for better build caching.

4-RUN npm install --production : Install only production dependencies (smaller and safer image).

5-COPY . . : Copy the rest of the application source code.

6-EXPOSE 3000 : Open port 3000 for the app to be accessed externally.

7-CMD ["npm", "start"] : Default command to run the app when the container starts.

How to Build and Run the Docker Image:

 Build the Docker image

docker build -t availability-tracker:1.0 .

 Run the container on port 3000

docker run -p 3000:3000 availability-tracker:1.0

After running the container, open your browser at:

http://localhost:3000

to see the application running inside Docker.

---

---

# Step 4 – Docker Compose

To manage the application and its dependencies, I created a `docker-compose.yml` file.

`yaml
version: "3.9"
services:
  app:
    build: .
    container_name: availability-tracker
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - redis
    restart: unless-stopped
  redis:
    image: redis:7-alpine
    container_name: availability-redis
    ports:
      - "6379:6379"
    restart: unless-stopped `

How to Run:

docker compose up -d --build

Opens the app on : 

http://localhost:3000

Runs Redis on port 6379.

Automatically restarts services unless manually stopped.

--------------------------------------------------------
---

## Step 5 – Validation & Documentation

I validated that each part of the pipeline works correctly:

1- CI Script (`ci.sh`)
   - Runs dependency installation, lint (if available), test (if available), Docker build, and Docker Compose.
   - Example run:
     `bash
     ./ci.sh
     `

2- Dockerfile
   - Builds a lightweight Node.js image.
   - Run locally:
     `bash
     docker build -t availability-tracker:test .
     docker run -p 3000:3000 availability-tracker:test
     `
   - Verified the application works in the browser.

3- Docker Compose
   - Manages the app and Redis together.
   - Run:
     `bash
     docker compose up -d --build
     `
   - Both containers start successfully (`availability-tracker`, `availability-redis`).

---

## Step 6 – Database Integration (PostgreSQL)

Extended docker-compose.yml to include PostgreSQL service:

db:
  image: postgres:15-alpine
  container_name: availability-db
  environment:
    POSTGRES_USER: admin
    POSTGRES_PASSWORD: admin123
    POSTGRES_DB: availability
  ports:
    - "5432:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data


Updated app service with DB environment variables:

DB_HOST=db, DB_PORT=5432, DB_USER=admin, DB_PASSWORD=admin123, DB_NAME=availability


Modified server.js to use pg.Pool and add /save endpoint.

Data is stored in availabilities table:

SELECT * FROM availabilities;

-----

## Step 7 – Jenkins Pipeline (CI/CD)

Added a Jenkinsfile for automated pipeline:

Jenkins pipeline now:

-Cleans up old containers.

-Installs dependencies.

-Runs lint & tests (non-blocking).

-Builds Docker image.

-Runs app + Redis + PostgreSQL via docker-compose.

-----

## Notes / Fixes

Fixed DB issue by adding depends_on: [redis, db] in docker-compose and modifying server.js with correct PostgreSQL integration.

Validated end-to-end: app saves data into PostgreSQL (availabilities table

### How to Run Everything
To run the full pipeline locally:
`bash
chmod +x ci.sh
./ci.sh
`
ذذ
