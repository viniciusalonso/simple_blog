defmodule SimpleBlog.RewriteHTML.PostsLink do
  require Floki

  def rewrite(html) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find_and_update(document, "a.post-link", fn element ->
      {"a", [{"href", x} | attrs]} = element
      {"a", [{"href", filename(x)} | attrs]}
    end)
    |> Floki.raw_html()
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
