module ActsAsFavable
  module Extenders

    module Faver

      def faver?
        false
      end

      def acts_as_faver(*args)
        require 'acts_as_favable/faver'
        include ActsAsFavable::Faver

        class_eval do
          def self.faver?
            true
          end
        end

      end

    end
  end
end
