defmodule SimpleBlog.Converter.Posts do
  require Earmark

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
