SELECT start_TS + ( LEVEL - 1 ) * INTERVAL '1' MINUTE AS dates,Agent,status
FROM input
CONNECT BY start_TS + ( LEVEL - 1 ) * INTERVAL '1' MINUTE <= end_TS;
