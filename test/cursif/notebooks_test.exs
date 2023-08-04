defmodule Cursif.NotebooksTest do
  use Cursif.DataCase

  import Cursif.{NotebooksFixtures, AccountsFixtures}

  alias Cursif.Notebooks
  alias Cursif.Notebooks.Notebook


  describe "notebooks" do
    @invalid_attrs %{
      title: nil,
      description: nil,
    }

    test "list_notebooks/0 returns all notebooks" do
      user = user_fixture()
      notebook = notebook_fixture(%{
        owner_type: "user",
        owner_id: user.id,
      })

      assert Notebooks.list_notebooks() == [notebook]
    end

    test "get_notebook!/1 returns the notebook with given id" do
      user = user_fixture()
      notebook = notebook_fixture(%{
        owner_type: "user",
        owner_id: user.id,
      })
      assert Notebooks.get_notebook!(notebook.id) == notebook
    end

    test "create_notebook/1 with valid data creates a notebook" do
      user = user_fixture()

      valid_attrs = %{
        title: "some title",
        description: "some description",
        owner_type: "user",
        owner_id: user.id,
      }

      assert {:ok, %Notebook{} = notebook} = Notebooks.create_notebook(valid_attrs)

      assert notebook.description == "some description"
      assert notebook.title == "some title"
    end

    test "create_notebook/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notebooks.create_notebook(@invalid_attrs)
    end

    # Something might be wrong with the update_notebook function 
    test "update_notebook/2 with valid data updates the notebook" do
      user = user_fixture()

      notebook = notebook_fixture(%{
        owner_type: "user",
        owner_id: user.id,
      })

      title = "some updated title"
      description = "some updated description"

      assert {:ok, %Notebook{} = notebook} = Notebooks.update_notebook(notebook, %{title: title, description: description})
      assert notebook.description == description
      assert notebook.title == title
    end

    test "update_notebook/2 with invalid data returns error changeset" do
      user = user_fixture()

      notebook = notebook_fixture(%{
        owner_type: "user",
        owner_id: user.id,
      })

      assert {:error, %Ecto.Changeset{}} = Notebooks.update_notebook(notebook, @invalid_attrs)
    end

    test "delete_notebook/1 deletes the notebook" do
      user = user_fixture()

      notebook = notebook_fixture(%{
        owner_type: "user",
        owner_id: user.id,
      })

      assert {:ok, %Notebook{}} = Notebooks.delete_notebook(notebook)
      assert_raise Ecto.NoResultsError, fn -> Notebooks.get_notebook!(notebook.id) end
    end
  end
end
