import pandas as pd
import numpy as np

# # Load the JSON file into a pandas DataFrame
# with open('input.json') as f:
#     data = json.load(f)
# df = pd.DataFrame(data)

# Create sample input DataFrame
df = pd.DataFrame({
    'timestamp_col': ['2023-03-29 10:12:43', '2023-03-29 10:14:55', '2023-03-29 10:17:07', '2023-03-29 10:19:19', '2023-03-29 10:20:31'],
    'agent_status': ['ready', 'notready', 'busy', 'ready', 'ready'],
    'count_per_status': [1, 2, 3, 4, 5]
})

# Convert timestamp column to datetime type
df['timestamp_col'] = pd.to_datetime(df['timestamp_col'])

# Get the date from the input table
date = df['timestamp_col'].dt.date[0]

# Create a DataFrame with all unique 1-second timestamps for the given date
date_range = pd.date_range(start=date, end=date + pd.Timedelta(days=1), freq='S', closed='left')
timestamps_df = pd.DataFrame({'timestamp_col': date_range})

# Merge the input DataFrame with the timestamps DataFrame to add missing timestamps
df = pd.merge(timestamps_df, df, on='timestamp_col', how='left')

# Forward-fill missing values to carry over the previous non-null value
df.fillna(method='ffill', inplace=True)

# Group by regularized timestamp and agent status, and sum the count per status code
result_df = df.groupby([pd.Grouper(freq='S'), 'agent_status'])['count_per_status'].sum().reset_index()

# Print result
print(result_df)
