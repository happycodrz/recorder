defmodule Recorder.ConverterCommon do
  def headers_to_json(headers) when is_list(headers) do
    headers |> Enum.map(fn {k, v} -> [k, v] end)
  end

  def headers_from_json(headers) when is_list(headers) do
    headers |> Enum.map(fn [k, v] -> {k, v} end)
  end

  def body_from_json(body) when is_binary(body), do: body |> Poison.decode!()
  def body_from_json(body), do: body

  def body_to_json(body) when is_binary(body), do: body |> Poison.encode!()
  def body_to_json(body), do: body
end

defmodule Recorder.RequestConverter do
  import Recorder.ConverterCommon

  def to_json(method, url, body, headers) do
    %{
      url: url,
      method: method,
      body: body,
      headers: headers |> headers_to_json()
    }
  end

  def from_json(json) do
    asmap =
      json
      |> Poison.decode!(%{keys: :atoms!})

    asmap
    |> Map.put(:body, asmap.body)
    |> Map.put(:headers, asmap.headers |> headers_from_json())
  end
end

defmodule Recorder.ResponseConverter do
  import Recorder.ConverterCommon

  def to_json(payload = %HTTPoison.Response{}) do
    payload
    |> Map.put(:headers, payload.headers |> headers_to_json())
    |> Map.put(:body, payload.body |> body_from_json())
    |> Map.put(:url, payload.request_url)
    |> Map.delete(:request_url)
    |> Map.delete(:__struct__)
  end

  def from_json(json) do
    map =
      json
      |> Poison.decode!(%{keys: :atoms!})

    map
    |> Map.put(:headers, map.headers |> headers_from_json())
    |> Map.put(:body, map.body |> Poison.encode!())
    |> Map.put(:request_url, map.url)
    |> Map.put(:__struct__, HTTPoison.Response)
    |> Map.delete(:url)
  end
end
