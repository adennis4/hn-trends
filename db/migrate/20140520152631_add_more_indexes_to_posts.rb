class AddMoreIndexesToPosts < ActiveRecord::Migration
  def up
    execute <<-SQL
      create index posts_posted_date_idx on posts using btree(posted_date);
      create index posts_plain_title_idx on posts using btree(plain_title);
      create index posts_url_idx on posts using btree(url);
    SQL
  end

  def down
    execute <<-SQL
      drop index posts_posted_date_idx;
      drop index posts_plain_title_idx;
      drop index posts_url_idx;
    SQL
  end
end
