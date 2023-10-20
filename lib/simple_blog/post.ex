defmodule SimpleBlog.Post do
  @moduledoc """
  Module responsible for Post
  """

  @extension "md"

  defstruct title: "", tags: [], body: "", date: "", filename: ""

  @doc """
  Generate filename for blog post

  ## Examples

    iex> SimpleBlog.Post.generate_filename(%SimpleBlog.Post{ title: "My first blog post", date: ~D[2023-10-04]  })
    "2023-10-04-my-first-blog-post.md"
  """
  def generate_filename(%SimpleBlog.Post{title: title, date: date}) do
    normalized_title =
      title
      |> String.downcase()
      |> String.replace(" ", "-", global: true)

    "#{date}-#{normalized_title}.#{@extension}"
  end

  def parse(body) do
    [_, filename_line, title_line, date_line | _] = String.split(body, "\n")

    filename = String.replace(filename_line, "filename: ", "")
    title = String.replace(title_line, "title: ", "")
    date = String.replace(date_line, "date: ", "")

    %SimpleBlog.Post{body: body, title: title, date: date, filename: filename}
  end
end
