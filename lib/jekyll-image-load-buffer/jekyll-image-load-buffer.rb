require 'nokogiri'
require 'base64'

module Jekyll
    module BUFFER
        def buffer(text)
            doc = Nokogiri::HTML(text)
            return doc.to_html
        end
    end
end




# Register the filter
Liquid::Template.register_filter(Jekyll::BUFFER)
