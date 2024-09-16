alias AdventOfCode.Y2016.BathroomSecurity

defmodule AdventOfCode.Y2016.BathroomSecurity do
  defp grid_step(d, {i, j}) do
    case d do
      "U" ->
        {max(0, i - 1), j}

      "D" ->
        {min(2, i + 1), j}

      "L" ->
        {i, max(0, j - 1)}

      "R" ->
        {i, min(2, j + 1)}
    end
  end

  defp grid_map({i, j}) do
    (3 * i + j + 1) |> Integer.to_string()
  end

  defp cross_step(d, {i0, j0}) do
    {i, j} =
      case d do
        "U" ->
          {i0 - 1, j0}

        "D" ->
          {i0 + 1, j0}

        "L" ->
          {i0, j0 - 1}

        "R" ->
          {i0, j0 + 1}
      end

    if abs(i) + abs(j) < 3 do
      {i, j}
    else
      {i0, j0}
    end
  end

  defp cross_map({i, j}) do
    (7 + min(6, max(-6, 4 * i)) + j) |> Integer.to_string(16)
  end

  defp process(contents, step_fn, map_fn) do
    {code, _} =
      contents
      |> String.split("\n")
      |> Enum.map_reduce({1, 1}, fn seq, x0 ->
        xf =
          seq
          |> String.graphemes()
          |> Enum.reduce(x0, step_fn)

        {xf |> map_fn.(), xf}
      end)

    code
    |> Enum.join()
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents |> process(&grid_step/2, &grid_map/1)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents |> process(&cross_step/2, &cross_map/1)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> BathroomSecurity.part1()
|> IO.puts()

contents
|> BathroomSecurity.part2()
|> IO.puts()
