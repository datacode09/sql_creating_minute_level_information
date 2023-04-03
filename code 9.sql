SELECT TO_CHAR(all_timestamps.timestamp, 'YYYY-MM-DD HH24:MI') AS one_min_interval,
       all_statuses.agent_status AS status,
       COUNT(input_table.agent_id) AS count_of_agentid_per_status
FROM (
  SELECT TRUNC(timestamp, 'MI') + (LEVEL-1)/(24*60) AS timestamp
  FROM input_table
  CONNECT BY TRUNC(timestamp, 'MI') + (LEVEL-1)/(24*60) <= TRUNC(timestamp, 'DD') + 1
) all_timestamps
CROSS JOIN (
  SELECT 'busy' AS agent_status FROM dual
  UNION ALL
  SELECT 'working' AS agent_status FROM dual
  UNION ALL
  SELECT 'unavailable' AS agent_status FROM dual
) all_statuses
LEFT JOIN input_table ON TRUNC(input_table.timestamp, 'MI') = all_timestamps.timestamp AND input_table.agent_status = all_statuses.agent_status
GROUP BY all_timestamps.timestamp, all_statuses.agent_status;
