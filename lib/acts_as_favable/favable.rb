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


    # faved
    def faved_by faver, args = {}

      options = {}.merge(args)
      return false if faver.nil?

      # find the favorite
      _favs_ = find_favs_for(faver_opts(faver))

      if _favs_.count == 0 or options[:duplicate]
        # this faver has never faved
        fav = ActsAsFavable::Favorite.new(
            faver_opts(faver).merge(default_conditions).merge(note: options[:note])
        )
      else
        # this faver is potentially changing his fav
        fav = _favs_.last
      end

      fav.save
    end

    def unfaved_by faver
      return false if faver.nil?
      _favs_ = find_favs_for faver_opts(faver)

      return true if _favs_.size == 0
      _favs_.each(&:destroy)
      true
    end

    # results
    def find_favs_for extra_conditions = {}
      favs_for.where(extra_conditions)
    end

    # favers
    def faved_by? faver
      favs = find_favs_for faver_opts(faver)
      favs.count > 0
    end

    private
    def default_conditions
      {:favable_id => self.id, :favable_type => self.class.base_class.name.to_s}
    end
    
    def faver_opts faver
      {:faver_id => faver.id, :faver_type => faver.class.base_class.name}
    end

  end
end
