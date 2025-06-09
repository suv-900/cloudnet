# Node.js Azure SQL App

This project is a simple Node.js application using Express.js that connects to an Azure SQL Database. It demonstrates how to load environment variables, connect to a SQL database, and expose basic API endpoints.

## Features

- Loads configuration from `.env` file if present, otherwise uses system environment variables
- Connects to Azure SQL Database using a connection pool
- Provides REST API endpoints:
  - `GET /` — Health check endpoint
  - `GET /users` — Returns all users from the `Users` table

## Prerequisites

- Node.js (v14+ recommended)
- An Azure SQL Database instance
- A `.env` file with your database credentials (optional, see below)

## Setup

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd nodejs-app
   ```

2. **Install dependencies:**
   ```sh
   npm install
   ```

3. **Configure environment variables:**

   You can either create a `.env` file in the project root with the following content:
   ```
   PORT=3000
   SQL_USER=<your-sql-username>
   SQL_PASSWORD=<your-sql-password>
   SQL_SERVER=<your-sql-server-name>.database.windows.net
   SQL_DATABASE=<your-database-name>
   SQL_ENCRYPT=true
   ```
   Or set these variables directly in your system environment if you do not wish to use a `.env` file.

4. **Create database tables:**

   After your Azure SQL Database is created, run the SQL scripts in the `sql` folder to set up the required tables (such as `Users`).  
   You can do this using tools like [Azure Data Studio](https://learn.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio) or [SQL Server Management Studio (SSMS)](https://aka.ms/ssms):

   - Open your SQL client and connect to your Azure SQL Database.
   - Open the `.sql` files from the `sql` folder.
   - Execute the scripts to create tables and insert any initial data.

5. **Start the application:**
   ```sh
   node app.js
   ```

   The server will run at [http://localhost:3000](http://localhost:3000).

## API Endpoints

- `GET /`  
  Returns a welcome message.

- `GET /users`  
  Returns a JSON array of users from the `Users` table in your Azure SQL Database.

## Project Structure

```
nodejs-app/
├── app.js
├── db.js
├── package.json
├── sql/
│   └── <your-sql-scripts>.sql
└── .env (optional)
```

## Notes

- Ensure your Azure SQL Database firewall allows connections from your IP.
- The `Users` table must exist in your database.
- If `.env` is not present, the app will use environment variables set in your system.