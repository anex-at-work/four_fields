class <%= model_name %> < ActiveRecord::Migration
  def change
    add_column <%= table_name.tableize %>, :start_at, :datetime, :null => false
    add_column <%= table_name.tableize %>, :end_at, :datetime, :default => nil
    add_column <%= table_name.tableize %>, :creator_id, :integer, :null => false
    add_column <%= table_name.tableize %>, :end_at, :integer, :default => nil
  end
end