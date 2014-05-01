require './scraper'
class CommentScraper < Scraper

  def scrape(_)
    if @scraped
      @scraped.links[3..22].each do |link|
        unless link.text.include? '(comments)'
          @text = link.text
        end
        if link.text.include? '(comments)'
          href = link.href
          begin
            new_page = agent.get href
          rescue
            puts "sleeping for 5 min"
            sleep 600
            puts "good morning...back to work"
            new_page = agent.get href
          end
          comments = new_page.search('.comment').map(&:text)
          alter_db(@text, comments.join(' '))
        end
      end
    end
  end

  def alter_db(text, comment)
    puts "comments for #{text}"
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
