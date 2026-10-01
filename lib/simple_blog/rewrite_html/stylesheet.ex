defmodule SimpleBlog.RewriteHTML.Stylesheet do
  import SimpleBlog.RewriteHTML

  def rewrite(html, path) do
    update_tags(html, "link", fn element ->
      if attribute(element, "rel") == "stylesheet" do
        update_attribute(element, "href", &rewrite_href(&1, path))
      else
        element
      end
    end)
  end

  defp rewrite_href("//" <> _ = href, _path), do: href
  defp rewrite_href("/" <> href, path), do: path <> href
  defp rewrite_href(href, _path), do: href
end
