defmodule SqliteClient do

  @doc """
  Helper function that will insert an arbitrary record into the database.
  """
  def insert(module, struct_format, struct_data) do
    changeset = module.changeset(struct_format, struct_data)

    case changeset.valid? do
      true -> GovRepublish.Repo.insert(changeset)
      false -> {:error, changeset.errors}
    end
  end

  @doc """
  Helper function to run a query and get all results.
  """
  def select(query) do
    GovRepublish.Repo.all(query)
  end

  @doc """
  Helper function which runs an update operation on a record.
  """
  def update_record(original_data, struct_data) do
    changeset = Ecto.Changeset.change(original_data, struct_data)
    case changeset.valid? do
      true -> GovRepublish.Repo.update(changeset)
      false -> {:error, changeset.errors}
    end
  end

end
