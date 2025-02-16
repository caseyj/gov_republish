defmodule AtProto.IdentityResolution do

  def handle_in_doc(did_doc, handle) do
    Enum.any?(Map.get(did_doc, "alsoKnownAs"), fn aka -> String.replace(aka, "at://", "") == handle end)
  end

  def did_equals_doc_id(did_doc, did) do
    Map.get(did_doc, "id") == did
  end

  def resolve_handle_to_did(handle) do
    case HTTPoison.get("https://#{handle}/.well-known/atproto-did") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      _-> IO.puts("error on requesting resolving handle")
    end

  end

  @spec resolve_did_to_did_doc(any()) :: any()
  def resolve_did_to_did_doc(did) do
    case HTTPoison.get("https://plc.directory/#{did}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      _-> IO.puts("error on resolving did doc")
    end
  end

  def get_session_obj(username, pw, endpoint) do
    case HTTPoison.post(
      "#{endpoint}/xrpc/com.atproto.server.createSession",
      Poison.encode!(
        %{
          "identifier"=>"#{username}",
          "password"=>"#{pw}"}),
      %{"content-type"=>"application/json"}
    ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> Poison.decode!(body)
      _ -> IO.puts("Error on login flow")
    end
  end

  def get_service(did_doc) do
    Map.get(hd(Map.get(did_doc, "service")), "serviceEndpoint")
  end

  def login_flow(username, pw) do
    did = resolve_handle_to_did(username)
    did_doc = resolve_did_to_did_doc(did) |> Poison.decode!()
    #did_doc
    # forcing to use the first available service for now
    get_session_obj(username, pw, get_service(did_doc))
  end

end
