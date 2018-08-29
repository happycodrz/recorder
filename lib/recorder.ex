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
      Recorder.setfile(f)
      res = unquote(block)
      Recorder.setfile(current_file)
      res
    end
  end

  def setfile(file) do
    Application.put_env(Recorder, :current_file, file)
  end

  def getfile() do
    Application.get_env(Recorder, :current_file)
  end
end

defmodule RecTest do
  def run do
    require Recorder
    IO.puts("IN file #{Recorder.getfile()}")

    Recorder.store_in "fixtures/file.json" do
      IO.puts("working")
      IO.puts("IN file #{Recorder.getfile()}")
      1 + 4
    end

    IO.puts("IN file #{Recorder.getfile()}")
  end
end

defmodule Recorder.HTTPoisonProxy do
  def request(method, url, body, headers) do
    HTTPoison.request(method, url, body, headers)
  end
end

defmodule SomeHTTPClient do
  def realclient do
    Application.get_env(Recorder, :http_client, HTTPoison)
  end

  def request(method, url, body, headers) do
    # HTTPoison.request!(method, url, body, headers)
    realclient().request(method, url, body, headers)
  end
end
