import pandas as pd

# Read in the input data from a CSV file
input_df = pd.read_csv('input_data.csv', parse_dates=['timestamp_col'])

# Generate a list of all 1-minute intervals in a day
all_intervals = pd.date_range(start=input_df['timestamp_col'].dt.date.min(),
                              end=input_df['timestamp_col'].dt.date.max() + pd.Timedelta(days=1),
                              freq='1min')

# Create a DataFrame to hold the output
output_df = pd.DataFrame(columns=['interval_start', 'agent_status', 'count_of_agentid'])

# Loop over each status code and interval, and count the number of agents in that status during that interval
for status_code in input_df['agent_status'].unique():
    for interval_start in all_intervals:
        interval_end = interval_start + pd.Timedelta(minutes=1)
        count = input_df[(input_df['agent_status'] == status_code) &
                         (input_df['timestamp_col'] >= interval_start) &
                         (input_df['timestamp_col'] < interval_end)]['agent_id'].nunique()
        output_df = output_df.append({'interval_start': interval_start,
                                      'agent_status': status_code,
                                      'count_of_agentid': count},
                                     ignore_index=True)

# Save the output to a CSV file
output_df.to_csv('output_data.csv', index=False)
