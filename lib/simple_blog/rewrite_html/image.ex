defmodule SimpleBlog.RewriteHTML.Image do
  require Floki

  def rewrite(html, path) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find_and_update(document, "img", fn {"img", attrs} ->
      {"img", Enum.map(attrs, &rewrite_attr(&1, path))}
    end)
    |> Floki.raw_html()
  end

  defp rewrite_attr({"src", "//" <> _} = attr, _path), do: attr
  defp rewrite_attr({"src", "/" <> src}, path), do: {"src", path <> src}
  defp rewrite_attr(attr, _path), do: attr
end
