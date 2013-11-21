require "mechanize"
require "pry"
require "colorize"

def main
  agent = Mechanize.new
  search_term = "deslangles"
  page = agent.get("http://www.google.co.uk")
  google_form = page.form("f")
  google_form.q = search_term
  page = agent.submit(google_form, google_form.buttons.first)
  
  links = map_links(page.links, search_term)  
  
  page.links_with(href: Regexp.new("/search\\\?q=#{search_term}&"), text: %r{\d+}).each do |result_page_link|
    next_page = result_page_link.click
    links += map_links(next_page.links, search_term)  	
  end
  
  links.compact!

  puts "#{links.size} links found for #{search_term}! I don't need Google anymore!"
  links.each{ |link| puts "#{link[:text]}".on_red.green; puts " -> #{link[:uri]}".on_green}
end

def map_links(links, search_term)
  links.map do |link|
    if link.text =~ Regexp.new(search_term, :i) && !((matched_uri = /http.*?&/.match(link.uri.to_s).to_s).empty?)
      {
        text: link.text,
        uri: matched_uri	
      }    	
    end
  end
end

main