require 'active_record'

# delete before forking and connecting with ActiveRecord
`psql writable_cte_bench -c 'delete from products'`

child_pid = Process.fork

ActiveRecord::Base.establish_connection adapter: 'postgresql',
  database: 'writable_cte_bench'

class Product < ActiveRecord::Base
  def self.merge_increment(id)
    sql = <<-SQL
      with upd as (
        update products
        set counter = counter + 1,
          lock_version = lock_version + 1
        where id = ?
        returning *
      )
      insert into products(id, counter)
      select ?, 1
      where not exists(select * from upd)
    SQL

    connection.execute sanitize_sql([sql, id, id])
  end
end

product_ids = (1..100).to_a

collisions = 0

100.times do
  product_ids.shuffle.each do |pid|
    begin
      Product.merge_increment(pid)
    rescue ActiveRecord::RecordNotUnique
      collisions += 1
      retry
    end
  end
end

puts "PID #{Process.pid} Collisions: #{collisions}"

Process.wait child_pid if child_pid
