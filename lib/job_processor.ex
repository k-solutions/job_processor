defmodule JobProcessor do
  @moduledoc """
    Plug Router to handles HTTP request for POST /process_jobs and POST /bash_script paths.
  """
  alias JobProcessor.{Processor, CircularDependencyError}

 
  use Plug.Router
  use Plug.ErrorHandler

  # @behaviour Plug.ErrorHandler

  plug :match
  plug :dispatch

  post "/bash_script" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    try do 
      sorted_tasks = Jason.decode!(body)["tasks"]
                   |> Processor.generate_bash_script()
      response = %{"tasks" => sorted_tasks}
      send_resp(conn, 200, Jason.encode!(response))
    rescue
      e in CircularDependencyError ->
        send_resp(conn, 400, e.message)
    end
  end 

  post "/process_jobs" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    try do 
      sorted_tasks = Jason.decode!(body)["tasks"]
                   |> Processor.process_jobs()
      response = %{"tasks" => sorted_tasks}
      send_resp(conn, 200, Jason.encode!(response))
    rescue
      e in CircularDependencyError ->
      send_resp(conn, 400, e.message)
    
    end
  end
  # Custom error handler
  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    send_resp(conn, conn.status, "An error occurred: #{reason.message}")
  end
end
