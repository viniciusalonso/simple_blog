defmodule SimpleBlog.RewriteHTML.Image do
  require Floki

  def rewrite(html, path) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find_and_update(document, "img", fn element ->
      {"img", [{"src", src} | attrs]} = element
      {"img", [{"src", String.replace(src, "/", path, global: false)} | attrs]}
    end)
    |> Floki.raw_html()
  end
end
