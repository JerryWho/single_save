require File.dirname(__FILE__) + '/spec_helper'

class Winken < ActiveRecord::Base
  has_many :blinkens, :single_save => true
  has_many :nods, :through => :blinkens, :single_save => true
  has_many :taggings
  has_many :tags, :through => :taggings, :single_save => true
  has_and_belongs_to_many :bars, :single_save => true
  has_one :foo, :single_save => true
end

class Blinken < ActiveRecord::Base
  belongs_to :blinken
  belongs_to :nod
end

class Nod < ActiveRecord::Base
  has_many :blinkens
  has_many :winkens, :through => :blinkens
end

class Bar < ActiveRecord::Base
  has_and_belongs_to_many :winkens
end

class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :winkens, :through => :taggings
end

class Tagging < ActiveRecord::Base
  belongs_to :winken
  belongs_to :tag
end

class Foo < ActiveRecord::Base
  belongs_to :winken
end

# class Twinkle < ActiveRecord::Base
#   belongs_to :blinken
#   has_one :winken, :through => :blinken
# end

describe Winken do
  before(:each) do
    @winken = Winken.new
  end
  it "should maintain the old methods" do
    @winken.should respond_to(:blinkens=)
  end
  
  describe "has_many" do
    it "should have a new_blinken_attributes= method" do
      @winken.should respond_to(:new_blinken_attributes=)
    end
    it "should have an existing_blinken_attributes= method" do
      @winken.should respond_to(:new_blinken_attributes=)
    end
    it "should have an save_blinkens method" do
      @winken.should respond_to(:save_blinkens)
    end
  end
  
  describe "has_many :through" do
    it "should have a tag_attributes= method" do
      @winken.should respond_to(:tag_attributes=)
    end
    it "should have a save_taggings method" do
      @winken.should respond_to(:save_taggings)
    end
  end
  
  describe "has_one" do
    it "should have a foo_attributes= method" do
      @winken.should respond_to(:foo_attributes=)
    end
    it "should have a save_foo method" do
      @winken.should respond_to(:save_foo)
    end
  end
  
  describe "has_and_belongs_to_many" do
    it "should have a bar_attributes= method" do
      @winken.should respond_to(:bar_attributes=)
    end
    it "should have a save_bars method" do
      @winken.should respond_to(:save_bars)
    end
  end
end