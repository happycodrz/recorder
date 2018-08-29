defmodule Recorder.Store do
  def persist(state = %Recorder.State{name: name}) do
    File.mkdir_p!(name |> Path.dirname())
    json = state |> Poison.encode!(pretty: true)
    File.write!(name, json)
  end
end
