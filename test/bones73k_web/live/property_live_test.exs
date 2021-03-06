defmodule Bones73kWeb.PropertyLiveTest do
  use Bones73kWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bones73k.AccountsFixtures

  alias Bones73k.Properties

  @create_attrs %{description: "some description", name: "some name", price: "120.5"}
  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    price: "456.7"
  }
  @invalid_attrs %{description: nil, name: nil, price: nil}

  defp fixture(:property, user) do
    create_attributes = Enum.into(%{user_id: user.id}, @create_attrs)
    {:ok, property} = Properties.create_property(create_attributes)
    property
  end

  describe "Index" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      property = fixture(:property, user)
      property_from_another_user = fixture(:property, user_fixture())

      %{
        conn: conn,
        property: property,
        property_from_another_user: property_from_another_user,
        user: user
      }
    end

    test "lists all properties", %{conn: conn, property: property} do
      {:ok, _index_live, html} = live(conn, Routes.property_index_path(conn, :index))

      assert html =~ "Listing Properties"
      assert html =~ property.description
    end

    test "saves new property", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      assert index_live |> element("a", "New Property") |> render_click() =~
               "New Property"

      assert_patch(index_live, Routes.property_index_path(conn, :new))

      assert index_live
             |> form("#property-form", property: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # update form attrs
      index_live
      |> form("#property-form", property: @update_attrs)
      |> render_change()

      # submit new form attrs
      index_live
      |> form("#property-form", property: @update_attrs)
      |> render_submit()

      # send modal close event & observe results
      send(index_live.pid, {:close_modal, true})
      html = render(index_live)

      assert_patched(index_live, Routes.property_index_path(conn, :index))
      assert html =~ "Property created successfully"
      assert html =~ "some updated description"
    end

    test "updates property in listing", %{conn: conn, property: property} do
      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      assert index_live |> element("#property-#{property.id} a", "Edit") |> render_click() =~
               "Edit Property"

      assert_patch(index_live, Routes.property_index_path(conn, :edit, property))

      assert index_live
             |> form("#property-form", property: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # update form attrs
      index_live
      |> form("#property-form", property: @update_attrs)
      |> render_change()

      # submit new form attrs
      index_live
      |> form("#property-form", property: @update_attrs)
      |> render_submit()

      # send modal close event & observe results
      send(index_live.pid, {:close_modal, true})
      html = render(index_live)

      assert_patched(index_live, Routes.property_index_path(conn, :index))
      assert html =~ "Property updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes property in listing", %{conn: conn, property: property} do
      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      assert index_live |> element("#property-#{property.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#property-#{property.id}")
    end

    test "can see property from from other user in listing",
         %{
           conn: conn,
           property_from_another_user: property
         } do
      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      assert has_element?(index_live, "#property-#{property.id}")
    end

    test "can't see edit action for property from other user in listing",
         %{
           conn: conn,
           property_from_another_user: property
         } do
      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      refute has_element?(index_live, "#property-#{property.id} a", "Edit")
    end

    test "as an admin, I can update property from other user in listing", %{
      conn: conn,
      property_from_another_user: property
    } do
      conn = log_in_user(conn, admin_fixture())

      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      assert index_live |> element("#property-#{property.id} a", "Edit") |> render_click() =~
               "Edit Property"

      assert_patch(index_live, Routes.property_index_path(conn, :edit, property))

      assert index_live
             |> form("#property-form", property: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # update form attrs
      index_live
      |> form("#property-form", property: @update_attrs)
      |> render_change()

      # submit new form attrs
      index_live
      |> form("#property-form", property: @update_attrs)
      |> render_submit()

      # send modal close event & observe results
      send(index_live.pid, {:close_modal, true})
      html = render(index_live)

      assert_patched(index_live, Routes.property_index_path(conn, :index))
      assert html =~ "Property updated successfully"
      assert html =~ "some updated description"
    end

    test "can't see delete action for property from other user in listing", %{
      conn: conn,
      property_from_another_user: property
    } do
      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      refute has_element?(index_live, "#property-#{property.id} a", "Delete")
    end

    test "as an admin, I can delete property from others in listing", %{
      conn: conn,
      property_from_another_user: property
    } do
      conn = log_in_user(conn, admin_fixture())

      {:ok, index_live, _html} = live(conn, Routes.property_index_path(conn, :index))

      assert index_live |> element("#property-#{property.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#property-#{property.id}")
    end

    test "can't edit property from other user in listing",
         %{
           conn: conn,
           property_from_another_user: property
         } do
      assert {:error, {:redirect, %{to: "/"}}} =
               live(conn, Routes.property_index_path(conn, :edit, property))
    end

    test "logs out when force logout on logged user", %{
      conn: conn
    } do
      user = user_fixture()
      conn = conn |> log_in_user(user)

      {:ok, index_live, html} = live(conn, Routes.property_index_path(conn, :index))

      assert html =~ "Listing Properties"
      assert render(index_live) =~ "Listing Properties"

      Bones73k.Accounts.logout_user(user)

      # Assert our liveview process is down
      ref = Process.monitor(index_live.pid)
      assert_receive {:DOWN, ^ref, _, _, _}
      refute Process.alive?(index_live.pid)

      # Assert our liveview was redirected, following first to /users/force_logout, then to "/"
      assert_redirect(index_live, "/users/force_logout")

      conn = get(conn, "/users/force_logout")
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redir_path)

      assert html_response(conn, 200) =~
               "You were logged out. Please login again to continue using our application."
    end

    test "doesn't log out when force logout on another user", %{
      conn: conn
    } do
      user1 = user_fixture()
      user2 = user_fixture()
      conn = conn |> log_in_user(user2)

      {:ok, index_live, html} = live(conn, Routes.property_index_path(conn, :index))

      assert html =~ "Listing Properties"
      assert render(index_live) =~ "Listing Properties"

      Bones73k.Accounts.logout_user(user1)

      # Assert our liveview is alive
      ref = Process.monitor(index_live.pid)
      refute_receive {:DOWN, ^ref, _, _, _}
      assert Process.alive?(index_live.pid)

      # If we are able to rerender the page it means nothing happened
      assert render(index_live) =~ "Listing Properties"
    end
  end

  describe "Show" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      property = fixture(:property, user)
      property_from_another_user = fixture(:property, user_fixture())

      %{
        conn: conn,
        property: property,
        property_from_another_user: property_from_another_user,
        user: user
      }
    end

    test "displays property", %{conn: conn, property: property} do
      {:ok, _show_live, html} = live(conn, Routes.property_show_path(conn, :show, property))

      assert html =~ "Show Property"
      assert html =~ property.description
    end

    test "updates property within modal", %{conn: conn, property: property} do
      {:ok, show_live, _html} = live(conn, Routes.property_show_path(conn, :show, property))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Property"

      assert_patch(show_live, Routes.property_show_path(conn, :edit, property))

      assert show_live
             |> form("#property-form", property: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # update form attrs
      show_live
      |> form("#property-form", property: @update_attrs)
      |> render_change()

      # submit new form attrs
      show_live
      |> form("#property-form", property: @update_attrs)
      |> render_submit()

      # send modal close event & observe results
      send(show_live.pid, {:close_modal, true})
      html = render(show_live)

      assert_patched(show_live, Routes.property_show_path(conn, :show, property))
      assert html =~ "Property updated successfully"
      assert html =~ "some updated description"
    end

    test "can't see edit action for property from another user in show page", %{
      conn: conn,
      property_from_another_user: property
    } do
      {:ok, show_live, _html} = live(conn, Routes.property_show_path(conn, :show, property))

      refute has_element?(show_live, "a", "Edit")
    end

    test "as an admin, can updates property from others within modal", %{
      conn: conn,
      property_from_another_user: property
    } do
      conn = log_in_user(conn, admin_fixture())

      {:ok, show_live, _html} = live(conn, Routes.property_show_path(conn, :show, property))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Property"

      assert_patch(show_live, Routes.property_show_path(conn, :edit, property))

      assert show_live
             |> form("#property-form", property: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # update form attrs
      show_live
      |> form("#property-form", property: @update_attrs)
      |> render_change()

      # submit new form attrs
      show_live
      |> form("#property-form", property: @update_attrs)
      |> render_submit()

      # send modal close event & observe results
      send(show_live.pid, {:close_modal, true})
      html = render(show_live)

      assert_patched(show_live, Routes.property_show_path(conn, :show, property))
      assert html =~ "Property updated successfully"
      assert html =~ "some updated description"
    end

    test "can't edit property from another user in show page", %{
      conn: conn,
      property_from_another_user: property
    } do
      assert {:error, {:redirect, %{to: "/"}}} =
               live(conn, Routes.property_show_path(conn, :edit, property))
    end

    test "logs out when force logout on logged user", %{conn: conn, property: property} do
      user = user_fixture()
      conn = conn |> log_in_user(user)

      {:ok, show_live, html} = live(conn, Routes.property_show_path(conn, :show, property))

      assert html =~ "Show Property"
      assert html =~ property.description
      assert render(show_live) =~ property.description

      Bones73k.Accounts.logout_user(user)

      # Assert our liveview process is down
      ref = Process.monitor(show_live.pid)
      assert_receive {:DOWN, ^ref, _, _, _}
      refute Process.alive?(show_live.pid)

      # Assert our liveview was redirected, following first to /users/force_logout, then to "/", and then to "/users/log_in"
      assert_redirect(show_live, "/users/force_logout")

      conn = get(conn, "/users/force_logout")
      assert "/" = redir_path = redirected_to(conn, 302)
      conn = get(recycle(conn), redir_path)

      assert html_response(conn, 200) =~
               "You were logged out. Please login again to continue using our application."
    end

    test "doesn't log out when force logout on another user", %{conn: conn, property: property} do
      user1 = user_fixture()
      user2 = user_fixture()
      conn = conn |> log_in_user(user2)

      {:ok, show_live, html} = live(conn, Routes.property_show_path(conn, :show, property))

      assert html =~ "Show Property"
      assert html =~ property.description
      assert render(show_live) =~ property.description

      Bones73k.Accounts.logout_user(user1)

      # Assert our liveview is alive
      ref = Process.monitor(show_live.pid)
      refute_receive {:DOWN, ^ref, _, _, _}
      assert Process.alive?(show_live.pid)

      # If we are able to rerender the page it means nothing happened
      assert render(show_live) =~ property.description
    end
  end
end
