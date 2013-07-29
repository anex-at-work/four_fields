class FourFieldsGenerator < Rails::Generators::Base
  desc 'Generate migration (with default fields) for model'
  argument :model_name, :type => :string
  source_root File.expand_path('../templates', __FILE__)
  
  def create_migration_file
    migration_template 'four_fileds_change.rb', %(db/migrate/add_four_fileds_to_#{model_name.tableize}.rb)
  end
end