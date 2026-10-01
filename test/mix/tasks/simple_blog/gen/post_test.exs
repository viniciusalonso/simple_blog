defmodule Mix.Tasks.SimpleBlog.Gen.PostTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @today NaiveDateTime.local_now() |> NaiveDateTime.to_date() |> Date.to_string()

  setup do
    on_exit(fn ->
      "test/blog/_posts/*.md" |> Path.wildcard() |> Enum.each(&File.rm/1)
    end)
  end

  describe "run/1" do
    test "creates a markdown file named after today's date and the title" do
      message =
        capture_io(fn ->
          Mix.Tasks.SimpleBlog.Gen.Post.run(["My First Blog Post", "test/blog"])
        end)

      path = "test/blog/_posts/#{@today}-my-first-blog-post.md"

      assert message == "Blog post created at #{path}\n"

      assert File.read!(path) == """
             <!---
             filename: #{@today}-my-first-blog-post.md
             title: My First Blog Post
             date: #{@today}
             --->
             """
    end

    test "removes accents and punctuation from the filename, keeping the title" do
      capture_io(fn ->
        Mix.Tasks.SimpleBlog.Gen.Post.run(["Introdução ao Elixir: o básico?", "test/blog"])
      end)

      path = "test/blog/_posts/#{@today}-introducao-ao-elixir-o-basico.md"

      assert File.read!(path) =~ "title: Introdução ao Elixir: o básico?\n"
    end

    test "accepts titles with slashes" do
      capture_io(fn -> Mix.Tasks.SimpleBlog.Gen.Post.run(["CI/CD com GitHub", "test/blog"]) end)

      assert File.exists?("test/blog/_posts/#{@today}-ci-cd-com-github.md")
    end

    test "does not overwrite an existing post" do
      path = "test/blog/_posts/#{@today}-my-first-blog-post.md"
      capture_io(fn -> Mix.Tasks.SimpleBlog.Gen.Post.run(["My First Blog Post", "test/blog"]) end)
      File.write!(path, "my content", [:append])

      assert_raise Mix.Error, ~r/#{path} already exists/, fn ->
        Mix.Tasks.SimpleBlog.Gen.Post.run(["My First Blog Post", "test/blog"])
      end

      assert File.read!(path) =~ "my content"
    end

    test "raises when the blog directory does not exist" do
      assert_raise Mix.Error, ~r/The directory invalid\/_posts was not found/, fn ->
        Mix.Tasks.SimpleBlog.Gen.Post.run(["My First Blog Post", "invalid"])
      end
    end

    test "raises when the title has no letters or numbers" do
      assert_raise Mix.Error, ~r/must contain at least one letter or number/, fn ->
        Mix.Tasks.SimpleBlog.Gen.Post.run(["???", "test/blog"])
      end
    end

    test "shows the usage for missing or extra arguments" do
      for args <- [[], ["a", "test/blog", "c"], ["--title", "a"]] do
        assert_raise Mix.Error, ~r/mix simple_blog.gen.post "My first blog post"/, fn ->
          Mix.Tasks.SimpleBlog.Gen.Post.run(args)
        end
      end
    end
  end

  test "has a short description for mix help" do
    assert Mix.Task.shortdoc(Mix.Tasks.SimpleBlog.Gen.Post) == "Generates a new blog post"
  end
end
