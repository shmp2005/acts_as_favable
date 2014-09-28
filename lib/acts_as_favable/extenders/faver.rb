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
          define_method "fav_#{fav.name.pluralize.downcase}" do
            self.favables_with(fav)
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
