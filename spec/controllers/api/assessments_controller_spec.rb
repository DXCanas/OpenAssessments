require 'rails_helper'

RSpec.describe Api::AssessmentsController, type: :controller do
  before do
    file = File.join(__dir__, '../../fixtures/assessment.xml')
    @xml = open(file).read

    @account = FactoryGirl.create(:account)
    @account.restrict_assessment_create = false
    @account.save!
    @user = FactoryGirl.create(:user, account: @account)
    @user.confirm!
    
    @admin = CreateAdminService.new.call
    @admin.make_account_admin({account_id: @account.id})

    @user_token = AuthToken.issue_token({ user_id: @user.id })
    @admin_token = AuthToken.issue_token({ user_id: @admin.id })

    allow(controller).to receive(:current_account).and_return(@account)
  end

  describe "GET 'index'" do

    before do
      request.headers['Authorization'] = @admin_token
    end
    it "returns http success" do
      FactoryGirl.create(:assessment)
      get 'index', format: :json, q: 'Question'
      expect(response).to have_http_status(200)
    end
    describe "search" do
      before do
        request.headers['Authorization'] = @admin_token
        @assessment = FactoryGirl.create(:assessment, title: "#{FactoryGirl.generate(:name)} batman dark knight", description: "#{FactoryGirl.generate(:description)} shrimp on the barbie")
        @outcome = FactoryGirl.create(:outcome)
        @assessment_outcome = FactoryGirl.create(:assessment_outcome, assessment: @assessment, outcome: @outcome)
      end
      it "should return the assessment from the title" do
        get 'index', format: :json, q: @assessment.title
        expect(assigns(:assessments)).to include(@assessment)
      end
      it "should return the assessment from the title" do
        get 'index', format: :json, q: "batman"
        expect(assigns(:assessments)).to include(@assessment)
      end
      it "should return the assessment from the description" do
        get 'index', format: :json, q: @assessment.description
        expect(assigns(:assessments)).to include(@assessment)
      end
      it "should return the assessment from the description" do
        get 'index', format: :json, q: "shrimp"
        expect(assigns(:assessments)).to include(@assessment)
      end
      it "should return the assessment from the outcome name" do
        pending "need to fix search using outcomes - commit 950c16f37c13e39914e4724fc7de0435d8d6b192"
        get 'index', format: :json, q: @outcome.name
        expect(assigns(:assessments)).to include(@assessment)
      end
    end
  end

  describe "GET 'show'" do
    before do
      request.headers['Authorization'] = @admin_token
      @assessment = FactoryGirl.create(:assessment, account: @account)
      @assessment_xml = AssessmentXml.create!(xml: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<questestinterop xmlns=\"http://www.imsglobal.org/xsd/ims_qtiasiv1p2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.imsglobal.org/xsd/ims_qtiasiv1p2 http://www.imsglobal.org/xsd/ims_qtiasiv1p2p1.xsd\">\n  <assessment ident=\"i84370e65ac8a6fa96a597c44612c1de2\" title=\"mc &amp; sa\">\n    <qtimetadata>\n      <qtimetadatafield>\n        <fieldlabel>cc_maxattempts</fieldlabel>\n        <fieldentry>1</fieldentry>\n      </qtimetadatafield>\n    </qtimetadata>\n    <section ident=\"root_section\">\n      <item ident=\"i7f0b73c230bd437902b54afe936999cd\" title=\"the mult chic\">\n        <itemmetadata>\n          <qtimetadata>\n            <qtimetadatafield>\n              <fieldlabel>question_type</fieldlabel>\n              <fieldentry>multiple_choice_question</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>points_possible</fieldlabel>\n              <fieldentry>1</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>assessment_question_identifierref</fieldlabel>\n              <fieldentry>i6313af431984f0cdb2f4fec664ff424c</fieldentry>\n            </qtimetadatafield>\n          </qtimetadata>\n        </itemmetadata>\n        <presentation>\n          <material>\n            <mattext texttype=\"text/html\">&lt;div&gt;&lt;p&gt;how much can you chuck?&lt;/p&gt;&lt;/div&gt;</mattext>\n          </material>\n          <response_lid ident=\"response1\" rcardinality=\"Single\">\n            <render_choice>\n              <response_label ident=\"1524\">\n                <material>\n                  <mattext texttype=\"text/plain\">not much at all</mattext>\n                </material>\n              </response_label>\n              <response_label ident=\"1744\">\n                <material>\n                  <mattext texttype=\"text/plain\">a whole TON</mattext>\n                </material>\n              </response_label>\n              <response_label ident=\"5690\">\n                <material>\n                  <mattext texttype=\"text/plain\">a hotdog</mattext>\n                </material>\n              </response_label>\n            </render_choice>\n          </response_lid>\n        </presentation>\n        <resprocessing>\n          <outcomes>\n            <decvar maxvalue=\"100\" minvalue=\"0\" varname=\"SCORE\" vartype=\"Decimal\"/>\n          </outcomes>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">1524</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"1524_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">1744</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"1744_fb\"/>\n          </respcondition>\n          <respcondition continue=\"No\">\n            <conditionvar>\n              <varequal respident=\"response1\">1744</varequal>\n            </conditionvar>\n            <setvar action=\"Set\" varname=\"SCORE\">100</setvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"correct_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_incorrect_fb\"/>\n          </respcondition>\n        </resprocessing>\n        <itemfeedback ident=\"general_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">you can chuck a lot</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"correct_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">that's a car!!!!!!</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"general_incorrect_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">dude, seriously?</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"1524_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">weakling</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"1744_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">that's right!</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n      </item>\n      <item ident=\"i26b905fa2ac9ed3ce3218bba203e958b\" title=\"the short answer\">\n        <itemmetadata>\n          <qtimetadata>\n            <qtimetadatafield>\n              <fieldlabel>question_type</fieldlabel>\n              <fieldentry>short_answer_question</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>points_possible</fieldlabel>\n              <fieldentry>1</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>assessment_question_identifierref</fieldlabel>\n              <fieldentry>i812edcb28e590638a4aa64d6bf497cc0</fieldentry>\n            </qtimetadatafield>\n          </qtimetadata>\n        </itemmetadata>\n        <presentation>\n          <material>\n            <mattext texttype=\"text/html\">&lt;div&gt;&lt;p&gt;What is your favorite color?&lt;/p&gt;&lt;/div&gt;</mattext>\n          </material>\n          <response_str ident=\"response1\" rcardinality=\"Single\">\n            <render_fib>\n              <response_label ident=\"answer1\" rshuffle=\"No\"/>\n            </render_fib>\n          </response_str>\n        </presentation>\n        <resprocessing>\n          <outcomes>\n            <decvar maxvalue=\"100\" minvalue=\"0\" varname=\"SCORE\" vartype=\"Decimal\"/>\n          </outcomes>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">Yellow</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"3389_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">yellow</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"9569_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">amarillo</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"4469_fb\"/>\n          </respcondition>\n          <respcondition continue=\"No\">\n            <conditionvar>\n              <varequal respident=\"response1\">Yellow</varequal>\n              <varequal respident=\"response1\">yellow</varequal>\n              <varequal respident=\"response1\">amarillo</varequal>\n              <varequal respident=\"response1\">blue</varequal>\n            </conditionvar>\n            <setvar action=\"Set\" varname=\"SCORE\">100</setvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"correct_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_incorrect_fb\"/>\n          </respcondition>\n        </resprocessing>\n        <itemfeedback ident=\"general_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">That dude is old.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"correct_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">You stay on the bridge. Good job.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"general_incorrect_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">You were thrown off the bridge.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"3389_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">good</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"9569_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">good again</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"4469_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">spanish</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n      </item>\n    </section>\n  </assessment>\n</questestinterop>\n", assessment_id: @assessment.id)
    end
    context "json" do
      it "returns http success" do
        get 'show', format: :json, id: @assessment.id
        expect(response).to have_http_status(200)
      end
    end
    context "xml" do
      it "renders the assessment QTI xml" do
        get 'show', format: :xml, id: @assessment.id
        expect(response).to have_http_status(200)
      end

      it "should use the per_sec value on the settings" do
        @assessment_xml.xml = open('./spec/fixtures/sections_assessment.xml').read
        @assessment_xml.save!

        @assessment.assessment_settings.create({per_sec: 1})

        get :show, format: :xml, id: @assessment.id

        node = Nokogiri::XML(response.body)
        node.css('section section').each do |s|
          expect(s.css('item').count).to eq 1
        end
      end

    end
  end

  describe "POST 'create'" do
    before do
      request.headers['Authorization'] = @admin_token
      @user = FactoryGirl.create(:user)
    end

    # context "xml" do

      # it "denies unauthenticated requests" do
      #   request.headers['Authorization'] = ""
      #   request.env['RAW_POST_DATA'] = @xml
      #   post :create, format: :xml
      #   expect(response.status).to eq(401)
      # end
      
      # it "creates an assessment xml" do
      #   request.headers['Authorization'] = @admin_token
      #   request.env['RAW_POST_DATA'] = @xml
      #   post :create, auth_token: @user.authentication_token, format: :xml
      #   expect(response).to have_http_status(201)
      # end

    # end


    context "json" do
      
      it "creates an assessment json" do
        xml_file = Rack::Test::UploadedFile.new File.join(Rails.root, 'spec', 'fixtures', 'assessment.xml')
        params = FactoryGirl.attributes_for(:assessment)
        params[:title] = 'Test'
        params[:description] = 'Test description'
        params[:xml_file] = xml_file
        params[:license] = 'test'
        post :create, assessment: params, format: :json
        expect(response).to have_http_status(201)
      end

      it "should create two assessment xml objects" do
        xml_file = Rack::Test::UploadedFile.new File.join(Rails.root, 'spec', 'fixtures', 'assessment.xml')
        params = FactoryGirl.attributes_for(:assessment)
        params[:title] = 'Test'
        params[:description] = 'Test description'
        params[:xml_file] = xml_file
        params[:license] = 'test'
        post :create, assessment: params, format: :json
        assessment_result = JSON.parse(response.body)
        assessment = Assessment.find(assessment_result['id'])
        expect(assessment.assessment_xmls.length).to eq(2)
      end

    end

  end

  describe "PUT 'update'" do
    before(:each) do
      request.headers['Authorization'] = @admin_token
      @assessment = FactoryGirl.create(:assessment)
      @assessment_xml = AssessmentXml.create!(xml: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<questestinterop xmlns=\"http://www.imsglobal.org/xsd/ims_qtiasiv1p2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.imsglobal.org/xsd/ims_qtiasiv1p2 http://www.imsglobal.org/xsd/ims_qtiasiv1p2p1.xsd\">\n  <assessment ident=\"i84370e65ac8a6fa96a597c44612c1de2\" title=\"mc &amp; sa\">\n    <qtimetadata>\n      <qtimetadatafield>\n        <fieldlabel>cc_maxattempts</fieldlabel>\n        <fieldentry>1</fieldentry>\n      </qtimetadatafield>\n    </qtimetadata>\n    <section ident=\"root_section\">\n      <item ident=\"i7f0b73c230bd437902b54afe936999cd\" title=\"the mult chic\">\n        <itemmetadata>\n          <qtimetadata>\n            <qtimetadatafield>\n              <fieldlabel>question_type</fieldlabel>\n              <fieldentry>multiple_choice_question</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>points_possible</fieldlabel>\n              <fieldentry>1</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>assessment_question_identifierref</fieldlabel>\n              <fieldentry>i6313af431984f0cdb2f4fec664ff424c</fieldentry>\n            </qtimetadatafield>\n          </qtimetadata>\n        </itemmetadata>\n        <presentation>\n          <material>\n            <mattext texttype=\"text/html\">&lt;div&gt;&lt;p&gt;how much can you chuck?&lt;/p&gt;&lt;/div&gt;</mattext>\n          </material>\n          <response_lid ident=\"response1\" rcardinality=\"Single\">\n            <render_choice>\n              <response_label ident=\"1524\">\n                <material>\n                  <mattext texttype=\"text/plain\">not much at all</mattext>\n                </material>\n              </response_label>\n              <response_label ident=\"1744\">\n                <material>\n                  <mattext texttype=\"text/plain\">a whole TON</mattext>\n                </material>\n              </response_label>\n              <response_label ident=\"5690\">\n                <material>\n                  <mattext texttype=\"text/plain\">a hotdog</mattext>\n                </material>\n              </response_label>\n            </render_choice>\n          </response_lid>\n        </presentation>\n        <resprocessing>\n          <outcomes>\n            <decvar maxvalue=\"100\" minvalue=\"0\" varname=\"SCORE\" vartype=\"Decimal\"/>\n          </outcomes>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">1524</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"1524_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">1744</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"1744_fb\"/>\n          </respcondition>\n          <respcondition continue=\"No\">\n            <conditionvar>\n              <varequal respident=\"response1\">1744</varequal>\n            </conditionvar>\n            <setvar action=\"Set\" varname=\"SCORE\">100</setvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"correct_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_incorrect_fb\"/>\n          </respcondition>\n        </resprocessing>\n        <itemfeedback ident=\"general_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">you can chuck a lot</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"correct_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">that's a car!!!!!!</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"general_incorrect_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">dude, seriously?</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"1524_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">weakling</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"1744_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">that's right!</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n      </item>\n      <item ident=\"i26b905fa2ac9ed3ce3218bba203e958b\" title=\"the short answer\">\n        <itemmetadata>\n          <qtimetadata>\n            <qtimetadatafield>\n              <fieldlabel>question_type</fieldlabel>\n              <fieldentry>short_answer_question</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>points_possible</fieldlabel>\n              <fieldentry>1</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>assessment_question_identifierref</fieldlabel>\n              <fieldentry>i812edcb28e590638a4aa64d6bf497cc0</fieldentry>\n            </qtimetadatafield>\n          </qtimetadata>\n        </itemmetadata>\n        <presentation>\n          <material>\n            <mattext texttype=\"text/html\">&lt;div&gt;&lt;p&gt;What is your favorite color?&lt;/p&gt;&lt;/div&gt;</mattext>\n          </material>\n          <response_str ident=\"response1\" rcardinality=\"Single\">\n            <render_fib>\n              <response_label ident=\"answer1\" rshuffle=\"No\"/>\n            </render_fib>\n          </response_str>\n        </presentation>\n        <resprocessing>\n          <outcomes>\n            <decvar maxvalue=\"100\" minvalue=\"0\" varname=\"SCORE\" vartype=\"Decimal\"/>\n          </outcomes>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">Yellow</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"3389_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">yellow</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"9569_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">amarillo</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"4469_fb\"/>\n          </respcondition>\n          <respcondition continue=\"No\">\n            <conditionvar>\n              <varequal respident=\"response1\">Yellow</varequal>\n              <varequal respident=\"response1\">yellow</varequal>\n              <varequal respident=\"response1\">amarillo</varequal>\n              <varequal respident=\"response1\">blue</varequal>\n            </conditionvar>\n            <setvar action=\"Set\" varname=\"SCORE\">100</setvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"correct_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_incorrect_fb\"/>\n          </respcondition>\n        </resprocessing>\n        <itemfeedback ident=\"general_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">That dude is old.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"correct_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">You stay on the bridge. Good job.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"general_incorrect_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">You were thrown off the bridge.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"3389_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">good</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"9569_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">good again</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"4469_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">spanish</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n      </item>\n    </section>\n  </assessment>\n</questestinterop>\n", assessment_id: @assessment.id)
    end

    it "should update an assessment" do
      xml_file = Rack::Test::UploadedFile.new File.join(Rails.root, 'spec', 'fixtures', 'assessment.xml')
      params = {}
      params[:title] = 'Test'
      params[:description] = 'Test description'
      params[:xml_file] = xml_file
      params[:license] = 'test'
      put :update, account_id: @account, id: @assessment.id, assessment: params, format: :json
      assessment = Assessment.find(@assessment.id)
      expect(assessment.title).to eq("Test")
      expect(assessment.description).to eq("Test description")
      expect(assessment.assessment_xmls.length).to eq(2)
      expect(assessment.assessment_xmls.first.xml).to include("conditionvar")
      expect(assessment.assessment_xmls.second.xml).not_to include("conditionvar")
      expect(assessment.assessment_xmls.first.xml).to include("Neptune") 
      expect(response).to have_http_status(:success)
    end

    it "doesn't delete assessment xmls if there is not a new xml file" do
      params = {}
      params[:title] = 'Test'
      params[:description] = 'Test description'
      params[:license] = 'test'
      put :update, account_id: @account, id: @assessment.id, assessment: params, format: :json
      assessment = Assessment.find(@assessment.id)
      expect(assessment.assessment_xmls.first.xml).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<questestinterop xmlns=\"http://www.imsglobal.org/xsd/ims_qtiasiv1p2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.imsglobal.org/xsd/ims_qtiasiv1p2 http://www.imsglobal.org/xsd/ims_qtiasiv1p2p1.xsd\">\n  <assessment ident=\"i84370e65ac8a6fa96a597c44612c1de2\" title=\"mc &amp; sa\">\n    <qtimetadata>\n      <qtimetadatafield>\n        <fieldlabel>cc_maxattempts</fieldlabel>\n        <fieldentry>1</fieldentry>\n      </qtimetadatafield>\n    </qtimetadata>\n    <section ident=\"root_section\">\n      <item ident=\"i7f0b73c230bd437902b54afe936999cd\" title=\"the mult chic\">\n        <itemmetadata>\n          <qtimetadata>\n            <qtimetadatafield>\n              <fieldlabel>question_type</fieldlabel>\n              <fieldentry>multiple_choice_question</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>points_possible</fieldlabel>\n              <fieldentry>1</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>assessment_question_identifierref</fieldlabel>\n              <fieldentry>i6313af431984f0cdb2f4fec664ff424c</fieldentry>\n            </qtimetadatafield>\n          </qtimetadata>\n        </itemmetadata>\n        <presentation>\n          <material>\n            <mattext texttype=\"text/html\">&lt;div&gt;&lt;p&gt;how much can you chuck?&lt;/p&gt;&lt;/div&gt;</mattext>\n          </material>\n          <response_lid ident=\"response1\" rcardinality=\"Single\">\n            <render_choice>\n              <response_label ident=\"1524\">\n                <material>\n                  <mattext texttype=\"text/plain\">not much at all</mattext>\n                </material>\n              </response_label>\n              <response_label ident=\"1744\">\n                <material>\n                  <mattext texttype=\"text/plain\">a whole TON</mattext>\n                </material>\n              </response_label>\n              <response_label ident=\"5690\">\n                <material>\n                  <mattext texttype=\"text/plain\">a hotdog</mattext>\n                </material>\n              </response_label>\n            </render_choice>\n          </response_lid>\n        </presentation>\n        <resprocessing>\n          <outcomes>\n            <decvar maxvalue=\"100\" minvalue=\"0\" varname=\"SCORE\" vartype=\"Decimal\"/>\n          </outcomes>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">1524</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"1524_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">1744</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"1744_fb\"/>\n          </respcondition>\n          <respcondition continue=\"No\">\n            <conditionvar>\n              <varequal respident=\"response1\">1744</varequal>\n            </conditionvar>\n            <setvar action=\"Set\" varname=\"SCORE\">100</setvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"correct_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_incorrect_fb\"/>\n          </respcondition>\n        </resprocessing>\n        <itemfeedback ident=\"general_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">you can chuck a lot</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"correct_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">that's a car!!!!!!</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"general_incorrect_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">dude, seriously?</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"1524_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">weakling</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"1744_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">that's right!</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n      </item>\n      <item ident=\"i26b905fa2ac9ed3ce3218bba203e958b\" title=\"the short answer\">\n        <itemmetadata>\n          <qtimetadata>\n            <qtimetadatafield>\n              <fieldlabel>question_type</fieldlabel>\n              <fieldentry>short_answer_question</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>points_possible</fieldlabel>\n              <fieldentry>1</fieldentry>\n            </qtimetadatafield>\n            <qtimetadatafield>\n              <fieldlabel>assessment_question_identifierref</fieldlabel>\n              <fieldentry>i812edcb28e590638a4aa64d6bf497cc0</fieldentry>\n            </qtimetadatafield>\n          </qtimetadata>\n        </itemmetadata>\n        <presentation>\n          <material>\n            <mattext texttype=\"text/html\">&lt;div&gt;&lt;p&gt;What is your favorite color?&lt;/p&gt;&lt;/div&gt;</mattext>\n          </material>\n          <response_str ident=\"response1\" rcardinality=\"Single\">\n            <render_fib>\n              <response_label ident=\"answer1\" rshuffle=\"No\"/>\n            </render_fib>\n          </response_str>\n        </presentation>\n        <resprocessing>\n          <outcomes>\n            <decvar maxvalue=\"100\" minvalue=\"0\" varname=\"SCORE\" vartype=\"Decimal\"/>\n          </outcomes>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">Yellow</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"3389_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">yellow</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"9569_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <varequal respident=\"response1\">amarillo</varequal>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"4469_fb\"/>\n          </respcondition>\n          <respcondition continue=\"No\">\n            <conditionvar>\n              <varequal respident=\"response1\">Yellow</varequal>\n              <varequal respident=\"response1\">yellow</varequal>\n              <varequal respident=\"response1\">amarillo</varequal>\n              <varequal respident=\"response1\">blue</varequal>\n            </conditionvar>\n            <setvar action=\"Set\" varname=\"SCORE\">100</setvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"correct_fb\"/>\n          </respcondition>\n          <respcondition continue=\"Yes\">\n            <conditionvar>\n              <other/>\n            </conditionvar>\n            <displayfeedback feedbacktype=\"Response\" linkrefid=\"general_incorrect_fb\"/>\n          </respcondition>\n        </resprocessing>\n        <itemfeedback ident=\"general_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">That dude is old.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"correct_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">You stay on the bridge. Good job.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"general_incorrect_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">You were thrown off the bridge.</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"3389_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">good</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"9569_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">good again</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n        <itemfeedback ident=\"4469_fb\">\n          <flow_mat>\n            <material>\n              <mattext texttype=\"text/plain\">spanish</mattext>\n            </material>\n          </flow_mat>\n        </itemfeedback>\n      </item>\n    </section>\n  </assessment>\n</questestinterop>\n") 
      expect(response).to have_http_status(:success)
    end
  end

end
