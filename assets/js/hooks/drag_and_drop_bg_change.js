const DragAndDropBgChange = {
  mounted() {
    const dropArea = this.el;

    dropArea.addEventListener("dragenter", () => {
      dropArea.classList.add("bg-neutral-tertiary");
    });
    dropArea.addEventListener("dragleave", () => {
      dropArea.classList.remove("bg-neutral-tertiary");
    });
    dropArea.addEventListener("drop", (e) => {
      dropArea.classList.remove("bg-neutral-tertiary");
    })

  }
}

export { DragAndDropBgChange };
