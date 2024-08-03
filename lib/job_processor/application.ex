defmodule JobProcessor.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: JobProcessor, options: [port: 4000]}
    ]
    
    IO.puts("JobProcessor application started on port: 4000")
    opts = [strategy: :one_for_one, name: JobProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
