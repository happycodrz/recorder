defmodule Recorder.StoreTest do
  use ExUnit.Case

  alias Recorder.Store

  describe "persist" do
    test "works" do
      File.rm("test/fixtures/persist-state.json")
      refute File.exists?("test/fixtures/persist-state.json")
      Store.persist(statepayload())
      assert File.exists?("test/fixtures/persist-state.json")
    end
  end

  def statepayload do
    %Recorder.State{
      name: "test/fixtures/persist-state.json",
      interactions: [
        %{
          request: %{
            body: "",
            headers: [["Accept", "application/json"]],
            method: "get",
            url: "https://jsonplaceholder.typicode.com/comments?postId=1"
          },
          response: %{
            body: [
              %{
                "body" =>
                  "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium",
                "email" => "Eliseo@gardner.biz",
                "id" => 1,
                "name" => "id labore ex et quam laborum",
                "postId" => 1
              }
            ],
            headers: [
              ["Date", "Wed, 29 Aug 2018 20:04:36 GMT"],
              ["Content-Type", "application/json; charset=utf-8"],
              ["Transfer-Encoding", "chunked"],
              ["Connection", "keep-alive"],
              ["Server", "cloudflare"],
              ["CF-RAY", "4521a0b08e2c9bf3-AMS"]
            ],
            request_url: "https://jsonplaceholder.typicode.com/comments?postId=1",
            status_code: 200
          }
        }
      ]
    }
  end
end
