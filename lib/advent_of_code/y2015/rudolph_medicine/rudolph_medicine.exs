alias AdventOfCode.Y2015.RudolphMedicine

defmodule AdventOfCode.Y2015.RudolphMedicine do
  @atom_re ~r/([A-Z][a-z]{0,1}|e)/

  @spec parse_replacement(binary()) :: {binary(), binary()}
  defp parse_replacement(line) do
    line
    |> String.split(" => ")
    |> List.to_tuple()
  end

  defp split_by_atoms(molecule) do
    @atom_re
    |> Regex.scan(molecule, capture: :first)
    |> List.flatten()
  end

  @spec span_transformations(
          binary(),
          %{binary() => [binary(), ...]}
        ) :: [binary(), ...]
  defp span_transformations(initial_molecule, plant) do
    split_molecule = initial_molecule |> split_by_atoms()

    for(
      idx <- 0..(length(split_molecule) - 1),
      x <- plant |> Map.get(split_molecule |> Enum.at(idx), []),
      do: split_molecule |> List.replace_at(idx, x) |> Enum.join()
    )
    |> Enum.uniq()
  end

  def part1(contents) do
    lines = contents |> String.split("\n")

    plant =
      lines
      |> Enum.filter(&String.contains?(&1, " => "))
      |> Enum.map(&parse_replacement/1)
      |> Enum.group_by(fn {k, _} -> k end, fn {_, v} -> v end)

    lines
    |> Enum.at(-1)
    |> span_transformations(plant)
    |> length()
  end

  defp reduce_molecule(steps, initial_molecule, replacements) do
    modified_molecule =
      replacements
      |> Enum.reduce_while(initial_molecule, fn {src, dst}, mol ->
        if mol |> String.contains?(dst) do
          {:halt, mol |> String.replace(dst, src, global: false)}
        else
          {:cont, mol}
        end
      end)

    cond do
      modified_molecule == initial_molecule ->
        nil

      modified_molecule == "e" ->
        steps

      true ->
        reduce_molecule(steps + 1, modified_molecule, replacements)
    end
  end

  def part2(contents) do
    lines = contents |> String.split("\n")

    replacements =
      lines
      |> Enum.filter(&String.contains?(&1, " => "))
      |> Enum.map(&parse_replacement/1)
      |> Enum.sort_by(
        fn {_src, dst} ->
          dst |> split_by_atoms() |> length()
        end,
        &>=/2
      )

    target = lines |> List.last()

    reduce_molecule(1, target, replacements)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> RudolphMedicine.part1()
|> IO.puts()

contents
|> RudolphMedicine.part2()
|> IO.puts()
