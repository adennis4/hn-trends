class AddIndexesToPosts < ActiveRecord::Migration
  def up
    execute <<-SQL
      create index posts_title_idx on posts using gin(title);
      create index posts_comments_idx on posts using gin(comments);
    SQL
  end

  def down
    execute <<-SQL
      drop index posts_title_idx;
      drop index posts_comments_idx;
    SQL
  end
end
