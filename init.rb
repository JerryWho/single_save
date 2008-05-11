require 'associations'
require 'marked_for_deletion'
require 'view_helpers'
ActiveRecord::Base.send :include, MarkedForDeletion
ActiveRecord::Associations::ClassMethods.send :include, AssociationCreationFromParams
ActionView::Base.class_eval { include ViewHelpers }