SELECT
  t1.timestamp,
  t1.agent_status,
  COALESCE(t2.count_of_agents, 0) AS count_of_agents
FROM
  (
    SELECT
      DISTINCT timestamp,
      agent_status
    FROM
      input
  ) t1
  CROSS JOIN
  (
    SELECT
      ROW_NUMBER() OVER (ORDER BY timestamp) AS n
    FROM
      input
    WHERE
      agent_status = 'busy'
    GROUP BY
      TRUNC(timestamp)
  ) t3
  LEFT OUTER JOIN
  (
    SELECT
      TRUNC(timestamp) AS timestamp,
      agent_status,
      COUNT(*) AS count_of_agents
    FROM
      input
    GROUP BY
      TRUNC(timestamp),
      agent_status
  ) t2
  ON
    t1.timestamp = t2.timestamp
    AND t1.agent_status = t2.agent_status
WHERE
  t3.n <= 86400 -- number of seconds in a day
ORDER BY
  t1.timestamp,
  t1.agent_status
