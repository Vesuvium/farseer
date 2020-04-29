defmodule Farseer.Rules.Parser do
  alias Farseer.Log
  alias Farseer.Rules.{Parser, Validator}
  alias YamlElixir.{FileNotFoundError, ParsingError}

  @doc """
  Replaces variables in farseer.yml with the corresponding env var.
  """
  def replace(string) do
    Enum.reduce(System.get_env(), string, fn {key, value}, acc ->
      placeholder = "$#{key}"
      Log.variable_replacing(string, placeholder, value)
      String.replace(acc, placeholder, value)
    end)
  end

  def yaml(string) do
    case YamlElixir.read_from_string(string) do
      {:ok, yaml} ->
        yaml

      {:error, %ParsingError{message: message}} ->
        IO.puts("Failed to parse configuration because: #{message}")
        System.halt(1)
    end
  end

  def read(path) do
    case YamlElixir.read_from_file(path) do
      {:ok, yaml} ->
        yaml

      {:error, %FileNotFoundError{message: _message}} ->
        IO.puts("File \"#{path}\" was not found")
        System.halt(1)

      {:error, %ParsingError{message: message}} ->
        IO.puts("Failed to read \"#{path}\" because: #{message}")
        System.halt(1)
    end
  end

  def parse(path) do
    path
    |> Parser.read()
    |> Validator.validate()
  end
end
