try {
  require('dotenv').config();
  console.log('.env file loaded');
} catch (err) {
  console.log('No .env file found, using system environment variables');
}

const express = require('express');
const { poolPromise } = require('./db');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Node.js App Connected to Azure SQL!');
});

app.get('/users', async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request().query('SELECT * FROM Users');
    res.json(result.recordset);
  } catch (err) {
    console.error('SQL error', err);
    res.status(500).send('Server error');
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
