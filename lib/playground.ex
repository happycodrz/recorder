defmodule Playground do
  @moduledoc """
  for quick tests in IEx
  """
  def run do
    require Recorder
    Registry.start_link(keys: :unique, name: Registry.ViaTest)

    Recorder.with_client Recorder.HTTPoisonProxy do
      Recorder.store_in "fixtures/file.json" do
        SomeHTTPClient.request(
          "get",
          "https://jsonplaceholder.typicode.com/comments?postId=1",
          "",
          [{"Accept", "application/json"}]
        )

        SomeHTTPClient.request("get", "https://jsonplaceholder.typicode.com/posts", "", [
          {"Accept", "application/json"}
        ])
      end
    end
  end
end

defmodule SomeHTTPClient do
  @moduledoc """
  very basic http client that allows swapping the actual module
  """
  def realclient do
    Recorder.getclient() || HTTPoison
  end

  def request(method, url, body, headers) do
    realclient().request(method, url, body, headers)
  end
end
