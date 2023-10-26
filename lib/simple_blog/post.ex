defmodule SimpleBlog.Post do
  @moduledoc """
  Module responsible for Post
  """

  @extension "md"

  defstruct title: "", body: "", date: "", filename: ""

  @doc """
  Generate directory name for blog post

  ## Examples

      iex> SimpleBlog.Post.generate_filename(%SimpleBlog.Post{ title: "My first blog post", date: ~D[2023-10-04]})
      "2023-10-04-my-first-blog-post.md"
  """
  def generate_filename(%SimpleBlog.Post{title: title, date: date}) do
    normalized_title =
      title
      |> String.downcase()
      |> String.replace(" ", "-", global: true)

    "#{date}-#{normalized_title}.#{@extension}"
  end

  @doc """
  Parse comment with data into %SimpleBlog.Post struct

  ## Examples
      iex> body = "<!---
      ...>filename: 2023-10-25-dev-onboarding.md
      ...>title: Dev onboarding
      ...>date: 2023-10-25
      ...> --->"
      iex> SimpleBlog.Post.parse(body)
      %SimpleBlog.Post{body: body, title: "Dev onboarding", date: "2023-10-25", filename: "2023-10-25-dev-onboarding.md"}
  """
  def parse(body) do
    [_, filename_line, title_line, date_line | _] = String.split(body, "\n")

    filename = String.replace(filename_line, "filename: ", "")
    title = String.replace(title_line, "title: ", "")
    date = String.replace(date_line, "date: ", "")

    %SimpleBlog.Post{body: body, title: title, date: date, filename: filename}
  end

  @doc """
  Generate filename for blog post

  ## Examples

      iex> SimpleBlog.Post.generate_html_dir(%SimpleBlog.Post{date: "2023-10-04"}, "output")
      "output/2023/10/04/"
  """
  def generate_html_dir(%SimpleBlog.Post{date: date}, base_dir) do
    [year, month, day] = String.split(date, "-")
    base_dir <> "/" <> year <> "/" <> month <> "/" <> day <> "/"
  end

  @doc """
  Generate html filename for blog post

  ## Examples

      iex> SimpleBlog.Post.generate_html_filename(%SimpleBlog.Post{title: "doctests with elixir"})
      "doctests-with-elixir.html"
  """
  def generate_html_filename(%SimpleBlog.Post{title: title}) do
    title
    |> String.replace(" ", "-")
    |> String.downcase()
    |> Kernel.<>(".html")
  end
end
