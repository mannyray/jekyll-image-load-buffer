require 'nokogiri'
require_relative 'helper'

module Jekyll
    module BUFFER
        def buffer(text,buffering_enabled)
            if buffering_enabled.nil?
                # default behaviour. specify if we apply the filter when
                # `image_buffering:` property in a post is not defined
                buffering_enabled = false
            end
            
            plugin_dir = File.join(Jekyll.configuration({})['plugins_dir'],"jekyll-image-load-buffer")
            styling_html_content_text = File.read( File.join(plugin_dir,"style.html" ))
            script_html_content_text = File.read( File.join(plugin_dir,"script.html" ))
            
            if buffering_enabled
                text = styling_html_content_text + text + script_html_content_text
                return wrap_each_img_tag(text)                
            end
            doc = Nokogiri::HTML(text)
            return doc.to_html
        end
    end
end

# Register the filter
Liquid::Template.register_filter(Jekyll::BUFFER)
