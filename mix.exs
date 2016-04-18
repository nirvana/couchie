defmodule Couchie.Mixfile do
  use Mix.Project
  @moduledoc """
   Mixfile for the Couchie.

   Designed to be a dependency in other projects.
   """

  @doc "Project Details"
  def project do
    [ app: :couchie,
      elixir: "~> 1.0.2",
      version: "0.0.6",
      deps: deps ]
  end

  def application do
    [
		 applications: [:cberl]
	  ]
  end

  # Returns the list of dependencies in the format:
  # {:erlmc, "0.1", git: "https://github.com/n1rvana/erlmc.git"}
  defp deps do
    [
		  {:cberl, github: "muut/cberl"}, #chitika is authoritative source
      {:poison, ">= 1.2.0"}
    ]
  end
end
