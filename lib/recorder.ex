defmodule Recorder do
  @moduledoc """
  ## recording to a file


  # set the proxy to record interactions
  Application.put_env(Recorder, :http_client, Recorder.HTTPoisonProxy)
  Recorder.store_in("test/fixtures/something.json") do
    SomeHTTPClient.make_request1(args)
    SomeHTTPClient.make_request2(args)
  end
  # undo proxy
  Application.put_env(Recorder, :http_client, nil)


  ## this uses the recorded file
  Recorder.use_fixture("test/fixtures/something.json") do
    assert SomeHTTPClient.make_request1(args) == %{body: "", headers: [], status_code: 200, url: ""}
    assert SomeHTTPClient.make_request2(args) == %{body: "", headers: [], status_code: 200, url: ""}
  end

  ## configuration:
  Recorder, :http_client
  Recorder, :current_file
  """

  defmacro store_in(file, do: block) do
    quote do
      f = unquote(file)
      current_file = Recorder.getfile()
      Recorder.State.start_link(f)
      Recorder.setfile(f)
      res = unquote(block)
      Recorder.setfile(current_file)
      Recorder.Store.persist(Recorder.State.state(f))
      Recorder.State.stop(f)
      res
    end
  end

  defmacro with_client(client, do: block) do
    quote do
      current_client = Recorder.getclient()
      Recorder.setclient(unquote(client))
      res = unquote(block)
      Recorder.setclient(current_client)
      res
    end
  end

  def setfile(file) do
    Application.put_env(Recorder, :current_file, file)
  end

  def getfile() do
    Application.get_env(Recorder, :current_file)
  end

  def setclient(client) do
    Application.put_env(Recorder, :http_client, client)
  end

  def getclient() do
    Application.get_env(Recorder, :http_client)
  end
end
