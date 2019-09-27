class AddSendCsvToDocH < ActiveRecord::Migration
  def change
    add_column   :doc_hs,  :sent_csv_on, :datetime
  end
end
