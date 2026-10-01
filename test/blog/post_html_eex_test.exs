defmodule Blog.PostHtmlEexTest do
  use ExUnit.Case

  @template File.read!("blog/post.html.eex")

  test "loads prism-markup-templating before prism-php, since php depends on it" do
    markup_templating_index =
      :binary.match(@template, "prism-markup-templating.min.js") |> elem(0)

    php_index = :binary.match(@template, "prism-php.min.js") |> elem(0)

    assert markup_templating_index < php_index
  end

  test "links the stylesheet of the configured theme" do
    html =
      SimpleBlog.Converter.Page.eex_to_html({:ok, @template}, %SimpleBlog.Post{}, theme: "sepia")

    assert html =~ ~s(<link rel="stylesheet" href="/css/themes/sepia.css">)
  end
end
