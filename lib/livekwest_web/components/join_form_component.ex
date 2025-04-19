defmodule LivekwestWeb.JoinFormComponents do
  use Phoenix.Component
  use LivekwestWeb, :html

  def join_form(assigns) do
    ~H"""
    <form phx-submit="join" class="flex flex-col justify-center">
      <div class="flex flex-col mb-4">
        <label>Code</label>
        <input class="input w-full" type="text" name="code" phx-debounce="blur" />
      </div>

      <div class="flex flex-col mb-4">
        <label>Name</label>
        <input class="input w-full" type="text" name="name" phx-debounce="blur" />
      </div>

      <div class="grid [grid-template-columns:repeat(auto-fit,_minmax(4rem,_1fr))] gap-4 justify-center mb-4">
        <%= for avatar_url <- @avatar_options do %>
          <div
            class={
              ~s(w-16 h-16 rounded-lg bg-primary flex items-center justify-center transition-opacity text-2xl cursor-pointer hover:opacity-100 #{if @selected_avatar == avatar_url, do: "border-4 border-solid border-primary opacity-100", else: "opacity-80"})
            }
            phx-click="select_avatar"
            phx-value-url={avatar_url}
          >
            <img src={~p"/images/avatars/#{avatar_url}"} />
          </div>
        <% end %>
      </div>

      <button class="btn btn-primary" type="submit">Join!</button>
    </form>
    """
  end
end
