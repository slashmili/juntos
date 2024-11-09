import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import { Markdown } from 'tiptap-markdown';
import Heading from "@tiptap/extension-heading";
import BulletList from "@tiptap/extension-bullet-list";
import OrderedList from "@tiptap/extension-ordered-list";
import Placeholder from "@tiptap/extension-placeholder";

export default {
  TextEditor:{
    initialValue() {
      return this.el.dataset.value || "";
    },
    classes() {
      return this.el.dataset.class || "";
    },
    placeholder() {
      return this.el.dataset.placeholder || "";
    },
    mounted() {
      const element = this.el.querySelector("[data-editor]");
      const hidden = this.el.querySelector("[data-editor-hidden]");
      const extensions = [
        StarterKit,
        Placeholder.configure({placeholder: this.placeholder()}),
        Markdown,
        Heading.configure({
          HTMLAttributes: {
            class: "text-xl font-bold capitalize",
            levels: [1, 2, 3],
          },
        }),
        BulletList.configure({
          HTMLAttributes: {
            class: "list-disc ml-2",
          },
        }),
        OrderedList.configure({
          HTMLAttributes: {
            class: "list-decimal ml-2",
          },
        }),
      ]
      this.editor = new Editor({
        element,
        extensions: extensions,
        onUpdate: ({ editor }) => {
          hidden.value = editor.storage.markdown.getMarkdown()
          hidden.dispatchEvent(new Event("input", { bubbles: true }));
        },
        content: this.initialValue(),
        editorProps: {
          attributes: {
            class: this.classes()
          }
        }
      });
    },
  } 
}

