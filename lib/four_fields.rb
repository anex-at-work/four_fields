module FourFields
  def fields_before_create
    self.start_at = Time.now
    self.creator_id = current_user_id
  end
  
  def assign_attributes(new_attributes)
    attributes = new_attributes.stringify_keys
    attributes = sanitize_for_mass_assignment(attributes)
    
    attributes.each do |k, v|
      if respond_to?("#{k}=") & v.is_a?(Hash)
        if !(/_attributes$/ =~ k.to_s).nil? & respond_to?(%(#{k.gsub(/_attributes$/, '')})) then
          break if method(k.gsub(/_attributes$/, '').to_sym).call.nil?
          eval %(#{k.gsub(/_attributes$/, '')}.assign_attributes v)
          attributes.delete k
        end
      end
    end
    super attributes
  end
  
  def destroy
    self.destroyer_id = current_user_id
    self.end_at = Time.now
    self.save!
  end
  
  private
    def fields_devised?
      defined? Devise
    end
    
    def current_user_id
      fields_devised? ? (User.current_user.nil? ? nil : User.current_user.id) : nil
    end
    
    def update_record(attribute_names = @attributes.keys)
      attrs = arel_attributes_with_values_for_update(attribute_names)
      if changed? && !(
        changes.has_key? :destroyer_id or changes.has_key? :end_at) && 
        !(four_field_options[:disable_update] || false) then
        attrs = attributes.delete_if do |k, v|
          :id == k.intern
        end
        inserted = self.class.create attrs
        update_attributes changed_attributes
        destroy
        super
        attrs = inserted.attributes.delete_if do |k, v|
          :id == k.intern
        end
        assign_attributes attrs
      else
        super
      end
    end
end

class ActiveRecord::Base
  # *four_fields* in model allows use the logging and tracking
  # 
  # ==== Options   
  # * +disable_update* - if sets and "true", only destroyed fields will be tracking
  def self.four_fields(options = {})
    cattr_accessor :four_field_options
    
    include FourFields
    
    self.four_field_options = options
    
    scope :active, -> {where{sift :sift_active}}
    scope :unactive, -> {where{sift :sift_unactive}}
    
    sifter :sift_active do
      end_at == nil
    end
    
    sifter :sift_unactive do
      end_at != nil
    end
    
    before_create :fields_before_create
    
    default_scope {where{sift :sift_active}}
  end
end