defmodule Mix.Tasks.SimpleBlog.CompileTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  describe "run/1" do
    setup do
      on_exit(fn -> File.rm_rf("test/output") end)
    end

    test "create a directory to static blog" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])
      assert File.exists?("test/output")
    end

    test "generates the static blog at the path given by --output" do
      output_directory = "test/output/custom/nested"

      File.cd!("test", fn ->
        Mix.Tasks.SimpleBlog.Compile.run(["--output=output/custom/nested"])
      end)

      assert File.exists?(output_directory <> "/index.html")
      assert File.exists?(output_directory <> "/css/plain.css")
      assert File.exists?(output_directory <> "/images/avatar.png")
    end

    test "converts posts to html" do
      capture_io(fn -> Mix.Tasks.SimpleBlog.Post.run(["My First Blog Post", "test/blog"]) end)
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])

      today = Date.utc_today() |> Date.to_string()
      dir = SimpleBlog.Post.generate_html_dir(%SimpleBlog.Post{date: today}, "test/output/posts")

      assert File.exists?(dir <> "my-first-blog-post.html")

      on_exit(fn -> File.rm("test/blog/_posts/#{today}-my-first-blog-post.md") end)
    end

    test "names post html after its filename, not its title" do
      post_path = "test/blog/_posts/2021-01-02-ruby-dig-methods.md"

      File.write!(post_path, """
      <!---
      filename: 2021-01-02-ruby-dig-methods.md
      title: Ruby tip: dig methods your best friends
      date: 2021-01-02
      --->
      """)

      on_exit(fn -> File.rm(post_path) end)

      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])

      assert File.exists?("test/output/posts/2021/01/02/ruby-dig-methods.html")

      assert File.read!("test/output/index.html") =~
               ~s(href="posts/2021/01/02/ruby-dig-methods.html")
    end

    test "lists posts on the index from the most recent to the oldest" do
      posts = [
        {"2021-03-15-middle-post.md", "Middle post", "2021-03-15"},
        {"2020-07-01-oldest-post.md", "Oldest post", "2020-07-01"},
        {"2022-11-20-newest-post.md", "Newest post", "2022-11-20"},
        {"2019-02-14-ancient-post.md", "Ancient post", "2019-02-14"},
        {"2023-08-09-latest-post.md", "Latest post", "2023-08-09"}
      ]

      for {filename, title, date} <- posts do
        post_path = "test/blog/_posts/" <> filename

        File.write!(post_path, """
        <!---
        filename: #{filename}
        title: #{title}
        date: #{date}
        --->
        """)

        on_exit(fn -> File.rm(post_path) end)
      end

      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])

      titles =
        Regex.scan(~r/<h2 class="post-title">(.*?)<\/h2>/, File.read!("test/output/index.html"),
          capture: :all_but_first
        )
        |> List.flatten()

      assert [
               "Latest post",
               "Newest post",
               "Middle post",
               "Oldest post",
               "Ancient post"
             ] == titles
    end

    test "links the light theme when there is no config.exs" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])

      assert File.read!("test/output/index.html") =~
               ~s(<link rel="stylesheet" href="./css/themes/light.css">)
    end

    test "links the theme set in config.exs on index and posts" do
      File.write!("test/blog/config.exs", ~s([theme: "solarized"]))

      post_path = "test/blog/_posts/2021-01-02-themed-post.md"

      File.write!(post_path, """
      <!---
      filename: 2021-01-02-themed-post.md
      title: Themed post
      date: 2021-01-02
      --->
      """)

      on_exit(fn ->
        File.rm("test/blog/config.exs")
        File.rm(post_path)
      end)

      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])

      assert File.read!("test/output/index.html") =~
               ~s(<link rel="stylesheet" href="./css/themes/solarized.css">)

      assert File.read!("test/output/posts/2021/01/02/themed-post.html") =~
               ~s(<link rel="stylesheet" href="../../../../css/themes/solarized.css">)
    end

    test "keeps the original html formatting" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])
      index_html = File.read!("test/output/index.html")

      assert index_html =~ "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n"
      assert index_html =~ ~s(\n    <link rel="stylesheet" href="./css/plain.css">\n)

      assert index_html =~
               ~s(\n        <img src="./images/avatar.png" alt="avatar" class="avatar">\n)
    end

    test "creates css files" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])
      css_dir = "test/output/css/"

      assert File.exists?(css_dir <> "plain.css")
      assert File.exists?(css_dir <> "reset.css")

      for theme <- ["light", "dark", "solarized", "sepia"] do
        assert File.exists?(css_dir <> "themes/#{theme}.css")
      end
    end

    test "creates images files" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])
      images_dir = "test/output/images/"

      assert File.exists?(images_dir <> "avatar.png")
    end
  end
end
