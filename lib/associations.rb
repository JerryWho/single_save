module AssociationCreationFromParams
  def self.included(base)
    base.send :include, InstanceMethods
    base.alias_method_chain :has_many, :creation_from_params
    base.alias_method_chain :has_one, :creation_from_params
    base.alias_method_chain :has_and_belongs_to_many, :creation_from_params
  end

  module InstanceMethods

    # == Example
    #
    #   class Project
    #     has_many :tasks, :single_save => true
    #     has_many :resource_assignments
    #     has_many :resources, :through => :resource_assignments, :single_save => true
    #   end
    #
    # The following methods are added for the has_many:
    # * new_task_attributes=(attributes) # => {"3"=>{"name"=>"Task One", "marked_for_deletion"=>"false", "complete"=>"0"}, "4"=>{"name"=>"Task Two", "marked_for_deletion"=>"false", "complete"=>"1"}}
    # * existing_task_attributes=(attributes) # => {"6"=>{"name"=>"Come Back Safely", "marked_for_deletion"=>"false", "complete"=>"0"}, "4"=>{"name"=>"Take Off", "marked_for_deletion"=>"false", "complete"=>"1"}, "5"=>{"name"=>"Land on Moon", "marked_for_deletion"=>"false", "complete"=>"1"}}
    # * save_tasks
    # * after_update :save_tasks
    # * tasks_without_deleted
    #
    # The following methods are added for the has_many :through:
    # * resource_attributes=(attributes) # => {"1"=>"1", "2"=>"0", "3"=>"1"}
    # * save_resource_assignments
    # * after_upate :save_resource_assignments
    #
    # If you define this on both sides of the relationship, you'll cause an endless loop
    # TODO: document the types of hashes these expect
    def has_many_with_creation_from_params(association_id, options = {}, &extension)
      single_save = options.delete(:single_save)
      reflection = create_has_many_reflection(association_id, options, &extension)
      if single_save
        if options[:through]

          define_method("#{Inflector.singularize(association_id.to_s)}_attributes=") do |child_attributes|
            child_attributes.each do |id, value|
              join_object = send(options[:through]).detect{|c| c.send(reflection.association_foreign_key).to_s == id.to_s}
              if value.is_a?(Array) || value.is_a?(Hash)
              else
                if join_object && value.to_s == "0"
                  join_object.marked_for_deletion = true
                  send(reflection.name).delete_if{|c| c.send(reflection.klass.primary_key).to_s == id.to_s}
                elsif  join_object.nil? && value.to_s == "1"
                  category = reflection.klass.find_by_id(id)
                  send(options[:through]).build(reflection.association_foreign_key => id)
                  send(reflection.name).insert(send(reflection.name).length, category)
                  send(reflection.name).compact!
                end
              end
            end
          end

          name = options[:through]
          define_method("save_#{name.to_s}") do
            send(name).each do |child|
              child.save! # => so it cancels any transactions that might be in place
            end
          end
          after_update "save_#{name.to_s}"

        else

          define_method("new_#{Inflector.singularize(association_id.to_s)}_attributes=") do |new_attributes|
            new_attributes.each do |id,attributes|
              send(association_id).build(attributes)
            end
          end

          define_method("existing_#{Inflector.singularize(association_id.to_s)}_attributes=") do |existing_attributes|
            send(association_id).reject(&:new_record?).each do |child|
              attributes = existing_attributes[child.send(reflection.klass.primary_key).to_s]
              if attributes
                child.attributes = attributes
              else
                child.marked_for_deletion = true
              end
            end
          end

          define_method("#{association_id}_without_deleted") do
            send(association_id).select{|t| t.marked_for_deletion == false}
          end

          name = association_id
          define_method("save_#{name.to_s}") do
            send(name).each do |child|
              child.save! # => so it cancels any transactions that might be in place
            end
          end
          after_update "save_#{name.to_s}"

        end
      end
      has_many_without_creation_from_params(association_id, options, &extension)
    end

    # == Example
    #
    #   class Project
    #     has_one :project_detail, :single_save => true
    #   end
    #
    # The following methods are added for the has_one:
    # * project_detail_attributes=(attributes) # => {"3"=>{"name"=>"Task One", "marked_for_deletion"=>"false", "complete"=>"0"}, "4"=>{"name"=>"Task Two", "marked_for_deletion"=>"false", "complete"=>"1"}}
    # * save_project_detail
    # * after_update :save_project_detail
    def has_one_with_creation_from_params(association_id, options = {})
      single_save = options.delete(:single_save)
      if single_save
        if options[:through]
          reflection = create_has_one_through_reflection(association_id, options)
          raise ":single_save is not implemented yet for has_one :through"
        else
          reflection = create_has_one_reflection(association_id, options)

          define_method "#{association_id}_attributes=" do |has_one_attributes|
            send("build_#{association_id}") if send(association_id).nil?
            send(association_id).attributes = has_one_attributes
          end

          define_method "save_#{association_id}" do
            if send(association_id) && send(association_id).changed?
              send(association_id).save!
            end
          end
          after_save "save_#{association_id}"

        end    
      end  
      has_one_without_creation_from_params(association_id, options)
    end

    def has_and_belongs_to_many_with_creation_from_params(association_id, options = {}, &extension)
      single_save = options.delete(:single_save)
      reflection = create_has_and_belongs_to_many_reflection(association_id, options, &extension)
      if single_save
        define_method "#{Inflector.singularize(association_id.to_s)}_attributes=" do |habtm_attributes|
          habtm_attributes.each do |id, value|
            existing = send(association_id).detect{|t| t.send(t.class.primary_key).to_s == id.to_s}
            if existing && value.to_s == "0"
              send(association_id).delete_if{|c| c.send(c.class.primary_key).to_s == id.to_s}
            elsif existing.nil? && value.to_s == "1"
              send(association_id).insert send(association_id).length, reflection.klass.find_by_id(id) # => association_foreign_key
            end
          end
        end

        # define_method("new_#{Inflector.singularize(association_id.to_s)}_attributes=") do |new_attributes|
        #   new_attributes.each do |id,attributes|
        #     send(association_id).build(attributes)
        #   end
        # end
        # 
        # define_method("existing_#{Inflector.singularize(association_id.to_s)}_attributes=") do |existing_attributes|
        #   send(association_id).reject(&:new_record?).each do |child|
        #     attributes = existing_attributes[child.send(reflection.klass.primary_key).to_s]
        #     if attributes
        #       child.attributes = attributes
        #     else
        #       child.marked_for_deletion = true
        #     end
        #   end
        # end

        # This will compare the 2 arrays and
        # * delete all of the ones that are in the db but not in this array
        # * add all of the ones that are not in this set using <<
        define_method "save_#{association_id}" do
          new_set = send(association_id).dup
          old_set = send(association_id, true)
          (new_set - old_set).each do |_child|
            send(association_id) << _child
          end
          (old_set - new_set).each do |_child|
            send(association_id).delete _child
          end
        end
        after_update "save_#{association_id}"

      end
      has_and_belongs_to_many_without_creation_from_params(association_id, options)
    end

  end
end