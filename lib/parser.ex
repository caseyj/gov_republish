defmodule Parser do

  def get_data(data_str) do
    Saxy.parse_string(data_str, TweetHandler, {nil, []})
  end

end
