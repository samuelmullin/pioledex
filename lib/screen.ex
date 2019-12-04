defmodule PIOLEDex.Screen do
  @moduledoc """
  Documentation for Button.
  """
  use GenServer
  require Circuits.I2C

  @spec start_link(any) :: GenServer.on_start()
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, i2c_ref} = Circuits.I2C.open("i2c-1")
    PIOLEDex.Commands.init_display(i2c_ref)

    state = %{
      lines: ["", "", "", ""],
      i2c_ref: i2c_ref
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:update_display, new_lines}, _from, %{i2c_ref: i2c_ref} = state) do
    PIOLEDex.Commands.display_text(i2c_ref, new_lines)

    state = state
    |> Map.put(:lines, new_lines)

    {:reply, "Updated Display.", state}
  end

  @impl true
  def handle_call({:clear}, _from, %{i2c_ref: i2c_ref} = state) do
    PIOLEDex.Commands.clear(i2c_ref)

    state = state
    |> Map.put(:lines, ["", "", "", ""])

    {:reply, "Cleared Display.", state}
  end

  def update_display(new_lines) when is_list(new_lines) do
    GenServer.call(__MODULE__, {:update_display, new_lines})
  end

  def update_display(image) when is_binary(image) do
    GenServer.call(__MODULE__, {:display_image, image})
  end

  def clear() do
    GenServer.call(__MODULE__, {:clear})
  end

end
