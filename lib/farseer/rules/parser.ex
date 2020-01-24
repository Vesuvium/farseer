defmodule Farseer.Rules.Parser do
  alias Farseer.Rules.Parser
  alias Farseer.Rules.Validator
  alias YamlElixir.{FileNotFoundError, ParsingError}

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
