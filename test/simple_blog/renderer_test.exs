defmodule SimpleBlog.RendererTest do
  use ExUnit.Case
  doctest SimpleBlog.Renderer

  describe "exx_to_html" do
    test "transform exx in html" do
      exx = """
      <!doctype html>
      <html>
        <head></head>
        <body>
          <%= for file <- files do %>
            <%= file %>
          <% end %>
        </body>
      </html>
      """

      posts_html = [
        "<h1> My first blog post</h1>",
        "<h1> 5 common mistaskes in tech interviews</h1>"
      ]

      output = """
      <!doctype html>
      <html>
        <head></head>
        <body>
          <h1> My first blog post</h1>
          <h1> 5 common mistaskes in tech interviews</h1>
        </body>
      </html>
      """

      html = SimpleBlog.Renderer.exx_to_html({:ok, exx}, posts_html)
      assert normalize(output) == normalize(html)
    end
  end

  defp normalize(input) do
    input
    |> String.replace("\n", "", global: true)
    |> String.split(" ", trim: true)
    |> Enum.join()
  end
end
