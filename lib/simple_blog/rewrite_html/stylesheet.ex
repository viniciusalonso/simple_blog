defmodule SimpleBlog.RewriteHTML.Stylesheet do
  require Floki

  def rewrite(html, path) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find_and_update(document, "link", fn
      {"link", [{"rel", "stylesheet"}, {"href", href}]} ->
        if String.contains?(href, ".css") do
          {"link",
           [{"rel", "stylesheet"}, {"href", String.replace(href, "/", path, global: false)}]}
        else
          {"link", [{"rel", "stylesheet"}, {"href", href}]}
        end
    end)
    |> Floki.raw_html()
  end
end
