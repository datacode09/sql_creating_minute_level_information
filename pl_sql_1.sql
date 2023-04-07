DECLARE
  v_date DATE;
  v_start_time TIMESTAMP;
  v_end_time TIMESTAMP;
  v_statuses SYS.DBMS_DEBUG_VC2COLL;
  v_rng SYS.DBMS_DEBUG_TS_VC2COLL;
  v_df_input input_table%ROWTYPE;
  v_df output_table%ROWTYPE;
BEGIN
  -- Read input table
  FOR i IN (SELECT * FROM input_table) LOOP
    -- Set timestamp column as index
    IF i.timestamp = i.timestamp THEN
      v_df.timestamp := i.timestamp;
    END IF;

    v_df.agent_status := i.agent_status;
    v_df.count_per_status := i.count_of_agents;

    -- Get date from timestamp and create a date range for the day
    v_date := TRUNC(i.timestamp);
    v_start_time := CAST(v_date AS TIMESTAMP);
    v_end_time := v_start_time + INTERVAL '1' DAY - INTERVAL '1' SECOND;
    v_rng := SYS.DBMS_DEBUG_TS_VC2COLL();

    FOR j IN 0..86399 LOOP -- number of seconds in a day
      v_rng.EXTEND;
      v_rng(j+1) := v_start_time + (j * INTERVAL '1' SECOND);
    END LOOP;

    -- Create a multi-index with all combinations of agent_status and timestamps
    v_statuses := SYS.DBMS_DEBUG_VC2COLL(i.agent_status);
    FOR j IN 1..v_rng.COUNT LOOP
      FOR k IN 1..v_statuses.COUNT LOOP
        INSERT INTO output_table (timestamp, agent_status, count_of_agents)
        VALUES (v_rng(j), v_statuses(k), 0);
      END LOOP;
    END LOOP;
  END LOOP;

  -- Merge input table with the multi-index to fill in missing data and reindex
  FOR i IN (SELECT * FROM output_table) LOOP
    SELECT * INTO v_df_output FROM output_table WHERE timestamp = i.timestamp AND agent_status = i.agent_status;
    v_df_output.count_of_agents := i.count_of_agents;
    UPDATE output_table SET count_of_agents = v_df_output.count_of_agents WHERE timestamp = i.timestamp AND agent_status = i.agent_status;
  END LOOP;
END;
