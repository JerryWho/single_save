# TODO: add marked for deletion method name so users can set this to destroy, delete or whatever else they want
module MarkedForDeletion

  # When the module is included it adds a marked_for_deletion
  # it adds an attribute to each model that's not mapped to the 
  # database called <tt>marked_for_deletion</tt> and a callback
  # after_save to destroy itself if it's marked for deletion
  #
  # This allows forms elements to be removed from the form, posted
  # back due to some validation error, then deleted when the user clicks
  # "save" and the save is valid
  def self.included(base)
    base.after_save :destroy_if_marked_for_deletion
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    # guaranteed to be a boolean - no matter what you set it to
    # true and "true" both return true
    # anything else returns false
    def marked_for_deletion
      read_attribute(:marked_for_deletion) == true
    end

    # true and "true", 1 and "1" are valid values
    # everything else evaluates to false
    def marked_for_deletion=(marked)
      write_attribute(:marked_for_deletion, marked.to_s == "true" || marked.to_s == "1" ? true : false)
    end

    # if marked_for_deletion is true
    # call destroy on the object
    def destroy_if_marked_for_deletion
      destroy if marked_for_deletion == true
    end
  end

end
