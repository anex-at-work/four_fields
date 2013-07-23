require 'test/unit'
require 'active_record'
require 'logger'
require 'squeel'

require 'four_fields'

class UnitTest < Test::Unit::TestCase
  def initialize(*args)
    super
    db_file = File.join(File.dirname(__FILE__), 'db_test.sqlite')
    File.new db_file, 'w'
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => db_file
    ActiveRecord::Base.connection.execute %(
      CREATE TABLE IF NOT EXISTS four_fields(
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        value TEXT DEFAULT '',
        start_at DATETIME NUT NULL,
        end_at DATETIME DEFAULT NULL,
        creator_id INTEGER DEFAULT NULL,
        destroyer_id INTEGER DEFAULT NULL
      );
    )
    ActiveRecord::Base.connection.execute %(
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        four_field_id INTEGER NOT NULL,
        value TEXT DEFAULT '',
        start_at DATETIME NUT NULL,
        end_at DATETIME DEFAULT NULL,
        creator_id INTEGER DEFAULT NULL,
        destroyer_id INTEGER DEFAULT NULL
      )
    )
    ActiveRecord::Base.connection.execute %(
      CREATE TABLE IF NOT EXISTS update_fields(
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        value TEXT DEFAULT '',
        start_at DATETIME NUT NULL,
        end_at DATETIME DEFAULT NULL,
        creator_id INTEGER DEFAULT NULL,
        destroyer_id INTEGER DEFAULT NULL
      );
    )
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  def test_create_object
    obj = FourField.new :value => 'test value'
    obj.save!
    assert_equal 'test value', obj.value
  end
  
  def test_create_many_objects
    (1..20).each do |n|
      FourField.create :value => n
    end
    (1..20).each do |n|
      obj = FourField.where(:value => n).first
      assert_not_nil obj
      assert_nil obj.end_at
      assert_not_nil obj.start_at
    end
  end
  
  def test_destroy_object
   obj = FourField.create :value => 'destroyed'
   assert_not_nil obj
   assert_equal 1, obj.id
   obj.destroy
   
   assert_not_nil obj.end_at
   
   finded = FourField.where(:value => 'destroyed', :end_at => nil).first
   assert_nil finded
   old = FourField.unscoped.unactive.where{value == 'destroyed'}.first
   assert_not_nil old
  end

  def test_update_object
    obj = FourField.create :value => 'update me!'
    assert_not_nil obj
    obj.value = 'updated'
    obj.save!
    assert_nil obj.end_at
    assert_equal 'updated', obj.value
    
    finded = FourField.unscoped.unactive.first
    assert_not_nil finded
    assert_equal 'update me!', finded.value
  end  

  def test_table_with_association
    obj = FourField.create :value => 'first'
    obj.build_user
    obj.user.value = 'first user'
    obj.user.save
    
    assert_nil obj.user.end_at
    assert_not_nil obj.user.start_at
    
    obj.user.value = 'first user with remarcs'
    obj.user.save
    finded = FourField.joins(:user).includes(:user).first
    assert_nil finded.user.end_at
    old_user_finded = FourField.joins(:user_unactive).includes(:user_unactive).first
    assert_not_nil old_user_finded.user_unactive.end_at
  end
  
  def test_table_with_disable_update
    obj = UpdateField.create :value => 'test'
    obj.save
    
    assert_nil obj.end_at
    loaded = UpdateField.where(:value => 'test').first
    assert_not_nil loaded
    loaded.value = 'new test'
    loaded.save
    
    assert_nil loaded.end_at
    finded = UpdateField.where(:value => 'new test').first
    assert_not_nil finded
    finded.destroy
    
    deleted = UpdateField.unscoped.unactive.first
    assert_not_nil deleted.end_at
    assert_equal deleted.value, 'new test'
  end

  def test_table_with_sifters
    obj = FourField.create :value => 'first'
    obj.build_user
    obj.user.value = 'first user'
    obj.user.save
    
    assert_nil obj.user.end_at
    assert_not_nil obj.user.start_at
    
    ret = FourField.joins(:user).where{
      user.sift(:sift_active) &
      user.value == 'first_user'
    }.first
    assert_not_nil ret
  end

  def test_new_with_nested
    obj = FourField.new :value => 'first', :user_attributes => {:value => 'user'}
    assert_nothing_raised {
      obj.save!
    }
    
    assert_equal obj.value, 'first'
    assert_not_nil obj.user
    assert_equal obj.user.value, 'user'
    
    finded = FourField.joins(:user).includes(:user).
      where{user.sift(:sift_active) &
        (user.value == 'user')}.first
    assert_not_nil finded
    assert_equal finded.user.value, 'user'
    assert_nil finded.user.end_at
    assert_equal finded.value, 'first'
  end

  def test_update_with_nested
    obj = FourField.create :value => 'first'
    obj.build_user
    obj.user.value = 'first user'
    obj.save!
    
    assert_nil obj.user.end_at
    
    find_object = FourField.joins(:user).includes(:user).
      where{user.sift(:sift_active) &
        (user.value == 'first user')
      }.first
    assert_not_nil find_object
    
    find_object.user.update_attributes! :value => 'update user'
        
    assert_equal find_object.user.value, 'update user'
    assert_nil find_object.user.end_at
    assert_equal find_object.id, 1
    
    find_object.update_attributes! :user_attributes => {:value => 'update user 2'}
    
    assert_equal find_object.user.value, 'update user 2'
    assert_nil find_object.user.end_at
    assert_equal find_object.id, 1
  end

  def test_create_and_update_with_nested
    obj = FourField.create :value => 'first',
      :user_attributes => {:value => 'user'}
    obj.save!
    assert_nil obj.user.end_at
    assert_equal obj.id, obj.user.four_field_id
    
    obj.update_attributes! :user_attributes => {
      :value => 'second user'
    }
    assert_nil obj.user.end_at
    assert_equal obj.id, obj.user.four_field_id
    assert_equal 'second user', obj.user.value
  end
end

class FourField < ActiveRecord::Base
  four_fields
  
  has_one :user, -> { where end_at: nil}
  has_one :user_unactive, -> { where.not end_at: nil }, :class_name => 'User'
  
  accepts_nested_attributes_for :user
end

class User < ActiveRecord::Base
  four_fields
  
  belongs_to :four_field
end

class UpdateField < ActiveRecord::Base
  four_fields :disable_update => true
end