class Posts < ActiveRecord::Migration
  def up
    execute <<-SQL
      create table posts (
        posted_date date,
        title tsvector,
        comments tsvector,
        url text,
        id serial
      );
    SQL
  end

  def down
    execute <<-SQL
      drop table posts
    SQL
  end
end
