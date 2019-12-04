defmodule PIOLEDex do
  def update_display(new_lines) when is_list(new_lines) do
    PIOLEDex.Screen.update_display(new_lines)
  end

  def update_display(data) do
    PIOLEDex.Screen.update_display(data)
  end
end
