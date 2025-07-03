require 'nokogiri'

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

      # Build nested wrapper elements
      image_container = Nokogiri::XML::Node.new('div', doc)
      image_container['class'] = 'image-container'

      placeholder_wrapper = Nokogiri::XML::Node.new('div', doc)
      placeholder_wrapper['class'] = 'placeholder-wrapper'
      placeholder_wrapper['data-aspect-ratio'] = "100 / 100"

      placeholder = Nokogiri::XML::Node.new('div', doc)
      placeholder['class'] = 'placeholder'

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
