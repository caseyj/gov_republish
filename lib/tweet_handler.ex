defmodule TweetHandler do

  @behaviour Saxy.Handler
  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _, {_current_tag, content}) do
    {:ok, content}
  end


  def handle_event(:start_element, {tag_name, _}, {_, collector}) do
    if tag_name == "item" do
      {:ok, { tag_name , [%{} | collector]}}
    else
      {:ok, {tag_name, collector}}
    end

  end

  def handle_event(:end_element, _data, state) do
    {:ok, state}
  end

  def handle_event(:characters, content, {current_tag, collector}) do
    case collector do
      [] -> {:ok, {current_tag, collector}}
      _->
        [ current_collection | remaining_collection] = collector
        updated_collection = case current_tag do
          "title" -> Map.put(current_collection, "content", content)
          "dc:creator" -> Map.put(current_collection, "author", content)
          "pubDate" -> Map.put(current_collection, "publish_timestamp", content)
          "guid" -> Map.put(current_collection, "post_id", Utils.get_id(content))
          _ -> current_collection
        end
        {:ok, {"item", [ updated_collection | remaining_collection ]}}
    end
  end

end
