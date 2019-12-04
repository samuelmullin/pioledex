defmodule Pioledex.MixProject do
  use Mix.Project

  def project do
    [
      app: :pioledex,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {PIOLEDex.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:circuits_i2c, "~> 0.3.5"},
      {:egd, github: "erlang/egd"}
    ]
  end
end
