defmodule SimpleBlog.Reader.Posts do
  @moduledoc """
  Module responsible for read blog posts
  """

  @doc """
  Reads content from markdown files located in _posts

  ## Examples

      iex> SimpleBlog.Reader.Posts.read_from_dir("blog")
      ["## post title 1", "## post title 2"]
  """
  def read_from_dir(root_directory) do
    posts_directory = root_directory <> "/_posts/"

    case File.ls(posts_directory) do
      {:ok, files} -> pipeline(posts_directory, files)
      {:error, :enoent} -> raise("Directory #{posts_directory} not found")
    end
  end

  @doc """
  Reads content from markdown file for specific post

  ## Examples

      iex> SimpleBlog.Reader.Posts.read_post("blog", "2023-10-25-metaprogramming-in-ruby.md")
      "### Metaprogramming in ruby"
  """
  def read_post(root_directory, post) do
    posts_directory = root_directory <> "/_posts/"
    post_path = posts_directory <> post

    case File.read(post_path) do
      {:ok, file} -> pipeline(posts_directory, file)
      {:error, :enoent} -> raise("Directory #{posts_directory} not found")
    end
  end

  defp pipeline(_posts_directory, []), do: []

  defp pipeline(posts_directory, files) when is_list(files) do
    files
    |> Enum.map(fn file -> full_path(file, posts_directory) end)
    |> Enum.filter(&only_markdown_file/1)
    |> Enum.map(&read_markdown/1)
  end

  defp pipeline(_posts_directory, file), do: file

  defp full_path(file, posts_directory) do
    Path.expand(posts_directory <> file)
  end

  defp only_markdown_file(file), do: String.ends_with?(file, ".md")

  defp read_markdown(file) do
    result = File.read(file)

    {:ok, content} = result
    content
  end
end
