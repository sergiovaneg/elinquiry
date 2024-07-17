alias AdventOfCode.Y2015.AssemblyRequired

defmodule AdventOfCode.Y2015.AssemblyRequired do
  @typep cache :: %{optional(binary()) => non_neg_integer()}
  @typep entry :: (registry(), cache() -> cache())
  @typep registry :: %{binary() => entry()}

  @spec safe_query(binary(), registry(), cache()) ::
          {non_neg_integer(), cache()}
  defp safe_query(operand, registry, cache) do
    if Regex.run(~r/[0-9]+/, operand, capture: :first) == [operand] do
      {operand |> String.to_integer() |> Bitwise.band(0xFFFF), cache}
    else
      cache = registry[operand].(registry, cache)
      {cache[operand], cache}
    end
  end

  @spec parse_instruction(binary()) :: {binary(), entry()}
  defp parse_instruction(line) do
    operands = line |> String.split(~r/ -> | /)
    target = operands |> List.last()

    case operands |> length() do
      2 ->
        {
          target,
          fn registry, cache ->
            if cache |> Map.has_key?(target) do
              cache
            else
              {x, cache} = operands |> Enum.at(0) |> safe_query(registry, cache)

              cache |> Map.put(target, x)
            end
          end
        }

      # Only 'NOT' fits this case
      3 ->
        {
          target,
          fn registry, cache ->
            if cache |> Map.has_key?(target) do
              cache
            else
              {x, cache} = operands |> Enum.at(1) |> safe_query(registry, cache)
              cache |> Map.put(target, x |> Bitwise.bxor(0xFFFF))
            end
          end
        }

      4 ->
        op =
          case operands |> Enum.at(1) do
            "AND" ->
              &Bitwise.band/2

            "OR" ->
              &Bitwise.bor/2

            "LSHIFT" ->
              &Bitwise.bsl/2

            "RSHIFT" ->
              &Bitwise.bsr/2
          end

        {
          target,
          fn registry, cache ->
            if cache |> Map.has_key?(target) do
              cache
            else
              {x, cache} = operands |> Enum.at(0) |> safe_query(registry, cache)
              {y, cache} = operands |> Enum.at(2) |> safe_query(registry, cache)

              cache |> Map.put(target, x |> op.(y) |> Bitwise.band(0xFFFF))
            end
          end
        }
    end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    registry =
      contents
      |> String.split("\n")
      |> Enum.map(&parse_instruction/1)
      |> Map.new()

    registry["a"].(registry, %{})["a"]
  end

  @spec part2(binary(), non_neg_integer()) :: non_neg_integer()
  def part2(contents, a) do
    (contents <> "\n#{a} -> b")
    |> part1()
  end
end

contents = File.read!("./input.txt") |> String.trim()

a = contents |> AssemblyRequired.part1()
a |> IO.puts()

contents |> AssemblyRequired.part2(a) |> IO.puts()
