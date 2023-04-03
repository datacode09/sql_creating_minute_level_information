SELECT TRUNC(timestamp, 'MI') + NUMTODSINTERVAL((LEVEL-1)*60, 'SECOND') AS one_min_interval,
       agent_status AS status,
       COUNT(agent_id) AS count_of_agentid_per_status
FROM input_table
CONNECT BY TRUNC(timestamp, 'DD') = TRUNC(SYSDATE-1, 'DD') AND LEVEL <= 1440
GROUP BY TRUNC(timestamp, 'MI') + NUMTODSINTERVAL((LEVEL-1)*60, 'SECOND'), agent_status;
