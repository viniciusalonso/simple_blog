defmodule SimpleBlog.RewriteHTML.BackLink do
  require Floki

  @moduledoc """
  Module responsible for rewrite back link in post page
  """

  @doc """
  Rewrite link href attribute

  ## Examples

      iex> link = ~s(<a href="/" class="back-link">Back</a>)
      iex> SimpleBlog.RewriteHTML.BackLink.rewrite(link)
      ~s(<a href="../../../../index.html" class="back-link">Back</a>)
  """
  def rewrite(html) do
    {:ok, document} = Floki.parse_document(html)

    Floki.find_and_update(document, "a.back-link", fn element ->
      {"a", [{"href", "/"} | attrs]} = element
      {"a", [{"href", "../../../../index.html"} | attrs]}
    end)
    |> Floki.raw_html()
  end
end
