module ActsAsFavable
  module Extenders

    module Faver

      def faver?
        false
      end

      def acts_as_faver(*args)
        require 'acts_as_favable/faver'
        include ActsAsFavable::Faver

        args.each do |fav|

          define_method "fav_#{fav.model_name.route_key}" do
            ids = self.favorites.favables_with(fav).collect(&:favable_id)
            fav.where(Hash[fav.primary_key, ids])
          end
        end

        class_eval do
          def self.faver?
            true
          end
        end

      end

    end
  end
end
