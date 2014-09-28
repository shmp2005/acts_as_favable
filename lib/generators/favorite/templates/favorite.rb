class Favorite < ActiveRecord::Base

  include ActsAsFavable::Favorite

  belongs_to :favable, :polymorphic => true

  # NOTE: Favorite belongs to a user
  belongs_to :user
end