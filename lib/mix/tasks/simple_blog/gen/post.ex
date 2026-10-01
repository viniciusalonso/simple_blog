defmodule Mix.Tasks.SimpleBlog.Gen.Post do
  use Mix.Task

  @shortdoc "Generates a new blog post"

  @moduledoc """
  Generates a new blog post in `blog/_posts/`.

      $ mix simple_blog.gen.post "10 tips for new developers"

  The file is named after today's date and the title, without accents or
  punctuation, such as `blog/_posts/2026-10-01-10-tips-for-new-developers.md`.
  An existing post is never overwritten.

  To create the post in another blog directory, pass it after the title:

      $ mix simple_blog.gen.post "10 tips for new developers" path/to/blog
  """

  @usage """
  To generate a new blog post you should pass a title as string:

      $ mix simple_blog.gen.post "My first blog post"
  """

  @impl Mix.Task
  def run(args) do
    case OptionParser.parse(args, strict: []) do
      {[], [title], []} -> generate(title, "blog")
      {[], [title, root_directory], []} -> generate(title, root_directory)
      _ -> Mix.raise(@usage)
    end
  end

  defp generate(title, root_directory) do
    posts_directory = Path.join(root_directory, "_posts")

    unless File.dir?(posts_directory) do
      Mix.raise("The directory #{posts_directory} was not found")
    end

    if SimpleBlog.Post.slugify(title) == "" do
      Mix.raise("The title #{inspect(title)} must contain at least one letter or number")
    end

    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date() |> Date.to_string()
    filename = SimpleBlog.Post.generate_filename(%SimpleBlog.Post{title: title, date: today})
    full_file_path = Path.join(posts_directory, filename)

    content = """
    <!---
    filename: #{filename}
    title: #{title}
    date: #{today}
    --->
    """

    case File.write(full_file_path, content, [:exclusive]) do
      :ok ->
        Mix.shell().info("Blog post created at #{full_file_path}")

      {:error, :eexist} ->
        Mix.raise("The post #{full_file_path} already exists")

      {:error, reason} ->
        Mix.raise("Could not create #{full_file_path}: #{:file.format_error(reason)}")
    end
  end
end
