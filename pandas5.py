import pandas as pd

# Read in input table
df = pd.read_sql('SELECT * FROM input_table', connection)

# Set timestamp column as index
df.set_index('timestamp', inplace=True)

# Get date from timestamp and create a date range for the day
date = pd.to_datetime(df.index[0]).date()
start_time = pd.Timestamp(date)
end_time = start_time + pd.Timedelta(days=1) - pd.Timedelta(seconds=1)
rng = pd.date_range(start=start_time, end=end_time, freq='S')

# Create a multi-index with all combinations of agent_status and timestamps
statuses = df['agent_status'].unique()
idx = pd.MultiIndex.from_product([statuses, rng], names=['agent_status', 'timestamp'])
df = pd.DataFrame(index=idx)

# Merge input table with the multi-index to fill in missing data and reindex
df = df.merge(df_input, how='left', left_index=True, right_on=['agent_status', 'timestamp'])
df['count_per_status'].fillna(0, inplace=True)
df.set_index(['agent_status', 'timestamp'], inplace=True)
df.sort_index(inplace=True)
df = df.reindex(idx)

# Reset the index and write to output table
df.reset_index(inplace=True)
df.to_sql('output_table', connection, if_exists='replace', index=False)
