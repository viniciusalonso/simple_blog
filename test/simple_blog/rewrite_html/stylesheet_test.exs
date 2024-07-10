defmodule SimpleBlog.RewriteHTML.StylesheetTest do
  use ExUnit.Case
  doctest SimpleBlog.RewriteHTML.Stylesheet

  describe "rewrite" do
    test "rewrites .css files path" do
      stylesheet = ~s(<link rel="stylesheet" href="/css/_solarized-light.css">)
      path = "../"
      result = SimpleBlog.RewriteHTML.Stylesheet.rewrite(stylesheet, path)
      assert result == ~s(<link rel="stylesheet" href="../css/_solarized-light.css"/>)
    end

    test "returns font links" do
      font =
        ~s(<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Merriweather:300|Raleway:400,700"/>)

      path = "../"
      result = SimpleBlog.RewriteHTML.Stylesheet.rewrite(font, path)
      assert result == font
    end
  end
end
