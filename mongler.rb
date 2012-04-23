require 'nokogiri'

class Mongler
  def initialize(url,prefix=nil)
    url = "http://#{url}" if !self.is_url?(url) 
    @url = URI.parse(url)
    @prefix = prefix
    @toast = "/toast?url="
    @doc = Nokogiri(open(url, "User-Agent" => "Mongler Ruby/#{RUBY_VERSION}"))
  end

  def is_url?(url=nil)
    url.nil? ? !@url.scheme.nil? : !(URI.parse(url).scheme.nil?)
  end

  def mangle(tag, attribute, prefix = '')
    @doc.xpath("//#{tag}").each do |e|
      if is_url? e[attribute]
        e[attribute] = "#{@prefix}#{e[attribute]}"
      else
        e[attribute] = "#{@prefix}http://#{@url.host}/#{e[attribute]}"
      end
    end
  end
  
  def fixup
    attribute = 'src'
    @doc.xpath('//script').each do |e|
      if !is_url? e[attribute]
        e[attribute] = "http://#{@url.host}/#{e[attribute]}"
      end
    end
    attribute = 'href'
    @doc.xpath('//link').each do |e|
      if !is_url? e[attribute]
        e[attribute] = "http://#{@url.host}/#{e[attribute]}"
      end
    end
    attribute = 'href'
    @doc.xpath('//a//img').each do |e|
      if is_url? e[attribute]
        e[attribute] = "#{@toast}#{e[attribute]}"
      else
        e[attribute] = "#{@toast}http://#{@url.host}/#{e[attribute]}"
      end
    end
  end
  
  def toast 
    attribute = 'src'
    @toast = ''
    @doc.xpath('//img').each do |e|
      if is_url? e[attribute]
        e[attribute] = "#{@toast}#{e[attribute]}"
      else
        e[attribute] = "#{@toast}http://#{@url.host}/#{e[attribute]}"
      end
    end
  end

  def parse
    @doc.to_s
  end
end
