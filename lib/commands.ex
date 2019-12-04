defmodule PIOLEDex.Commands do
  use Bitwise
  alias Circuits.I2C

  @disp_height          32
  @disp_width           128
  @pages                4

  @control_register     0x80
  @data_register        0x40

  @set_contrast         0x81
  @set_entire_on        0xa4
  @set_norm_inv         0xa6
  @set_disp             0xae
  @set_mem_addr         0x20
  @set_col_addr         0x21
  @set_page_addr        0x22
  @set_disp_start_line  0x40
  @set_seg_remap        0xa0
  @set_mux_ratio        0xa8
  @set_com_out_dir      0xc0
  @set_disp_offset      0xd3
  @set_com_pin_cfg      0xda
  @set_disp_clk_div     0xd5
  @set_precharge        0xd9
  @set_vcom_desel       0xdb
  @set_charge_pump      0x8d

  @spec init_display(reference) :: :ok | {:error, any}
  def init_display(i2c_ref) do
    send_command(i2c_ref, @set_disp ||| 0x00) # off
    send_command(i2c_ref, @set_mem_addr)
    send_command(i2c_ref, 0x00)
    send_command(i2c_ref, @set_disp_start_line ||| 0x00)
    send_command(i2c_ref, @set_seg_remap ||| 0x01)
    send_command(i2c_ref, @set_mux_ratio)
    send_command(i2c_ref, @disp_height - 1)
    send_command(i2c_ref, @set_com_out_dir ||| 0x08)
    send_command(i2c_ref, @set_disp_offset)
    send_command(i2c_ref, 0x00)
    send_command(i2c_ref, @set_com_pin_cfg)
    send_command(i2c_ref, 0x02)
    send_command(i2c_ref, @set_disp_clk_div)
    send_command(i2c_ref, 0x80)
    send_command(i2c_ref, @set_precharge)
    send_command(i2c_ref, 0xf1)
    send_command(i2c_ref, @set_vcom_desel)
    send_command(i2c_ref, 0x30)
    send_command(i2c_ref, @set_contrast)
    send_command(i2c_ref, 0xff)
    send_command(i2c_ref, @set_entire_on)
    send_command(i2c_ref, @set_norm_inv)
    send_command(i2c_ref, @set_charge_pump)
    send_command(i2c_ref, 0x14)
    send_command(i2c_ref, @set_disp ||| 0x01)
  end

  @spec show(reference, binary) :: :ok | {:error, any}
  def show(i2c_ref, buffer) do
    send_command(i2c_ref, @set_col_addr)
    send_command(i2c_ref, 0)
    send_command(i2c_ref, @disp_width - 1)
    send_command(i2c_ref, @set_page_addr)
    send_command(i2c_ref, 0)
    send_command(i2c_ref, @pages - 1)
    send_data(i2c_ref, buffer)
  end

  @spec display_text(reference, list(binary)) :: :ok | {:error, any}
  def display_text(i2c_ref, lines) when is_list(lines) do
    formatted_lines = PIOLEDex.Text.format_lines(lines)
    show(i2c_ref, formatted_lines)
  end

  @spec clear(reference) :: :ok | {:error, any}
  def clear(i2c_ref) do
    show(i2c_ref, :binary.copy(<<0>>, 4096))
  end

  @spec send_command(reference, integer) :: :ok | {:error, any}
  def send_command(i2c_ref, cmd), do: I2C.write(i2c_ref, 0x3c, <<@control_register, cmd>>)

  @spec send_data(reference, binary) :: :ok | {:error, any}
  def send_data(i2c_ref, buffer), do: I2C.write(i2c_ref, 0x3c, <<@data_register>> <> buffer)

end
