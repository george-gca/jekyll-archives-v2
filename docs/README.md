## About Jekyll Archives

Automatically generate collections archives by dates, tags, categories, or any other Array attribute.

[![Gem Version](https://badge.fury.io/rb/jekyll-archives-v2.svg)](http://badge.fury.io/rb/jekyll-archives-v2)
[![Tests](https://github.com/george-gca/jekyll-archives-v2/actions/workflows/test.yml/badge.svg)](https://github.com/george-gca/jekyll-archives-v2/actions/workflows/test.yml)
[![Ruby Style Guide](https://img.shields.io/badge/Code_Style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Style Check](https://github.com/george-gca/jekyll-archives-v2/actions/workflows/style-check.yml/badge.svg)](https://github.com/george-gca/jekyll-archives-v2/actions/workflows/style-check.yml)

## Getting started

### Installation

1. Add `gem 'jekyll-archives-v2'` to your site's Gemfile
2. Add the following to your site's `_config.yml`:

```yml
plugins:
  - jekyll-archives-v2
```

### Configuration

Archives can be configured by using the `jekyll-archives` key in the Jekyll configuration (`_config.yml`) file. See the [Configuration](configuration.md) page for a full list of configuration options.

All archives are rendered with specific layouts using certain metadata available to the archive page. The [Layouts](layouts.md) page will show you how to create a layout for use with Archives.

## Documentation

For more information, see:

* [Getting-started](getting-started.md)
* [Configuration](configuration.md)
* [Layouts](layouts.md)
