defmodule Recorder.RequestConverter do
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

  def headers_to_json(headers) when is_list(headers) do
    headers |> Enum.map(fn {k, v} -> [k, v] end)
  end

  def headers_from_json(headers) when is_list(headers) do
    headers |> Enum.map(fn [k, v] -> {k, v} end)
  end
end

defmodule Recorder.ResponseConverter do
  def to_json(payload = %HTTPoison.Response{}) do
    payload
    |> Map.put(:headers, payload.headers |> headers_to_json())
    |> Map.put(:body, payload.body |> Poison.decode!())
    |> Map.delete(:__struct__)
  end

  def from_json(json) do
    asmap =
      json
      |> Poison.decode!(%{keys: :atoms!})

    asmap
    |> Map.put(:headers, asmap.headers |> headers_from_json())
    |> Map.put(:body, asmap.body |> Poison.encode!())
    |> Map.put(:__struct__, HTTPoison.Response)
  end

  def headers_to_json(headers) when is_list(headers) do
    headers |> Enum.map(fn {k, v} -> [k, v] end)
  end

  def headers_from_json(headers) when is_list(headers) do
    headers |> Enum.map(fn [k, v] -> {k, v} end)
  end
end
