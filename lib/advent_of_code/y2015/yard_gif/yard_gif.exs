alias AdventOfCode.Y2015.YardGif

defmodule AdventOfCode.Y2015.YardGif do
  @type grid :: [[boolean(), ...], ...]

  @spec run_step(grid()) :: grid()
  defp run_step(grid) do
    padding = for _ <- 1..length(grid), do: false

    ([padding] ++ grid ++ [padding])
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(fn triple ->
      padding = [false, false, false]

      ([padding] ++
         (triple
          |> Enum.zip_with(fn x -> x end)) ++ [padding])
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.map(fn neighbourhood ->
        [_, [_, m, _], _] = neighbourhood

        count =
          neighbourhood
          |> List.flatten()
          |> List.replace_at(4, false)
          |> Enum.count(&Function.identity/1)

        if m do
          count == 2 or count == 3
        else
          count == 3
        end
      end)
    end)
  end

  @spec set_corners(grid()) :: grid()
  defp set_corners(grid) do
    grid
    |> List.update_at(0, fn row ->
      row |> List.replace_at(0, true) |> List.replace_at(-1, true)
    end)
    |> List.update_at(-1, fn row ->
      row |> List.replace_at(0, true) |> List.replace_at(-1, true)
    end)
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    1..100
    |> Enum.reduce(
      contents
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.map(fn c -> c == "#" end)
      end),
      fn _, g ->
        g |> run_step()
      end
    )
    |> List.flatten()
    |> Enum.count(&Function.identity/1)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    1..100
    |> Enum.reduce(
      contents
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.map(fn c -> c == "#" end)
      end)
      |> set_corners(),
      fn _, g ->
        g
        |> run_step()
        |> set_corners()
      end
    )
    |> List.flatten()
    |> Enum.count(&Function.identity/1)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> YardGif.part1()
|> IO.puts()

contents
|> YardGif.part2()
|> IO.puts()
