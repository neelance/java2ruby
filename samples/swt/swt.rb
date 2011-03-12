require "swt4ruby"

begin
Swt4Ruby.new_display {
  shell = new_shell(:title, :resize, :min, :max) {
    set_text "SWT widget test"
    apply_grid_layout

    set_menu_bar new_menu(:bar) {
      new_menu_item(:cascade) {
        set_text "Menu"

        set_menu new_menu(:drop_down) {
          new_menu_item(:push) {
            set_text "Push menu item"
          }
          new_menu_item(:cascade) {
            set_text "Submenu"

            set_menu new_menu(:drop_down) {
              new_menu_item(:radio) {
                set_text "Radio menu item 1"
                set_selection true
              }
              new_menu_item(:radio) {
                set_text "Radio menu item 2"
              }
              new_menu_item(:radio) {
                set_text "Radio menu item 3"
              }
            }
          }
        }
      }
    }

    new_tab_folder(:border) {
      apply_grid_data :fill_both

      new_tab_item {
        set_text "Simple Widgets"

        set_control new_composite {
          apply_grid_layout

          new_label {
            set_text "Label"
          }

          new_link {
            set_text "<a>Link</a> (<a>second</a>, <a>third</a>)"

            on_widget_selected { |event|
              new_message_box(:icon_information, :ok) {
                set_message event.attr_text
                open
              }
            }
          }

          new_button(:push) {
            set_text "Open File"

            on_widget_selected {
              new_file_dialog {
                open
              }
            }
          }

          new_button(:check) {
            set_text "Check"
          }

          new_button(:radio) {
            set_text "Radio 1"
            set_selection true
          }

          new_button(:radio) {
            set_text "Radio 2"
          }

          new_button(:toggle) {
            set_text "Toggle"
          }

          new_button(:arrow, :down) {
            set_text "Arrow"
          }

          new_spinner {
          }

          bar = nil
          new_scale(:horizontal) {
            apply_grid_data :fill_horizontal
            set_minimum 0
            set_maximum 100

            on_widget_selected {
              bar.set_selection get_selection
            }
          }

          bar = new_progress_bar {
            apply_grid_data :fill_horizontal
            set_minimum 0
            set_maximum 100
          }

          new_slider(:horizontal) {
            apply_grid_data :fill_horizontal
            set_minimum 0
            set_maximum 100
          }

          new_combo(:read_only) {
            apply_grid_data :fill_horizontal
            set_items ["Item 1", "Item 2", "Item 3"]
            select 0
          }

          new_list(:border, :multi) {
            apply_grid_data :fill_horizontal
            set_items ["Item 1", "Item 2", "Item 3"]
          }

          new_text(:single, :border) {
            apply_grid_data :fill_horizontal
            set_text "single line"
          }

          new_text(:single, :border, :password) {
            apply_grid_data :fill_horizontal
            set_text "password"
          }

          new_text(:multi, :border) {
            apply_grid_data :fill_both
            set_text "multi line"
          }
        }
      }

      new_tab_item {
        set_text "DateTime"

        set_control new_composite {
          apply_grid_layout
          
          new_date_time(:calendar)
          new_date_time(:time)
        }
      }

      new_tab_item {
        set_text "ToolBar && CoolBar"

        set_control new_composite {
          apply_grid_layout
          
          new_tool_bar(:border) {
            apply_grid_data :fill_horizontal

            3.times do |i|
              new_tool_item(:push) {
                set_text i.to_s
              }
            end

            new_tool_item(:separator)

            new_tool_item(:separator) {
              set_width 200
              set_control new_text(:single, :border)
            }
          }

#          new_cool_bar(:border) {
#            apply_grid_data :fill_horizontal
#
#            new_cool_item {
#              button = new_tool_bar(:flat) {
#                apply_grid_data :fill_horizontal
#
#                3.times do |i|
#                  new_tool_item(:push) {
#                    set_text i.to_s
#                  }
#                end
#              }
#              size = button.compute_size Org::Eclipse::Swt::SWT::DEFAULT, Org::Eclipse::Swt::SWT::DEFAULT
#              set_size compute_size(size.attr_x, size.attr_y)
#              set_control button
#            }
#          }
        }
      }

      new_tab_item {
        set_text "SashForm"

        set_control new_sash_form(:vertical) {
          new_label {
            set_text "Child 1"
          }
          new_label {
            set_text "Child 2"
          }
          new_label {
            set_text "Child 3"
          }
        }
      }

      new_tab_item {
        set_text "Tree"

        set_control new_tree {
          new_tree_item {
            set_text "Item 1"

            new_tree_item {
              set_text "Item 2"
            }
          }
          new_tree_item {
            set_text "Item 3"
          }
        }
      }

      new_tab_item {
        set_text "Table"

        set_control new_table(:multi, :full_selection) {
          set_header_visible true

          5.times { |i|
            new_table_column {
              set_text "Column #{i}"
              set_width 100
            }
          }

          50.times { |i|
            new_table_item {
              5.times { |j|
                set_text j, "#{i}/#{j}"
              }
            }
          }
        }
      }

      new_tab_item {
        set_text "Canvas"

        set_control new_canvas {
          on_paint_control { |event|
            rect = get_client_area
            event.attr_gc.draw_oval 0, 0, rect.attr_width - 1, rect.attr_height - 1
          }
        }
      }

#      new_tab_item {
#        set_text "Browser"
#
#        set_control new_browser
#      }
    }

    pack
    open
  }

  new_tray_item {
    set_image new_image(16, 16)
    set_tool_tip_text "SWT tray item"

    on_menu_detected {
      shell.new_menu(:pop_up) {
        new_menu_item(:push) {
          set_text "Tray menu item 1"
        }
        new_menu_item(:push) {
          set_text "Tray menu item 2"
        }
        new_menu_item(:push) {
          set_text "Tray menu item 3"
        }

        set_visible true
      }
    }
  }

  read_and_dispatch or sleep until shell.is_disposed
}
rescue Exception => e
puts e, e.backtrace
end
