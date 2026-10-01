defmodule Mix.Tasks.SimpleBlog.BuildTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @args ["--source", "test/blog", "--output", "test/output"]

  describe "run/1" do
    setup do
      Mix.shell(Mix.Shell.Process)

      on_exit(fn ->
        Mix.shell(Mix.Shell.IO)
        File.rm_rf("test/output")
      end)
    end

    test "create a directory to static blog" do
      Mix.Tasks.SimpleBlog.Build.run(@args)
      assert File.exists?("test/output")
    end

    test "generates the static blog at the path given by --output" do
      output_directory = "test/output/custom/nested"

      File.cd!("test", fn ->
        Mix.Tasks.SimpleBlog.Build.run(["--output=output/custom/nested"])
      end)

      assert_received {:mix_shell, :info, ["Blog built at output/custom/nested with 0 posts"]}

      assert File.exists?(output_directory <> "/index.html")
      assert File.exists?(output_directory <> "/css/plain.css")
      assert File.exists?(output_directory <> "/images/avatar.png")
    end

    test "converts posts to html" do
      capture_io(fn -> Mix.Tasks.SimpleBlog.Gen.Post.run(["My First Blog Post", "test/blog"]) end)
      Mix.Tasks.SimpleBlog.Build.run(@args)

      today = NaiveDateTime.local_now() |> NaiveDateTime.to_date() |> Date.to_string()
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

      Mix.Tasks.SimpleBlog.Build.run(@args)

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

      Mix.Tasks.SimpleBlog.Build.run(@args)

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
      Mix.Tasks.SimpleBlog.Build.run(@args)

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

      Mix.Tasks.SimpleBlog.Build.run(@args)

      assert File.read!("test/output/index.html") =~
               ~s(<link rel="stylesheet" href="./css/themes/solarized.css">)

      assert File.read!("test/output/posts/2021/01/02/themed-post.html") =~
               ~s(<link rel="stylesheet" href="../../../../css/themes/solarized.css">)
    end

    test "reads the blog from the directory given by --source" do
      File.mkdir_p!("test/output")
      File.cp_r!("test/blog", "test/output/source")

      File.write!("test/output/source/_posts/2021-01-02-from-source.md", """
      <!---
      filename: 2021-01-02-from-source.md
      title: From source
      date: 2021-01-02
      --->
      """)

      Mix.Tasks.SimpleBlog.Build.run([
        "--source",
        "test/output/source",
        "--output",
        "test/output/site"
      ])

      assert File.exists?("test/output/site/posts/2021/01/02/from-source.html")
      assert_received {:mix_shell, :info, ["Blog built at test/output/site with 1 post"]}
    end

    test "removes posts that no longer exist from a previous build" do
      stale = "test/output/posts/2020/01/01/deleted-post.html"
      File.mkdir_p!(Path.dirname(stale))
      File.write!(stale, "old")

      Mix.Tasks.SimpleBlog.Build.run(@args)

      refute File.exists?(stale)
    end

    test "keeps files in the output it did not generate" do
      File.mkdir_p!("test/output")
      File.write!("test/output/CNAME", "blog.example.com")

      Mix.Tasks.SimpleBlog.Build.run(@args)

      assert File.read!("test/output/CNAME") == "blog.example.com"
    end

    test "raises when the blog directory does not exist" do
      assert_raise Mix.Error, ~r/The blog directory missing was not found/, fn ->
        Mix.Tasks.SimpleBlog.Build.run(["--source", "missing"])
      end
    end

    test "raises naming the missing template" do
      File.mkdir_p!("test/output")
      File.cp_r!("test/blog", "test/output/source")
      File.rm!("test/output/source/post.html.eex")

      assert_raise Mix.Error, ~r{test/output/source/post.html.eex was not found}, fn ->
        Mix.Tasks.SimpleBlog.Build.run([
          "--source",
          "test/output/source",
          "--output",
          "test/output/site"
        ])
      end
    end

    test "shows the usage for unknown flags or extra arguments" do
      for args <- [["--ouput=dist"], ["test/blog", "test/output"]] do
        assert_raise Mix.Error, ~r/mix simple_blog.build \[--source DIR\] \[--output DIR\]/, fn ->
          Mix.Tasks.SimpleBlog.Build.run(args)
        end
      end
    end

    test "keeps the original html formatting" do
      Mix.Tasks.SimpleBlog.Build.run(@args)
      index_html = File.read!("test/output/index.html")

      assert index_html =~ "<!DOCTYPE html>\n<html lang=\"en\">\n  <head>\n"
      assert index_html =~ ~s(\n    <link rel="stylesheet" href="./css/plain.css">\n)

      assert index_html =~
               ~s(\n        <img src="./images/avatar.png" alt="avatar" class="avatar">\n)
    end

    test "creates css files" do
      Mix.Tasks.SimpleBlog.Build.run(@args)
      css_dir = "test/output/css/"

      assert File.exists?(css_dir <> "plain.css")
      assert File.exists?(css_dir <> "reset.css")

      for theme <- ["light", "dark", "solarized", "sepia"] do
        assert File.exists?(css_dir <> "themes/#{theme}.css")
      end
    end

    test "creates images files" do
      Mix.Tasks.SimpleBlog.Build.run(@args)
      images_dir = "test/output/images/"

      assert File.exists?(images_dir <> "avatar.png")
    end
  end

  test "has a short description for mix help" do
    assert Mix.Task.shortdoc(Mix.Tasks.SimpleBlog.Build) ==
             "Builds the static blog from blog/ into output/"
  end
end
