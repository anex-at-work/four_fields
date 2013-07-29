class AddFourFields<%= model_name.pluralize %> < ActiveRecord::Migration
  def change
    add_column :<%= model_name.tableize %>, :start_at, :datetime, :null => false
    add_column :<%= model_name.tableize %>, :end_at, :datetime, :default => nil
    add_column :<%= model_name.tableize %>, :creator_id, :integer, :null => false
    add_column :<%= model_name.tableize %>, :end_at, :integer, :default => nil
  end
end