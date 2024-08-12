alias AdventOfCode.Y2015.AuntSue

defmodule AdventOfCode.Y2015.AuntSue do
  @ticker_tape %{
    children: 3,
    cats: 7,
    samoyeds: 2,
    pomeranians: 3,
    akitas: 0,
    vizslas: 0,
    goldfish: 5,
    trees: 3,
    cars: 2,
    perfumes: 1
  }

  @spec parse_aunt(binary()) :: {pos_integer(), %{atom() => non_neg_integer()}}
  defp parse_aunt(line) do
    [id] =
      ~r/Sue ([0-9]+)/
      |> Regex.run(line, capture: :all_but_first)

    {id |> String.to_integer(),
     ~r/([a-z]+): ([0-9]+)/
     |> Regex.scan(line, capture: :all_but_first)
     |> Enum.map(fn [key, val] ->
       {
         key |> String.to_existing_atom(),
         val |> String.to_integer()
       }
     end)}
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.reduce_while(0, fn line, acc ->
      {id, data} = line |> parse_aunt()

      if data |> Enum.all?(fn {k, v} -> v == @ticker_tape[k] end) do
        {:halt, id}
      else
        {:cont, acc}
      end
    end)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.reduce_while(0, fn line, acc ->
      {id, data} = line |> parse_aunt()

      if data
         |> Enum.all?(fn {k, v} ->
           case k do
             key when key in [:cats, :trees] ->
               v > @ticker_tape[k]

             key when key in [:pomeranians, :goldfish] ->
               v < @ticker_tape[k]

             _ ->
               v == @ticker_tape[k]
           end
         end) do
        {:halt, id}
      else
        {:cont, acc}
      end
    end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> AuntSue.part1()
|> IO.puts()

contents
|> AuntSue.part2()
|> IO.puts()
