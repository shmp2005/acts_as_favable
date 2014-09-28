require 'active_record'
require 'active_support/inflector'

$LOAD_PATH.unshift(File.dirname(__FILE__))

module ActsAsFavable

  if defined?(ActiveRecord::Base)
    require 'acts_as_favable/extenders/favable'
    require 'acts_as_favable/extenders/faver'
    require 'acts_as_favable/favorite'
    ActiveRecord::Base.extend ActsAsFavable::Extenders::Favable
    ActiveRecord::Base.extend ActsAsFavable::Extenders::Faver
  end

end

require 'acts_as_favable/extenders/controller'
ActiveSupport.on_load(:action_controller) do
  include ActsAsFavable::Extenders::Controller
end