Pandas Optimization

1: Converting Columns to Category
    Columns in our dataset such as state_code, category, and parameter_name are stored as object (string) types. Since these columns contain repeated values, converting them to the category type reduces memory usage and improves filtering performance. Categorical data stores each unique value only once and replaces the actual strings with integer codes internally, making operations more efficient.

    After converting to categorical types, memory usage decreased and groupby operations became faster. This is useful for large datasets with repeated string values.

2: Using .query() for Filtering
    Instead of filtering using boolean indexing, we used the .query() method. The .query() method can improve performance when filtering large datasets. The .query() method is cleaner and slightly faster than boolean indexing.


3: Using set_index() for Faster Lookups
    Since we frequently filter by state_code, setting it as the DataFrame index allows faster row selection using .loc[]. When a column is used often for filtering, making it the index avoids scanning the entire column each time.