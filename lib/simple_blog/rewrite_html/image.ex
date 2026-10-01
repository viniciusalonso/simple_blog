defmodule SimpleBlog.RewriteHTML.Image do
  import SimpleBlog.RewriteHTML

  def rewrite(html, path) do
    update_tags(html, "img", fn element ->
      update_attribute(element, "src", &rewrite_src(&1, path))
    end)
  end

  defp rewrite_src("//" <> _ = src, _path), do: src
  defp rewrite_src("/" <> src, path), do: path <> src
  defp rewrite_src(src, _path), do: src
end
