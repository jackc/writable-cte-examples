require 'active_record'

# delete before forking and connecting with ActiveRecord
`psql writable_cte_bench -c 'delete from products'`

child_pid = Process.fork

ActiveRecord::Base.establish_connection adapter: 'postgresql',
  database: 'writable_cte_bench'

class Product < ActiveRecord::Base
end

product_ids = (1..100).to_a

collisions = 0

100.times do
  product_ids.shuffle.each do |pid|
    begin
      product = Product.find_or_initialize_by(id: pid)
      product.counter += 1
      product.save!
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError
      collisions += 1
      retry
    end
  end
end

puts "PID #{Process.pid} Collisions: #{collisions}"

Process.wait child_pid if child_pid
