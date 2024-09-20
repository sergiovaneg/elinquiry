alias AdventOfCode.Y2016.CyberspaceExplosives

defmodule AdventOfCode.Y2016.CyberspaceExplosives do
  @marker_regex ~r/\(([0-9]+)x([0-9]+)\)/

  @spec decompress_v1(binary(), binary()) :: binary()
  defp decompress_v1(buffer, rest) do
    case Regex.run(@marker_regex, rest, return: :index) do
      [{i0, l0}, {i1, l1}, {i2, l2}] ->
        num_chars = rest |> String.slice(i1, l1) |> String.to_integer()
        num_reps = rest |> String.slice(i2, l2) |> String.to_integer()

        {s0, _} = rest |> String.split_at(i0)
        {_, s1} = rest |> String.split_at(i0 + l0)
        {s1, s2} = s1 |> String.split_at(num_chars)

        (buffer <> s0 <> (s1 |> String.duplicate(num_reps)))
        |> decompress_v1(s2)

      nil ->
        buffer <> rest
    end
  end

  @spec decompress_v2(non_neg_integer(), binary()) :: non_neg_integer()
  defp decompress_v2(buffer, rest) do
    case Regex.run(@marker_regex, rest, return: :index) do
      [{i0, l0}, {i1, l1}, {i2, l2}] ->
        num_chars = rest |> String.slice(i1, l1) |> String.to_integer()
        num_reps = rest |> String.slice(i2, l2) |> String.to_integer()

        {s0, _} = rest |> String.split_at(i0)
        {_, s1} = rest |> String.split_at(i0 + l0)
        {s1, s2} = s1 |> String.split_at(num_chars)

        buffer
        |> Kernel.+(s0 |> String.length())
        |> Kernel.+(num_reps * decompress_v2(0, s1))
        |> Kernel.+(decompress_v2(0, s2))

      nil ->
        buffer + (rest |> String.length())
    end
  end

  @spec decompress(binary(), :v1 | :v2) :: binary() | non_neg_integer()
  defp decompress(rest, version) do
    case version do
      :v1 ->
        "" |> decompress_v1(rest)

      :v2 ->
        0 |> decompress_v2(rest)
    end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> decompress(:v1)
    |> String.length()
  end

  def part2(contents) do
    contents
    |> decompress(:v2)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> CyberspaceExplosives.part1()
|> IO.puts()

contents
|> CyberspaceExplosives.part2()
|> IO.puts()
