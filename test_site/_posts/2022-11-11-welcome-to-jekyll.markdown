---
layout: post
title:  "Welcome to Jekyll!"
date:   2022-11-11 16:27:06 -0600
categories: jekyll update
image_buffering: true
---

Hey hey hey! Let's test this new Jekyll plugin. There is supposed to be an image between this paragraph and the next one. Ideally we don't have our page jumping around too much once it loads even if images are slow to load.

![](/photos/out.gif)

Now the image is supposed to be above this sentence. It is purposely a large (over 20Mb) file of a gif that the host of this site, github pages, takes some time to load (like 10 seconds). The large file helps make sure you don't miss seeing the grey box with the spinner. For smaller images the loading would be much faster, but regardless the grey box with spinner helps avoid the jumping around of images loading after the overall html.

For image loading speed I have done some experimentation in [https://github.com/mannyray/image-optimize?tab=readme-ov-file#what-about-the-numbers](https://github.com/mannyray/image-optimize?tab=readme-ov-file#what-about-the-numbers) as well as in [https://github.com/mannyray/jekyll-image-load-buffer?tab=readme-ov-file#motivation](https://github.com/mannyray/jekyll-image-load-buffer?tab=readme-ov-file#motivation).
