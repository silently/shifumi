defmodule ShifumiWeb do
  @moduledoc false

  def controller do
    quote do
      use Phoenix.Controller, namespace: ShifumiWeb
      import Plug.Conn
      import ShifumiWeb.Router.Helpers
      import ShifumiWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/shifumi_web/templates",
        namespace: ShifumiWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ShifumiWeb.Router.Helpers
      import ShifumiWeb.ErrorHelpers
      import ShifumiWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ShifumiWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
