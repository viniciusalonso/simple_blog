defmodule Mix.Tasks.SimpleBlog.Compile do
  use Mix.Task
  require Logger

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
      |> SimpleBlog.Converter.Page.exx_to_html(posts)
      |> rewrite_stylesheets()
      |> rewrite_images()

    File.mkdir(output_directory)
    {:ok, file} = File.open(output_directory <> "/index.html", [:write])

    index_html
    |> String.split("\n")
    |> Enum.each(fn line -> IO.binwrite(file, rewrite_post_links(line) <> "\n") end)

    File.close(file)

    File.cp_r(root_directory <> "/css", output_directory <> "/css")
    File.cp_r(root_directory <> "/images", output_directory <> "/images")

    write_html_posts(root_directory, output_directory, posts)
  end

  defp rewrite_stylesheets(html) do
    html
    |> String.replace(
      ~s(<link rel="stylesheet" href="/css/_solarized-light.css">),
      ~s(<link rel="stylesheet" href="./css/_solarized-light.css">)
    )
    |> String.replace(
      ~s(<link rel="stylesheet" href="/css/plain.css">),
      ~s(<link rel="stylesheet" href="./css/plain.css">)
    )
    |> String.replace(
      ~s(<link rel="stylesheet" href="/css/style.css">),
      ~s(<link rel="stylesheet" href="./css/style.css">)
    )
  end

  defp rewrite_stylesheets_post(html) do
    html
    |> String.replace(
      ~s(<link rel="stylesheet" href="/css/_solarized-light.css">),
      ~s(<link rel="stylesheet" href="../../../../css/_solarized-light.css">)
    )
    |> String.replace(
      ~s(<link rel="stylesheet" href="/css/plain.css">),
      ~s(<link rel="stylesheet" href="../../../../css/plain.css">)
    )
    |> String.replace(
      ~s(<link rel="stylesheet" href="/css/style.css">),
      ~s(<link rel="stylesheet" href="../../../../css/style.css">)
    )
  end

  defp rewrite_images(html) do
    html
    |> String.replace(
      ~s(<img src="/images/avatar.png" alt="avatar" class="avatar">),
      ~s(<img src="./images/avatar.png" alt="avatar" class="avatar">)
    )
  end

  defp rewrite_images_post(html) do
    html
    |> String.replace(
      ~s(<img src="/images/avatar.png" alt="avatar" class="avatar">),
      ~s(<img src="../../../../images/avatar.png" alt="avatar" class="avatar">)
    )
  end

  defp rewrite_back_link_post(html) do
    html
    |> String.replace(
      ~s(<a href="/">Back</a>),
      ~s(<a href="../../../../index.html">Back</a>)
    )
  end

  defp rewrite_post_links(line) do
    if String.contains?(line, "post-link") do
      href = String.split(line, "?post=") |> List.last() |> String.split(".md") |> List.first()

      <<year::binary-size(4), _, month::binary-size(2), _, day::binary-size(2), _,
        filename::binary>> = href

      ~s(<a class="post-link" href="posts/#{year}/#{month}/#{day}/#{filename}.html">)
    else
      line
    end
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
      |> SimpleBlog.Converter.Page.exx_to_html(post)
      |> rewrite_stylesheets_post()
      |> rewrite_images_post()
      |> rewrite_back_link_post()

    {:ok, file} = File.open(dir <> filename, [:write])
    IO.binwrite(file, result)
    File.close(file)
  end
end
