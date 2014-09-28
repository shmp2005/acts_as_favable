module ActsAsFavable
  module Faver

    def self.included(base)
      base.class_eval do

        has_many :favorites, :class_name => 'ActsAsFavable::Favorite', :as => :faver, :dependent => :destroy do
          def favables
            includes(:favable).map(&:favable)
          end

          def favables_with klass
            includes(:favable).where(favable_type: klass.name).map(&:favable)
          end
        end
      end
    end

    # faving
    def fav favable, args={}
      favable.faved_by self, args
    end

    # unfaving
    def unfav favable
      favable.unfaved_by self
    end

    # results
    def fav_on? favable
      favs = find_favs(:favable_id => favable.id, :favable_type => favable.class.base_class.name)
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
      klass.joins(:favs_for).merge find_favs(extra_conditions)
    end
  end
end
