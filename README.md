# Setup

From the writable-cte-examples directory:

    bundle

Assuming you have a local PostgreSQL install run the following:

    createdb writable_cte_bench
    psql writable_cte_bench < structure.sql

If your PostgreSQL server is not on your local machine you will also need to adjust the connection settings in writable_cte_bench.rb

# Running Benchmarks

    bundle exec ruby writable_cte_bench.rb
    bundle exec time ruby merge_naive.rb
    bundle exec time ruby merge_sql.rb

