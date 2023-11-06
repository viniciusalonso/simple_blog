defmodule Mix.Tasks.SimpleBlog.CompileTest do
  use ExUnit.Case

  describe "run/1" do
    setup do
      on_exit(fn -> File.rm_rf("test/output") end)
    end

    test "create a directory to static blog" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])
      assert File.exists?("test/output")
    end

    test "converts posts to html" do
      Mix.Tasks.SimpleBlog.Post.run(["My First Blog Post", "test/blog"])
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])

      today = Date.utc_today() |> Date.to_string()
      dir = SimpleBlog.Post.generate_html_dir(%SimpleBlog.Post{date: today}, "test/output/posts")

      assert File.exists?(dir <> "my-first-blog-post.html")

      on_exit(fn -> File.rm("test/blog/_posts/#{today}-my-first-blog-post.md") end)
    end

    test "creates css files" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])
      css_dir = "test/output/css/"

      assert File.exists?(css_dir <> "_solarized-light.css")
      assert File.exists?(css_dir <> "plain.css")
      assert File.exists?(css_dir <> "reset.css")
      assert File.exists?(css_dir <> "style.css")
    end

    test "creates images files" do
      Mix.Tasks.SimpleBlog.Compile.run(["test/blog", "test/output"])
      images_dir = "test/output/images/"

      assert File.exists?(images_dir <> "avatar.png")
    end
  end
end
