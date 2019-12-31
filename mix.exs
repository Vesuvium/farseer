defmodule Farseer.MixProject do
  use Mix.Project

  def project do
    [
      app: :farseer,
      version: "0.2.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      escript: escript(),
      deps: deps(),
      name: "Farseer",
      source_url: "https://github.com/strangemachines/farseer",
      homepage_url: "",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def escript do
    [main_module: Farseer.Cli]
  end

  defp deps do
    [
      {:confex, "~> 3.3"},
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.9", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dummy, "~> 1.2", only: :test},
      {:jason, "~> 1.1"},
      {:plug, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:tesla, "~> 1.2"},
      {:yaml_elixir, "~> 2.1"}
    ]
  end

  defp package do
    [
      name: :farseer,
      files: ~w(mix.exs lib .formatter.exs README.md LICENSE priv/example.yml),
      maintainers: ["Jacopo Cascioli"],
      licenses: ["GPL-3.0-or-later"],
      links: %{"GitHub" => "https://github.com/strangemachines/farseer"}
    ]
  end

  defp description do
    "A configurable Elixir API gateway."
  end
end
