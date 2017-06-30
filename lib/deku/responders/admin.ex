defmodule Deku.Responders.Admin do
  use Deku.Responder

  require Logger

  @channels Application.get_env(:deku, Deku.Robot)[:rooms]

  respond ~r/list channels$/, msg do
    Logger.warn inspect(@channels)
    send msg, inspect(@channels)
  end

  respond ~r/deploy now$/, msg do
    if is_admin?(msg.user) do
      Logger.warn "Deploying now..."
      System.cmd "curl", [Config.get_env(:deku, :deployhook)]
      send msg, "Yes, sir. (╭ರᴥ•́)"
    else
      Logger.warn "Loser trying to deploy..."
      send msg, "No, sir. ಠ_ರೃ"
    end
  end

  # kick <channel> <nick> :[reason]
  respond ~r/kick (#[^\s]+) ([^\s]+)(?: (.+))?$/, msg do
    if is_admin?(msg.user) do
      # matches
      channel = msg.matches[1]
      kickee = msg.matches[2]
      reason = ":" <> (msg.matches[3] || kickee)
      #chanserv
      pmsg = %{msg | room: "Chanserv"}
      # kick
      maybe_join(msg, channel)
      send pmsg, "op #{channel}"
      :timer.sleep(1000)
      command msg, Irc.Commands.kick!(channel, kickee, reason)
      leave_or_deop(msg, channel)
    else
      send msg, "No, sir. ಠ_ರೃ"
    end
  end

  # kickban <channel> <nick|pattern> [!P|!T <minutes>] [reason]
  respond ~r/kickban (#[^\s]+) ([^\s]+)(?: .+)?$/, msg do
    if is_admin?(msg.user) do
      # matches
      channel = msg.matches[1]
      kickee = msg.matches[2]
      opts = msg.matches[3] || ""
      #chanserv
      pmsg = %{msg | room: "Chanserv"}
      # kickban
      maybe_join(msg, channel)
      send pmsg, "op #{channel}"
      :timer.sleep(1000)
      send pmsg, "AKICK #{channel} ADD #{kickee}#{opts}"
      leave_or_deop(msg, channel)
    else
      send msg, "No, sir. ಠ_ರೃ"
    end
  end

  @doc """
  Check if the user is an admin.
  """
  @spec is_admin?(Hedwig.User.t | String.t) :: boolean
  def is_admin?(%{id: id}) do
    id
    |> String.split("@")
    |> Enum.at(0)
    |> is_admin?()
  end

  def is_admin?(user) when is_binary(user) do
    Config.get_env(:deku, :admins, "")
    |> String.split(",")
    |> Enum.any?(&String.equivalent?(&1, user))
  end

  @doc """
  Join channel if not in the channels list.
  """
  def maybe_join(msg, channel) do
    unless is_joined?(channel) do
      command msg, Irc.Commands.join!(channel)
      :timer.sleep(500)
    end
  end

  @doc """
  Leave channel if not in the channels list.
  """
  def leave_or_deop(msg, channel) do
    :timer.sleep(500)
    if is_joined?(channel) do
      send %{msg | room: "Chanserv"}, "deop #{channel}"
    else
      command msg, Irc.Commands.part!(channel)
    end
  end

  @doc """
  Check if the channel is in the channels list.
  """
  def is_joined?(channel) do
    @channels
    |> Enum.map(&elem(&1, 0))
    |> Enum.any?(&String.equivalent?(&1, channel))
  end
end
