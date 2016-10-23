defmodule UUIDGenerator.Mixfile do
  use Mix.Project

  def project do
    [app: :uuid_generator,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: UUIDGenerator, path: "./_build/artifacts/uuid"],
     deps: deps()]
  end

  def application do
    [applications: [:logger, :uuid]]
  end

  defp deps do
    [{ :uuid, "~> 1.1" }]
  end
end
