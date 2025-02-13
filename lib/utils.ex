defmodule Utils do
  def get_id(str) do
    components =
      String.replace(str, "#m", "", trim: true)
      |> String.split("/", trim: true)
      |> List.to_tuple()

    if tuple_size(components) != 5 do
      ""
    else
      "#{get_account_name(components)}_#{get_id_number(components)}"
    end
  end

  def get_id_number(str_components) do
    elem(str_components, 4)
  end

  def get_account_name(str_components) do
    elem(str_components, 2)
  end

  def parse_date(date_str) do
    {status, result} = DateTimeParser.parse(date_str)

    case status do
      :ok -> Calendar.strftime(result, "%s")
      :error -> IO.puts(result)
    end
  end

end
