alias AdventOfCode.Y2016.SecurityObscurity

defmodule AdventOfCode.Y2016.SecurityObscurity do
  @spec sort_letters(
          binary(),
          binary(),
          %{binary() => non_neg_integer()}
        ) :: boolean()
  defp sort_letters(a, b, f) do
    if f[a] == f[b] do
      a <= b
    else
      f[a] > f[b]
    end
  end

  defp get_checksum(line) do
    frequencies =
      line
      |> String.replace(~r/[0-9]|-/, "")
      |> String.graphemes()
      |> Enum.frequencies()

    frequencies
    |> Map.keys()
    |> Enum.sort(&sort_letters(&1, &2, frequencies))
    |> Enum.take(5)
    |> Enum.join()
  end

  defp get_id(line) do
    [[num]] = ~r/[0-9]+/ |> Regex.scan(line)
    num |> String.to_integer()
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.filter(fn line ->
      line
      |> String.slice(0..-8//1)
      |> get_checksum() == line |> String.slice(-6..-2//1)
    end)
    |> Enum.map(&get_id/1)
    |> Enum.sum()
  end

  def decrypt(line) do
    id = line |> get_id()

    line
    |> to_charlist()
    |> Enum.map(fn c ->
      if c in ~c"-[]" or c in ?0..?9 do
        c
      else
        (c - ?a + id)
        |> Kernel.rem(?z - ?a + 1)
        |> Kernel.+(?a)
      end
    end)
    |> to_string()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.filter(fn line ->
      line
      |> String.slice(0..-8//1)
      |> get_checksum() == line |> String.slice(-6..-2//1)
    end)
    |> Enum.map(&decrypt/1)
    |> Enum.filter(&String.contains?(&1, "north"))
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> SecurityObscurity.part1()
|> IO.puts()

contents
|> SecurityObscurity.part2()
|> IO.puts()
