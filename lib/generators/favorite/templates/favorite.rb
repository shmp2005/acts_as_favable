class Favorite < ActiveRecord::Base

  include ActsAsFavable::Favorite

  belongs_to :favable, :polymorphic => true

  default_scope { order(created_at: :asc)}

  # NOTE: Favorite belongs to a user
  belongs_to :user
end