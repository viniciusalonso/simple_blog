defmodule Mix.Tasks.SimpleBlog.Compile do
  use Mix.Task
  require Logger
  require Floki
  require SimpleBlog.RewriteHTML.{Stylesheet, Image, PostsLink}

  @moduledoc """
  Command responsible for transpile markdown into html
  """

  @doc """
  Generates a static blog at output folder

  ## Examples

      iex> Mix.Tasks.SimpleBlog.Compile.run([])
  """
  @impl Mix.Task
  def run([]), do: run(["blog", "output"])

  def run([root_directory, output_directory]) do
    posts =
      root_directory
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> Enum.map(&SimpleBlog.Post.parse(&1))

    index_html =
      File.read(root_directory <> "/index.html.eex")
      |> SimpleBlog.Converter.Page.eex_to_html(posts)
      |> SimpleBlog.RewriteHTML.Stylesheet.rewrite("./")
      |> SimpleBlog.RewriteHTML.Image.rewrite("./")
      |> SimpleBlog.RewriteHTML.PostsLink.rewrite()

    File.mkdir(output_directory)
    {:ok, file} = File.open(output_directory <> "/index.html", [:write])
    IO.binwrite(file, index_html)
    File.close(file)

    File.cp_r(root_directory <> "/css", output_directory <> "/css")
    File.cp_r(root_directory <> "/images", output_directory <> "/images")

    write_html_posts(root_directory, output_directory, posts)
  end

  defp write_html_posts(root_directory, output_directory, posts) do
    posts
    |> Enum.map(&create_folders(&1, output_directory))

    posts
    |> Enum.map(&create_posts_html(&1, root_directory, output_directory))
  end

  defp create_folders(post, output_directory) do
    post
    |> SimpleBlog.Post.generate_html_dir(output_directory <> "/posts/")
    |> File.mkdir_p()
  end

  def create_posts_html(post, root_directory, output_directory) do
    dir = SimpleBlog.Post.generate_html_dir(post, output_directory <> "/posts/")
    filename = SimpleBlog.Post.generate_html_filename(post)
    postname = SimpleBlog.Post.generate_filename(post)

    post =
      root_directory
      |> SimpleBlog.Reader.Posts.read_post(postname)
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> SimpleBlog.Post.parse()

    result =
      File.read(root_directory <> "/post.html.eex")
      |> SimpleBlog.Converter.Page.eex_to_html(post)
      |> SimpleBlog.RewriteHTML.Stylesheet.rewrite("../../../../")
      |> SimpleBlog.RewriteHTML.Image.rewrite("../../../../")
      |> SimpleBlog.RewriteHTML.BackLink.rewrite()

    {:ok, file} = File.open(dir <> filename, [:write])
    IO.binwrite(file, result)
    File.close(file)
  end
end
