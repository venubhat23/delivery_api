module Api
  module V1
    class AdvertisementsController < ApplicationController
      # GET /api/v1/advertisements
      def index
        advertisements = Advertisement.active.current.order(start_date: :desc)
        render json: advertisements, status: :ok
      end
    end
  end
end