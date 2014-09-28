module ActsAsFavable
  module Faver

    def self.included(base)

      # allow user to define these
      aliases = {
          :fav_for => [:likes],
          :unfav_for => [:unlike],
          :faved_on? => [:faved_for?]
      }

      base.class_eval do

        has_many :favorites, :class_name => 'ActsAsFavable::Favorite', :as => :faver, :dependent => :destroy do
          def favables
            includes(:favable).map(&:favable)
          end
        end

        aliases.each do |method, links|
          links.each do |new_method|
            alias_method(new_method, method)
          end
        end

      end

    end

    # faving
    def fav args
      args[:favable].fav_by args.merge({:faver => self})
    end

    def fav_for model=nil, args={}
      fav :favable => model, :note => args[:note]
    end

    def unfav_for model
      model.unfav :faver => self
    end

    # results
    def faved_on? favable
      favs = find_votes(:favable_id => favable.id, :favable_type => favable.class.base_class.name)
      favs.size > 0
    end

    def find_favs extra_conditions = {}
      favorites.where(extra_conditions)
    end

    def find_favs_for_class klass, extra_conditions = {}
      find_favs extra_conditions.merge({:favable_type => klass.name})
    end

    # Including polymporphic relations for eager loading
    def include_objects
      ActsAsFavable::Favorite.includes(:favable)
    end

    def find_faved_items extra_conditions = {}
      options = extra_conditions.merge :faver_id => id, :faver_type => self.class.base_class.name
      include_objects.where(options).collect(&:favable)
    end

    def get_faved klass, extra_conditions = {}
      klass.joins(:faves_for).merge find_faves(extra_conditions)
    end
  end
end
