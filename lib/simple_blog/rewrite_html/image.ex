defmodule SimpleBlog.RewriteHTML.Image do
  require Floki

  def rewrite(html, path) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find_and_update(document, "img", fn
      {"img", [{"src", src}, {"alt", alt}, {"class", class}]} ->
        {"img",
         [{"src", String.replace(src, "/", path, global: false)}, {"alt", alt}, {"class", class}]}

      {"img", [{"src", src}, {"alt", alt}, {"class", _class}, {"title", _t}]} ->
        {"img", [{"src", String.replace(src, "/", path, global: false)}, {"alt", alt}]}
    end)
    |> Floki.raw_html()
  end
end
