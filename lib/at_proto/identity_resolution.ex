defmodule AtProto.IdentityResolution do
  @doc """
  Function that shows that atleast one handle in a DID Doc matches the provided handle

  This is a utility function suggested by the ATProtocol documentation
  to ensure that an acquired DID Doc matches the provided handle for a user.

  ## Examples

      iex> handle_in_doc(%{"alsoKnownAs"=>["at://hello.bsky.social"]}, "hello.bsky.social")
      true
      iex> handle_in_doc(%{"alsoKnownAs"=>["at://hello.bsky.social"]}, "not_me.bsky.social")
      false
  """
  def handle_in_doc(did_doc, handle) do
    Enum.any?(Map.get(did_doc, "alsoKnownAs"), fn aka ->
      String.replace(aka, "at://", "") == handle
    end)
  end

  @doc """
  Function that shows the acquired DID Doc is the correct one for a user.

  This is a utility function suggested by the ATProtocol documentation
  to ensure that an acquired DID Doc matches the provided handle for a user.

  ## Examples

      iex> did_equals_doc_id(%{"id"=>"did:plc:jlpacvjn6h3u4mum5eg7po2m"}, "did:plc:jlpacvjn6h3u4mum5eg7po2m")
      true
      iex> did_equals_doc_id(%{"id"=>"did:plc:jlpacvjn6h3u4mum5eg7po2m"}, "did:plc:wrong_one")
      false
  """
  def did_equals_doc_id(did_doc, did) do
    Map.get(did_doc, "id") == did
  end

  @doc """
  The ATProtocol requires getting the DID that owns a particular handle on a network.

  This function goes and acquires said handle.
  """
  def resolve_handle_to_did(handle) do
    url = "https://#{handle}/.well-known/atproto-did"
    {success, response} = HTTPoison.get(url)
    Utils.decide_http_success(url, {success, response})
  end

  @doc """
  ATProtocol requires getting the full DID Document belonging to a DID

  This function gets the DID Document from the PLC directory service and provides the document as a useable map.
  """
  def resolve_did_to_did_doc(did) do
    url = "https://plc.directory/#{did}"
    {success, response} = Utils.decide_http_success(url, HTTPoison.get(url))

    case {success, response} do
      {:ok, response} -> Poison.decode(response)
      _ -> {success, response}
    end
  end

  @doc """
  Performs the actual log in process using a username, password, and endpoint triplet.
  """
  def get_session_obj(username, pw, endpoint) do
    url = "#{endpoint}/xrpc/com.atproto.server.createSession"

    {success, response} =
      Utils.decide_http_success(
        url,
        HTTPoison.post(
          url,
          Poison.encode!(%{
            "identifier" => "#{username}",
            "password" => "#{pw}"
          }),
          %{"content-type" => "application/json"}
        )
      )

    case {success, response} do
      {:ok, response} -> Poison.decode(response)
      _ -> {success, response}
    end
  end

  @doc """
  Utility function to quickly get the service endpoint for an AtProto PDS

  ## Examples
      iex> get_service(%{"service"=>[%{
          "id" => "#atproto_pds",
          "serviceEndpoint" => "https://polypore.us-west.host.bsky.network",
          "type" => "AtprotoPersonalDataServer"
        }]})
      "https://polypore.us-west.host.bsky.network"
  """
  def get_service(did_doc) do
    Enum.reduce(Map.get(did_doc, "service"), "", fn data, acc ->
      if Map.get(data, "id") == "#atproto_pds" do
        Map.get(data, "serviceEndpoint")
      else
        acc
      end
    end)
  end

  @doc """
  Function that handles the process of logging in to an AtProto PDS

  Returns an authenticated identity document
  """
  def login_flow(username, pw) do
    {:ok, did} = resolve_handle_to_did(username)
    {:ok, did_doc} = resolve_did_to_did_doc(did)
    get_session_obj(username, pw, get_service(did_doc))
  end
end
