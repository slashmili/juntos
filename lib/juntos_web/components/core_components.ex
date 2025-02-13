defmodule JuntosWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component
  use Gettext, backend: JuntosWeb.Gettext

  alias Phoenix.LiveView.JS

  attr :variant, :string,
    values: ~w(primary secondary link outline),
    default: "primary",
    doc: "the button variant style"

  attr :size, :string, default: "lg", values: ~w(lg md)
  attr :type, :string, default: "submit", values: ~w(submit button reset link)
  attr :class, :any, default: nil
  attr :icon_right, :string, default: nil
  attr :icon_left, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value href)

  slot :inner_block, required: true

  @doc """
  Renders a button.
  """
  def button(%{type: "link"} = assigns) do
    assigns = Map.put(assigns, :variant_class, button_variant_class(assigns))
    assigns = Map.put(assigns, :size_class, button_size_class(assigns))
    assigns = Map.put(assigns, :icon_class, button_icon_class(assigns))

    ~H"""
    <.link
      class={[
        @variant_class,
        @size_class,
        @class,
        "flex gap-1 justify-center font-medium  max-w-md"
      ]}
      {@rest}
    >
      <.icon :if={@icon_left} name={@icon_left} class={@icon_class} />
      {render_slot(@inner_block)}
      <.icon :if={@icon_right} name={@icon_right} class={@icon_class} />
    </.link>
    """
  end

  def button(assigns) do
    assigns = Map.put(assigns, :variant_class, button_variant_class(assigns))
    assigns = Map.put(assigns, :size_class, button_size_class(assigns))
    assigns = Map.put(assigns, :icon_class, button_icon_class(assigns))

    ~H"""
    <button
      type={@type}
      class={[
        @variant_class,
        @size_class,
        @class,
        "flex gap-1 justify-center font-medium  max-w-md"
      ]}
      {@rest}
    >
      <.icon :if={@icon_left} name={@icon_left} class={@icon_class} />
      {render_slot(@inner_block)}
      <.icon :if={@icon_right} name={@icon_right} class={@icon_class} />
    </button>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart class),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      {render_slot(@inner_block, f)}
      <div :for={action <- @actions} class="">
        {render_slot(action, f)}
      </div>
    </.form>
    """
  end

  defp button_icon_class(assigns) do
    case assigns[:size] do
      "md" -> "w-4 h-4"
      _ -> "w-6 h-6"
    end
  end

  defp button_size_class(assigns) do
    case assigns[:size] do
      "md" -> "rounded-full p-3"
      _ -> "rounded-lg px-3 py-3 px-2"
    end
  end

  defp button_variant_class(%{variant: "secondary"} = assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400"
      else
        "bg-violet-100 text-violet-700 dark:bg-violet-950 dark:text-violet-200"
      end

    colors
  end

  defp button_variant_class(%{variant: "outline"} = assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400 border-gray-300 dark:bg-gray-900 dark:text-gray-700 dark:border-gray-700"
      else
        "bg-slate-50 text-slate-900 border-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-600"
      end

    ["border-2", colors]
  end

  defp button_variant_class(%{variant: "link"} = assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400 dark:bg-gray-900 dark:text-gray-700"
      else
        "text-slate-600 dark:text-slate-400"
      end

    ["border-0", colors]
  end

  defp button_variant_class(assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400"
      else
        "bg-violet-700 text-slate-50"
      end

    colors
  end

  attr :logged_in, :boolean, default: false

  def navbar(assigns) do
    ~H"""
    <navbar class="flex max-w-6xl w-full pt-2 py-4">
      <div class="flex">
        <.button variant="link" icon_right="logo"></.button>
        <.button variant="link" icon_right="hero-magnifying-glass"></.button>
      </div>
      <div :if={@logged_in} class="grow flex justify-end">
        <.button variant="outline" size="md">Create event</.button>
        <.button variant="link" icon_right="hero-bell"></.button>
        <.button variant="link" icon_right="hero-user-solid"></.button>
      </div>
    </navbar>
    """
  end

  @doc """
  Render Hero section
  """

  slot :title, doc: "the title block", required: true
  slot :subtitle, doc: "the optional subtitle block"
  slot :body, doc: "the optional body block"

  def hero(assigns) do
    ~H"""
    <section class="max-w-md text-center pt-8 flex gap-2 flex-col">
      <div class="text-3xl font-semibold text-slate-900 dark:text-slate-200">
        {render_slot(@title)}
      </div>
      <div :if={@subtitle} class="text-base font-normal text-slate-500 dark:text-slate-400">
        {render_slot(@subtitle)}
      </div>
      <div :if={@body} class="text-base font-normal text-slate-900 dark:text-slate-200">
        {render_slot(@body)}
      </div>
    </section>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: type} = assigns) when type in ~w(text email datetime-local) do
    input_text(assigns)
  end

  attr :field, Phoenix.HTML.FormField, doc: "label for this field"
  attr :class, :any, default: []
  slot :inner_block, required: true

  def label_for(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    ~H"""
    <label for={@field.id} class={@class}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  attr :id, :any, default: nil
  attr :name, :any, default: nil
  attr :value, :any
  attr :label, :string, default: nil
  attr :placeholder, :string, default: nil

  attr :icon_left, :string, default: nil
  attr :icon_right, :string, default: nil

  attr :type, :string,
    default: "text",
    values: ~w(email hidden text)

  attr :errors, :list, default: []

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                      multiple pattern placeholder readonly required rows size step row onInput)

  def input_text(assigns) do
    ~H"""
    <section>
      <label class="text-slate-600 dark:text-slate-400 pb-0.5 text-sm" for={@id}>{@label}</label>
      <div class="px-3 py-2 border border-slate-400 rounded-lg flex gap-2 text-slate-400 dark:text-slate-500 focus-within:text-slate-900 dark:focus-within:text-slate-400 focus-within:border-2">
        <div :if={@icon_left}>
          <.icon name={@icon_left} class="w-6 h-6" />
        </div>
        <input
          id={@id}
          name={@name}
          class="border-0 p-0 m-0 outline-none text-slate-900 dark:text-slate-400 placeholder-slate-400  dark:placeholder-slate-500 focus:ring-0 bg-transparent"
          type={@type}
          value={@value}
          placeholder={@placeholder}
          {@rest}
        />
        <div :if={@icon_right}>
          <.icon name={@icon_right} class="w-6 h-6" />
        </div>
      </div>
    </section>
    <p :if={@errors != []} data-role="error-for-input">{@errors}</p>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        {@title}
      </p>
      <p class="mt-2 text-sm leading-5">{msg}</p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  def page_wrapper(assigns) do
    ~H"""
    <div class="flex justify-center">
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  def icon(%{name: "logo"} = assigns) do
    ~H"""
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g clip-path="url(#clip0_139_1721)">
        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M18 2H6C3.79086 2 2 3.79086 2 6V18C2 20.2091 3.79086 22 6 22H18C20.2091 22 22 20.2091 22 18V6C22 3.79086 20.2091 2 18 2ZM6 0C2.68629 0 0 2.68629 0 6V18C0 21.3137 2.68629 24 6 24H18C21.3137 24 24 21.3137 24 18V6C24 2.68629 21.3137 0 18 0H6Z"
          fill="#475569"
        />
        <circle
          cx="7.27037"
          cy="17.0709"
          r="2.3125"
          transform="rotate(-45 7.27037 17.0709)"
          fill="#475569"
        />
        <circle
          cx="12.0082"
          cy="12.0081"
          r="2.3125"
          transform="rotate(-45 12.0082 12.0081)"
          fill="#475569"
        />
        <circle
          cx="17.0709"
          cy="7.27039"
          r="2.3125"
          transform="rotate(-45 17.0709 7.27039)"
          fill="#475569"
        />
      </g>
      <defs>
        <clipPath id="clip0_139_1721">
          <rect width="24" height="24" fill="white" />
        </clipPath>
      </defs>
    </svg>
    """
  end

  def icon(%{name: "google"} = assigns) do
    ~H"""
    <span class={[@name, @class]}>
      <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <mask id="mask0_157_484" style="mask-type:luminance" maskUnits="userSpaceOnUse" x="0" y="0">
          <path d="M24 0H0V24H24V0Z" fill="white" />
        </mask>
        <g mask="url(#mask0_157_484)">
          <path
            d="M23.52 12.2727C23.52 11.4218 23.4437 10.6036 23.3018 9.81812H12V14.46H18.4582C18.18 15.96 17.3346 17.2309 16.0637 18.0818V21.0927H19.9418C22.2109 19.0036 23.52 15.9272 23.52 12.2727Z"
            fill="#4285F4"
          />
          <path
            d="M12 24C15.24 24 17.9563 22.9254 19.9417 21.0928L16.0636 18.0819C14.9891 18.8019 13.6145 19.2273 12 19.2273C8.87448 19.2273 6.22908 17.1163 5.2854 14.28H1.27632V17.3891C3.25092 21.3109 7.30908 24 12 24Z"
            fill="#34A853"
          />
          <path
            d="M5.2854 14.2799C5.0454 13.5599 4.90908 12.7908 4.90908 11.9999C4.90908 11.209 5.0454 10.4399 5.2854 9.71992V6.61084H1.27632C0.463679 8.23084 0 10.0636 0 11.9999C0 13.9362 0.463679 15.769 1.27632 17.389L5.2854 14.2799Z"
            fill="#FBBC04"
          />
          <path
            d="M12 4.77276C13.7617 4.77276 15.3436 5.37816 16.5872 6.56724L20.0291 3.1254C17.9509 1.18908 15.2345 0 12 0C7.30908 0 3.25092 2.68908 1.27632 6.61092L5.2854 9.72C6.22908 6.88368 8.87448 4.77276 12 4.77276Z"
            fill="#E94235"
          />
        </g>
      </svg>
    </span>
    """
  end

  def icon(%{name: "github"} = assigns) do
    ~H"""
    <span class={[@name, @class]}>
      <svg viewBox="0 0 25 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path
          d="M9.5 18.9999C4.5 20.4999 4.5 16.4999 2.5 15.9999M16.5 21.9999V18.1299C16.5375 17.6531 16.4731 17.1737 16.311 16.7237C16.1489 16.2737 15.8929 15.8634 15.56 15.5199C18.7 15.1699 22 13.9799 22 8.51994C21.9997 7.12376 21.4627 5.78114 20.5 4.76994C20.9559 3.54844 20.9236 2.19829 20.41 0.999938C20.41 0.999938 19.23 0.649938 16.5 2.47994C14.208 1.85876 11.792 1.85876 9.5 2.47994C6.77 0.649938 5.59 0.999938 5.59 0.999938C5.07638 2.19829 5.04414 3.54844 5.5 4.76994C4.53013 5.78864 3.99252 7.1434 4 8.54994C4 13.9699 7.3 15.1599 10.44 15.5499C10.111 15.8899 9.85726 16.2953 9.69531 16.7399C9.53335 17.1844 9.46681 17.658 9.5 18.1299V21.9999"
          stroke="#0F172A"
          stroke-width="1.5"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
    </span>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(JuntosWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(JuntosWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
