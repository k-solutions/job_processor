defmodule JobProcessor.MixProject do
  use Mix.Project

  def project do
    [
      app: :job_processor,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {JobProcessor.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.5"},
      {:jason,  "~> 1.2"},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false}
    ]
  end
end
