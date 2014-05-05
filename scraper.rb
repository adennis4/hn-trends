class Scraper
  require 'mechanize'
  require 'pg'

  YEARS       = (2010..2014).to_a
  MONTHS      = (1..12).to_a
  DAYS        = (1..31).to_a
  START_DATE  = "20100727"
  FINISH_DATE = "20110504"

  def run!
    date_setup
  end

  def agent
    Mechanize.new
  end

  def page(post_date)
    @scraped = begin
      agent.get "http://daemonology.net/hn-daily/#{post_date}.html"
    rescue
      nil
    end
  end

  def date_setup
    YEARS.each do |year|
      MONTHS.each do |month|
        month = sanitize month
        DAYS.each do |day|
          day = sanitize day
          historical_date = [year, month, day].join
          if range_includes? historical_date
            extract_info "#{year}-#{month}-#{day}"
          end
        end
      end
    end
  end

  def sanitize(num)
    num < 10 ? "0#{num}" : num
  end

  def extract_info(post_date)
    page post_date
    scrape post_date
  end

  def range_includes?(date)
    START_DATE < date && date < FINISH_DATE
  end
end
