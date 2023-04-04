CREATE TABLE input_table (
  timestamp_col TIMESTAMP,
  agent_status VARCHAR2(20),
  agent_id NUMBER
);

-- This assumes that you have data in the input table already. Replace with your own data.
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 1);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:01:00', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 2);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:02:00', 'YYYY-MM-DD HH24:MI:SS'), 'working', 3);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:03:00', 'YYYY-MM-DD HH24:MI:SS'), 'working', 4);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-03-29 10:04:00', 'YYYY-MM-DD HH24:MI:SS'), 'unavailable', 5);

CREATE TABLE output_table (
  interval_start TIMESTAMP,
  agent_status VARCHAR2(20),
  count_of_agentid NUMBER
);

-- Generate a list of all 1-minute intervals in a day
WITH all_intervals AS (
  SELECT TRUNC(SYSDATE) + NUMTODSINTERVAL(LEVEL - 1, 'SECOND') AS interval_start
  FROM DUAL
  CONNECT BY LEVEL <= 86400
)

-- Join the intervals with the input table to get the count of agent IDs per status code
SELECT all_intervals.interval_start, input_table.agent_status, COUNT(DISTINCT input_table.agent_id) AS count_of_agentid
FROM all_intervals
LEFT JOIN input_table ON all_intervals.interval_start <= input_table.timestamp_col 
                      AND input_table.timestamp_col < all_intervals.interval_start + NUMTODSINTERVAL(60, 'SECOND')
GROUP BY all_intervals.interval_start, input_table.agent_status
ORDER BY all_intervals.interval_start, input_table.agent_status;
