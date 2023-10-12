Application.ensure_all_started(:plug)
Application.ensure_all_started(:plug_cowboy)
Application.ensure_all_started(:earmark)

defmodule SimpleBlog.Server do
  import Plug.Conn
  require Logger
  require Earmark

  def init(options) do
    Logger.info("Initializing server ...")
    IO.inspect(options)
  end

  def call(conn, opts) do
    IO.inspect("jjjjjjjjjjj")
    IO.inspect(opts)

    posts_html =
      "blog"
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()

    result =
      File.read("blog/index.html.eex")
      |> SimpleBlog.Converter.Page.exx_to_html(posts_html)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, result)
  end
end
