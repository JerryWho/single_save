require File.dirname(__FILE__) + '/spec_helper'

describe Winken do

  before(:each) do
    @object = Winken.new
  end
  it "should not be marked for deletion before you mark it" do
    @object.marked_for_deletion.should be_false
  end
  it "should mark for deletion with true" do
    @object.marked_for_deletion = true
    @object.marked_for_deletion.should be_true
  end
  it "should mark for deletion with 'true'" do
    @object.marked_for_deletion = "true"
    @object.marked_for_deletion.should be_true
  end
  it "should mark for deletion with 1" do
    @object.marked_for_deletion = "true"
    @object.marked_for_deletion.should be_true
  end
  it "should mark for deletion with '1'" do
    @object.marked_for_deletion = "true"
    @object.marked_for_deletion.should be_true
  end
  it "should unmark for deletion with anything else" do
    ["false", false, nil, "jo", 10, "one", Date.new].each do |value|
      @object.marked_for_deletion = true
      @object.marked_for_deletion = value
      @object.marked_for_deletion.should be_false
    end
  end
  it "should destroy existing records if marked for deletion after save" do
    @object = Winken.create!(:name => "name")
    @object.marked_for_deletion = true
    @object.save.should be_true
    lambda do
      @object.reload
    end.should raise_error(ActiveRecord::RecordNotFound)
  end
  it "should destroy new records" do
    @object = Winken.new(:name => "name")
    @object.marked_for_deletion = true
    @object.save!.should be_true
    lambda do
      @object.reload
    end.should raise_error(ActiveRecord::RecordNotFound)
  end
  it "should be a member of attributes when true" do
    @object.marked_for_deletion = true
    @object.attributes["marked_for_deletion"].should be_true
  end

end

describe Blinken do
  before(:each) do
    @object = Blinken.new
  end
  it "should be a member of attributes when nil" do
    @object.attributes["marked_for_deletion"].should be_false
  end
end
