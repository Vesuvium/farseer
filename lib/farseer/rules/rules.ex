defmodule Farseer.Rules do
  @moduledoc """
  Provides parsing of rules found in the yaml file.
  """

  alias Farseer.Rules.Parser

  def parse(path) do
    Parser.parse(path)
  end

  def endpoints(rules) do
    Map.get(rules, "endpoints")
  end

  def get(rules, target) do
    get_in(rules, target)
  end
end
