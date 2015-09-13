class AssessmentResult < ActiveRecord::Base
  has_one :test_result, dependent: :destroy
  belongs_to :assessment
  belongs_to :user
  has_many :item_results, dependent: :destroy

  acts_as_taggable_on :keywords
  acts_as_taggable_on :objectives

  scope :by_status_final, -> { where(session_status: 'final') }

  STATUS_INITIAL = 'initial'
  STATUS_PENDING_SUBMISSION = 'pendingSubmission'
  STATUS_PENDING_RESPONSE_PROCESSING  = 'pendingResponseProcessing'
  STATUS_FINAL = 'final'

  STATUS_VALUES = [STATUS_INITIAL, STATUS_PENDING_SUBMISSION, STATUS_PENDING_RESPONSE_PROCESSING, STATUS_FINAL]

  def user_assessment
    UserAssessment.find_by_assessment_id_and_user_id(self.assessment_id, self.user_id)
  end

end
