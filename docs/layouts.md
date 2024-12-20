# Layouts

Archives layouts are special layouts that specify how an archive page is displayed. Special attributes are available to these layouts to represent information about the specific layout being generated. These layouts are otherwise identical to regular Jekyll layouts. To handle the variety of cases presented through the attributes, we recommend that you use [type-specific layouts](./configuration.md#type-specific-layouts).

### Layout attributes
#### Title (`page.title`)
The `page.title` attribute contains information regarding the name of the archive *if and only if* the archive is a tag or category archive. In this case, the attribute simply contains the name of the tag/category. For date-based archives (year, month, and day), this attribute is `nil`.

#### Date (`page.date`)
In the case of a date archive, this attribute contains a Date object that can be used to present the date header of the archive in a suitable format. For year archives, the month and day components of the Date object passed to Liquid should be neglected; similarly, for month archives, the day component should be neglected. We recommend using the [`date` filter](http://docs.shopify.com/themes/liquid-documentation/filters/additional-filters#date) in Liquid to process the Date objects. For tag and category archives, this field is `nil`.

#### Documents (`page.documents`)
The `page.documents` attribute contains an array of Document objects matching the archive criteria. You can iterate over this array just like any other Document array in Jekyll.

#### Type (`page.type`)
This attribute contains a simple string indicating the type of the layout being generated. Its value can be one of `year`, `month`, `day`, or any other array attribute. When not date-based, this string will be a singularized version of the attribute name. For example, if the archive is generated from the `tags` attribute, this attribute will be `tag`. The singularization of the attribute name is handled by the [singularize](https://www.rubydoc.info/gems/activesupport/String:singularize) method from the ActiveSupport gem.

#### Collection name (`page.collection_name`)
Contains the name of the collection being currently handled, as named in `_config.yml`.

### Sample layouts

The sample layouts were generated considering this configuration in `_config.yml`:
```yml
collections:
  books:
    output: true

jekyll-archives:
  posts:
    enabled: [year, tags, categories]
  books:
    enabled: [year, tags, categories]
```

Note that, by default, Jekyll also generates the `posts` collection.

#### Tag and category layout

<!-- {% raw %} -->
```html
<h1>Archive of {{ page.collection_name }} with {{ page.type }} '{{ page.title }}'</h1>
<ul class="posts">
  {% for document in page.documents %}
    <li>
      <span class="post-date">{{ document.date | date: "%b %-d, %Y" }}</span>
      <a class="post-link" href="{{ document.url | relative_url }}">{{ document.title }}</a>
    </li>
  {% endfor %}
</ul>
```

#### Year layout
```html
<h1>Archive of {{ page.collection_name }} from {{ page.date | date: "%Y" }}</h1>

<ul class="posts">
{% for document in page.documents %}
  <li>
    <span class="post-date">{{ document.date | date: "%b %-d, %Y" }}</span>
    <a class="post-link" href="{{ document.url | relative_url }}">{{ document.title }}</a>
  </li>
{% endfor %}
</ul>
```

#### Month layout
```html
<h1>Archive of {{ page.collection_name }} from {{ page.date | date: "%B %Y" }}</h1>

<ul class="posts">
{% for document in page.documents %}
  <li>
    <span class="post-date">{{ document.date | date: "%b %-d, %Y" }}</span>
    <a class="post-link" href="{{ document.url | relative_url }}">{{ document.title }}</a>
  </li>
{% endfor %}
</ul>
```

#### Day layout
```html
<h1>Archive of {{ page.collection_name }} from {{ page.date | date: "%B %-d, %Y" }}</h1>

<ul class="posts">
{% for document in page.documents %}
  <li>
    <span class="post-date">{{ document.date | date: "%b %-d, %Y" }}</span>
    <a class="post-link" href="{{ document.url | relative_url }}">{{ document.title }}</a>
  </li>
{% endfor %}
</ul>
```
<!-- {% endraw %} -->
