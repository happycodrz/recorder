defmodule RecorderTest do
  use ExUnit.Case
  doctest Recorder

  test "greets the world" do
    assert Recorder.hello() == :world
  end
end
