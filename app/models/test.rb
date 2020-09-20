# == Schema Information
#
# Table name: tests
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(FALSE), not null
#  description             :text             not null
#  language                :string
#  level                   :integer          default("snitch")
#  minimum_pass_percentage :integer          default(80), not null
#  name                    :string
#  negative_feedback       :text
#  positive_feedback       :text
#  recertification         :boolean          default(FALSE)
#  testable_question_count :integer          default(0), not null
#  time_limit              :integer          default(18), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  certification_id        :integer
#

class Test < ApplicationRecord
  require 'csv'
  require 'activerecord-import/base'
  require 'activerecord-import/active_record/adapters/postgresql_adapter'

  MAXIMUM_RETRIES = 6

  belongs_to :certification

  has_many :questions, dependent: :destroy
  has_many :referee_answers, dependent: :nullify
  has_many :test_attempts, dependent: :nullify
  has_many :test_results, dependent: :nullify

  enum level: {
    snitch: 0,
    assistant: 1,
    head: 2
  }

  scope :active, -> { where(active: true) }
  scope :recertification, -> { where(recertification: true) }

  def fetch_random_questions
    questions.limit(testable_question_count).order(Arel.sql('RANDOM()'))
  end
end
