class AddAttachToTabConfig < ActiveRecord::Migration
  def change
    add_attachment  :tab_configs, :attach_file
  end
end
