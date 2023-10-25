defmodule Mix.Tasks.SimpleBlog.Post.NewTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  # doctest Mix.Tasks.SimpleBlog.Post.New

  @instructions """
  To generate a new blog post you should pass a title as string:

  $ mix simple_blog.post.new "My first blog post"
  """

  describe "run" do
    test "returns instructions for no arguments" do
      message = capture_io(fn -> Mix.Tasks.SimpleBlog.Post.New.run([]) end)

      assert message == "#{@instructions}\n"
    end

    test "show success message for created blog post" do
      message =
        capture_io(fn ->
          Mix.Tasks.SimpleBlog.Post.New.run(["My First Blog Post", "blog_test"])
        end)

      today = Date.utc_today() |> Date.to_string()

      assert message == "Blog post created at blog_test/_posts/#{today}-my-first-blog-post.md\n\n"
      on_exit(fn -> File.rm("blog_test/_posts/#{today}-my-first-blog-post.md") end)
    end

    test "creates a new markdown file for blog post" do
      Mix.Tasks.SimpleBlog.Post.New.run(["My First Blog Post", "blog_test"])

      today = Date.utc_today() |> Date.to_string()

      assert File.exists?("blog_test/_posts/#{today}-my-first-blog-post.md")
      on_exit(fn -> File.rm("blog_test/_posts/#{today}-my-first-blog-post.md") end)
    end

    test "show error message when blog does not exist" do
      message =
        capture_io(fn -> Mix.Tasks.SimpleBlog.Post.New.run(["My First Blog Post", "invalid"]) end)

      assert message == "The directory invalid was not found\n\n"
    end
  end

  describe "usage" do
    test "returns instructions" do
      assert Mix.Tasks.SimpleBlog.Post.New.usage() == @instructions
    end
  end
end
