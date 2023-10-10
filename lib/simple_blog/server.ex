Application.ensure_all_started(:plug)
Application.ensure_all_started(:plug_cowboy)
Application.ensure_all_started(:earmark)

defmodule SimpleBlog.Server do
  import Plug.Conn
  require Logger
  require Earmark

  def init(_options) do
    Logger.info("Initializing server ...")
  end

  def call(conn, _opts) do
    files = SimpleBlog.PostsReader.read_from_dir(File.ls("blog/_posts"))
    html = SimpleBlog.PostsTransform.markdown_to_html(files)

    result =
      File.read("blog/index.html.eex")
      |> SimpleBlog.Renderer.exx_to_html(html)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, result)
  end
end
