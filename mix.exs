defmodule EnvConfig.Mixfile do
  use Mix.Project

  def project do
    [
      app: :env_config,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      description: description(),
      elixir: "~> 1.3",
      package: package(),
      start_permanent: Mix.env == :prod,
      version: "0.1.0",
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp description do
    """
    Handles fetching values from config with support for runtime ENV loading.
    """
  end

  defp package do
    [
      name: :avrolixr,
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Donald Plummer"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dplummer/env_config"}
    ]
  end
end
