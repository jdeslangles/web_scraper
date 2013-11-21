require 'mechanize'
require 'pry'
require 'colorize'

def search_term
  raise ArgumentError.new("you need to provide a search query (ruby scrape.rb q=SEARCH_QUERY)") if (/q=/ =~ ARGV[0]).nil?
  @search_term ||= ARGV[0].gsub("q=", "").gsub(' ', '\\\+')

end

def main
  agent = Mechanize.new

  page = agent.get('http://www.google.co.uk/')
  
  google_form = page.form('f')
  google_form.q = search_term
  page = agent.submit(google_form, google_form.buttons.first)

  puts "searching page"
  links = map_links(page.links, search_term)

  page.links_with(href: Regexp.new("/search\\\?q=#{search_term}&"), text: %r{\d+}).each do |result_page_link|
    puts "searching page"
    next_page = result_page_link.click
    links += map_links(next_page.links, search_term)
  end

  links.compact!

  links.each{ |link| puts "#{link[:text]}".red; puts" -> #{link[:uri]}".on_green }
  puts "#{links.size} links found"
  
end


def map_links(links, search_term)
  links.map do |link|

    if link.text =~ Regexp.new(search_term, :i) && !((matched_uri = /http.*?&/.match(link.uri.to_s).to_s).empty?)
      {
        text: link.text,
        uri: matched_uri[0...-1],
      }
    end
  end
end

main