defmodule SqliteClient do

  def insert(module, struct_format, struct_data) do
    changeset = module.changeset(struct_format, struct_data)
    case changeset.valid? do
      true -> GovRepublish.Repo.insert(changeset)
      false -> {:error, changeset.errors}
    end
  end

end
