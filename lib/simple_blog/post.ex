defmodule SimpleBlog.Post do
  @moduledoc """
  Module responsible for Post
  """

  @extension "md"

  defstruct title: "", tags: [], body: "", date: ""

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
end
