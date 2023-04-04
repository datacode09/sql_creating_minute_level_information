SELECT
  TO_CHAR(TRUNC(i.timestamp) + (s.seconds/86400), 'YYYY-MM-DD HH24:MI:SS') AS timestamp,
  i.agent_status,
  COALESCE(SUM(i.count_of_agents), 0) AS count_of_agents
FROM
  input i
  CROSS JOIN
  (
    SELECT LEVEL-1 AS seconds
    FROM DUAL
    CONNECT BY LEVEL <= 86400 -- number of seconds in a day
  ) s
GROUP BY
  TO_CHAR(TRUNC(i.timestamp) + (s.seconds/86400), 'YYYY-MM-DD HH24:MI:SS'),
  i.agent_status
ORDER BY
  timestamp,
  agent_status
