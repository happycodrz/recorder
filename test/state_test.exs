defmodule Recorder.StateTest do
  use ExUnit.Case

  alias Recorder.State

  describe "accessing by name" do
    test "works" do
      name = "fixtures/test.json"
      State.start_link(name)

      State.push(name, "1")
      State.push(name, "2")
      State.push(name, "3")

      assert State.pop(name) == "3"
      assert State.state(name) == ["1", "2"]
      assert State.reset(name)
      assert State.state(name) == []

      # test lookup
      assert GenServer.whereis(State.name(name)) != nil
      State.stop(name)
      assert GenServer.whereis(State.name(name)) == nil

      ## check with a different name
      name2 = "fixture2.json"
      State.start_link(name2)
      assert State.state(name2) == []
      State.push(name2, "4")
      assert State.state(name2) == ["4"]
      assert GenServer.whereis(State.name(name2)) != nil
      State.stop(name2)
      assert GenServer.whereis(State.name(name2)) == nil
    end
  end
end
