require 'rails_helper'
require 'jwt'

describe AssessmentGrader do
  # example of what params to GradesController#create looks like
    # params = {"itemToGrade" =>
    #                   {"questions" =>
    #                            [{"id" => "4965",
    #                              "confidenceLevel" => "Just A Guess",
    #                              "timeSpent" => 4069,
    #                              "startTime" => 1449619801421,
    #                              "outcome_guid" => "f71c5ce2-46b7-4cce-9531-1680d42faf1b"},
    #                             {"id" => "3790",
    #                              "confidenceLevel" => "Pretty Sure",
    #                              "timeSpent" => 3236,
    #                              "startTime" => 1449619805490,
    #                              "outcome_guid" => "9a82d67b-21ce-4cbf-8298-6bd1109f03b2"},
    #                             {"id" => "5555",
    #                              "confidenceLevel" => "Very Sure",
    #                              "timeSpent" => 1593,
    #                              "startTime" => 1449619808726,
    #                              "outcome_guid" => "a9fc4312-f9dd-4430-bea7-b551790a4c51"},
    #                             ],
    #                    "answers" => [["4501"], ["6386"], ["6368"]],
    #                    "assessmentId" => "345",
    #                    "identifier" => "ib7b957adb7ce471691e27cf3dd9d37a7_swyk",
    #                    "settings" =>
    #                            {"externalUserId" => "1d59ddbce40747fd7c9664c7c08e24017b8b734c",
    #                             "externalContextId" => "d4dcc12bc137c611fb8d61d0cb77f1f6c4473f34",
    #                             "userAssessmentId" => "36853",
    #                             "userAttempts" => 3,
    #                             "srcUrl" =>
    #                                     "https://assessments.lumenlearning.com/api/assessments/345.xml?lti_context_id=d4dcc12bc137c611fb8d61d0cb77f1f6c4473f34",
    #                             "lisResultSourceDid" => "",
    #                             "lisOutcomeServiceUrl" => "",
    #                             "lisUserId" => "1d59ddbce40747fd7c9664c7c08e24017b8b734c",
    #                             "isLti" => true,
    #                             "ltiRole" => "admin",
    #                             "assessmentKind" => "show_what_you_know",
    #                             "accountId" => "1"}}}
  before do
    @questions = [{"id" => "4965",
                   "confidenceLevel" => "Just A Guess",
                   "timeSpent" => 4069,
                   "startTime" => 1449619801421,
                   "outcome_guid" => "f71c5ce2-46b7-4cce-9531-1680d42faf1b"},
                  {"id" => "3790",
                   "confidenceLevel" => "Pretty Sure",
                   "timeSpent" => 3236,
                   "startTime" => 1449619805490,
                   "outcome_guid" => "9a82d67b-21ce-4cbf-8298-6bd1109f03b2"},
                  {"id" => "5555",
                   "confidenceLevel" => "Very Sure",
                   "timeSpent" => 1593,
                   "startTime" => 1449619808726,
                   "outcome_guid" => "a9fc4312-f9dd-4430-bea7-b551790a4c51"},
                  ]

    @answers = [["9755"], ["483", "1708"], "6368"]

    file = File.join(__dir__, '../fixtures/swyk_quiz.xml')
    @assessment = Assessment.create!(title: 'testing', xml_file: open(file).read )
  end

  context "Grades quiz" do
    it "grades a quiz with all correctly chosen answers" do
      ag = AssessmentGrader.new(@questions, @answers, @assessment)
      ag.grade!
      expect(ag.score).to eq 1
      expect(ag.correct_list).to eq [true, true, true]
    end

    it "grades a quiz with all incorrectly chosen answers" do
      ag = AssessmentGrader.new(@questions, [["4501"], ["6386"], "7824"], @assessment)
      ag.grade!
      expect(ag.score).to eq 0
      expect(ag.correct_list).to eq [false, false, false]
    end

    it "grades a quiz with one wrong answer" do
      ag = AssessmentGrader.new(@questions, [["4501"], ["483", "1708"], "6368"], @assessment)
      ag.grade!
      expect(ag.score).to eq 0.667
      expect(ag.correct_list).to eq [false, true, true]
    end

    it "grades a quiz with one partially right" do
      ag = AssessmentGrader.new(@questions, [["9755"], ["483", "6386"], "6368"], @assessment)
      ag.grade!
      expect(ag.score).to eq 0.75
      expect(ag.correct_list).to eq [true, "partial", true]
    end
  end

end
