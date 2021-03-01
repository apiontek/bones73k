defmodule Bones73kWeb.PropertyLive.Show do
  use Bones73kWeb, :live_view

  alias Bones73k.Properties
  alias Bones73kWeb.Roles

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    current_user = socket.assigns.current_user
    live_action = socket.assigns.live_action
    property = Properties.get_property!(id)

    if Roles.can?(current_user, property, live_action) do
      {:noreply,
       socket
       |> assign(:property, property)
       |> assign(:page_title, page_title(live_action))}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Unauthorised")
       |> redirect(to: "/")}
    end
  end

  defp page_title(:show), do: "Show Property"
  defp page_title(:edit), do: "Edit Property"
end
