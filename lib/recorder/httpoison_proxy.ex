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
