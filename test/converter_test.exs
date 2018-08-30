defmodule Recorder.ConverterTest do
  use ExUnit.Case
  alias Recorder.RequestConverter
  alias Recorder.ResponseConverter

  describe "RequestConverter" do
    test "to_json" do
      assert RequestConverter.to_json("post", "https://www.google.com", %{a: 1}, [
               {"Accept", "text/html"}
             ]) == %{
               body: %{a: 1},
               headers: [["Accept", "text/html"]],
               method: "post",
               url: "https://www.google.com"
             }
    end

    test "from_json" do
      json =
        %{
          body: %{a: 1},
          headers: [["Accept", "text/html"]],
          method: "post",
          url: "https://www.google.com"
        }
        |> Poison.encode!()

      assert RequestConverter.from_json(json) == %{
               method: "post",
               url: "https://www.google.com",
               body: %{a: 1},
               headers: [{"Accept", "text/html"}]
             }
    end
  end

  describe "ResponseConverter" do
    test "to_json" do
      res = %HTTPoison.Response{
        status_code: 200,
        body: "{\"key\": \"value\"}",
        headers: [{"Accept", "text/html"}],
        request_url: "http://www.google.com"
      }

      assert ResponseConverter.to_json(res) == %{
               body: %{"key" => "value"},
               headers: [["Accept", "text/html"]],
               status_code: 200,
               url: "http://www.google.com"
             }
    end

    test "from_json" do
      json =
        %{
          body: %{"key" => "value"},
          headers: [["Accept", "text/html"]],
          status_code: 200,
          url: "http://www.google.com"
        }
        |> Poison.encode!()

      assert ResponseConverter.from_json(json) == %HTTPoison.Response{
               body: "{\"key\":\"value\"}",
               headers: [{"Accept", "text/html"}],
               request_url: "http://www.google.com",
               status_code: 200
             }
    end
  end
end
