module ActsAsFavable
  module Extenders

    module Controller

      def faver_params(params_object = params[:favorite])
        params_object.permit(:favable_id, :favable_type,
          :faver_id, :faver_type,
          :favable, :faver,
          :note)
      end

    end
  end
end
