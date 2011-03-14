require 'test_helper.rb'
require 'no_fuzz'
require 'rails/generators'
# require 'rails_generator/scripts/generate'
require 'generators/no_fuzz/no_fuzz_generator'

module Trigrams
  def self.table_name_prefix
    'trigrams_for_'
  end
end

class Trigrams::Package < ActiveRecord::Base
  belongs_to :package, :class_name => '::Package'
end

class Package < ActiveRecord::Base
  include NoFuzz

  fuzzy :name
end


class Trigrams::NamespacedItem < ActiveRecord::Base
end

module Namespaced
  class Item < ActiveRecord::Base
    include NoFuzz

    fuzzy :name
  end
end

class NoFuzzTest < ActiveSupport::TestCase

  load_schema

  def test_populating_and_deleting_trigram_index
    Package.delete_all
    Package.create!(:name => "abcdef")
    Package.populate_trigram_index
    assert_equal 5, Trigrams::Package.all.size
    Package.clear_trigram_index
    assert_equal 0, Trigrams::Package.all.size
  end
  
  
  def test_populating_and_deleting_trigram_index_for_namespaced_model
    Namespaced::Item.delete_all
    Namespaced::Item.create!(:name => "abcdef")
    Namespaced::Item.populate_trigram_index
    assert_equal 5, Trigrams::NamespacedItem.all.size
    Namespaced::Item.clear_trigram_index
    assert_equal 0, Trigrams::NamespacedItem.all.size
  end
  
  def test_fuzzy_find
    Package.delete_all
    Package.create!(:name => "foobar")
    Package.create!(:name => "foobaz")
    Package.create!(:name => "voobar")
    Package.create!(:name => "xyzabc")
    Package.populate_trigram_index
    res = Package.fuzzy_find("voobaz", 2)
    assert_equal 2, res.size
    res = Package.fuzzy_find("foobar")
    assert_equal 1, res[0].id
    assert_equal 3, res.size
  end

end

# class GeneratorHelpersTest < Test::Unit::TestCase
#   include GeneratorHelpers
# 
#   def test_graceful_pluralization
#     ActiveRecord::Base.pluralize_table_names = false
#     assert_equal "chicken", gracefully_pluralize("chicken")
#     ActiveRecord::Base.pluralize_table_names = true
#     assert_equal "chickens", gracefully_pluralize("chicken")
#   end
# end
