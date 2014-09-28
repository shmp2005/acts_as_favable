class ActsAsFavableMigration < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|

      t.references :favable, :polymorphic => true
      t.references :faver, :polymorphic => true

      t.string :note

      t.timestamps
    end

    if ActiveRecord::VERSION::MAJOR < 4
      add_index :favorites, [:favable_id, :favable_type]
      add_index :favorites, [:faver_id, :faver_type]
    end

    add_index :favorites, [:faver_id, :faver_type]
    add_index :favorites, [:favable_id, :favable_type]
  end

  def self.down
    drop_table :favorites
  end
end
