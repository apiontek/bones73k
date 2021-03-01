defmodule Bones73kWeb.IconHelpers do
  @moduledoc """
  Generate SVG sprite use tags for SVG icons
  """

  use Phoenix.HTML
  alias Bones73kWeb.Router.Helpers, as: Routes

  def icon_div(conn, name, div_opts \\ [], svg_opts \\ []) do
    content_tag(:div, tag_opts(name, div_opts)) do
      icon_svg(conn, name, svg_opts)
    end
  end

  def icon_svg(conn, name, opts \\ []) do
    content_tag(:svg, tag_opts(name, opts)) do
      tag(:use, "xlink:href": Routes.static_path(conn, "/images/icons.svg##{name}"))
    end
  end

  defp tag_opts(name, opts) do
    Keyword.update(opts, :class, name, fn c -> "#{c} #{name}" end)
  end
end