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
  def run([]) do
    posts =
      "blog"
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> Enum.map(&SimpleBlog.Post.parse(&1))

    index_html =
      File.read("blog/index.html.eex")
      |> SimpleBlog.Converter.Page.exx_to_html(posts)
      |> rewrite_stylesheets()
      |> rewrite_images()

    File.mkdir("output")
    {:ok, file} = File.open("output/index.html", [:write])

    index_html
    |> String.split("\n")
    |> Enum.each(fn line -> IO.binwrite(file, rewrite_post_links(line) <> "\n") end)

    File.close(file)

    File.cp_r("blog/css", "output/css")
    File.cp_r("blog/images", "output/images")

    write_html_posts(posts)
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

  defp write_html_posts(posts) do
    posts
    |> Enum.map(&create_folders/1)
    |> IO.inspect()

    posts
    |> Enum.map(&create_posts_html/1)
  end

  defp create_folders(post) do
    post
    |> SimpleBlog.Post.generate_html_dir("output/posts/")
    |> File.mkdir_p()
  end

  def create_posts_html(post) do
    dir = SimpleBlog.Post.generate_html_dir(post, "output/posts/")
    filename = SimpleBlog.Post.generate_html_filename(post)
    postname = SimpleBlog.Post.generate_filename(post)

    post =
      "blog"
      |> SimpleBlog.Reader.Posts.read_post(postname)
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> SimpleBlog.Post.parse()

    result =
      File.read("blog/post.html.eex")
      |> SimpleBlog.Converter.Page.exx_to_html(post)
      |> rewrite_stylesheets_post()
      |> rewrite_images_post()
      |> rewrite_back_link_post()

    {:ok, file} = File.open(dir <> filename, [:write])
    IO.binwrite(file, result)
    File.close(file)
  end
end
