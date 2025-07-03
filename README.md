# jekyll-image-load-buffer

 - actual stats for loading in page - not that much but people expect quality - amazon quote


## How to use

### 1. Import the plugin

Copy the plugin folder `jekyll-image-load-buffer` from this repository `lib` directory into your site's `_plugin` folder.

### 2. Modify `_layouts/post.html` to have the ` | buffer` feature.

The buffer feature uses a custom post property so `{{ content }}` will be replaced with  `{{ content | buffer: page.image_buffering  }}`.

<table>
<tr>
<td> Before </td> <td> After </td>
</tr>
<tr>
<td>


```html
---
layout: default
---
<div class="post">
    <article class="post-content">
        {{ content }}
    </article>
</div>
```

</td>
<td>
    
```html
---
layout: default
---
<div class="post">
    <article class="post-content">
        {{ content | buffer: page.image_buffering  }}
    </article>
</div>
```
</td>
</tr>
</table>

### 3. Specify `image_buffering` property to be `true` to use the buffer image loading in a post

```markdown
---
layout: post
title:  "Welcome to Jekyll!"
date:   2022-11-11 16:27:06 -0600
categories: jekyll update
image_buffering: true
---
```
By default, a page will not have the plugin applied unless one defines `image_buffering` and sets it to `true` explicitly. This is done for backwards compatability in cases where you may have previous posts that you don't want to apply this filter to.

To reverse the default behavaiour to always buffer load images when `image_buffering` is not specified, then you must modify this repository's `lib/jekyll-image-load-buffer/jekyll-image-load-buffer.rb` 
```ruby
        ...
        def buffer(text,buffering_enabled)
            if buffering_enabled.nil?
                # default behaviour. specify if we apply the filter when
                # `image_buffering:` property in a post is not defined
                buffering_enabled = false
            end
            ...
```
to set `buffering_enabled = true`. 


### 4. Optional styling
