class PostsController < ApplicationController
  expose(:query) { params[:q] }
  expose(:results) { search }

  private

  def search
    conn = PG::Connection.open(:dbname => 'HN-trends_development')

    conn.exec <<-SQL
      select * from (
        select posted_date, plain_title, (ts_stat(comments)).* from posts
        where comments @@ to_tsquery('#{query}')
        ) as words
      where word @@ to_tsquery('#{query}')
      order by posted_date;
    SQL
    ensure
      conn.close
  end
end
