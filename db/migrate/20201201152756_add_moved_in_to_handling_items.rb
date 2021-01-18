class AddMovedInToHandlingItems < ActiveRecord::Migration
  def change
    add_column   :handling_items, :datetime_op_it, :datetime	#ora italiana
  	add_column   :handling_items, :moved_in, 	   :integer		#minuti intercorsi (box -> spunta tablet)
  end
end
