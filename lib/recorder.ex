defmodule Recorder do
  @moduledoc """
  ## recording to a file
  Recorder.store_in("test/fixtures/something.json") do
    SomeHTTPClient.make_request1(args)
    SomeHTTPClient.make_request2(args)
  end


  ## this uses the recorded file
  Recorder.use_fixture("test/fixtures/something.json") do
    assert SomeHTTPClient.make_request1(args) == %{body: "", headers: [], status_code: 200, url: ""}
    assert SomeHTTPClient.make_request2(args) == %{body: "", headers: [], status_code: 200, url: ""}
  end
  """
end
