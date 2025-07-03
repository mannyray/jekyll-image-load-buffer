# jekyll-image-load-buffer

This repository hosts code for a [filter plugin](https://jekyllrb.com/docs/liquid/filters/) for Jekyll based websites. Once Jekyll generates the html for the site via the `jekyll build/serve` command, then this plugin filters the html for `<img>` tags and wraps them in a series of `<div>`s with added `javascript` and `css` styling. The result is that each image on the page has a placeholder with a loading spinner with the same dimensions and location as the image. Once the image is fully loaded the placeholder is replaced by the image.

<center>
<img src="assets/simulation.gif" height="50%">
</center>

By having a loading placeholder for slow to load images we can now resolve the [Cumulative Layout Shift](https://www.bfoliver.com/2020/jekyll-image-loading) problem which removes the annoying experience of loading a web page and scrolling down... only to have your web view port bumped due to some images above loading and displacing what you are reading. Removing the annoying experience would make your site more appealing.

The effect appealing - web viewers are impatient
#

 - actual stats for loading in page - not that much but people expect quality - amazon quote
 - how this was tested and developed via chat gpt
- do people scroll down to see images

I am grateful for Ben Oliver's article [https://www.bfoliver.com/2020/jekyll-image-loading](https://www.bfoliver.com/2020/jekyll-image-loading) on this issue as it gave me a starting ground to develop the filter.


For development I heavily relied on chatgpt. I
I am grateful for Ben Oliver's website 

## How to use

### 1. Import the plugin

Copy the plugin folder `jekyll-image-load-buffer` from this repository `lib` directory into your site's `_plugin` folder.

### 2. Modify `_layouts/post.html` to have the ` | buffer` filter.

The buffer filter uses a custom page property so `{{ content }}` will be replaced with  `{{ content | buffer: page.image_buffering  }}`. You can modify any layout you have (does not have to be `post.html`) - read more about Jekyll layouts [here](https://jekyllrb.com/docs/step-by-step/04-layouts/).

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

### 4. Add the images to your markdown files

For example:

```markdown
![](http://<SOME RANDOM (but not my) WEBSITE>.com/images/best_image.png)

![](/images/my_site_image.png)

<center>
<img src="/images/my_site_image_2.png" width="60%">
</center>
```

> [!CAUTION]
> For the second link ( i.e. `![](/images/my_site_image.png)`) the path used is called a "root-relative URL". You _must_ use root-relative paths for images that are local-to-your-website. For images outside of your website feel free to use "absolute URL" (e.g `http://<SOME RANDOM (but not my) WEBSITE>.com/images/best_image.png`) so long as the plugin has access to the internet when building the site.
>  
> Other  "root-relative URL" markdown alternatives for local-to-your-website images are "relative URL" (e.g `![](my_site_image.png)`) and "absolute URL" (e.g. `![]({{ site.url }}/images/my_site_image.png)`). Do not use these two alternatives as this repository's plugin needs to be able to compute the dimensions of your image first which is easiest with a root relative path.
>
> This path restriction is one of the reasons that in step 3 above we have `image_buffering` default to false.

> [!NOTE]
> The third image link ( i.e `<img src="/images/my_site_image_2.png" width="60%">` ) shows that this plugin allows for linking images outside of the usual markdown style of `![](...)`. I find this personally useful as sometimes my site's Jekyll minima theme will show images that are too big (especially portrait formatted ones) and so restricting via `width="<SOME PERCENTAGE>%"` is handy.

### 5. Build your website via `jekyll serve` or `jekyll build` to see the results.
