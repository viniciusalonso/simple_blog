defmodule SimpleBlog.Converter.Page do
  def exx_to_html({:ok, body}, posts) do
    quoted = EEx.compile_string(body)

    case Code.eval_quoted(quoted, posts: posts) do
      {result, _bindings} -> result
    end
  end
end
