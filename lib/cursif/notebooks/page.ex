defmodule Cursif.Notebooks.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cursif.Accounts.User
  alias Cursif.Notebooks.Notebook
  alias Cursif.Repo

  @type t :: %__MODULE__{
               title: String.t(),
               content: String.t(),
               parent_id: binary(),
               parent_type: String.t(),
               author: User.t(),
               children: [Page.t()],

               # Timestamps
               inserted_at: any(),
               updated_at: any()
             }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pages" do
    field :title, :string
    field :content, :string
    field :parent_id, :binary_id
    field :parent_type, :string

    belongs_to :author, User, foreign_key: :author_id
    has_many :children, __MODULE__, foreign_key: :parent_id, where: [parent_type: "page"]

    timestamps()
  end

  @doc false
  @spec changeset(Page.t(), %{}) :: Page.t()
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :content, :author_id, :parent_id, :parent_type])
    |> validate_required([:title, :author_id, :parent_id, :parent_type])
    |> validate_association()
  end

  @doc false
  @spec update_changeset(Page.t(), %{}) :: Page.t()
  def update_changeset(page, attrs) do
    page |> cast(attrs, [:title, :content, :author_id])
  end

  # TODO: See if there's a better way to handle that. Maybe a custom validator?
  defp validate_association(%{changes: %{parent_type: "notebook", parent_id: parent_id}} = changeset) do
    Repo.get!(Notebook, parent_id)
    changeset
  rescue
    Ecto.NoResultsError -> add_error(changeset, :parent_id, "is not a valid notebook")
  end

  defp validate_association(%{changes: %{parent_type: "page", parent_id: parent_id}} = changeset) do
    Repo.get!(Page, parent_id)
    changeset
  rescue
    Ecto.NoResultsError -> add_error(changeset, :parent_id, "is not a valid page")
  end

  defp validate_association(changeset) do
    add_error(changeset, :parent_type, "is not a valid parent type")
  end
end
