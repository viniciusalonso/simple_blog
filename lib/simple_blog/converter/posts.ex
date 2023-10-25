defmodule SimpleBlog.Converter.Posts do
  require Earmark

  @moduledoc """
  Module responsible for convert posts from markdown to html
  """

  @doc """
  Convert markdown file to html

  ## Examples

      iex> SimpleBlog.Converter.Posts.markdown_to_html(["# post1", "# post2"])
      ["<h1>\\npost1</h1>\\n", "<h1>\\npost2</h1>\\n"]

      iex> SimpleBlog.Converter.Posts.markdown_to_html("# post1")
      "<h1>\\npost1</h1>\\n"

      iex> SimpleBlog.Converter.Posts.markdown_to_html([])
      []
  """
  def markdown_to_html([]), do: []

  def markdown_to_html(files) when is_list(files) do
    html =
      for file <- files do
        {:ok, html_doc, []} = Earmark.as_html(file)
        html_doc
      end

    html
  end

  def markdown_to_html(file) do
    {:ok, html_doc, []} = Earmark.as_html(file)
    html_doc
  end
end
