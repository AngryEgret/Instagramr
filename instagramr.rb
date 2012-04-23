require 'open-uri'
require 'sinatra'

require './minimagick'
require './mongler'

get // do
  puts request.env['REQUEST_URI']
  if %w{.gif .png .jpeg .jpg .bmp}.include? File.extname(request.env['REQUEST_URI'])
    content_type "image/#{File.extname(request.env['REQUEST_URI']).tr('.', '')}"
    image = MiniMagick::Image.open(request.env['REQUEST_URI'])
    image.toaster
    return image.to_blob
  elsif %w{.js}.include? File.extname(request.env['REQUEST_URI'])
    content_type "text/javascript"
  elsif %w{.css}.include? File.extname(request.env['REQUEST_URI'])
    content_type "text/css"
  end
  @resp = mangle_page request.env['REQUEST_URI'], ''
  return @resp
end

def mangle_page(url, prefix)
  doc = Mongler.new(url, prefix)
  doc.fixup
  doc.toast
  doc.parse
end
