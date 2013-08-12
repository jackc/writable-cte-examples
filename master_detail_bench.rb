require 'active_record'
require 'benchmark'

ActiveRecord::Base.establish_connection adapter: 'postgresql',
  database: 'writable_cte_bench'

class Question < ActiveRecord::Base
  has_many :answers

  def self.insert_via_cte(attributes)
    sql = <<-SQL
      with q as (
        insert into questions(text) values(?) returning *
      ), a as (
        insert into answers(question_id, text)
        select q.id, t.text
        from q cross join (values
    SQL
    args = [attributes[:question]]

    sql << attributes[:answers].map do |a|
      args << a
      "(?)"
    end.join(", ")

    sql << ") t(text)) select id from q"

    connection.select_value sanitize_sql([sql, *args])
  end
end

class Answer < ActiveRecord::Base
  belongs_to :question
end

Answer.delete_all
Question.delete_all

Benchmark.bmbm do |x|
  x.report "ActiveRecord" do
    10.times do
      question = Question.new text: "What is your favorite text editor?"
      question.answers.new text: 'vim'
      question.answers.new text: 'emacs'
      question.answers.new text: 'Sublime Text'
      question.save!
    end
  end

  x.report "Writable CTE" do
    10.times do
      Question.insert_via_cte(question: "What is your favorite text editor?",
        answers: ['vim', 'emacs', 'Sublime Text'])
    end
  end
end

