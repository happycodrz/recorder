defmodule Recorder.State do
  require Logger
  use GenServer

  # Client
  def start_link(file) do
    GenServer.start_link(__MODULE__, [], name: name(file))
  end

  def stop(file) do
    GenServer.stop(name(file), :normal)
  end

  def push(file, item) do
    GenServer.cast(name(file), {:push, item})
  end

  def pop(file) do
    GenServer.call(name(file), :pop)
  end

  def state(file) do
    GenServer.call(name(file), :state)
  end

  def reset(file) do
    GenServer.cast(name(file), :reset)
  end

  # Server (callbacks)
  @impl true
  def init(stack) do
    Process.flag(:trap_exit, true)
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_call(:state, _, state) do
    # we reverse the order to represent the actual timeline
    {:reply, state |> Enum.reverse(), state}
  end

  @impl true
  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end

  @impl true
  def handle_cast(:reset, _state) do
    {:noreply, []}
  end

  def name(file) when is_binary(file) do
    {:via, Registry, {Registry.ViaTest, file}}
  end
end
