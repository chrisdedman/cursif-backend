defmodule CursifWeb.Schema.AccountTypesTest do
  use CursifWeb.ConnCase

  import Cursif.AccountsFixtures

  setup [:create_unique_user, :authenticate]

  describe "queries" do
    test "current user", %{conn: conn, current_user: current_user, token: token} do
      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> post("/api", %{
        "query" => """
          query {
            me {
              id
              username
              email
              first_name
              last_name
            }
          }
        """
      })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "me" => %{
                   "id" => current_user.id,
                   "username" => current_user.username,
                   "email" => current_user.email,
                   "first_name" => current_user.first_name,
                   "last_name" => current_user.last_name,
                 }
               }
             }
    end
  end

  describe "authentification" do
    test "successful registration", %{conn: conn} do
      user = unique_user_attributes()

      conn = post(conn, "/api", %{
        "query" => """
          mutation Login($email: String!, $username: String!, $password: String!) {
            register(email: $email, username: $username, password: $password) {
              username
            }
          }
        """,
        "variables" => %{email: user.email, username: user.username, password: user.password}
      })

      assert json_response(conn, 200) == %{
        "data" => %{
          "register" => %{
            "username" => user.username
          }
        }
      }
    end

    setup [:create_unique_user]
    test "successful login", %{conn: conn, user: user, password: password} do
      conn = post(conn, "/api", %{
        "query" => """
          mutation Login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
              user {
                username
              }
            }
          }
        """,
        "variables" => %{email: user.email, password: password}
      })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "login" => %{
                   "user" => %{
                     "username" => user.username
                   }
                 }
               }
             }
    end
  end
end