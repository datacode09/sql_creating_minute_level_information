SELECT  CAST(start_TS AS TIMESTAMP) + ( LEVEL - 1 ) * INTERVAL '1' MINUTE AS dates,Agent,status
FROM   input
CONNECT BY  CAST(start_TS AS TIMESTAMP)  + ( LEVEL - 1 ) * INTERVAL '1' MINUTE <=  end_TS;
