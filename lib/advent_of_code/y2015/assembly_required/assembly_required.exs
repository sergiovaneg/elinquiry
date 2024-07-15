alias AdventOfCode.Y2015.AssemblyRequired

defmodule AdventOfCode.Y2015.AssemblyRequired do
  defp safe_query(operand, registry, cache) do
    if Regex.match?(~r/[0-9]+/, operand) do
      {operand |> String.to_integer(), cache}
    else
      cache = registry[operand].(registry, cache)
      {cache[operand], cache}
    end
  end

  defp parse_instruction(line) do
    operands = line |> String.split(~r/( -> | )/)
    target = operands |> List.last()

    case operands |> length() do
      2 ->
        %{
          target => fn registry, cache ->
            if cache |> Map.has_key?(target) do
              cache
            else
              {num, cache} =
                operands
                |> List.first()
                |> safe_query(registry, cache)

              cache |> Map.put(target, num)
            end
          end
        }

      # Only 'NOT' fits this pattern
      3 ->
        %{
          target => fn registry, cache ->
            if cache |> Map.has_key?(target) do
              cache
            else
              {x, cache} = operands |> Enum.at(1) |> safe_query(registry, cache)

              cache
              |> Map.put(
                target,
                x
                |> Bitwise.bnot()
                |> Bitwise.band(0xFFFF)
              )
            end
          end
        }

      4 ->
        %{
          target => fn registry, cache ->
            if cache |> Map.has_key?(target) do
              cache
            else
              {x, cache} = operands |> Enum.at(0) |> safe_query(registry, cache)
              {y, cache} = operands |> Enum.at(2) |> safe_query(registry, cache)

              res =
                case operands |> Enum.at(1) do
                  "AND" ->
                    x |> Bitwise.band(y)

                  "OR" ->
                    x |> Bitwise.bor(y)

                  "LSHIFT" ->
                    x
                    |> Bitwise.bsl(y)
                    |> Bitwise.band(0xFFFF)

                  "RSHIFT" ->
                    x
                    |> Bitwise.bsr(y)
                    |> Bitwise.band(0xFFFF)
                end

              cache |> Map.put(target, res)
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
      |> Enum.reduce(%{}, &Map.merge/2)

    registry["a"].(registry, %{})["a"]
  end

  def part2(contents, a) do
    contents
    |> String.split("\n")
    |> Enum.map(fn x ->
      if(x |> String.ends_with?("-> b")) do
        "#{a} -> b"
      else
        x
      end
    end)
    |> Enum.join("\n")
    |> part1()
  end
end

contents = File.read!("./input.txt") |> String.trim()

a =
  contents
  |> AssemblyRequired.part1()

a |> IO.puts()

contents |> AssemblyRequired.part2(a) |> IO.puts()
