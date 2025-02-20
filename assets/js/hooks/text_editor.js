import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
const TextEditor = {
  initialValue() {
    if (this.el.dataset.value) {
      return JSON.parse(this.el.dataset.value);
    }
  },
  mounted() {
    const element = this.el.querySelector("[data-editor]");
    const hidden = this.el.querySelector("[data-editor-hidden]");
    this.editor = new Editor({
      element,
      autofocus: this.el.hasAttribute("data-autofocus"),
      editable: this.el.hasAttribute("data-editable"),
      extensions: [StarterKit],
      content: this.initialValue(),
      onUpdate: ({ editor }) => {
        this.content = JSON.stringify(editor.getJSON());
        hidden.value = this.content;
        hidden.dispatchEvent(new Event("input", { bubbles: true }));
      },
      editorProps: {
        attributes: {
          class: 'prose prose-sm sm:prose-base m-5 focus:outline-none',
        },
      }
    });
  }
}

export { TextEditor };
