defmodule Mix.Tasks.SimpleBlog.PostTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  # doctest Mix.Tasks.SimpleBlog.Post.New

  @instructions """
  To generate a new blog post you should pass a title as string:

  $ mix simple_blog.post.new "My first blog post"
  """

  describe "run" do
    test "returns instructions for no arguments" do
      message = capture_io(fn -> Mix.Tasks.SimpleBlog.Post.run([]) end)

      assert message == "#{@instructions}\n"
    end

    test "show success message for created blog post" do
      message =
        capture_io(fn ->
          Mix.Tasks.SimpleBlog.Post.run(["My First Blog Post", "test/blog"])
        end)

      today = Date.utc_today() |> Date.to_string()

      assert message == "Blog post created at test/blog/_posts/#{today}-my-first-blog-post.md\n\n"
      on_exit(fn -> File.rm("test/blog/_posts/#{today}-my-first-blog-post.md") end)
    end

    test "creates a new markdown file for blog post" do
      Mix.Tasks.SimpleBlog.Post.run(["My First Blog Post", "test/blog"])

      today = Date.utc_today() |> Date.to_string()

      assert File.exists?("test/blog/_posts/#{today}-my-first-blog-post.md")
      on_exit(fn -> File.rm("test/blog/_posts/#{today}-my-first-blog-post.md") end)
    end

    test "show error message when blog does not exist" do
      message =
        capture_io(fn -> Mix.Tasks.SimpleBlog.Post.run(["My First Blog Post", "invalid"]) end)

      assert message == "The directory invalid was not found\n\n"
    end
  end

  describe "usage" do
    test "returns instructions" do
      assert Mix.Tasks.SimpleBlog.Post.usage() == @instructions
    end
  end
end
