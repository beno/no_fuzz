class NoFuzzGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  source_root File.expand_path('../templates', __FILE__)
  argument :model_name, :type => :string
  
  def self.next_migration_number(dirname)
    next_migration_number = current_migration_number(dirname) + 1
    if ActiveRecord::Base.timestamped_migrations
      [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
    else
      "%.3d" % next_migration_number
    end
  end
  
  def create_module
    template "module.rb", "app/models/trigrams.rb"
  end
  
  def create_model
    template "model.rb", "app/models/trigrams/#{downcased_name}.rb"
  end

  def create_migration
    migration_template "migration.rb", "db/migrate/#{migration_file_name}.rb"
  end

  protected
  
  def table_name_prefix
    "trigrams_for_"
  end
  
  def class_name
    model_name.pluralize.classify
  end

  def downcased_name
    class_name.underscore.gsub('/','_').downcase
  end
  
  def belongs_to_association
    class_name.demodulize.underscore.to_sym
  end
  
  def flattened_class_name
    downcased_name.pluralize.classify
  end
  
  def migration_class_name
     "CreateTrigramsTableFor#{flattened_class_name}"
  end

  def migration_file_name
     migration_class_name.underscore.downcase
  end
  
  def table_name
     name = ActiveRecord::Base.pluralize_table_names ? downcased_name.pluralize : downcased_name
     table_name_prefix + name
  end
  
  def foreign_key
     downcased_name + "_id"
  end
  
end

