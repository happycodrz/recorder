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

      IO.inspect Recorder.State.state(f)
      ## needs persisting...
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

defmodule RecTest do
  def run do
    require Recorder
    IO.puts("IN file #{Recorder.getfile()}")

    Recorder.with_client(Recorder.HTTPoisonProxy) do
      Recorder.store_in "fixtures/file.json" do
        # IO.puts("IN file #{Recorder.getfile()}")

        SomeHTTPClient.request("get", "https://jsonplaceholder.typicode.com/comments?postId=1", "", [{"Accept", "application/json"}])
        SomeHTTPClient.request("get", "https://jsonplaceholder.typicode.com/posts", "", [{"Accept", "application/json"}])
      end
    end

    IO.puts("IN file #{Recorder.getfile()}")
  end
end

defmodule Recorder.HTTPoisonProxy do
  def request(method, url, body, headers) do
    req = Recorder.RequestConverter.to_json(method, url, body, headers)
    {:ok, raw_res} = HTTPoison.request(method, url, body, headers)
    res = Recorder.ResponseConverter.to_json(raw_res)
    interaction = %{
      request: req,
      response: res
    }
    Recorder.State.push(Recorder.getfile(), interaction)
    # respond with raw result
    raw_res
  end
end

defmodule SomeHTTPClient do
  def realclient do
    # Application.get_env(Recorder, :http_client, )
    Recorder.getclient() || HTTPoison
  end

  def request(method, url, body, headers) do
    # HTTPoison.request!(method, url, body, headers)
    realclient().request(method, url, body, headers)
  end
end
