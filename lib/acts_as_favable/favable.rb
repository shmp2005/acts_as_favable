module ActsAsFavable
  module Favable

    def self.included base
      base.class_eval do
        has_many :favs_for, :class_name => 'ActsAsFavable::Favorite', :as => :favable, :dependent => :destroy do
          def favers
            includes(:faver).map(&:faver)
          end
        end
      end
    end

    def default_conditions
      {
          :favable_id => self.id,
          :favable_type => self.class.base_class.name.to_s
      }
    end

    # faved
    def fav_by args = {}

      options = {}.merge(args)
      if options[:faver].nil?
        return false
      end

      # find the favorite
      _favs_ = find_favs_for({
                                 :faver_id => options[:faver].id,
                                 :note => options[:note],
                                 :faver_type => options[:faver].class.base_class.name
                             })

      if _faves_.count == 0 or options[:duplicate]
        # this faver has never faved
        fav = ActsAsFavable::Favorite.new(
            :favable => self,
            :faver => options[:faver]
        )
      else
        # this faver is potentially changing his fav
        fav = _favs_.last
      end

      fav.save
    end

    def unfav args = {}
      return false if args[:faver].nil?
      _favs_ = find_favs_for(:faver_id => args[:faver].id, :faver_type => args[:faver].class.base_class.name)

      return true if _favs_.size == 0
      _favs_.each(&:destroy)
      true
    end

    # results
    def find_favs_for extra_conditions = {}
      favs_for.where(extra_conditions)
    end

    # favers
    def faved_on_by? faver
      favs = find_faves_for :faver_id => faver.id, :faver_type => faver.class.base_class.name
      favs.count > 0
    end

  end
end
