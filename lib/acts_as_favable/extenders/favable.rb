module ActsAsFavable
  module Extenders

    module Favable

      def favable?
        false
      end

      def acts_as_favable
        require 'acts_as_favable/favable'
        include ActsAsFavable::Favable

        class_eval do
          def self.favable?
            true
          end
        end

      end

    end

  end
end
