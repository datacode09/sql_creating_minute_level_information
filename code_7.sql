CREATE TABLE input_table (
  timestamp TIMESTAMP(0),
  agent_status VARCHAR2(20),
  agent_id NUMBER
);

-- insert sample data into input_table
INSERT INTO input_table (timestamp, agent_status, agent_id)
VALUES 
  (TO_TIMESTAMP('2023-04-03 09:01:23', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 101),
  (TO_TIMESTAMP('2023-04-03 09:02:34', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 102),
  (TO_TIMESTAMP('2023-04-03 09:05:17', 'YYYY-MM-DD HH24:MI:SS'), 'working', 103),
  (TO_TIMESTAMP('2023-04-03 09:05:59', 'YYYY-MM-DD HH24:MI:SS'), 'working', 104),
  (TO_TIMESTAMP('2023-04-03 09:07:05', 'YYYY-MM-DD HH24:MI:SS'), 'unavailable', 105),
  (TO_TIMESTAMP('2023-04-03 09:09:43', 'YYYY-MM-DD HH24:MI:SS'), 'unavailable', 106),
  (TO_TIMESTAMP('2023-04-04 10:15:32', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 107),
  (TO_TIMESTAMP('2023-04-04 10:20:14', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 108),
  (TO_TIMESTAMP('2023-04-04 10:30:08', 'YYYY-MM-DD HH24:MI:SS'), 'working', 109),
  (TO_TIMESTAMP('2023-04-04 10:35:45', 'YYYY-MM-DD HH24:MI:SS'), 'working', 110),
  (TO_TIMESTAMP('2023-04-04 10:40:02', 'YYYY-MM-DD HH24:MI:SS'), 'unavailable', 111),
  (TO_TIMESTAMP('2023-04-04 10:45:57', 'YYYY-MM-DD HH24:MI:SS'), 'unavailable', 112);

WITH all_statuses AS (
  SELECT 'busy' AS agent_status FROM dual
  UNION ALL
  SELECT 'working' AS agent_status FROM dual
  UNION ALL
  SELECT 'unavailable' AS agent_status FROM dual
),
all_timestamps AS (
  SELECT TRUNC(timestamp, 'MI') + (LEVEL-1)/(24*60) AS timestamp
  FROM input_table
  CONNECT BY TRUNC(timestamp, 'MI') + (LEVEL-1)/(24*60) <= TRUNC(timestamp, 'DD') + 1
),
all_timestamps_and_statuses AS (
  SELECT all_timestamps.timestamp, all_statuses.agent_status
  FROM all_timestamps
  CROSS JOIN all_statuses
)
SELECT TO_CHAR(all_timestamps_and_statuses.timestamp, 'YYYY-MM-DD HH24:MI') AS one_min_interval,
       all_timestamps_and_statuses.agent_status AS status,
       COUNT(input_table.agent_id) AS count_of_agentid_per_status
FROM all_timestamps_and_statuses
LEFT JOIN input_table ON all_timestamps_and_statuses.timestamp = TRUNC(input_table.timestamp, 'MI') AND all_timestamps_and_statuses.agent_status = input_table.agent_status
GROUP BY all_timestamps_and_statuses.timestamp, all_timestamps_and_statuses.agent_status
