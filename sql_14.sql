WITH date_ranges AS (
  -- Generate date ranges for each day
  SELECT TRUNC(CAST(timestamp_col AS DATE)) AS day_start,
         TRUNC(CAST(timestamp_col AS DATE)) + INTERVAL '1' DAY - INTERVAL '1' SECOND AS day_end
  FROM input_table
), 
all_timestamps AS (
  -- Generate all unique timestamps for each day per each agent status
  SELECT agent_status, timestamp_col
  FROM date_ranges
  CROSS JOIN (SELECT DISTINCT agent_status FROM input_table)
  CROSS JOIN (
    SELECT (day_start + (LEVEL - 1) * INTERVAL '1' SECOND) AS timestamp_col
    FROM DUAL
    CONNECT BY (day_start + (LEVEL - 1) * INTERVAL '1' SECOND) <= day_end
  )
)
-- Join with input table to fill in missing data and write to output table
SELECT all_timestamps.agent_status, all_timestamps.timestamp_col, 
       COALESCE(input_table.count_of_agents, 0) AS count_of_agents
FROM all_timestamps
LEFT JOIN input_table 
  ON all_timestamps.agent_status = input_table.agent_status 
     AND all_timestamps.timestamp_col = input_table.timestamp_col
ORDER BY all_timestamps.agent_status, all_timestamps.timestamp_col;
