defmodule AtProto.IdentityResolutionTest do
  alias AtProto.IdentityResolution
  require Mock
  use ExUnit.Case
  import Mock

  for {did_doc, handle, expected} <-[
    {["at://hello.bsky.social"], "hello.bsky.social", true},
    {["at://hello.bsky.social"], "not_me.bsky.social", false},
    {["at://hello.bsky.social", "at://not_me.bsky.social"], "not_me.bsky.social", true},
  ] do
    test "Show handle_in_doc verifies handles correctly #{did_doc} and handle #{handle}" do
      assert IdentityResolution.handle_in_doc(%{"alsoKnownAs"=>unquote(did_doc)}, unquote(handle)) == unquote(expected)
    end
  end

  for {did_doc, handle, expected} <-[
    {"did:plc:jlpacvjn6h3u4mum5eg7po2m", "did:plc:jlpacvjn6h3u4mum5eg7po2m", true},
    {"did:plc:jlpacvjn6h3u4mum5eg7po2m", "did:plc:wrong_one", false}
  ] do
    test "Show did_equals_doc_id verifies handles correctly #{did_doc} and handle #{handle}" do
      assert IdentityResolution.did_equals_doc_id(%{"id"=>unquote(did_doc)}, unquote(handle)) == unquote(expected)
    end
  end

  test "Show get_service gets a service endpoint" do
    assert IdentityResolution.get_service(%{
      "@context" => [
        "https://www.w3.org/ns/did/v1",
        "https://w3id.org/security/multikey/v1",
        "https://w3id.org/security/suites/secp256k1-2019/v1"
      ],
      "alsoKnownAs" => ["at://jcasey-tech.bsky.social"],
      "id" => "did:plc:jlpacvjn6h3u4mum5eg7po2m",
      "service" => [
        %{
          "id" => "#atproto_pds",
          "serviceEndpoint" => "https://polypore.us-west.host.bsky.network",
          "type" => "AtprotoPersonalDataServer"
        }
      ],
      "verificationMethod" => [
        %{
          "controller" => "did:plc:jlpacvjn6h3u4mum5eg7po2m",
          "id" => "did:plc:jlpacvjn6h3u4mum5eg7po2m#atproto",
          "publicKeyMultibase" => "zQ3shWUjWh7AqRmTBjGDBhBfWsnoXt9V4MkQt4VvfjxmmPnAd",
          "type" => "Multikey"
        }
      ]
    }) == "https://polypore.us-west.host.bsky.network"
  end

  for {status, expected} <- [
    {200, :ok},
    {299, :ok},
    {300, :error},
    {400, :error},
    {500, :error},
    {nil, :error}
  ] do
    test "Show resolve_handle_to_did functions for response vals #{status}" do
      with_mock HTTPoison,
        get: fn _a ->
          if unquote(status) do
            {:ok, %HTTPoison.Response{status_code: unquote(status)}}
          else
            {:error, %HTTPoison.Error{}}
          end
        end do
          {success, _} = IdentityResolution.resolve_handle_to_did("hello_world")
          assert success == unquote(expected)
        end
    end
  end

  for {status, first_expected, is_garbage, second_expected} <- [
    {200, :ok, false, :ok},
    {299, :ok, false, :ok},
    {200, :ok, true, :error},
    {299, :ok, true, :error},
    {300, :error, false, :error},
    {400, :error, false, :error},
    {500, :error, false, :error},
    {nil, :error, false, :error},
  ] do
    test "Show resolve_did_to_did_doc is successful with code #{status}, and testing with garbage? #{is_garbage}"do
      with_mock HTTPoison,
        get: fn _a ->
          if unquote(status) do
            if unquote(is_garbage) do
              {:ok, %HTTPoison.Response{status_code: unquote(status), body: "<>assjdbal"}}
            else
              {:ok, %HTTPoison.Response{status_code: unquote(status), body: "{\"hello\":\"world\"}"}}
            end
          else
            {:error, %HTTPoison.Error{}}
          end
        end do
          {success, _} = IdentityResolution.resolve_did_to_did_doc("resolve_did_to_did_doc")
          assert success == unquote(second_expected)
        end
    end
  end

  for {status, first_expected, is_garbage, second_expected} <- [
    {200, :ok, false, :ok},
    {299, :ok, false, :ok},
    {200, :ok, true, :error},
    {299, :ok, true, :error},
    {300, :error, false, :error},
    {400, :error, false, :error},
    {500, :error, false, :error},
    {nil, :error, false, :error},
  ] do
    test "Show get_session_obj is successful with code #{status}, and testing with garbage? #{is_garbage}"do
      with_mock HTTPoison,
        post: fn _a, _b, _c ->
          if unquote(status) do
            if unquote(is_garbage) do
              {:ok, %HTTPoison.Response{status_code: unquote(status), body: "<>assjdbal"}}
            else
              {:ok, %HTTPoison.Response{status_code: unquote(status), body: "{\"hello\":\"world\"}"}}
            end
          else
            {:error, %HTTPoison.Error{}}
          end
        end do
          {success, _} = IdentityResolution.get_session_obj("uname", "pw", "hello")
          assert success == unquote(second_expected)
        end
    end
  end
end
