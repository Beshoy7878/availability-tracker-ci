const express = require('express');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'admin',
  password: process.env.DB_PASSWORD || 'admin123',
  database: process.env.DB_NAME || 'availability',
});

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());

app.post('/save', async (req, res) => {
  const data = req.body; 
  try {
    for (const empId in data) {
      const weeks = data[empId];
      for (const week in weeks) {
        const days = weeks[week];
        await pool.query(
          'INSERT INTO availabilities (week, name, days) VALUES ($1, $2, $3) ON CONFLICT (week, name) DO UPDATE SET days = $3',
          [week, empId, JSON.stringify(days)]
        );
      }
    }
    res.sendStatus(200);
  } catch (err) {
    console.error(err);
    res.status(500).send('DB Error');
  }
});


// Serve static frontend
app.use(express.static(path.join(__dirname, 'public')));

// Serve input JSON files
app.use('/input', express.static(path.join(__dirname, 'input')));

// Serve output folder (for history.json)
app.use('/output', express.static(path.join(__dirname, 'output')));

// API to save history data
app.post('/save-history', (req, res) => {
  const historyPath = path.join(__dirname, 'output', 'history.json');
  const json = JSON.stringify(req.body, null, 2);

  fs.writeFile(historyPath, json, 'utf8', (err) => {
    if (err) {
      console.error('Error saving history.json:', err);
      res.status(500).send('Failed to save history.json');
    } else {
      console.log('History successfully saved.');
      res.status(200).send('Saved');
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
