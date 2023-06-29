---
title: (ノಠ益ಠ)ノ
layout: "base.njk"
---

{% for post in collections.posts  %}
    {% if post.data.tag == "rpa" %}
        [{{ post.data.title }}]({{ post.url }})
    {% endif %}
{% endfor %}
