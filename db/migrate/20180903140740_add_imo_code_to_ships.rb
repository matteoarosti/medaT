class AddImoCodeToShips < ActiveRecord::Migration
  def change
    add_column    :ships, :imo_code, :string, limit: 30
  end
end
