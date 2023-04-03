CREATE TABLE input_table (
    timestamp_col TIMESTAMP,
    agent_status VARCHAR2(10),
    agent_id NUMBER
);

-- Populate input table with sample data
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-04-03 08:01:00', 'YYYY-MM-DD HH24:MI:SS'), 'busy', 123);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-04-03 08:03:00', 'YYYY-MM-DD HH24:MI:SS'), 'working', 456);
INSERT INTO input_table VALUES (TO_TIMESTAMP('2023-04-03 08:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'unavailable', 789);

-- Regularize timestamps to 1-minute intervals and get count of agent IDs per status value
SELECT TRUNC(start_time, 'MI') + (level - 1) / 1440 AS one_min_interval,
       agent_status AS status,
       COUNT(agent_id) AS count_of_agentid_per_status
FROM (
    SELECT TRUNC(timestamp_col, 'DD') + NUMTODSINTERVAL((level - 1), 'MINUTE') AS start_time,
           agent_status,
           agent_id
    FROM input_table
    CONNECT BY LEVEL <= 1440
)
GROUP BY TRUNC(start_time, 'MI') + (level - 1) / 1440, agent_status;