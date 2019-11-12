defmodule UrlHistory.Server.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/visited_links" do
    conn = conn |> json_conn

    with %{"links" => links} <- conn.body_params,
         {:ok, _} <- UrlHistory.Service.HistorySaveHandler.save_links(links) do
      send_resp(conn, 201, response("ok"))
    else
      _ -> send_resp(conn, 500, response("error"))
    end
  end

  get "/visited_domains" do
    conn = conn |> json_conn

    with %{"from" => from, "to" => to} <- conn.query_params,
         {:ok, domains} <- UrlHistory.Service.HistorySaveHandler.get_domains(from, to) do
      send_resp(conn, 200, response("ok", domains))
    else
      _ -> send_resp(conn, 500, response("error"))
    end
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  defp json_conn(conn) do
    conn
    |> put_resp_content_type("application/json")
  end

  defp response(status) do
    %{status: status} |> Poison.encode!()
  end

  defp response(status, domains) do
    %{status: status, domains: domains} |> Poison.encode!()
  end
end
