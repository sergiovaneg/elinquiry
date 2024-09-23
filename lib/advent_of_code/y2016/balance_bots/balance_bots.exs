alias AdventOfCode.Y2016.BalanceBots

defmodule AdventOfCode.Y2016.BalanceBots do
  @typep system :: %{binary() => [integer(), ...]}
  @endpoint_regex ~r/(bot|output) ([0-9])+/

  @spec init_system([binary(), ...]) :: system()
  defp init_system(lines) do
    {init, loop} =
      lines
      |> Enum.split_with(fn line -> line |> String.starts_with?("value ") end)

    init
    |> Enum.group_by(
      fn line ->
        @endpoint_regex |> Regex.run(line, capture: :first) |> List.first()
      end,
      fn line ->
        ~r/value ([0-9]+)/
        |> Regex.run(line, capture: :all_but_first)
        |> List.first()
        |> String.to_integer()
      end
    )
    |> config_system(loop)
  end

  defp config_system(sys, []), do: sys

  defp config_system(sys, lines) do
    {valid, loop} =
      lines
      |> Enum.split_with(fn line ->
        @endpoint_regex
        |> Regex.run(line, capture: :first)
        |> List.first()
        |> then(fn k ->
          sys |> Map.get(k, []) |> length() == 2
        end)
      end)

    valid
    |> Enum.reduce(sys, fn line, upd_sys ->
      [[src], [dst_low], [dst_high]] =
        @endpoint_regex
        |> Regex.scan(line, capture: :first)

      [v_low, v_high] = upd_sys[src] |> Enum.sort()

      upd_sys
      |> Map.update(dst_low, [v_low], &[v_low | &1])
      |> Map.update(dst_high, [v_high], &[v_high | &1])
    end)
    |> config_system(loop)
  end

  @spec part1(binary()) :: binary()
  def part1(contents) do
    {res, _} =
      contents
      |> String.split("\n")
      |> init_system()
      |> Enum.find(-1, fn {_, v} -> v |> Enum.sort() == [17, 61] end)

    res
  end

  @spec part2(binary()) :: system()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> init_system()
    |> Enum.filter(fn {k, _} -> k |> String.match?(~r/output [012]$/) end)
    |> Enum.reduce(1, fn {_, [v]}, acc -> acc * v end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> BalanceBots.part1()
|> IO.inspect(charlists: :as_lists)

contents
|> BalanceBots.part2()
|> IO.inspect(charlists: :as_lists)
