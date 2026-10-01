defmodule Mix.Tasks.SimpleBlog.Build do
  use Mix.Task
  require Logger

  @shortdoc "Builds the static blog from blog/ into output/"

  @moduledoc """
  Builds the static version of the blog, ready to publish.

  Posts in `blog/_posts/` are converted from markdown to html with the
  `index.html.eex` and `post.html.eex` templates, and `blog/css/` and
  `blog/images/` are copied along.

      $ mix simple_blog.build
      $ mix simple_blog.build --output=/path/to/my_blog

  Every build replaces `index.html`, `posts/`, `css/` and `images/` in the
  output directory, so deleted posts are not published. Other files there,
  such as a `CNAME`, are kept.

  ## Options

    * `--source` - the blog directory to build. Defaults to `blog`.
    * `--output` - the directory to write the blog to. Defaults to `output`.
  """

  @usage """
  Invalid arguments. Usage:

      $ mix simple_blog.build [--source DIR] [--output DIR]
  """

  @templates ["index.html.eex", "post.html.eex"]
  @generated ["index.html", "posts", "css", "images"]

  @impl Mix.Task
  def run(args) do
    case OptionParser.parse(args, strict: [source: :string, output: :string]) do
      {opts, [], []} ->
        build(Keyword.get(opts, :source, "blog"), Keyword.get(opts, :output, "output"))

      _ ->
        Mix.raise(@usage)
    end
  end

  defp build(root_directory, output_directory) do
    validate_source!(root_directory)
    config = SimpleBlog.Config.read(root_directory)

    posts =
      root_directory
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> Enum.map(&SimpleBlog.Post.parse(&1))
      |> SimpleBlog.Post.sort_by_most_recent()

    index_html =
      File.read(root_directory <> "/index.html.eex")
      |> SimpleBlog.Converter.Page.eex_to_html(posts, config)
      |> SimpleBlog.RewriteHTML.Stylesheet.rewrite("./")
      |> SimpleBlog.RewriteHTML.Image.rewrite("./")
      |> SimpleBlog.RewriteHTML.PostsLink.rewrite()

    clean_output(output_directory)
    File.mkdir_p!(output_directory)
    {:ok, file} = File.open(output_directory <> "/index.html", [:write])
    IO.binwrite(file, index_html)
    File.close(file)

    File.cp_r(root_directory <> "/css", output_directory <> "/css")
    File.cp_r(root_directory <> "/images", output_directory <> "/images")

    write_html_posts(root_directory, output_directory, posts, config)

    Mix.shell().info("Blog built at #{output_directory} with #{pluralize_posts(length(posts))}")
  end

  defp validate_source!(root_directory) do
    unless File.dir?(root_directory) do
      Mix.raise("The blog directory #{root_directory} was not found")
    end

    for template <- @templates,
        path = Path.join(root_directory, template),
        not File.regular?(path) do
      Mix.raise("The template #{path} was not found")
    end
  end

  defp clean_output(output_directory) do
    for entry <- @generated, do: File.rm_rf!(Path.join(output_directory, entry))
  end

  defp pluralize_posts(1), do: "1 post"
  defp pluralize_posts(count), do: "#{count} posts"

  defp write_html_posts(root_directory, output_directory, posts, config) do
    posts
    |> Enum.map(&create_folders(&1, output_directory))

    posts
    |> Enum.map(&create_posts_html(&1, root_directory, output_directory, config))
  end

  defp create_folders(post, output_directory) do
    post
    |> SimpleBlog.Post.generate_html_dir(output_directory <> "/posts/")
    |> File.mkdir_p()
  end

  defp create_posts_html(post, root_directory, output_directory, config) do
    dir = SimpleBlog.Post.generate_html_dir(post, output_directory <> "/posts/")
    filename = SimpleBlog.Post.generate_html_filename(post)

    result =
      File.read(root_directory <> "/post.html.eex")
      |> SimpleBlog.Converter.Page.eex_to_html(post, config)
      |> SimpleBlog.RewriteHTML.Stylesheet.rewrite("../../../../")
      |> SimpleBlog.RewriteHTML.Image.rewrite("../../../../")
      |> SimpleBlog.RewriteHTML.BackLink.rewrite()

    {:ok, file} = File.open(dir <> filename, [:write])
    IO.binwrite(file, result)
    File.close(file)
  end
end
