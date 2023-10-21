defmodule SimpleBlog.PostTest do
  use ExUnit.Case
  doctest SimpleBlog.Post

  describe "generate_filename" do
    test "generate filename with date" do
      title = "Introduction to elixir"
      date = ~D[2023-10-04]
      filename = SimpleBlog.Post.generate_filename(%SimpleBlog.Post{title: title, date: date})
      assert "2023-10-04-introduction-to-elixir.md" == filename
    end
  end

  describe "parse" do
    test "set attributes to SimpleBlog.Post struct" do
      body = """
      <!---
      filename: 2023-10-18-2-tips-for-junior-developers.md
      title: 2 tips for junior developers
      date: 2023-10-18
      --->
      """

      struct = SimpleBlog.Post.parse(body)

      assert %SimpleBlog.Post{
               body: body,
               filename: "2023-10-18-2-tips-for-junior-developers.md",
               title: "2 tips for junior developers",
               date: "2023-10-18"
             } == struct
    end
  end
end
