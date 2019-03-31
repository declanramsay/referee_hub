module Api
  module V1
    class QuestionsController < ApplicationController
      before_action :authenticate_referee!
      before_action :verify_admin, only: %i[create show update destroy]
      before_action :find_test
      before_action :find_question, only: %i[show update destroy]
      skip_before_action :verify_authenticity_token

      layout false

      def index
        questions = @test.questions

        json_string = QuestionSerializer.new(questions).serialized_json

        render json: json_string, status: :ok
      end

      def create
        question = Question.new(permitted_params)

        if @test.questions << question
          json_string = QuestionSerializer.new(question).serialized_json

          render json: json_string, status: :ok
        else
          render json: { error: @test.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        json_string = QuestionSerializer.new(@question).serialized_json

        render json: json_string, status: :ok
      end

      def update
        if @question.update!(permitted_params)
          json_string = QuestionSerializer.new(@question).serialized_json

          render json: json_string, status: :ok
        else
          render json: { error: @question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        json_string = QuestionSerializer.new(@question).serialized_json

        if @question.destroy!
          render json: json_string, status: :ok
        else
          render json: { error: @question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def find_test
        @test = Test.find_by(id: params[:test_id])
      end

      def find_question
        @question = @test.questions.find_by(id: params[:id])
      end

      def permitted_params
        params.permit(:description, :feedback, :points_available)
      end
    end
  end
end

