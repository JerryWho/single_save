ActiveRecord::Schema.define(:version => 0) do
  create_table :winkens, :force => true do |t|
    t.string :name
  end
  create_table :blinkens, :force => true do |t|
    t.integer :winken_id
    t.integer :nod_id
    t.string :name
    t.boolean :marked_for_deletion, :default => false
  end
  create_table :nods, :force => true do |t|
    t.string :name
  end
  create_table :bars, :force => true do |t|
    t.string :name
  end
  create_table :bars_winkens, :force => true do |t|
    t.integer :winken_id
    t.integer :bar_id
  end
  create_table :tags, :force => true do |t|
    t.string :name
  end
  create_table :taggings, :force => true do |t|
    t.integer :winken_id
    t.integer :tag_id
  end
  create_table :foos, :force => true do |t|
    t.integer :winken_id
    t.string :name
  end
end
