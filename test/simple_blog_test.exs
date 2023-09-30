defmodule SimpleBlogTest do
  use ExUnit.Case
  doctest SimpleBlog

  test "greets the world" do
    assert SimpleBlog.hello() == :world
  end
end
