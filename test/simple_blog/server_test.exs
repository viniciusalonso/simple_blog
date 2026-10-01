defmodule SimpleBlog.ServerTest do
  use ExUnit.Case
  import Plug.Test

  describe "call" do
    test "serves images with the content type based on the extension" do
      conn = SimpleBlog.Server.call(conn(:get, "/images/avatar.png"), [])

      assert conn.status == 200
      assert Plug.Conn.get_resp_header(conn, "content-type") == ["image/png"]
      assert conn.resp_body == File.read!("blog/images/avatar.png")
    end

    test "serves stylesheets regardless of the accept header" do
      conn =
        conn(:get, "/css/plain.css")
        |> Plug.Conn.put_req_header("user-agent", "test")
        |> Plug.Conn.put_req_header("accept", "*/*")
        |> SimpleBlog.Server.call([])

      assert conn.status == 200
      assert Plug.Conn.get_resp_header(conn, "content-type") == ["text/css"]
    end

    test "links the theme set in blog/config.exs" do
      {theme, _} = Code.eval_file("blog/config.exs") |> elem(0) |> Keyword.pop(:theme)

      conn = SimpleBlog.Server.call(conn(:get, "/"), [])

      assert conn.status == 200
      assert conn.resp_body =~ ~s(<link rel="stylesheet" href="/css/themes/#{theme}.css">)
    end

    test "serves theme stylesheets" do
      conn = SimpleBlog.Server.call(conn(:get, "/css/themes/dark.css"), [])

      assert conn.status == 200
      assert Plug.Conn.get_resp_header(conn, "content-type") == ["text/css"]
    end

    test "returns 404 for missing files" do
      conn = SimpleBlog.Server.call(conn(:get, "/images/missing.png"), [])

      assert conn.status == 404
    end
  end
end
