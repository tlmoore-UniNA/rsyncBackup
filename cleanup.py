#!/bin/python3
import os
from datetime import datetime
import pandas as pd

# Define the directory to search
BACKUP_DIR = "/run/media/tmoore/myvault"

# Get sub-directories
sub_dirs = [d for d in os.listdir(BACKUP_DIR) if 
            os.path.isdir(os.path.join(BACKUP_DIR, d))]

# Sub-directories as dates
sub_dir_dates = [datetime.strptime(dir, "%Y-%m-%d_%H%M") for dir in sub_dirs]

# Get full path/directory names
filenames = [BACKUP_DIR+'/'+dir for dir in sub_dirs]

# Get date/time values from all directory names
years = []
months = []
days = []
hours = []
minutes = []

# Populate the lists with the values for year, month, day, hour, minute
for dir in sub_dir_dates:
    years.append(dir.strftime("%Y"))
    months.append(dir.strftime("%m"))
    days.append(dir.strftime("%d"))
    hours.append(dir.strftime("%H"))
    minutes.append(dir.strftime("%M"))

# Create a data frame from the different lists
d = {'dir_path': filenames, 'datetime': sub_dir_dates, 'year': years,# 
     'month': months, 'day': days, 'hour': hours, 'minute': minutes}
df = pd.DataFrame(data=d)

# Sort the data frame by datetime
df = df.sort_values(by='datetime')
df_drop = df # Duplicate data frame for later

# For duplicated YEAR-M-D, drop all but the most recent
df = df.drop_duplicates(subset=['year', 'month', 'day'], keep='last')

# Generate data frame of directories to keep
df_keep = df[-7:] # Keep the last 7 days of backups
df = df.head(-7) # Drop the last 

# Get directories where year and month match, and keep the most recent
df = df.drop_duplicates(subset=['year','month'], keep='last')
df_keep = pd.concat([df[-12:], df_keep], ignore_index = True)
df = df.head(-12) # Drop the last 12 monthly directories

# Get the most recent update for each year
df = df.drop_duplicates(subset=['year'], keep='last')
df = pd.concat([df, df_keep], ignore_index=True)


# Exclude directories if not in the `df`
exclude = pd.merge(df, df_drop, how='outer', indicator=True)
exclude = exclude.loc[exclude._merge == 'right_only', ['dir_path']]
exclude = exclude['dir_path'].tolist()

# Remove directories that need to be excluded
for dir in exclude:
#    print(f"Deleting "+dir)
    os.rmdir(os.path.join(dir))
