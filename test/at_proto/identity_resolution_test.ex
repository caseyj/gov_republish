defmodule AtProto.IdentityResolutionTest do
  use ExUnit.Case

  test "Checking client equality" do
    sample_data = %{
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
    }
  end
end
