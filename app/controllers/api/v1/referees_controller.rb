module Api
  module V1
    class RefereesController < ::ApplicationController
      before_action :authenticate_referee!, only: :update
      before_action :find_referee, only: %i[show update]
      skip_before_action :verify_authenticity_token

      layout false

      def index
        @referees = Services::FilterReferees.new(search_params).filter

        json_string = RefereeSerializer.new(@referees, include: serializer_include).serialized_json

        render json: json_string, status: :ok
      end

      def show
        json_string = RefereeSerializer.new(@referee, serializer_options).serialized_json

        render json: json_string, status: :ok
      end

      def update
        national_governing_body_ids = params.delete(:national_governing_body_ids)
        update_national_governing_bodies(national_governing_body_ids) if national_governing_body_ids.present?

        if @referee.update!(permitted_params)
          json_string = RefereeSerializer.new(@referee, serializer_options).serialized_json

          render json: json_string, status: :ok
        else
          render json: { error: @referee.errors.message }, status: :unprocessable_entity
        end
      end

      private

      def update_national_governing_bodies(ngb_ids)
        current_ngb_ids = @referee.national_governing_bodies.pluck(:id)
        national_governing_body_remove = current_ngb_ids - ngb_ids
        national_governing_body_add = ngb_ids - current_ngb_ids
        return unless national_governing_body_remove.present? || national_governing_body_add.present?

        to_remove = @referee.referee_locations.where(national_governing_body_id: national_governing_body_remove)
        to_remove.destroy_all if to_remove.present?

        ngb_records = NationalGoverningBody.where(id: national_governing_body_add)
        @referee.national_governing_bodies << ngb_records if ngb_records.present?
      end

      def find_referee
        @referee = Referee.find_by(id: params[:id])
      end

      def permitted_params
        params.permit(:id, :first_name, :last_name, :bio, :pronouns, :show_pronouns, :submitted_payment_at)
      end

      def search_params
        params.permit(:q, filter_by: [certifications: [], national_governing_bodies: []]).to_h.deep_symbolize_keys
      end

      def serializer_include
        @serializer_include ||= %i[national_governing_bodies certifications]
      end

      def serializer_options
        @serializer_options ||= {
          include: serializer_include,
          params: { current_user: current_referee }
        }
      end
    end
  end
end
