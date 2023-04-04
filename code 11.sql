CREATE TABLE input_table (
  timestamp_col TIMESTAMP,
  agent_status VARCHAR2(20),
  agent_id INTEGER
);

-- Insert sample data into input_table
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:12:43', 'YYYY-MM-DD HH24:MI:SS'), 'working', 1);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:14:55', 'YYYY-MM-DD HH24:MI:SS'), 'unavailable', 2);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:17:07', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 3);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:19:19', 'YYYY-MM-DD HH24:MI:SS'), 'working', 4);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:20:31', 'YYYY-MM-DD HH24:MI:SS'), 'working', 5);

-- Query to regularize timestamps and generate required output
SELECT 
  to_char(regularized_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS "1-second interval timestamp",
  agent_status AS "Status",
  COUNT(agent_id) AS "Count_of_agentid_per_status value"
FROM (
  SELECT 
    TRUNC(timestamp_col, 'MI') + NUMTODSINTERVAL((TO_CHAR(timestamp_col, 'SS') / 1) * 1, 'SECOND') AS regularized_timestamp,
    agent_status,
    agent_id
  FROM input_table
)
RIGHT JOIN (
  SELECT 
    TRUNC(SYSDATE) + (LEVEL-1)/(24*60*60) AS timestamp_per_second
  FROM DUAL
  CONNECT BY LEVEL <= 24*60*60 -- 86400 = 24*60*60
) ON regularized_timestamp = timestamp_per_second
GROUP BY 
  to_char(regularized_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
  agent_status
ORDER BY 1, 2;
