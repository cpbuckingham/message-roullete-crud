class CreateMessageTable < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.string  :message
      t.integer :likes
    end
  end

  def down
    drop_table :messages
  end
end
