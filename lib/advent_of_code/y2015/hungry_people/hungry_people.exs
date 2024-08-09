alias AdventOfCode.Y2015.HungryPeople

defmodule AdventOfCode.Y2015.HungryPeople do
  @lambda 1.0e9
  @patience 100_000
  @max_iter 1_000_000_000

  @typep ingredient :: %{binary() => integer()}
  @typep recipe :: %{ingredient() => non_neg_integer()}

  @spec parse_ingredient(binary()) :: ingredient
  defp parse_ingredient(line) do
    ~r/(?<name>[a-z]+) (?<val>-*[0-9]+)/
    |> Regex.scan(line, capture: :all_names)
    |> Map.new(fn [name, num] -> {name, num |> String.to_integer()} end)
  end

  @spec qty_constraint(recipe()) :: non_neg_integer()
  defp qty_constraint(rec) do
    rec
    |> Map.values()
    |> Enum.sum()
    |> Kernel.-(100)
    |> abs()
  end

  @spec cal_constraint(recipe()) :: non_neg_integer()
  defp cal_constraint(rec) do
    rec
    |> Enum.map(fn {ing, qty} -> qty * ing["calories"] end)
    |> Enum.sum()
    |> Kernel.-(500)
    |> abs()
  end

  @spec score_recipe(recipe()) :: integer()
  defp score_recipe(rec) do
    rec
    |> Enum.map(fn {ing, qty} ->
      ing
      |> Enum.map(fn {name, val} -> {name, val * qty} end)
    end)
    |> List.flatten()
    |> Enum.group_by(fn {k, _} -> k end, fn {_, v} -> v end)
    |> Map.drop(["calories"])
    |> Enum.reduce(1, fn {_, vals}, acc ->
      vals |> Enum.sum() |> Kernel.max(0) |> Kernel.*(acc)
    end)
  end

  @spec gen_candidate_recipes(recipe()) :: [recipe(), ...]
  defp gen_candidate_recipes(rec) do
    ings = rec |> Map.keys()

    ((ings
      |> Enum.map(fn ing -> rec |> Map.put(ing, rec[ing] - 1) end)) ++
       (ings
        |> Enum.map(fn ing -> rec |> Map.put(ing, rec[ing] + 1) end)) ++
       (ings
        |> Enum.map(fn ing1 ->
          ings
          |> Enum.filter(&(&1 != ing1))
          |> Enum.map(fn ing2 ->
            rec |> Map.put(ing1, rec[ing1] - 1) |> Map.put(ing2, rec[ing2] + 1)
          end)
        end)
        |> List.flatten()))
    |> Enum.filter(fn rec_cand ->
      rec_cand != rec && rec_cand |> Map.values() |> Enum.all?(&(&1 >= 0))
    end)
  end

  @spec get_starting_recipe(binary()) :: recipe()
  defp get_starting_recipe(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(fn line -> {line |> parse_ingredient(), 20} end)
    |> Map.new()
  end

  defp search(initial_recipe, score_fn) do
    result =
      1..@max_iter
      |> Enum.reduce_while(
        {score_fn.(initial_recipe), initial_recipe, 0, [], []},
        fn _, {best_score, last_recipe, patience_cnt, taboo, queue} ->
          # Update taboo list
          taboo = [last_recipe | taboo]

          # Get non-taboo candidates
          candidates =
            last_recipe
            |> gen_candidate_recipes()
            |> Enum.filter(fn x -> x not in taboo end)

          # Get best candidate (default to last valid)
          next_score =
            candidates
            |> Enum.map(score_fn)
            |> Enum.max(fn ->
              best_score
            end)

          candidates =
            candidates
            |> Enum.filter(fn x -> score_fn.(x) == next_score end)

          next_recipe =
            candidates
            |> List.first()

          cond do
            next_recipe == nil or next_score < best_score ->
              if Enum.empty?(queue) or patience_cnt >= @patience do
                {:halt, best_score}
              else
                [next_recipe | queue] = queue
                {:cont, {best_score, next_recipe, patience_cnt + 1, taboo, queue}}
              end

            best_score == next_score ->
              if patience_cnt >= @patience do
                {:halt, next_score}
              else
                {:cont,
                 {next_score, next_recipe, patience_cnt + 1, taboo,
                  (queue ++ candidates) |> Enum.uniq()}}
              end

            true ->
              {:cont, {next_score, next_recipe, 0, [], []}}
          end
        end
      )

    if result |> is_tuple() do
      result |> Enum.at(0)
    else
      result
    end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    rec = contents |> get_starting_recipe()

    score_fn = fn x ->
      score_recipe(x) - @lambda * qty_constraint(x)
    end

    rec |> search(score_fn)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    rec = contents |> get_starting_recipe()

    score_fn = fn x ->
      score_recipe(x) - @lambda * (qty_constraint(x) + cal_constraint(x))
    end

    rec |> search(score_fn)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> HungryPeople.part1()
|> IO.puts()

contents
|> HungryPeople.part2()
|> IO.puts()
