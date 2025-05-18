# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

set :markdown_engine, :kramdown
set :markdown,
    input: 'GFM',
    syntax_highlighter: :rouge,
    syntax_highlighter_opts: { css_class: 'highlight' }

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

activate :blog do |blog|
  blog.sources = "blog/{year}-{month}-{day}-{title}.html"
  blog.permalink = "blog/{year}/{month}/{day}/{title}.html"
  blog.layout = "blog"
  blog.taglink = "tags/{tag}.html"
  blog.tag_template = "tag"
  blog.new_article_template = "new_article"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page "/*.xml", layout: false
page "/*.json", layout: false
page "/*.txt", layout: false
page "/blog/*", layout: :blog_article

# With alternative layout
# page "/path/to/file.html", layout: "other_layout"

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   "/this-page-has-no-template.html",
#   "/template-file.html",
#   locals: {
#     which_fake_page: "Rendering a fake page with a local variable"
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  activate :minify_css
  activate :minify_html
  activate :minify_javascript, compressor: Terser.new
end
