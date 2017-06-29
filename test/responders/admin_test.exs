defmodule Deku.Responders.AdminTest do
  use Hedwig.RobotCase

  @tag start_robot: true, name: "alfred", responders: [{Deku.Responders.Admin, []}]

  test "doesn't deploy", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "alfred deploy now"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "No, sir.")
  end

  @tag start_robot: true, name: "alfred", responders: [{Deku.Responders.Admin, []}]

  test "doesn't kick", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "alfred kick #channel user"}}
    assert_receive {:message, %{text: text}}
    assert String.contains?(text, "No, sir. ಠ_ರೃ")
  end
end