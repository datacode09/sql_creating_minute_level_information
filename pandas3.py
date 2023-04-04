import pandas as pd
import numpy as np

# Create sample input DataFrame
df = pd.DataFrame({
    'timestamp_col': ['2023-03-29 10:12:43', '2023-03-29 10:14:55', '2023-03-29 10:17:07', '2023-03-29 10:19:19', '2023-03-29 10:20:31'],
    'agent_status': ['working', 'unavailable', 'busy', 'working', 'working'],
    'agent_id': [1, 2, 3, 4, 5]
})

# Convert timestamp column to datetime type
df['timestamp_col'] = pd.to_datetime(df['timestamp_col'])

# Set timestamp column as index
df.set_index('timestamp_col', inplace=True)

# Resample to 1-second intervals and fill missing values with NaN
df = df.resample('S').asfreq()

# Forward-fill NaN values to carry over the previous non-null value
df.fillna(method='ffill', inplace=True)

# Group by regularized timestamp and agent status, and calculate the count of agent IDs per status code
result_df = df.groupby([pd.Grouper(freq='S'), 'agent_status'])['agent_id'].count().reset_index()

# Rename columns to match required output
result_df.columns = ['1-second interval timestamp', 'Status', 'Count_of_agentid_per_status value']

# Print result
print(result_df)
