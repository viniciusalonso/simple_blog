defmodule SimpleBlog.RewriteHTML.PostsLink do
  import SimpleBlog.RewriteHTML

  def rewrite(html) do
    update_tags(html, "a", fn element ->
      if has_class?(element, "post-link") do
        update_attribute(element, "href", &rewrite_href/1)
      else
        element
      end
    end)
  end

  defp rewrite_href(href) do
    if String.contains?(href, "?post="), do: filename(href), else: href
  end

  defp filename(x) do
    href =
      String.split(x, "?post=")
      |> List.last()
      |> String.split(".md")
      |> List.first()

    <<year::binary-size(4), _, month::binary-size(2), _, day::binary-size(2), _,
      filename::binary>> = href

    "posts/#{year}/#{month}/#{day}/#{filename}.html"
  end
end
