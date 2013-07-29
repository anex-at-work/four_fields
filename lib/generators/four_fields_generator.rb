class FourFieldsGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  desc 'Generate migration (with default fields) for model'
  argument :model_name, :type => :string
  source_root File.expand_path('../templates', __FILE__)
  
  def self.next_migration_number(dirname)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
  
  def create_migration_file
    migration_template 'four_fields_change.rb', %(db/migrate/add_four_fields_to_#{model_name.tableize}.rb)
  end
end