defmodule SimpleBlog.Converter.Posts do
  require Earmark

  def markdown_to_html(files) do
    html =
      for file <- files do
        {:ok, html_doc, []} = Earmark.as_html(file)
        html_doc
      end

    html
  end
end
