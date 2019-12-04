defmodule PIOLEDex.Text do
  use Bitwise

  @disp_width  128

  @spec format_lines(list(binary)) :: binary
  def format_lines(lines) do
    lines
      |> Enum.map(fn(line) -> format_line(line) end)
      |> List.flatten
      |> :binary.list_to_bin
  end

  @spec format_line(binary) :: [any]
  def format_line(text) do
    text = text |> to_charlist
    # One row is 8 pixels
    img = :egd.create(@disp_width, 8)
    #Anyone knows any other fonts that work here? btw. it shrinks with canvas size, but it's never larger than 11px
    path = :filename.join([:code.priv_dir(:egd), "fonts", "6x11_latin1.wingsfont"])
    font = :egd_font.load(path)
    color = :egd.color(:black)

    x = 0
    # there was nonzero default offset, -4 did the trick
    # but christ, it was a fight
    :egd.text(img, {x,-4}, font, text, color)
    bitmap = :egd.render(img, :raw_bitmap)
    [bitmap
      |> :binary.bin_to_list
      |> monochrome
      |> convert_row
      |> pack_to_8bit]
      |> Enum.reverse
  end

  defp monochrome(rgb_bitmap) when is_list(rgb_bitmap) do
    rgb_bitmap
      |> Enum.chunk_every(3)
      |> Enum.map(fn([r,g,b]) -> if r + g + b > 0 do 0 else 1 end end)
  end

  defp convert_row(bitmap) when is_list(bitmap) do
    bitmap
      |> Enum.chunk_every(@disp_width)
      |> Enum.reverse
      |> transpose
      |> List.flatten
  end

  defp pack_to_8bit(bitmap) when is_list(bitmap) do
    bitmap
      |> Enum.chunk_every(8)
      |> Enum.map(fn(bits) -> elem(Enum.reduce(bits, {7,0}, fn (x, {i, acc}) -> {i-1, acc ||| x <<< i} end), 1) end)
  end

  defp transpose([[]|_]), do: []
  defp transpose(a) do
    [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end

end
