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
end
