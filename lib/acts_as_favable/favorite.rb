module ActsAsFavable
  class Favorite < ::ActiveRecord::Base

    if defined?(ProtectedAttributes) || ::ActiveRecord::VERSION::MAJOR < 4
      attr_accessible :favable_id, :favable_type,
        :faver_id, :faver_type,
        :favable, :faver,
        :note
    end

    belongs_to :favable, :polymorphic => true
    belongs_to :faver, :polymorphic => true

    scope :for_type, lambda{ |klass| where(:favable_type => klass) }
    scope :by_type,  lambda{ |klass| where(:faver_type => klass) }

    validates_presence_of :favable_id
    validates_presence_of :faver_id

  end

end

