defmodule Idiom.PluralPreprocess do
  @moduledoc """
  Preprocessor for language-specific pluralization rules.

  Idiom uses Unicode CLDR plural rules, which they provide for download as a JSON file. This is stored in our `priv` directory.
  The `Plural` and `PluralPreprocess` modules use these definitions to generate Elixir ASTs representing a `cond` statement for each language, which are then
  used at compile-time to generate functions.
  This module builds on a lexer and parser inside the `src/` directory to generate the ASTs.
  """

  @doc """
  Parses a list of plural rules and converts them into a `:cond` expression, with the clauses sorted by plural suffix.

  ## Examples

  ```elixir
  iex> Idiom.PluralPreprocess.parse_rules([{"pluralRule-count-one", "n = 1"}])
  {:cond, [], [[do: [{:->, [], [[{:==, [], [{:n, [], nil}, 1]}], "one"]}]]]}
  ```
  """
  @spec parse_rules(list({String.t(), String.t()})) :: term()
  def parse_rules(rules) do
    Enum.map(rules, fn {"pluralRule-count-" <> suffix, rule} ->
      {:ok, ast} = parse(rule)
      {suffix, ast}
    end)
    |> Enum.sort(&suffix_sorter/2)
    |> rules_to_cond()
  end

  def suffix_sorter({"zero", _}, _), do: true
  def suffix_sorter({"one", _}, {other, _}) when other in ["two", "few", "many", "other"], do: true
  def suffix_sorter({"two", _}, {other, _}) when other in ["few", "many", "other"], do: true
  def suffix_sorter({"few", _}, {other, _}) when other in ["many", "other"], do: true
  def suffix_sorter({"many", _}, {other, _}) when other in ["other"], do: true
  def suffix_sorter(_, _), do: false

  defp parse([]), do: {:ok, []}
  defp parse(tokens) when is_list(tokens), do: :plural_parser.parse(tokens)

  defp parse(definition) when is_binary(definition) do
    {:ok, tokens, _} =
      definition
      |> String.to_charlist()
      |> :plural_lexer.string()

    parse(tokens)
  end

  defp rules_to_cond(rules) do
    clauses =
      Enum.map(rules, fn {suffix, ast} ->
        rule_to_clause(ast, suffix)
      end)

    {:cond, [], [[do: clauses]]}
  end

  defp rule_to_clause(nil, suffix), do: {:->, [], [[true], suffix]}
  defp rule_to_clause(ast, suffix), do: {:->, [], [[ast], suffix]}
end
