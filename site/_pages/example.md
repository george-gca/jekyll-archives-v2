---
layout: base
permalink: /
---

# jekyll-archives-v2

This plugin enables to automatically generate collections archives by dates or by any other `Array` attribute, like tags and categories.

Here you can see the resulting archives pages:
- books
  - by year: [2024]({{ "/books/2024/" | relative_url }})
  - by tags: [tag1]({{ "tag1" | slugify | prepend: '/books/tag/' | relative_url }}), [tag2]({{ "tag2" | slugify | prepend: '/books/tag/' | relative_url }})
  - by categories: [category1]({{ "category1" | slugify | prepend: '/books/category/' | relative_url }}), [category2]({{ "category2" | slugify | prepend: '/books/category/' | relative_url }})
- posts
  - by year: [2024]({{ "/blog/2024/" | relative_url }})
  - by tags: [tag1]({{ "tag1" | slugify | prepend: '/blog/tag/' | relative_url }}), [tag2]({{ "tag2" | slugify | prepend: '/blog/tag/' | relative_url }})
  - by categories: [category1]({{ "category1" | slugify | prepend: '/blog/category/' | relative_url }}), [category2]({{ "category2" | slugify | prepend: '/blog/category/' | relative_url }})

## Installation

1. Add `gem 'jekyll-archives-v2'` to your site's Gemfile
2. Add the following to your site's `_config.yml`:

```yml
plugins:
  - jekyll-archives-v2
```

## Usage

Suppose you have a collection called `books` and also your blog posts, and you want to generate archives by date, tags, and categories, like in the example above. You can do this by adding the following to your site's `_config.yml`:

```yml
# adding the books collection. Note that jekyll already generates the posts collection
collections:
  books:
    output: true

jekyll-archives:
  books:
    enabled: [year, tags, categories]
  posts:
    enabled: [year, tags, categories]
    permalinks: # in this case, we wanted to replace /posts/ by /blog/
      year: "/blog/:year/"
      tags: "/blog/:type/:name/"
      categories: "/blog/:type/:name/"
```

By default, the plugin will look for a layout called `archive` in the `_layouts` directory. In this layout, the plugin will render the archive's content. In our example, we will use the same layout for all archives.

{% raw %}
```liquid
<div>
  {% if page.type == 'categories' %}
    <h2>an archive of {{ page.collection_name }} in {{ page.title }} category</h2>
  {% elsif page.type == 'year' %}
    <h2>an archive of {{ page.collection_name }} from {{ page.date | date: '%Y' }}</h2>
  {% elsif page.type == 'tags' %}
    <h2>an archive of {{ page.collection_name }} with {{ page.type }} {{ page.title }}</h2>
  {% endif %}

  <table>
    {% for document in page.documents %}
      <tr>
        <th>{{ document.date | date: '%b %d, %Y' }}</th>
        <td>
          <a href="{{ document.url | relative_url }}">{{ document.title }}</a>
        </td>
      </tr>
    {% endfor %}
  </table>
</div>
```
{% endraw %}

## Configuration

Default configuration:

```yml
jekyll-archives:
  posts:
    enabled: []
    layout: archive
    permalinks:
      year: '/:collection/:year/'
      month: '/:collection/:year/:month/'
      day: '/:collection/:year/:month/:day/'
      tags: '/:collection/:type/:name/'
```

This default configuration is generated per collection. You can customize the configuration for each collection individually by adding the collection name as a key inside `jekyll-archives`. For example, to customize the configuration for the `books` collection and the `posts`, you can do it like this:

```yml
jekyll-archives:
  books:
    ...
  posts:
    ...
```

Each collection configuration can have the following options.

### enabled

An array of the archive types you want to generate. The available types are `year`, `month`, `day`, and any other Array attribute that your collection might have, like `tags`. Note that this attribute have to be defined in the [front matter](https://jekyllrb.com/docs/front-matter/) of every document in your collection, for example, `tags: tag1 tag2`. If you want to support every option, you can set `enabled: true` or `enabled: 'all'`.

### layout or layouts

The layout that the plugin will use to render the archive's content. The default value is `layout: archive`, meaning that it will look for any file with the name `archive` in the `_layouts/` directory. This layout can have any extension, for example `archive.html` or `archive.liquid`. You can also set a different layout for each archive type by using the `layouts` option instead of `layout`. For example:

```yml
jekyll-archives:
  books:
    layouts:
      year: year-archive
      month: month-archive
      day: day-archive
      category: category-archive
      tag: tag-archive
```

These layouts works as any other Jekyll layout, except that they will receive the following extra or modified variables:

#### title (`page.title`)

The name of the archive if it is created from an Array attribute, like tags. For example, if the archive is for the tag `examples`, the title will be `examples`. For date-based archives (year, month, and day), this attribute is `nil`.

#### date (`page.date`)

In the case of a date archive, this attribute contains a Date object that can be used to present the date header of the archive in a suitable format. For year archives, the month and day components of the Date object passed to Liquid should be neglected; similarly, for month archives, the day component should be neglected. We recommend using the [date filter](https://shopify.dev/docs/api/liquid/filters/date) in Liquid to process the Date objects. For tag and category archives, this field is `nil`.

#### collection_name (`page.collection_name`)

The name of the collection that the archive is generated from. For example, if the archive is generated from the `books` collection, this attribute will be `books`.

#### documents (`page.documents`)

This is an array of Jekyll documents that are part of the archive. You can use this array to list the documents in the current archive, iterating through them with {% raw %}`{% for document in page.documents %}`{% endraw %}.

#### type (`page.type`)

This attribute contains a simple string indicating the type of the layout being generated. Its value can be one of `year`, `month`, `day`, or any other Array attribute that it was enabled for this collection. When not date-based, this string will be a singularized version of the attribute name. For example, if the archive is generated from the `tags` attribute, this attribute will be `tag`. The singularization of the attribute name is handled by the [singularize](https://www.rubydoc.info/gems/activesupport/String:singularize) method from the ActiveSupport gem.

### permalinks

Maps archive types to the permalink format used for archive pages. The permalink style is the same as regular Jekyll posts and pages, but with different variables.

These variables are:

- `:collection` for the collection name (e.g., `books`)
- `:type` for the archive type, singularized (e.g., `tag`)
- `:year` for year archives (e.g., `2024`)
- `:year` and `:month` for month archives (e.g. `2024` and `01`)
- `:year`, `:month`, and `:day` for day archives (e.g. `2024`, `01`, and `31`)
- `:name` for Array attributes, like categories and tags archives (e.g., `sample-tag`)

> Note: trailing slashes are required to create the archive as an `index.html` file of a directory, as in `/:collection/:type/:name/`.
