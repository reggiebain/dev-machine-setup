# Doing Python Stuff in Snowpark

## Starting a Session w/ Credentials
```python
from snowflake.snowpark import Session

session = Session.builder.configs({
    'account': 'your-account',
    'user': 'your-user',
    'password': 'your-password',
    'warehouse': 'DEV_WH',
    'database': 'DEV_DB',
    'schema': 'PUBLIC'
}).create()

# Just explore
df = session.table('SOME_TABLE')
df.show()  # See first few rows
print(df.count())  # Count rows
```

## Scikit Learn Version
```python
# Your comfortable workflow:
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

# Load sample data
df = pd.read_csv('sample_users.csv')

# Feature engineering
df['days_since_signup'] = (pd.Timestamp.now() - df['signup_date']).dt.days
df['engagement_score'] = df['page_views'] * df['time_on_site']

# Train model
X = df[['days_since_signup', 'engagement_score']]
y = df['churned']
model = RandomForestClassifier()
model.fit(X, y)

# Predict
predictions = model.predict(X)
```

## Snowpark Version
```python
# Same logic, Snowpark syntax:
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, current_timestamp, datediff
from snowflake.ml.modeling.ensemble import RandomForestClassifier

session = Session.builder.configs({...}).create()

# Load data (same as pd.read_csv, but from Snowflake)
df = session.table('USERS')

# Feature engineering (similar to Pandas)
df = df.with_column(
    'days_since_signup',
    datediff('day', col('signup_date'), current_timestamp())
)
df = df.with_column(
    'engagement_score',
    col('page_views') * col('time_on_site')
)

# Train model (almost identical to sklearn)
X = df.select(['days_since_signup', 'engagement_score'])
y = df.select('churned')
model = RandomForestClassifier()
model.fit(X)

# Predict
predictions = model.predict(X)
predictions.write.save_as_table('PREDICTIONS')
```