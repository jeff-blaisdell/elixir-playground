defmodule Morse.Mixfile do
  use Mix.Project

  def project do
    [app: :morse,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Morse],
     deps: deps()]
  end

  def application do
    [applications: [:logger, :synthex]]
  end

  defp deps do
    [{:synthex, path: "../synthex"}]
  end
end
