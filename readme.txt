
Team Project: Indexing and Query Optimization 

What optimizations made the biggest difference?

The most impactful optimization across all three queries was the introduction of covering indexes on the AQI_Record table. Because AQI_Record is the largest table in the database and participates in every query, it was the primary source of performance bottlenecks before indexing.

For Query 1, the baseline query plan showed a full table scan on AQI_Record and a second full scan triggered by the correlated subquery computing the global average AQI. After indexing, both scans were replaced by covering index scans: idx_aqi_composite for the main query and idx_aqi_aqi for the subquery. A covering index is particularly effective because SQLite can resolve the query entirely from the index without accessing the underlying table rows, reducing I/O significantly. The joins to State and County were already optimal via primary key lookups and required no additional indexing.

For Query 2, the composite index idx_ar_state_county_site on AQI_Record(state_code, county_code, site_code) allowed SQLite to use a covering index scan rather than a full table scan, and all subsequent joins to Site, County, and State were resolved using existing primary key indexes. The only remaining concern is the temporary B-tree used for DISTINCT, which is difficult to eliminate without restructuring the query.

For Query 3, the index idx_aqi_category_state_param on AQI_Record(category, state_code, parameter_name) had a significant effect. Because category is the first column in the index, SQLite could immediately narrow the scan to only rows where category = 'Hazardous', rather than reading the entire table. Critically, the correlated subquery also benefited from this same index by filtering on both category and state_code, avoiding repeated full scans for each state during subquery execution. This was the most meaningful improvement across all three queries given the complexity of the correlated subquery.


Did you face limitations with SQLite or pandas?

SQLite has several limitations that became apparent during this optimization exercise. First, temporary B-tree structures for GROUP BY, ORDER BY, and DISTINCT persisted in all three query plans even after indexing. SQLite can only avoid these when data is already stored or indexed in the exact order required, which is difficult to guarantee across multi-table joins.

Second, correlated subqueries in SQLite are executed once per row of the outer query, which is by nature, expensive regardless of indexing. Query 3 contains a correlated subquery that computes the maximum hazardous days per state for every row processed by the outer query. While the index made each individual subquery execution faster, the subquery still runs once for every row in the outer query, so the inefficiency adds up as the dataset grows.


Pandas Optimization Findings

In addition to database-level indexing, in-memory performance was optimized using pandas. The most impactful improvement was converting string columns that were frequently repeated to the dtype categorical. Columns such as state_code, category, and parameter_name contained many duplicate values and were originally stored as object types. Converting these columns to categorical encoding reduced memory usage and improved filtering performance and aggregation operations across the dataset.

The performance gains from categorical conversion can be attributed to how pandas represents object data internally. In an object column, each row stores the full string value independently. This allows the same value to be stored repeatedly, increasing memory usage and requiring more computationally expensive string comparisons during filtering and grouping operations. However, categorical encoding stores each value only once and represents the column internally using integer codes. Comparisons on integer codes are significantly more efficient than repeated string comparisons. By converting columns such as state_code, category, and parameter_name that had many repeated entries, the DataFrame became more efficient during repeated groupby and filtering operations by reducing redundant computation.

Additional improvements were achieved by refining how rows were accessed and filtered. Since filtering by state_code occurred often, assigning it as the DataFrame index allowed faster row selection using .loc[]. This reduced the need to repeatedly scan the entire column during selection operations. To further simplify filtering logic, .query() was used. In large datasets, .query() can reduce repeated computation and improve clarity by expressing filtering conditions more concisely. Together, these adjustments improved data access efficiency and reduced unnecessary computation during repeated filtering tasks.

Despite these significant improvements, pandas still presents limitations. Since all operations in pandas occur in memory, performance is constrained by available system resources. Pandas does not use a cost-based query planner to automatically determine optimal execution strategies. Thus, performance gains depend on strategic design decisions such as dtype optimization and indexing. Because pandas remains limited by system memory, these design strategies are most effective for moderate-sized datasets. Large-scale data processing would benefit most from distributed systems or database-backed solutions designed for scalable data management.


Would these techniques scale in a real system?

The techniques used in this project, including covering indexes, composite indexes, and EXPLAIN QUERY PLAN, are standard practices in real world database systems and scale effectively at larger volumes. Covering indexes in particular are effective because they allow SQLite to answer a query using only the index, without having to look up the actual table rows.

That being said, indexes can still be costly when not used effectively. They take up storage space and slow down writes like INSERT and UPDATE because the index has to be updated every time the table changes. For a dataset like AQI records, which is more focused on reading and analyzing data than constantly updating it, this tradeoff is worth it. In a system where data is being written constantly, you would need to be more selective about the number of indexes you create.

For very large datasets, the correlated subquery in Query 3 would still be slow even with indexes, and would need to be rewritten in a more efficient way. Overall, these strategies represent database optimization fundamentals that apply well beyond SQLite, though larger systems offer more advanced optimization capabilities at scale.
