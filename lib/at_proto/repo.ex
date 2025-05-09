defmodule AtProto.Repo do
  @moduledoc """
  Tools for interacting with BlueSky Repos defined by the standards in
  https://docs.bsky.app/docs/category/http-reference
  """

  @doc """
  Creates a new record at a repository.

  From https://docs.bsky.app/docs/api/com-atproto-repo-create-record
  """
  def create_record(did, record_type, record, record_key \\ nil, validate \\ nil, swap_commit \\ nil) do
    action = "com.atproto.repo.createRecord"
    uri = "/xrpc/com.atproto.repo.createRecord"

    %{
      :uri=> uri,
      :method=> :POST,
      :action => action,
      :request => %{
        :repo=> did,
        :collection=> record_type,
        :record=>record,
        :rkey=>record_key,
        :validate=>validate,
        :swapCommit=>swap_commit
      }
    }
  end

  @doc """
  Lists records for a given repository and record type.

  From https://docs.bsky.app/docs/api/com-atproto-repo-list-records
  """
  def list_records(did, record_type, limit \\ 50, cursor \\ nil, reverse \\ false) do
    action = "com.atproto.repo.listRecords"
    uri = "/xrpc/com.atproto.repo.listRecords"

    %{
      :uri=> uri,
      :method=> :GET,
      :action => action,
      :request => %{
        :repo=> did,
        :collection=> record_type,
        :limit => limit,
        :cursor => cursor,
        :reverse=> reverse
      }
    }
  end

end
