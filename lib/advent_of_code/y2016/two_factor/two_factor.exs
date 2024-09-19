alias AdventOfCode.Y2016.TwoFactor

defmodule AdventOfCode.Y2016.TwoFactor do
  @w 50
  @h 6
  @typep screen_state :: [[binary(), ...], ...]

  @spec init_screen() :: screen_state()
  defp init_screen() do
    "."
    |> List.duplicate(@w)
    |> List.duplicate(@h)
  end

  @spec rect(screen_state(), pos_integer(), pos_integer()) :: screen_state()
  defp rect(x0, a, b) do
    {top, bottom} = x0 |> Enum.split(b)

    (top
     |> Enum.map(fn row ->
       {_, right} = row |> Enum.split(a)

       1..a |> Enum.reduce(right, fn _, row -> ["#" | row] end)
     end)) ++ bottom
  end

  @spec rot_col(screen_state(), non_neg_integer(), pos_integer()) ::
          screen_state()
  defp rot_col(x0, j, n) do
    n = rem(n, @h)

    x0
    |> Enum.map(fn row -> row |> Enum.at(j) end)
    |> then(fn col ->
      {bottom, top} = col |> Enum.split(-n)
      top ++ bottom
    end)
    |> Enum.reverse()
    |> Enum.zip_reduce(
      x0 |> Enum.reverse(),
      [],
      fn e, row, x ->
        [row |> List.replace_at(j, e) | acc]
      end
    )
  end

  @spec rot_row(screen_state(), non_neg_integer(), pos_integer()) ::
          screen_state()
  defp rot_row(x0, i, n) do
    n = rem(n, @w)

    x0
    |> List.update_at(i, fn row ->
      {right, left} = row |> Enum.split(-n)
      left ++ right
    end)
  end

  @spec run_instruction(binary(), screen_state()) :: screen_state()
  defp run_instruction(line, x0) do
    case line do
      "rect " <> rest ->
        [[a, b]] = ~r/([0-9]+)x([0-9]+)/ |> Regex.scan(rest, capture: :all_but_first)
        x0 |> rect(a |> String.to_integer(), b |> String.to_integer())

      "rotate row " <> rest ->
        [[i, n]] = ~r/y=([0-9]+) by ([0-9]+)/ |> Regex.scan(rest, capture: :all_but_first)
        x0 |> rot_row(i |> String.to_integer(), n |> String.to_integer())

      "rotate column " <> rest ->
        [[j, n]] = ~r/x=([0-9]+) by ([0-9]+)/ |> Regex.scan(rest, capture: :all_but_first)
        x0 |> rot_col(j |> String.to_integer(), n |> String.to_integer())
    end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.reduce(init_screen(), &run_instruction/2)
    |> List.flatten()
    |> Enum.count(&(&1 == "#"))
  end

  @spec part2(binary()) :: binary()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.reduce(init_screen(), &run_instruction/2)
    |> Enum.join("\n")
    |> String.replace(".", " ")
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> TwoFactor.part1()
|> IO.inspect()

contents
|> TwoFactor.part2()
|> IO.puts()
