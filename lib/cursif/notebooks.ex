defmodule Cursif.Notebooks do
  @moduledoc """
  The Notebooks context.
  """

  import Ecto.Query, warn: false
  alias Cursif.Repo

  alias Cursif.Notebooks.Notebook
  alias Cursif.Accounts.{User}
  alias Cursif.Accounts

  @doc """
  Returns the list of notebooks available to a user.

  ## Examples

      iex> list_notebooks()
      [%Notebook{}, ...]

  """
  @spec list_notebooks(User.t()) :: list(Notebook.t())
  def list_notebooks(%User{id: user_id}) do
    query = from n in Notebook,
                 left_join: c in assoc(n, :collaborators),
                 where: n.owner_id == ^user_id or c.id == ^user_id

    Repo.all(query) |> Repo.preload([:macros, :collaborators, pages: [:author]])
  end

  @doc """
  Gets a single notebook by its `id`.

  Raises `Ecto.NoResultsError` if the Notebook does not exist.

  Associations can be preloaded by passing a list of associations to the
  `:preloads` option.

  ## Examples

      iex> get_notebook!(123)
      %Notebook{}

      iex> get_notebook!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_notebook!(binary()) :: Notebook.t()
  def get_notebook!(id, opts \\ [])

  def get_notebook!(id, [user: user] = opts) do
    query = from n in Notebook,
                 left_join: c in assoc(n, :collaborators),
                 where: n.id == ^id and (n.owner_id == ^user.id or c.id == ^user.id)

    get_notebook!(id, Keyword.put(opts, :query, query))
  end

  def get_notebook!(id, opts) do
    query = Keyword.get(opts, :query, Notebook)
    preloads = Keyword.get(opts, :preloads, [:macros, :collaborators, pages: [:author]])

    Repo.get!(query, id) |> Repo.preload(preloads)
  end

  @doc """
  Creates a notebook.

  ## Examples

      iex> create_notebook(%{field: value})
      {:ok, %Notebook{}}

      iex> create_notebook(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_notebook(map()) :: {:ok, Notebook.t()} | {:error, %Ecto.Changeset{}}
  def create_notebook(attrs \\ %{}) do
    %Notebook{}
    |> Notebook.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notebook.

  ## Examples

      iex> update_notebook(notebook, %{field: new_value})
      {:ok, %Notebook{}}

      iex> update_notebook(notebook, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_notebook(Notebook.t(), map()) :: {:ok, Notebook.t()} | {:error, %Ecto.Changeset{}}
  def update_notebook(%Notebook{} = notebook, attrs) do
    notebook
    |> Notebook.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notebook.

  ## Examples

      iex> delete_notebook(notebook)
      {:ok, %Notebook{}}

      iex> delete_notebook(notebook)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_notebook(Notebook.t()) :: {:ok, Notebook.t()} | {:error, %Ecto.Changeset{}}
  def delete_notebook(%Notebook{} = notebook) do
    Repo.delete(notebook)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notebook changes.

  ## Examples

      iex> change_notebook(notebook)
      %Ecto.Changeset{data: %Notebook{}}

  """
  @spec change_notebook(Notebook.t(), map()) :: %Ecto.Changeset{}
  def change_notebook(%Notebook{} = notebook, attrs \\ %{}) do
    Notebook.changeset(notebook, attrs)
  end

  @doc """
  Returns the owner of a notebook.

  ## Examples

      iex> get_owner!(%{owner_id: owner_id, owner_type: "user"})
      %User{}
  """
  @spec get_owner!(Notebook.t()) :: User.t()
  def get_owner!(%Notebook{owner_id: owner_id, owner_type: "user"}),
      do: Accounts.get_user!(owner_id)
end
