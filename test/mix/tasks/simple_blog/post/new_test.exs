defmodule Mix.Tasks.SimpleBlog.Post.NewTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Mix.Tasks.SimpleBlog.Post.New

  @instructions """
  To generate a new blog post you should pass a title as string:

  $ mix simple_blog.post.new "My first blog post"
  """

  @error_instructions """
  There is a directory missing, please run the following command:

  $ mix simple_blog.new .
  """

  describe "run" do
    setup do
      on_exit(fn -> File.rm_rf("blog") end)
    end

    test "returns instructions for no arguments" do
      Mix.Tasks.SimpleBlog.New.run(["."])
      message = capture_io(fn -> Mix.Tasks.SimpleBlog.Post.New.run([]) end)

      assert message == "#{@instructions}\n"
    end

    test "show success message for created blog post" do
      Mix.Tasks.SimpleBlog.New.run(["."])
      Mix.Tasks.SimpleBlog.Post.New.run(["My First Blog Post"])

      today = Date.utc_today() |> Date.to_string()

      assert File.exists?("blog/_posts/#{today}-my-first-blog-post.md")
    end

    test "show error message when blog does not exist" do
      message = capture_io(fn -> Mix.Tasks.SimpleBlog.Post.New.run(["My First Blog Post"]) end)
      assert message == "#{@error_instructions}\n"
    end
  end

  describe "usage" do
    test "returns instructions" do
      assert Mix.Tasks.SimpleBlog.Post.New.usage() == @instructions
    end
  end
end
