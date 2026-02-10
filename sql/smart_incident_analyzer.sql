/* ==========================================================================
   
    Project: Smart Incident Resolution Analyzer
    Author: Dipanwita Paul
    Year: 2026
    Description:
         
     This SQL script creates and analyzes an IT service ticket system 
     to identify SLA breaches, high-risk incidents, and root cause trends.

================================================================================= */



/* ==============================================================================

    DATABASE CREATION

================================================================================= */

    CREATE DATABASE IF NOT EXISTS smart_incident_analyzer;
    USE smart_incident_analyzer;

/* =============================================================================== */

    /* Users table */
    CREATE TABLE users (
     user_id INT PRIMARY KEY,
     user_name VARCHAR(50),
     email VARCHAR(50)
     );


    /* Category table */
    CREATE TABLE category (
     category_id INT PRIMARY KEY,
     category_name VARCHAR(30)
     );


    /* Priority table (includes SLA in days) */
    CREATE TABLE priority (
     priority_id INT PRIMARY KEY,
     priority_level VARCHAR(20),
     sla_days INT
     );


    /* Ticket status table */
    CREATE TABLE ticket_status (
     status_id INT PRIMARY KEY,
     status_name VARCHAR(20)
     );


    /* Tickets table */
     CREATE TABLE tickets (
     ticket_id INT PRIMARY KEY,
     user_id INT,
     category_id INT,
     priority_id INT,
     status_id INT,
     created_date DATE,
     resolved_date DATE,
     FOREIGN KEY (user_id) REFERENCES users(user_id),
     FOREIGN KEY(category_id) REFERENCES category(category_id),
     FOREIGN KEY (priority_id) REFERENCES priority(priority_id),
     FOREIGN KEY (status_id) REFERENCES ticket_status(status_id)
     );
    
    /* Resolution log table */
    CREATE TABLE resolution_log (
     log_id INT PRIMARY KEY,
     ticket_id INT,
     root_cause VARCHAR(100),
     resolution_notes VARCHAR(200),
     FOREIGN KEY (ticket_id) 
     REFERENCES tickets(ticket_id)
    );


/* ================================================================================

    DATA INSERTION

=================================================================================== */

    /* Users */
     INSERT INTO users VALUES
     (1, 'Dipanwita Paul', 'dipanwita@company.com'),
     (2, 'Aryan Bhagat', 'aryan@company.com'),
     (3, 'Nilansh Mishra', 'nilansh@company.com');

    /* Categories */
     INSERT INTO category VALUES
     (1, 'Network'),
     (2, 'Software'),
     (3, 'Hardware'),
     (4, 'Access');

    /* Priorities with SLA */
    INSERT INTO priority VALUES
     (1, 'Low', 5),
     (2, 'Medium', 3),
     (3, 'High', 2),
     (4, 'Critical', 1);

    /* Ticket Status */
    INSERT INTO ticket_status VALUES
     (1, 'Open'),
     (2, 'In Progress'),
     (3, 'Resolved'),
     (4, 'Closed');

    /* Tickets */
    INSERT INTO tickets VALUES
     (101, 1, 1, 4, 3, '2025-01-01', '2025-01-03'),
     (102, 2, 2, 3, 2, '2025-01-02', NULL),
     (103, 3, 3, 2, 4, '2025-01-01', '2025-01-05'),
     (104, 1, 4, 4, 1, '2025-01-03', NULL);

    /* Resolution Log */
    INSERT INTO resolution_log VALUES
     (1, 101, 'Router failure', 'Router replaced and configuration updated'),
     (2, 103, 'Disk issue', 'Replaced faulty hard drive');


/* ====================================================================================
  
    ANALYSIS QUERIES

======================================================================================= */

   /* 1. Find SLA breached tickets */
    SELECT 
     t.ticket_id, 
     p.priority_level,
     p.sla_days, 
    DATEDIFF(t.resolved_date, t.created_date) AS resolution_days 
    FROM tickets t
    JOIN priority p ON t.priority_id = p.priority_id 
    WHERE t.resolved_date IS NOT NULL 
    AND DATEDIFF(t.resolved_date, t.created_date) > p.sla_days; 
  
  /* 2. Identify high-risk open incidents */
   SELECT
    t.ticket_id, 
    p.priority_level, 
    s.status_name, 
    DATEDIFF(CURDATE(),
    t.created_date) AS days_open, 
    p.sla_days 
   FROM tickets t 
   JOIN priority p ON t.priority_id = p.priority_id 
   JOIN ticket_status s ON t.status_id = s.status_id 
   WHERE t.resolved_date IS NULL 
   AND DATEDIFF(CURDATE(), t.created_date) > p.sla_days;

   /* 3. Average resolution time by category */
   SELECT 
    c.category_name, 
    AVG(DATEDIFF(t.resolved_date, t.created_date)) AS avg_resolution_days  
   FROM tickets t 
   JOIN category c ON t.category_id = c.category_id
   WHERE t.resolved_date IS NOT NULL 
   GROUP BY c.category_name;
   
   /* 4. Root cause frequency analysis */
    SELECT 
     root_cause, 
     COUNT(*) AS occurrence_count 
    FROM resolution_log 
    GROUP BY root_cause 
    ORDER BY occurrence_count DESC;
    