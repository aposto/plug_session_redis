defmodule PlugSessionRedis.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_session_redis,
     version: "0.1.0",
     elixir: "~> 1.0",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {PlugSessionRedis, []},
      applications: []]
  end

  defp description do
    """
    The Redis Plug.Session adapter for the Phoenix framework.
    """
  end

  defp deps do
    [
      {:plug, "~> 1.0", optional: true},
      {:poolboy, "~> 1.5"},
      {:redo, "~> 2.0"}
    ]
  end

  defp package do
    [# These are the default files included in the package
      files: ["lib", "priv", "mix.exs", "README*", "README.md", "LICENSE"],
      contributors: ["Hee Yeon Cho", "Matt Widmann"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/aposto/plug_session_redis"}
    ]
  end

end
