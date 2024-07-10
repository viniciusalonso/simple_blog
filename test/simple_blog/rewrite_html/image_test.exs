defmodule SimpleBlog.RewriteHTML.ImageTest do
  use ExUnit.Case
  doctest SimpleBlog.RewriteHTML.Image

  describe "rewrite" do
    test "rewrites image src attribute" do
      image = ~s(<img src="/images/img_girl.jpg" alt="Girl in a jacket" class="img-circle" />)
      path = "./"
      result = SimpleBlog.RewriteHTML.Image.rewrite(image, path)

      assert result ==
               ~s(<img src="./images/img_girl.jpg" alt="Girl in a jacket" class="img-circle"/>)
    end
  end
end
