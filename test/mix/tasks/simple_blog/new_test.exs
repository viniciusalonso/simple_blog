defmodule Mix.Tasks.SimpleBlog.NewTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Mix.Tasks.SimpleBlog.New

  @instructions """
  To generate a new blog you should pass a valid path:

  $ mix simple_blog.new .
  """

  describe "run" do
    setup do
      on_exit(fn -> File.rm_rf("blog") end)
    end

    test "returns instructions for no arguments" do
      message = capture_io(fn -> Mix.Tasks.SimpleBlog.New.run([]) end)

      assert message == "#{@instructions}\n"
    end

    test "show success message for created structure" do
      message = capture_io(fn -> Mix.Tasks.SimpleBlog.New.run(["."]) end)

      assert message == "Blog created with success!\n"
    end

    test "create folder structure for blog" do
      Mix.Tasks.SimpleBlog.New.run(["."])

      assert File.exists?("blog")
    end
  end

  describe "usage" do
    test "returns instructions" do
      assert Mix.Tasks.SimpleBlog.New.usage() == @instructions
    end
  end
end
