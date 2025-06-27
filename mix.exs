defmodule Popkernel.MixProject do
  use Mix.Project

  @repo_url "https://github.com/byronalley/popkernel"

  def project do
    [
      app: :popkernel,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => @repo_url
        }
      ],
      description: "Functions that should be in Kernel but aren't",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.1.0", only: [:dev], runtime: false},
      {:mix_test_interactive, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
