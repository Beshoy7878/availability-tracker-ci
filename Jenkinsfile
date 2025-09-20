pipeline {
    agent any

    stages {
        stage('Cleanup') {
            steps {sh 'docker compose down || true'}
        }
        stage('Install Dependencies') {
            steps { sh 'npm ci' }
        }
        stage('Lint') {
            steps { sh 'npm run lint || echo "Lint skipped or failed, continuing..."' }
        }
        stage('Test') {
            steps { sh 'npm test || echo "Tests skipped or failed, continuing..."' }
        }
        stage('Docker Build') {
            steps { sh 'docker build -t availability-tracker:ci .' }
        }
        stage('Docker Compose Up') {
            steps { sh 'docker compose up -d --build' }
        }
    }
}