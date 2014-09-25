defmodule ExCsv.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_csv,
     version: "0.1.1",
     elixir: "~> 1.0.0",
     deps: deps,
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp package do
    [contributors: ["Bruce Williams"],
     licenses: ["MIT License"],
     description: "CSV for Elixir",
     links: %{github: "https://github.com/CargoSense/ex_csv"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end
end
