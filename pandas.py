import cx_Oracle
import pandas as pd


# load input data into a pandas DataFrame
#input_df = pd.read_csv('input_data.csv')


# Set up connection details
dsn_tns = cx_Oracle.makedsn('your_host', 'your_port', service_name='your_service_name')
conn = cx_Oracle.connect(user='your_username', password='your_password', dsn=dsn_tns)

# Read SQL query from file
with open('query.sql', 'r') as f:
    sql_query = f.read()

# Execute query and load result into dataframe
df = pd.read_sql(sql_query, conn)

# Close the connection
conn.close()

# create a list of all possible statuses
all_statuses = ['busy', 'working', 'unavailable']

# create a list of all possible minutes in a day
all_minutes = pd.date_range(start=input_df['timestamp'].min().floor('D'), end=input_df['timestamp'].max().ceil('D'), freq='min')

# create a DataFrame of all possible combinations of minutes and statuses
timestamps_and_statuses = pd.MultiIndex.from_product([all_minutes, all_statuses], names=['timestamp', 'status']).to_frame(index=False)

# join the timestamps_and_statuses DataFrame with the input DataFrame to get the count of agent_id per minute and status
output_df = pd.merge(timestamps_and_statuses, input_df, on=['timestamp', 'status'], how='left').groupby(['timestamp', 'status']).agg({'agent_id': 'count'}).reset_index()

# format the timestamp column
output_df['one_min_interval'] = output_df['timestamp'].dt.strftime('%Y-%m-%d %H:%M')

# select and reorder the output columns
output_df = output_df[['one_min_interval', 'status', 'agent_id']]
output_df.columns = ['one_min_interval', 'status', 'count_of_agentid_per_status']

# display the output DataFrame
print(output_df.head())
