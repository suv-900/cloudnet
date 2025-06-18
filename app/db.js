// Try loading .env file if it exists
try {
  require('dotenv').config();
  console.log('.env file loaded');
} catch (err) {
  console.log('No .env file found, using system environment variables');
}

const sql = require('mssql');

// Build config using process.env (works for both .env and real env vars)
const config = {
  user: process.env.SQL_USER,
  password: process.env.SQL_PASSWORD,
  server: process.env.SQL_SERVER,
  database: process.env.SQL_DATABASE,
  options: {
    encrypt: process.env.SQL_ENCRYPT === 'true',
    enableArithAbort: true,
  },
};

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    console.log('Connected to Azure SQL Database');
    return pool;
  })
  .catch(err => {
    console.error('Database connection failed!', err);
    throw err;
  });

module.exports = {
  sql, poolPromise,
};
