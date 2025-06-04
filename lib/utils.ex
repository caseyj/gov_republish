defmodule Utils do
  @moduledoc """
  General utilities for the GovRepublish project
  """

  @doc """
  A utility to get the components of a unique post ID from an RSS document.

  ## Examples

     iex> get_id("https://nitter.privacydev.net/JCParking/status/1889283372192514151#m")
     "JCParking_1889283372192514151"
  """
  def get_id(str) do
    components =
      String.replace(str, "#m", "", trim: true)
      |> String.split("/", trim: true)
      |> List.to_tuple()

    if tuple_size(components) != 5 do
      ""
    else
      "#{_get_account_name(components)}_#{_get_id_number(components)}"
    end
  end

  def _get_id_number(str_components) do
    elem(str_components, 4)
  end

  def _get_account_name(str_components) do
    elem(str_components, 2)
  end

  @doc """
  Parses a string based date into a useable datetime data structure.

  ## Examples

      iex> parse_date_to_map("Mon, 10 Feb 2025 18:28:16 GMT", %{}, "publish_timestamp")
      %{"publish_timestamp"=>~U[2025-02-10 18:28:16Z]}

      iex> Utils.parse_date_to_map("Not a Date", %{}, "publish_timestamp")
      %{:error=>["Unable to parse date for input \"Not a Date\", resulting error: \"Could not parse \"Not a Date\"\""]}
  """
  def parse_date_to_map(date_str, collecting_map, map_key) do
    {status, result} = DateTimeParser.parse_datetime(date_str)

    potential_error =
      "Unable to parse date for input \"#{date_str}\", resulting error: \"#{result}\""

    case status do
      :ok ->
        Map.put(collecting_map, map_key, result)

      :error ->
        Map.update(collecting_map, :error, [potential_error], fn data ->
          data ++ [potential_error]
        end)
    end
  end

  @spec url_or_file(binary() | URI.t()) ::
          {:filepath, nil | binary()} | {:url, binary() | URI.t()}
  @doc """
  Utility which allows us to quickly determine if a provided string is a filepath or a URI
  Usually only used in data source functions, we are expecting its only these two possibilities for now

  Returns `{:filepath, "/example/file/path.txt"}|{:url, "http://example.com"}`

  ## Examples

      iex> Utils.url_or_file("/example/file/path.txt")
      {:filepath, "/example/file/path.txt"}

      iex> Utils.url_or_file("http://example.com")
      {:url, "http://example.com"}
  """
  def url_or_file(string) do
    case URI.parse(string) do
      %URI{scheme: nil, path: path} -> {:filepath, path}
      %URI{scheme: _scheme, path: _path} -> {:url, string}
    end
  end

  @spec decide_http_success(any(), {:error, map()} | {:ok, map()}) ::
          {:error, <<_::64, _::_*8>>} | {:ok, any()}
  @doc """
  Decides whether an  HTTP request was successful.

  A 200-299 response code will give an :ok, 300+ will give :error
  """
  def decide_http_success(endpoint, {status, response}) do
    case {status, response} do
      {:ok, response} when response.status_code >= 200 and response.status_code < 300 ->
        {:ok, response.body}

      {:ok, response} when response.status_code >= 300 ->
        {
          :error,
          "Error requesting data from URL #{endpoint} with non 2XX status code #{response.status_code} and content \"#{response.body}\""
        }

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error retrieving data from src #{endpoint}, error msg \"#{reason}\""}
    end
  end

  @spec map_append_lists(map(), any(), list()) :: map()
  @doc """
  function automates adding elements to a map between arbitrary keys and lists at that key.

  Assumes the default value for any key of a map is an empty list
  """
  def map_append_lists(map, key, list) do
    Map.put(map, key, Map.get(map, key, []) ++ list)
  end

  def remove_nils_from_map(map) do
    Enum.reduce(map, %{}, fn ({k, v}, acc) ->
      if v != nil do
        Map.put(acc,k, v)
      else
        acc
      end
    end)
  end

  @doc """
  Function that checks a map has all required keys.
  """
  def map_contains_required_keys(source_map, required_keys) do
    key_list = Map.keys(source_map)
    missing_keys = Enum.reduce(required_keys, [], fn (key, acc) ->
      if Enum.member?(key_list, key) do
        acc
      else
        acc++[key]
      end
    end)
    if Enum.count(missing_keys) == 0 do
      {:ok, source_map}
    else
      {:error, "Keys missing: #{Enum.join(missing_keys, ", ")}"}
    end
  end

end
