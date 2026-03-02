
Team Project: Indexing and Query Optimization 

What optimizations made the biggest difference?

The most impactful optimization across all three queries was the introduction of covering indexes on the AQI_Record table. Since AQI_Record is the largest table in the database and serves as the central table in every query, it was the primary source of performance bottlenecks before indexing.

For Query 1, the baseline query plan showed a full table scan on AQI_Record and a second full scan triggered by the correlated subquery computing the global average AQI. After indexing, both scans were replaced by covering index scans- idx_aqi_composite for the main query and idx_aqi_aqi for the subquery. A covering index is particularly effective because SQLite can resolve the query entirely from the index without accessing the underlying table rows, reducing I/O significantly. The joins to State and County were already optimal via primary key lookups and required no additional indexing.

For Query 2, the composite index idx_ar_state_county_site on AQI_Record(state_code, county_code, site_code) allowed SQLite to use a covering index scan rather than a full table scan, and all subsequent joins to Site, County, and State were resolved using existing primary key indexes. The only remaining concern is the temporary B-tree used for DISTINCT, which is difficult to eliminate without restructuring the query.

For Query 3, the index idx_aqi_category_state_param on AQI_Record(category, state_code, parameter_name) had a significant effect. Because category is the first column in the index, SQLite could immediately narrow the scan to only rows where category = 'Hazardous', rather than reading the entire table. Critically, the correlated subquery also benefited from this same index by filtering on both category and state_code, avoiding repeated full scans for each state during subquery execution. This was the most meaningful improvement across all three queries given the complexity of the correlated subquery.


Did you face limitations with SQLite or pandas?

SQLite has several limitations that became apparent during this optimization exercise. First, temporary B-tree structures for GROUP BY, ORDER BY, and DISTINCT persisted in all three query plans even after indexing. SQLite can only avoid these when data is already stored or indexed in the exact order required, which is difficult to guarantee across multi-table joins.

Second, correlated subqueries in SQLite are executed once per row of the outer query, which is by nature, expensive regardless of indexing. Query 3 contains a correlated subquery that computes the maximum hazardous days per state for every row processed by the outer query. While the index made each individual subquery execution faster, the subquery still runs once for every row in the outer query, so the inefficiency adds up as the dataset grows.

Pandas Optimization

1: Converting Columns to Category
    Columns in our dataset such as state_code, category, and parameter_name are stored as object (string) types. Since these columns contain repeated values, converting them to the category type reduces memory usage and improves filtering performance. Categorical data stores each unique value only once and replaces the actual strings with integer codes internally, making operations more efficient.

    After converting to categorical types, memory usage decreased and groupby operations became faster. This is useful for large datasets with repeated string values.

2: Using .query() for Filtering
    Instead of filtering using boolean indexing, we used the .query() method. The .query() method can improve performance when filtering large datasets. The .query() method is cleaner and slightly faster than boolean indexing.


3: Using set_index() for Faster Lookups
    Since we frequently filter by state_code, setting it as the DataFrame index allows faster row selection using .loc[]. When a column is used often for filtering, making it the index avoids scanning the entire column each time.

Would these techniques scale in a real system?

The techniques used in this project-- covering indexes, composite indexes, and using EXPLAIN QUERY PLAN-- are standard practices in real database systems you would see out in the "real world" and would work well at larger scale. Covering indexes in particular are effective because they allow SQLite to answer a query using only the index, without having to look up the actual table rows.

That being said, indexes can still be costly when not used effectively. They take up storage space and slow down writes like INSERT and UPDATE because the index has to be updated every time the table changes. For a dataset like AQI records, which is more focused on reading and analyzing data than constantly updating it, this tradeoff is worth it. In a system where data is being written constantly, you would need to be more selective about the number of indexes you create.

For very large datasets, the correlated subquery in Query 3 would still be slow even with indexes, and would need to be rewritten in a more efficient way. Overall, the strategies used here are good database optimization fundamentals that apply well beyond SQLite, though larger systems offer more advanced tools to improve performance even further.