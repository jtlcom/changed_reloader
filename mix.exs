defmodule ChangedReloader.MixProject do
  use Mix.Project

  def project do
    [
      app: :changed_reloader,
      version: "0.1.4",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [applications: [:logger],
      mod: {ChangedReloader, []}]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, "~> 1.4", only: :dev},
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["cinside"],
      links: %{
        "GitHub" => "https://github.com/AgilionApps/remix"
      }
    ]
  end

  defp description do
    """
      auto recompile a modified elixir file to the lib directory.
      base on Remix (https://github.com/AgilionApps/remix)
    """
  end
end
