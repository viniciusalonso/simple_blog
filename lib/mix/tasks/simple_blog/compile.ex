defmodule Mix.Tasks.SimpleBlog.Compile do
  use Mix.Task
  require Logger

  @moduledoc """
  Module responsible for transpile markdown into html
  """

  @impl Mix.Task
  def run([]) do
    "blog"
    |> FlatFiles.list_all()
    |> Enum.map(&parse_files/1)

    File.cp_r("blog/css", "output/css")
    File.cp_r("blog/images", "output/images")
  end

  defp parse_files(file) do
    cond do
      String.contains?(file, "index.html.eex") -> convert_to_html(file)
      true -> IO.inspect(file)
    end
  end

  defp convert_to_html(_file) do
    posts =
      "blog"
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> Enum.map(&SimpleBlog.Post.parse(&1))

    result =
      File.read("blog/index.html.eex")
      |> SimpleBlog.Converter.Page.exx_to_html(posts)
      |> rewrite_stylesheets()
      |> rewrite_images()

    File.mkdir("output")
    {:ok, file} = File.open("output/index.html", [:write])

    result
    |> String.split("\n")
    |> Enum.each(fn line -> IO.binwrite(file, line <> "\n") end)

    File.close(file)
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

  defp rewrite_images(html) do
    html
    |> String.replace(
      ~s(<img src="/images/avatar.png" alt="avatar" class="avatar">),
      ~s(<img src="./images/avatar.png" alt="avatar" class="avatar">)
    )
  end
end
