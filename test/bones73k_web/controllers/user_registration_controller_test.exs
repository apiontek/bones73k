defmodule Bones73kWeb.UserRegistrationControllerTest do
  use Bones73kWeb.ConnCase, async: true

  import Bones73k.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Register</h2>"
      assert response =~ "Register</button>"
      assert response =~ "Log in</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      to = Routes.user_registration_path(conn, :new)
      conn = conn |> log_in_user(user_fixture()) |> get(to)
      assert redirected_to(conn) == "/"
    end
  end
end
