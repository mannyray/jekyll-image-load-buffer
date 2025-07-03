# jekyll-image-load-buffer

_First part here has a lot of descritpion and research behind making this plugin. If you want to skip the descriptions then you can go to [How to use](#how-to-use) right away._

This repository hosts code for a [filter plugin](https://jekyllrb.com/docs/liquid/filters/) for Jekyll based websites. Once Jekyll generates the html for the site via the `jekyll build/serve` command, then this plugin filters the html for `<img>` tags and wraps them in a series of `<div>`s with added `javascript`s and `css` styling. The result is that each image on the page has a placeholder with a loading spinner with the same dimensions and location as the image. Once the image is fully loaded the placeholder is replaced by the image - see directly below:

BIG GIF LOADING HERE (BE PATIENT):

<center>
<img src="assets/simulation.gif" width="30%">
</center>

By having a loading placeholder for slow to load images we can now resolve the [Cumulative Layout Shift](https://www.bfoliver.com/2020/jekyll-image-loading) (CLS) problem which removes the annoying experience of loading a web page and scrolling down... only to have your web view port bumped due to some images above loading and displacing what you are reading. You probably experienced this effect just now when reading _this_ very README as the gif between this and previous paragraph takes some time to load. Removing this annoying experience would make your site more appealing.

The filter plugin is refered to as a "buffer", because traditionally in computer science "a buffer is a region of memory used to temporarily store data while it's being moved between different locations or processes" - this plugin siilarly adds a temporary loading square until the the image is loaded in. 

## motivation:

Making things more appealing is important as internet users value speed and are used to beautiful user experience on the web through all the big brand sites they use. These big brand sites take good care to optimize the experience as their bottom line depends on it:

> [More than 10 years ago, Amazon found that every 100ms of latency cost them 1% in sales. In 2006, Google found an extra .5 seconds in search page generation time dropped traffic by 20%. A broker could lose $4 million in revenues per millisecond if their electronic trading platform is 5 milliseconds behind the competition.](https://www.gigaspaces.com/blog/amazon-found-every-100ms-of-latency-cost-them-1-in-sales) 

Now this plugin is not designed for big brand sites, but intended for small Jekyll sites. However, the bar is set high by the big brands stores and we will try to match it. Unfortunately, it is not always possible to increase the speed of delivery of one's web page's image assets, but you can avoid the CLS problem simliar to how one can't easily increase their running pace, but can at least wear matching socks to appear more sane while jogging.
 
 I decided to test how slowly one of my [github hosted](https://pages.github.com) web pages loads images, by using a created-and-perfected-in-minutes-by-chatgpt python script (see `test_backend/load_times.py`) that checked image average load time on my webpage as if it was uncached (i.e first time loading) and got one second:
 ```
> python3 load_times.py https://szonov.com/about/ 10
...
📊 Per-Image Breakdown:
[1] https://szonov.com/assets/moped.png... -> loaded 10 times, avg: 0.9777s, size: 1.37 MB
```

The `1.4mb` file takes a second to load on average. I confirmed this duration lag visually in the browser as well. I then tried another link:

```
> python3 load_times.py https://szonov.com/programming/2021/08/30/simple-online-realtime-tracking/  10
...
📊 Per-Image Breakdown:
[1] https://szonov.com/assets/prototype/out.gif... -> loaded 10 times, avg: 4.8933s, size: 23.18 MB
[2] https://szonov.com/assets/prototype/video_capture.png... -> loaded 10 times, avg: 0.9191s, size: 0.96 MB
[3] https://szonov.com/assets/prototype/IMG_6378.JPG... -> loaded 10 times, avg: 0.7144s, size: 0.30 MB

```

The `24mb` gif is my Jekyll static site's version of self hosting a video so I intend to keep it and will definitely benefit from this buffer for a 5 second loading file as one can easily scroll to the bottom of a page in that time and encounter the CLS issue. However, outside of gifs maybe many of my image file are just too big and this is a reminder that some of my images should be measured in `kb` and not `mb`? I tried checking one of my site pages that has the smallest image of `20kb` and got `0.5` second load time.

```
> python3 load_times.py https://szonov.com/courses/cs246/  10              
...
📊 Per-Image Breakdown:
[1] https://szonov.com/assets/bb7k.png... -> loaded 10 times, avg: 0.5163s, size: 0.02 MB
```

It seems that as an image varies from `0.02mb` to `1.4mb` then its load time varies from `0.5s` to `1s` while somewhere in between like `0.3mb` sized image takes `0.7s` ( and `0.5mb` takes `1s` - terminal results not displayed here).

From checking the internet and various search-engine-optimization type sites it seems that `0.2mb`-`0.5mb` is an ideal size for a website image. Thus I decided to test my buffer feature with `0.7s` for my ideal future website where all my pictures are optimized to that range to reduce size while maintaining visual quality. Maybe `0.7s` is so fast that we don't need a buffer..let's test visually!

To add lag to an image loading locally, I wrote another created-and-perfected-in-minutes-by-chatgpt python scripts (see `test_backend/app.py`) that hosts a simple backend:

```python
RESPONSE_DELAY_SECONDS = 0.7 

@app.route('/images/<path:filename>')
def serve_image(filename):
    time.sleep(RESPONSE_DELAY_SECONDS)  # Add artificial lag

    try:
        return send_from_directory(IMAGE_FOLDER, filename)
    except FileNotFoundError:
        abort(404)

``` 

Now, if you run the python script in a directory with a `images/smile.png` file and enter `http://127.0.0.1:3000/images/smile.png` in a browser then you will see the image after `0.7s` of lag. If you lack images to use then you use Google's AI Gemini feature to generate some test ones like the ones I am using in this repository.

I can add the images to my Jekyll markdown post via:

```markdown
<center>
<img src="http://127.0.0.1:3000/images/smile_landscape.png" width="50%">
</center>
```

Furthermore, for testing locally, I will not be doing as much scrolling since if lag is less than a second then that is above threshold for an overly distracted reader as seen by `Time to First Scroll` in table below (source: chatgpt to question _"Do you know how quickly after a page appears in phone browser does a person usually scrolls down in cases where they are just scanning it. Is there some sort of metric out there in seconds or milliseconds"_)




| Use Case                                | Time to First Scroll (avg) | Notes                                  |
| --------------------------------------- | -------------------------- | -------------------------------------- |
| Scanning a blog/news article            | **1–2 seconds**            | Users want to find headings or summary |
| Searching for info on a product page    | **2–3 seconds**            | Visual scanning for images, prices     |
| Landing page with strong CTA above fold | **3–5 seconds**            | Might delay scroll if CTA is engaging  |
| Content perceived as ad or fluff        | **<1 second**              | Immediate scroll or bounce             |

Below is the table comparing with and without the buffer image load how page loads when image take `0.7s` to load given that the user is not scrolling down right away:

| With plugin                                | Without
| --------------------------------------- | -------------------------- |
| ![](assets/new_look.gif) | ![](assets/old_look.gif) |

I think the plugin (left hand side) makes things look better as there no jumping around. On each screen the two images load at the same time which is because the lag is `0.7s` exactly whereas it might appear more jagged in real life as some images might load faster or slower than others. I consider the improvement here a more of a cherry-on-top-of-your-ice-cream rather than the ice cream itself - a small beautiful touch.

Developing this cherry was lots of fun. For development I primarily used chatgpt to assist in accelerating  development especially when it came to ruby code or css/html styling. This all took me a day to create, but without chat-gpt this might have taken a week with lots of will power. I find coding is fundamentally the same in most computer languages but it's the tiny details that slow you down which I am grateful that chatgpt has allowed me to power through - I know how to say "I love you", just not in all (computer) languages.

Before coding up the plugin itself, I used the (aformentioned) backend in `test_backend/app.py` to simulate slowly loading images as well as `test_backend/display.html` to narrow down how exactly I want the plugin to work. Both `display.html` and `app.py` were created via chatgpt. I will list the questions, in order, I asked chatgpt to demonstrate that UI/Jekyll plugin work is now super easy for those html averse (I did minimal coding here - just quick copy paste and seeing if I like the prototype):

- Write a flask python application for serving images locally. For example when I call endpoint 127:0.0.1:3000/images/smile.png then the flask app will return the image 
- Can you modify the code to add a lag to the picture being returned
- can you write html code that displays that image and before it has loaded displays a loading message until the image is loaded
- Can you change the script code such that it assumes that image does not have a specific ID but instead is of class image
- would it work if there were multiple such images
- Nice! Can you modify the html such that images are in a single column that's width is 50% of screen as in the middle of the page
- Given that, in advance, I am aware of the actual dimensions of the image (which I can hardcode on the html page ), is it possible to replace the "Loading image 1..." type messages with a grey box that would have the same dimension as the image once it loaded
- Nice! Can we make it more difficult by having the image be 100% of the width of the column? This way even if the actual raw image is 300x200 then it may be stretched depending on the browser width. Can we make the loading grey box match that render width in all cases of how big the browser view is?
- Can the aspect ratio be computed in advance and stored by each individual image instead of an overarching .placeholder::before property
- This is good, but when I run the code only one image loads
- What is the "data-aspect-ratio" property of the div? It is not referenced anywhere
- I like the code, but once the images load there is an issue in that there is added whitespaces between the images. I checked the html and I believe it is due to the padding-bottom being set to the aspect ratio percentage even after the image has loaded. I believe once the image is loaded the aspect ratio should be set to zero
- Can you modify the code given that
    -image 1 has src "http://127.0.0.1:3000/images/smile.png" with width and height both 2048
    -image 2 has src "http://127.0.0.1:3000/images/smile_portrait.png" with width 1077  and height  1645
    -image 3 has src "http://127.0.0.1:3000/images/smile_landscape.png" width width 1795 and height 1032
- for some reason the images are not rendered on the screen
- If I use the "Full fixed minimal changes" fix then the images load but there is large space between the images. How do I fix that
- Can you change the grey box so that it is light grey and has a loading spinner in the middle of it

Finally, I am grateful for Ben Oliver's article [https://www.bfoliver.com/2020/jekyll-image-loading](https://www.bfoliver.com/2020/jekyll-image-loading) on this issue as it gave me a starting ground to develop the filter and idea about storing the image dimensions in advance.

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
