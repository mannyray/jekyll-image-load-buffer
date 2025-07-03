require 'nokogiri'
require 'base64'

module Jekyll
    module BUFFER
        def buffer(text,buffering_enabled)
            if buffering_enabled.nil?
                # default behaviour. specify if we apply the filter when
                # `image_buffering:` property in a post is not defined
                buffering_enabled = false
            end
            doc = Nokogiri::HTML(text)
            if buffering_enabled
                return "to be buffered"
            end
            return doc.to_html
        end
    end
end

# Register the filter
Liquid::Template.register_filter(Jekyll::BUFFER)
