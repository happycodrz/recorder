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
      assert State.state(name) == %Recorder.State{interactions: ["2", "1"], name: "fixtures/test.json"}
      assert State.reset(name)
      assert State.state(name) == %Recorder.State{interactions: [], name: nil}

      # test lookup
      assert GenServer.whereis(State.name(name)) != nil
      State.stop(name)
      assert GenServer.whereis(State.name(name)) == nil

      ## check with a different name
      name2 = "fixture2.json"
      State.start_link(name2)
      assert State.state(name2) == %Recorder.State{interactions: [], name: "fixture2.json"}
      State.push(name2, "4")
      assert State.state(name2) == %Recorder.State{interactions: ["4"], name: "fixture2.json"}
      assert GenServer.whereis(State.name(name2)) != nil
      State.stop(name2)
      assert GenServer.whereis(State.name(name2)) == nil
    end
  end
end
