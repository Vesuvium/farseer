use Mix.Config

config :farseer,
  yaml_file: {:system, :string, "FARSEER_YML", "farseer.yml"},
  port: {:system, :integer, "FARSEER_PORT", 8000},
  compress: {:system, :boolean, "FARSEER_COMPRESS", true},
  table: {:system, "FARSEER_ETS_TABLE", :farseer}

import_config "#{Mix.env()}.exs"
