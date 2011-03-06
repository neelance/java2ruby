require "swt4ruby"
require "jface4ruby"

class MyCellLabelProvider < Org::Eclipse::Jface::Viewers::StyledCellLabelProvider
  def self.color=(color)
    @@color = color
  end

  def update(cell)
    node = cell.element
    cell.style_ranges = [Org::Eclipse::Swt::Custom::StyleRange.new(0, node.length, @@color, nil)]
    cell.text = node
    super
  end
end

Swt4Ruby.new_display {
  MyCellLabelProvider.color = new_color 255, 0, 0

  shell = new_shell(:title, :resize, :min, :max) {
    set_text "JFace widget test"
#    apply_grid_layout
apply_fill_layout


#    new_tab_folder(:border) {
#      apply_grid_data :fill_both

#      new_tab_item {
#        set_text "TreeViewer"

        tree_viewer = new_tree_viewer(:multi, :virtual) {
          set_use_hashlookup true

          apply_label_provider {
            def add_listener(listener)
            end

            def remove_listener(listener)
            end

            def get_text(element)
              element
            end

            def get_image(element)
              nil
            end

            def dispose
            end
          }

          set_label_provider MyCellLabelProvider.new

          apply_lazy_tree_content_provider {
            def input_changed(viewer, old_input, new_input)
              return if new_input.nil?
              @viewer = viewer
            end
            
            def update_child_count(parent, current_child_count)
              count = parent.is_a?(Array) ? parent.size : 0
              @viewer.set_child_count parent, count if count != current_child_count
            end
            
            def update_element(parent, index)
              child = parent[index]
              @viewer.replace parent, index, child
            end
            
            def get_parent(element)
              nil
            end
            
            def dispose
            end
          }

#          set_input(["root", (1..1000).to_a.map { |i| ["Item #{i}-1", [["Item #{i}-2", []], ["Item #{i}-3", []]]] }])
          set_input((1..1000).to_a.map { |i| "Item #{i}" })
           #set_input(["root", [["Test", [["Test", []]]]]])
        }

#        set_control tree_viewer.get_tree
#      }
#    }

    set_size 600, 400
    open
  }

  read_and_dispatch or sleep until shell.is_disposed
}
