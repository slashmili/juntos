defmodule Storybook.Components.CoreComponents.TextEditor do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.text_editor/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "storybook-text-editor-ex01",
          name: "storybook-text-name",
          value: value()
        },
        slots: []
      }
    ]
  end

  defp value do
    """
        <h2>
          Hi there,
        </h2>
        <p>
          this is a basic <em>basic</em> example of <strong>Tiptap</strong>. Sure, there are all kind of basic text styles you’d probably expect from a text editor. But wait until you see the lists:
        </p>
        <ul>
          <li>
            That’s a bullet list with one …
          </li>
          <li>
            … or two list items.
          </li>
        </ul>
        <p>
          Isn’t that great? And all of that is editable. But wait, there’s more. Let’s try a code block:
        </p>
    <pre><code >body {
      display: none;
    }</code></pre>
        <p>
          I know, I know, this is impressive. It’s only the tip of the iceberg though. Give it a try and click a little bit around. Don’t forget to check the other examples too.
        </p>
        <blockquote>
          Wow, that’s amazing. Good work, boy! 👏
          <br />
          — Mom
        </blockquote>
    """
  end
end
