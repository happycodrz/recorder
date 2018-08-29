defmodule Recorder.State do
  defstruct name: nil, interactions: []
  require Logger
  use GenServer

  # Client
  def start_link(file) do
    GenServer.start_link(__MODULE__, %Recorder.State{name: file}, name: name(file))
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
  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  @impl true
  def handle_call(:pop, _from, state = %Recorder.State{interactions: [head | tail]}) do
    {:reply, head, state |> Map.put(:interactions, tail)}
  end

  @impl true
  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, item}, state) do
    {:noreply, Map.put(state, :interactions, [item | state.interactions])}
  end

  @impl true
  def handle_cast(:reset, _state) do
    {:noreply, %Recorder.State{}}
  end

  def name(file) when is_binary(file) do
    {:via, Registry, {Registry.ViaTest, file}}
  end
end
