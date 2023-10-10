defmodule Mix.Tasks.SimpleBlog.Server.StartTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Mix.Tasks.SimpleBlog.Server.Start

  @instructions """
  To start a blog server you should use the command below:

  $ mix simple_blog.server.start
  """

  # # describe "run" do
  #   setup do
  #     Mix.Tasks.SimpleBlog.New.run(["."])
  #     on_exit(fn -> File.rm_rf("blog") end)
  #   end

  #   test "returns instructions for no arguments" do
  #     spawn(fn -> Mix.Tasks.SimpleBlog.Server.Start.run([]) end)
  #     # flush()
  #     # IO.puts pid

  #     # assert Process.alive?(pid)
  #     # Process.exit(pid, :kill)
  #   end

  #   # test "show success message for created structure" do
  #   #   message = capture_io(fn -> Mix.Tasks.SimpleBlog.New.run(["."]) end)

  #   #   assert message == "Blog created with success!\n"
  #   # end

  #   # test "create folder structure for blog" do
  #   #   Mix.Tasks.SimpleBlog.New.run(["."])

  #   #   assert File.exists?("blog")
  #   # end
  # end

  # describe "usage" do
  #   test "returns instructions" do
  #     assert Mix.Tasks.SimpleBlog.New.usage() == @instructions
  #   end
  # end
end
