class Post < ActiveRecord::Base
  attr_reader :queries

  def initialize(params)
    @queries = params.values
  end

  def results
    grouped_results = queries.map { |query| scatter_plot_results(query) }

    [
      { key: queries[0], values: values(grouped_results[0]) },
      { key: queries[1], values: values(grouped_results[1]) }
    ]
  end

  def values(grouped_results)
    grouped_results.map do |key, results|
      {
        x: DateTime.parse(results.first[:posted_date]).to_i,
        y: results.map{|item| item[:y].to_i }.sum
      }
    end.flatten
  end

  def line_plot_results(query)
    if query.present?
      aggregate_results(query).map {|item| {x: "#{item[0]}-#{item[1]}", y: item[4], posted_date: item[3] } }.group_by {|item| item[:x] }
    else
      []
    end
  end

  def aggregate_results(query)
    Rails.cache.fetch(query) do
      agg_results(query).values
    end
  end

  def verbose_results
    Rails.cache.fetch(first_query) do
      verbose_results(first_query).values
    end
  end

  def agg_results(query)
    conn = PG::Connection.open(:dbname => 'HN-trends_development')

    conn.exec <<-SQL
      select extract(month from posted_date) as month,
             extract(year from posted_date) as yyyy,
             word,
             posted_date,
             sum("nentry") as "freq"
      from (
        select posted_date, title, plain_title, (ts_stat(comments)).* from posts
        where comments @@ plainto_tsquery('#{query}')
      ) as words

      where word @@ to_tsquery('#{queries[0]}')
      group by 1,2,3,4
      order by posted_date;
    SQL
    ensure
      conn.close
  end

  def verb_results(query)
    conn = PG::Connection.open(:dbname => 'HN-trends_development')

    conn.exec <<-SQL
      select * from (
        select posted_date, title, plain_title, (ts_stat(comments)).* from posts
        where comments @@ plainto_tsquery('#{query}')
        ) as words
      where word @@ to_tsquery('#{queries[0]})
      order by posted_date;
    SQL
    ensure
      conn.close
  end
end
