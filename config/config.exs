# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :deku, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:deku, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
config :deku, Deku.Robot,
  adapter: Hedwig.Adapters.IRC,
  name: System.get_env("IRC_NICK"),
  aka: System.get_env("IRC_ALIAS"),
  irc_user: System.get_env("IRC_USER"),
  full_name: System.get_env("IRC_NAME"),
  password: System.get_env("IRC_PASS") || "",
  server: "chat.freenode.net",
  port: 6697, # optional, defaults to `6667`
  ssl?: true, # optional, defaults to `false`
  rooms:
    (System.get_env("IRC_CHANNELS") || ":")
    |> String.split(",")
    |> Enum.map(fn creds ->
         [chann, pass] = String.split(creds, ":", parts: 2)
         {chann, pass}
       end),
  responders: [
    # Included
    {Hedwig.Responders.Help, []},
    {Hedwig.Responders.Ping, []},
    # Simple Responders
    {HedwigSimpleResponders.Time, []},
    {HedwigSimpleResponders.Uptime, []},
    # Custom
    {Deku.Responders.Admin, []},
    {Deku.Responders.Debugger, []},
  ]

config :deku,
  admins: {:system, "IRC_ADMINS"},
  deployhook: {:system, "DEPLOYHOOK"}

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
