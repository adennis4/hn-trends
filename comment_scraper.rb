require './scraper'
class CommentScraper < Scraper

  def scrape(_)
    if @scraped
      @scraped.links[3..22].each do |link|
        unless link.text.include? '(comments)'
          @text = link.text
        end
        if link.text.include? '(comments)'
          new_page = agent.get link.href
          comments = new_page.search('.comment').map(&:text)
          alter_db(@text, comments.join(' '))
        end
      end
    end
  end

  def alter_db(text, comment)
    conn = PG::Connection.open(:dbname => 'hn')

    conn.exec <<-SQL
      update posts
      set comments = '#{conn.escape_string(comment)}'
      where title ='#{conn.escape_string(text)}';
    SQL
    ensure
      conn.close
  end
end

CommentScraper.new.run!
