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
        conn(:get, "/css/style.css")
        |> Plug.Conn.put_req_header("user-agent", "test")
        |> Plug.Conn.put_req_header("accept", "*/*")
        |> SimpleBlog.Server.call([])

      assert conn.status == 200
      assert Plug.Conn.get_resp_header(conn, "content-type") == ["text/css"]
    end

    test "returns 404 for missing files" do
      conn = SimpleBlog.Server.call(conn(:get, "/images/missing.png"), [])

      assert conn.status == 404
    end
  end
end
