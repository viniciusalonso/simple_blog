defmodule Mix.Tasks.SimpleBlog.CompileTest do
  use ExUnit.Case

  describe "run/1" do
    setup do
      on_exit(fn -> File.rm_rf("output_test") end)
    end

    test "create a directory to static blog" do
      Mix.Tasks.SimpleBlog.Compile.run(["blog_test", "output_test"])
      assert File.exists?("output_test")
    end

    test "converts posts to html" do
      Mix.Tasks.SimpleBlog.Post.New.run(["My First Blog Post", "blog_test"])
      Mix.Tasks.SimpleBlog.Compile.run(["blog_test", "output_test"])

      today = Date.utc_today() |> Date.to_string()
      dir = SimpleBlog.Post.generate_html_dir(%SimpleBlog.Post{date: today}, "output_test/posts")

      assert File.exists?(dir <> "my-first-blog-post.html")

      on_exit(fn -> File.rm("blog_test/_posts/#{today}-my-first-blog-post.md") end)
    end

    test "creates css files" do
      Mix.Tasks.SimpleBlog.Compile.run(["blog_test", "output_test"])
      css_dir = "output_test/css/"

      assert File.exists?(css_dir <> "_solarized-light.css")
      assert File.exists?(css_dir <> "plain.css")
      assert File.exists?(css_dir <> "reset.css")
      assert File.exists?(css_dir <> "style.css")
    end

    test "creates images files" do
      Mix.Tasks.SimpleBlog.Compile.run(["blog_test", "output_test"])
      images_dir = "output_test/images/"

      assert File.exists?(images_dir <> "avatar.png")
    end
  end
end
