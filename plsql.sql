-- Declare variables
DECLARE
  v_date DATE;
  v_start_time TIMESTAMP;
  v_end_time TIMESTAMP;
  v_interval INTERVAL DAY TO SECOND;
BEGIN
  -- Get the date from the input table
  SELECT TRUNC(timestamp_col) INTO v_date FROM input_table WHERE ROWNUM = 1;

  -- Compute start and end times for the given date
  v_start_time := v_date;
  v_end_time := v_date + INTERVAL '1' DAY;

  -- Compute the interval between timestamps
  v_interval := INTERVAL '1' SECOND;

  -- Create a temporary table with all unique 1-second timestamps for the given date
  CREATE GLOBAL TEMPORARY TABLE temp_timestamps (
    timestamp_col TIMESTAMP(0) WITH TIME ZONE
  ) ON COMMIT PRESERVE ROWS;
  INSERT INTO temp_timestamps (timestamp_col)
  SELECT v_start_time + (v_interval * LEVEL) - v_interval
  FROM DUAL
  CONNECT BY v_start_time + (v_interval * LEVEL) - v_interval < v_end_time;
  
  -- Join the temporary table with the input table to add missing timestamps
  CREATE GLOBAL TEMPORARY TABLE temp_data (
    timestamp_col TIMESTAMP(0) WITH TIME ZONE,
    agent_status VARCHAR2(20),
    count_per_status NUMBER(10)
  ) ON COMMIT PRESERVE ROWS;
  INSERT INTO temp_data (timestamp_col, agent_status, count_per_status)
  SELECT t.timestamp_col, d.agent_status, d.count_per_status
  FROM temp_timestamps t
  LEFT JOIN input_table d ON t.timestamp_col = d.timestamp_col
  ORDER BY t.timestamp_col;

  -- Forward-fill missing values to carry over the previous non-null value
  UPDATE temp_data
  SET agent_status = (SELECT agent_status FROM temp_data d2 WHERE d2.timestamp_col < temp_data.timestamp_col AND d2.agent_status IS NOT NULL ORDER BY d2.timestamp_col DESC FETCH FIRST 1 ROW ONLY)
  WHERE agent_status IS NULL;
  
  -- Group by regularized timestamp and agent status, and sum the count per status code
  SELECT timestamp_col, agent_status, SUM(count_per_status) AS count_per_status
  FROM temp_data
  GROUP BY timestamp_col, agent_status
  ORDER BY timestamp_col, agent_status;
END;
/
