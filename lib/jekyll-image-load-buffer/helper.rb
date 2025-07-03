require 'nokogiri'
require 'fastimage'

def get_img_tag_width(img)
    # Inside your img loop
    width_value = nil

    # 1. Check for width attribute
    if img.has_attribute?('width')
      width_value = img['width']
    end

    # 2. Check for width in inline style
    if img['style']
      style = img['style']
      # Use regex to extract width from style (e.g., width: 300px;)
      match = style.match(/(^|;)\s*width\s*:\s*([^;]+)/i)
      width_value ||= match[2].strip if match
    end

    return width_value
end

def wrap_each_img_tag(html)
    # Normalize invalid </img> closing tags by removing them
    html = html.gsub(%r{</img>}, '')

    # Parse the HTML
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    # Process all <img> tags
    doc.css('img').each do |img|
      # Update or append class
      existing_class = img['class']
      img['class'] = existing_class ? "#{existing_class} buffer-image" : 'buffer-image'
      
      image_width = '100%'
      specified_image_width = get_img_tag_width(img)
      if specified_image_width
          image_width = specified_image_width
      end
      img['width'] = '100%'

      
      width = 1
      height = 1
      img_src = img['src']
      is_local_image = img_src.start_with?("/")
      path_for_checking = img_src
      if is_local_image
          path_for_checking = File.join(Dir.pwd,img_src)
      end
      
          
      size = FastImage.size(path_for_checking,:timeout=>5)
      if size
          width, height = size
          #print "Width: #{width}, Height: #{height}"
      else
          raise "Could not determine image size due to failing to load or failing to load within 5 seconds: " + path_for_checking
      end
      
      
      # Build nested wrapper elements
      image_container = Nokogiri::XML::Node.new('div', doc)
      image_container['class'] = 'image-container'
      image_container['style'] = 'width: 100%;'

      placeholder_wrapper = Nokogiri::XML::Node.new('div', doc)
      placeholder_wrapper['class'] = 'placeholder-wrapper'
      placeholder_wrapper['data-aspect-ratio'] = height.to_s + " / " + width.to_s
      placeholder_wrapper['data-custom-width-percentage'] = image_width.delete('%')
      placeholder_wrapper['style'] = 'width: '+ image_width +';'

      placeholder = Nokogiri::XML::Node.new('div', doc)
      placeholder['class'] = 'placeholder'
      placeholder['style'] = 'width: 100%;'

      spinner = Nokogiri::XML::Node.new('div', doc)
      spinner['class'] = 'spinner'

      # Assemble the structure
      placeholder.add_child(spinner)
      placeholder_wrapper.add_child(placeholder)
      placeholder_wrapper.add_child(img.clone)
      image_container.add_child(placeholder_wrapper)

      # Replace original img with wrapped structure
      img.replace(image_container)

  end

  doc.to_html
end
