require 'jwt'

class AssessmentGrader

  attr_reader :questions, :answers, :assessment, :correct_list, :confidence_level_list

  def initialize(questions, answers, assessment)
    @questions = questions
    @answers = answers
    @assessment = assessment
    @correct_list = []
    @confidence_level_list = []
    @ungraded_questions = []
    @xml_index_list = []
    @answered_correctly = 0
    @doc = Nokogiri::XML(@assessment.assessment_xmls.where(kind: "formative").last.xml)
    @doc.remove_namespaces!
    @xml_questions = @doc.xpath("//item")
  end

  def grade!
    @questions.each_with_index do |question, index|
      # make sure we are looking at the right question
      xml_index = get_xml_index(question["id"], @xml_questions)
      @xml_index_list.push(xml_index)
      if question["id"] == @xml_questions[xml_index].attributes["ident"].value
        total = 0
        
        # find the question type
        # todo - don't grab type by order of metadata fields
        question["type"] = @xml_questions[xml_index].children.xpath("qtimetadata").children.xpath("fieldentry").children.text
        # if the question type gets some wierd stuff if means that the assessment has outcomes so we need
        # to get the question data a little differently
        if question["type"] != "multiple_choice_question" && question["type"] != "multiple_answers_question" && question["type"] != "matching_question"
          question["type"] = @xml_questions[xml_index].children.xpath("qtimetadata").children.xpath("fieldentry").children.first.text
        end

        # grade the question based off of question type
        if question["type"] == "multiple_choice_question"
          total = grade_multiple_choice(xml_index, @answers[index])
        elsif question["type"] == "multiple_answers_question"
          total = grade_multiple_answers(xml_index, @answers[index])
        elsif question["type"] == "mom_embed"
          total = grade_mom_embed(xml_index, @answers[index])
        end

        if total == 1 then @correct_list[index] = true
        elsif total == 0 then @correct_list[index] = false
        elsif total == ! 1 || 0 then @correct_list[index] = "partial" end

        @answered_correctly += total
        @confidence_level_list[index] = question["confidenceLevel"]
        question["score"] = total
      end
    end
  end

  def score
    ((@answered_correctly.to_f) / (@questions.length.to_f)).round(3)
  end

  def get_xml_index(id, xml_questions)
    xml_questions.each_with_index do |question, index|
      return index if question.attributes["ident"].value == id
    end
    return -1
  end

 def grade_multiple_choice(xml_index, answer)
   correct_answer_id = get_correct_mc_answer_id(xml_index)
   answer == correct_answer_id ? 1 : 0
 end

 def get_correct_mc_answer_id(xml_index)
   question = @xml_questions[xml_index]
   choices = question.children.xpath("respcondition")
   choices.each_with_index do |choice, index|
     # if the students response id matches the correct response id for the question the answer is correct
     setvar = choice.xpath("setvar")[0]
     if setvar && setvar.children.text == "100"
       return choice.xpath("conditionvar").xpath("varequal").children.text
     end
   end
 end

  # - for each correct chosen, add 1/#correct
  # - for each incorrectly chosen, subtract 1/total#
  # - make sure #correct * (1/#correct) is 1
  def grade_multiple_answers(xml_index, answers)
    question_node = @xml_questions[xml_index]

    correct_idents = question_node.children.xpath("respcondition").children.xpath("and").xpath("varequal").map(&:text)
    count_of_response_options = correct_idents.length + (question_node.children.xpath("respcondition").children.xpath("and").xpath("not").xpath("varequal")).length

    user_correct_count = 0
    correct_idents.each do |ident|
      user_correct_count += 1 if answers.include?(ident)
    end
    user_wrongly_chosen_count = (answers.length - user_correct_count)

    if user_correct_count == 0
      0
    elsif correct_idents.length == user_correct_count && user_wrongly_chosen_count == 0
      1
    else
      score = (((user_correct_count)/correct_idents.length.to_f) - (user_wrongly_chosen_count/count_of_response_options.to_f)).round(3)
      score < 0.0 ? 0.0 : score
    end
  end

  # MOM returns a a JWT signed with the shared secret
  # This allows us to trust the score even though it goes through the client
  # If the JWT is invalid we score the answer for 0 points
  # The JWT's payload looks like:
  # {
  #         "id" => 79660,
  #         "score" => 1,
  #         "redisplay" => "3766;0;(2,2)",
  #         "auth" => "secret_lookup_key"
  # }
  def grade_mom_embed(xml_index, answer)
    payload, header = JWT.decode(answer, Rails.application.secrets.mom_secret)

    # Verify that the score is for the designated question
    if payload["id"] == get_mom_question_id(xml_index)
      return payload["score"]
    end

    return 0
  rescue JWT::DecodeError
    # The token was invalid
    return 0
  end

  def get_mom_question_id(xml_index)
    question = @xml_questions[xml_index]
    id = question.children.at_css("material mat_extension mom_question_id").text.strip
    id.to_i
  end
end
