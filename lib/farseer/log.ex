defmodule Farseer.Log do
  @moduledoc """
  Logging utilities.
  """
  require Logger

  def server_start(port) do
    version = Application.spec(:farseer, :vsn)
    Logger.info("Farseer #{version} started on port #{port}")
  end

  @doc """
  Logs the registration of an endpoint.
  """
  def endpoint(method, endpoint) do
    Logger.info("Endpoint #{method} #{endpoint} registered")
  end

  def request_received() do
    Logger.info("Request received")
  end

  def response_sending() do
    Logger.info("Sending response")
  end
end
