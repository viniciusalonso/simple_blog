defmodule SimpleBlog.RewriteHTML.PostsLink do
  require Floki

  def rewrite(html) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find_and_update(document, "a.post-link", fn
      {"a", [{"class", _}, {"href", x}]} ->
        href = String.split(x, "?post=") |> List.last() |> String.split(".md") |> List.first()

        <<year::binary-size(4), _, month::binary-size(2), _, day::binary-size(2), _,
          filename::binary>> = href

        {"a", [{"href", "posts/#{year}/#{month}/#{day}/#{filename}.html"}]}
    end)
    |> Floki.raw_html()
  end
end
