defmodule Blog.PostHtmlEexTest do
  use ExUnit.Case

  @template File.read!("blog/post.html.eex")

  test "loads prism-markup-templating before prism-php, since php depends on it" do
    markup_templating_index =
      :binary.match(@template, "prism-markup-templating.min.js") |> elem(0)

    php_index = :binary.match(@template, "prism-php.min.js") |> elem(0)

    assert markup_templating_index < php_index
  end

  test "stylesheet rewrite leaves the Prism CDN link untouched" do
    result = SimpleBlog.RewriteHTML.Stylesheet.rewrite(@template, "../../../../")

    assert result =~
             ~s(href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css")
  end
end
