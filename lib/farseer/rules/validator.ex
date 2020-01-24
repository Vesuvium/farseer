defmodule Farseer.Rules.Validator do
  @moduledoc """
  Validates parsed rules, ensuring that they are structurally valid and make sense.

  Halts Farseer for critical errors or emits warning for minor errors.
  """
  alias Farseer.Rules.Validator

  @supported_versions ["0.4", "0.4.0"]

  @doc """
  Ensures that a farseer version has been declared.
  """
  def farseer(rules) do
    unless Map.has_key?(rules, "farseer") do
      IO.puts("No farseer version specified in the configuration")
      System.halt(1)
    else
      rules
    end
  end

  @doc """
  Ensures that the declared farseer version is supported.
  """
  def version(rules) do
    config_version = Map.get(rules, "farseer")
    version = Application.spec(:farseer, :vsn)

    if Enum.member?(@supported_versions, config_version) do
      rules
    else
      message =
        "Farseer #{version} does not support configuration version #{
          config_version
        }"

      IO.puts(message)
      System.halt(1)
    end
  end

  @doc """
  Ensures that an endpoints object is defined in the rules.
  """
  def endpoints(rules) do
    unless Map.has_key?(rules, "endpoints") do
      IO.puts("No endpoints found in the configuration")
      System.halt(1)
    else
      rules
    end
  end

  @doc """
  Validates parsed rules.
  """
  def validate(rules) do
    rules
    |> Validator.farseer()
    |> Validator.version()
    |> Validator.endpoints()
  end
end
