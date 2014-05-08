require './scraper'
class PostScraper < Scraper

  def scrape(post_date)
    if @scraped
      @scraped.links[3..22].each do |link|
        unless link.text.include? '(comments)'
          insert_db([post_date, link.text, link.href])
        end
      end
    end
  end

  def insert_db(post_info)
    posted_date, title, url = post_info
    conn = PG::Connection.open(:dbname => 'hn')

    conn.exec <<-SQL
      insert into posts( posted_date, title, url )
      values( '#{posted_date}', '#{conn.escape_string(title)}', '#{url}' );
    SQL
    ensure
      conn.close
  end
end

PostScraper.new.run!
