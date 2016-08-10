"use strict";

import React                          from 'react';
import BaseComponent                  from '../base_component.jsx';
import Style                          from './css/style';
import {Accordion, AccordionSection}  from './accordion/accordion.js';
import ReviewAssessmentActions        from "../../actions/review_assessment";
import ReviewAssessmentStore          from "../../stores/review_assessment";
import SettingsStore                  from '../../stores/settings.js';

import Question                       from './question/question.jsx';
import OutcomeSection                 from './outcome_section/outcome_section.jsx';
import QuestionBlock                  from './question_block/question_block.jsx';
import QuestionInterface              from './question_interface/question_interface.jsx';
import ValidationMessages             from './validation_messages.jsx';
import CommunicationHandler           from "../../utils/communication_handler";
import Instructions                   from "./instructions.jsx";

export default class Edit extends BaseComponent{

  constructor(props, context) {
    super(props, context);
    this.stores = [ReviewAssessmentStore];
    this._bind("handleAddQuestion", "handleSaveAssessment", 'handleResize', 'handlePostMessageHomeNav');

    if(!ReviewAssessmentStore.isLoaded() && !ReviewAssessmentStore.isLoading()){
      ReviewAssessmentActions.loadAssessment(window.DEFAULT_SETTINGS, this.props.params["assessmentId"], true);
    }

    this.state = this.getState();
  }

  getState(){
    let assessment = ReviewAssessmentStore.current();
    if(assessment && !assessment.assessmentId){
      assessment.assessmentId = this.props.params["assessmentId"];
    }
    return {
      questions        : ReviewAssessmentStore.allQuestions(),
      outcomes         : ReviewAssessmentStore.outcomes(),
      settings         : SettingsStore.current(),
      assessment       : ReviewAssessmentStore.current(),
      needsSaving      : ReviewAssessmentStore.isDirty(),
      errorMessages    : ReviewAssessmentStore.errorMessages(),
      warningMessages  : ReviewAssessmentStore.warningMessages(),
      windowWidth      : window.innerWidth
    }
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.handleResize);
  }

  handleResize(e) {
    this.setState({
      windowWidth: window.innerWidth
    });
  }

  componentDidMount(){
    window.addEventListener('resize', this.handleResize);
    super.componentDidMount();
    CommunicationHandler.sendSize();
  }

  render(){
    let style = Style.styles();
    let windowWidth = this.state.windowWidth;
    let title = typeof this.state.assessment == 'undefined' || this.state.assessment == null ? '' : this.state.assessment.title;


    return (
      <div className="editQuizWrapper" style={style.editQuizWrapper}>
        <ValidationMessages errorMessages={this.state.errorMessages} warningMessages={this.state.warningMessages} needsSaving={this.state.needsSaving} />
        <div className="eqNewQuestion" style={_.merge({}, style.eqNewQuestion, this.btnAreaStyle())} >
          <label for="save_quiz" style={_.merge({}, style.addQuestionLbl, this.questionLblStyle())}>
            <button name='save_quiz' className='btn btn-sm' onMouseDown={this.toggleButtonStyle} onMouseUp={this.toggleButtonStyle} onClick={this.handleSaveAssessment} style={style.addQuestionBtn}>
              <img style={style.addQuestionImg} src="/assets/upload.png" alt="Save Assessment"/>
            </button>
            Save Assessment
          </label>
          <label for="add_question" style={_.merge({}, style.addQuestionLbl, this.questionLblStyle())}>
            <button name='add_question' className='btn btn-sm' onMouseDown={this.toggleButtonStyle} onMouseUp={this.toggleButtonStyle} onClick={()=>this.handleAddQuestion("top")} style={style.addQuestionBtn} >
              <img style={style.addQuestionImg} src="/assets/plus-52.png" alt="Add Question"/>
            </button>
            Add Question
          </label>
          <label for="studyplan" style={_.merge({}, style.addQuestionLbl, this.questionLblStyle())}>
            {windowWidth > 1000 ? 'Study Plan' : ''}
            <button name='studyplan' className='btn btn-sm' onMouseDown={this.toggleButtonStyle} onMouseUp={this.toggleButtonStyle} onClick={this.handlePostMessageHomeNav} style={style.addQuestionBtn} >
              <img style={_.merge({}, style.addQuestionImg, {width:'32px', height:'32px'})} src="/assets/return.png" alt="Study Plan"/>
            </button>
            {windowWidth < 1000 ? 'Study Plan' : ''}

          </label>
        </div>
        <div style={{paddingLeft: '40px'}}>
        <Instructions settings={this.state.settings}/>
        </div>
        <ul className="eqContent" style={{listStyleType: 'none', padding:'40px'}}>
          {this.displayQuestions()}
        </ul>
        <div className="eqNewQuestion" style={_.merge({}, style.eqNewQuestion, this.btnAreaStyle())} >
          <label for="save_quiz" style={_.merge({}, style.addQuestionLbl, this.questionLblStyle())}>
            <button name='save_quiz' className='btn btn-sm' onMouseDown={this.toggleButtonStyle} onMouseUp={this.toggleButtonStyle} onClick={this.handleSaveAssessment} style={style.addQuestionBtn}>
              <img style={style.addQuestionImg} src="/assets/upload.png" alt="Save Assessment"/>
            </button>
            Save Assessment
          </label>
          <label for="add_question" style={_.merge({}, style.addQuestionLbl, this.questionLblStyle())}>
            <button name='add_question' className='btn btn-sm' onMouseDown={this.toggleButtonStyle} onMouseUp={this.toggleButtonStyle} onClick={()=>this.handleAddQuestion("bottom")} style={style.addQuestionBtn} >
              <img style={style.addQuestionImg} src="/assets/plus-52.png" alt="Add Question"/>
            </button>
            Add Question
          </label>
          <label for="studyplan" style={_.merge({}, style.addQuestionLbl, this.questionLblStyle())}>
            {windowWidth > 1000 ? 'Study Plan' : ''}

            <button name='studyplan' className='btn btn-sm' onMouseDown={this.toggleButtonStyle} onMouseUp={this.toggleButtonStyle} onClick={()=>{CommunicationHandler.navigateHome()}} style={style.addQuestionBtn} >
              <img style={_.merge({}, style.addQuestionImg, {width:'32px', height:'32px'})} src="/assets/return.png" alt="Study Plan"/>
            </button>
            {windowWidth <= 1000 ? 'Study Plan' : ''}

          </label>
        </div>
      </div>
    );
  }

  /*CUSTOM HANDLER FUNCTIONS*/
  handleAddQuestion(placement){
    let question = {
      id: `newQuestion-${((Math.random() * 100) * (Math.random()*100))}`, //specifies new and has random num.
      title: 'New Question',
      edited: true,
      inDraft: true,
      isValid: false,
      question_type: 'multiple_choice_question',
      material: '',
      answers: [ReviewAssessmentStore.blankNewQuestion(), ReviewAssessmentStore.blankNewQuestion(), ReviewAssessmentStore.blankNewQuestion()],
      errorMessages: [],
      outcome: this.state.outcomes[0]
    };

    ReviewAssessmentActions.addAssessmentQuestion(question, placement);

  }

  toggleButtonStyle(e){

  }

  handleSaveAssessment(e) {
    if (this.state.errorMessages.length > 0) {
      alert("You must resolve the errors before saving.");
    } else if (this.state.warningMessages.length > 0) {
      var message = "Are you sure? ";
      this.state.warningMessages.forEach((m)=> { message = message + "\n" + m });

      var r = confirm(message);
      if (r == true) {
        ReviewAssessmentActions.saveAssessment(this.state.assessment);
      }
    } else if(this.state.needsSaving) {
      ReviewAssessmentActions.saveAssessment(this.state.assessment);
    }
  }

  handlePostMessageHomeNav(e){
    if(ReviewAssessmentStore.isDirty()){
      var r = confirm("If you leave your changes won't be saved.");
      if (r == true) {
        CommunicationHandler.navigateHome();
      }
    } else{
      CommunicationHandler.navigateHome();
    }
  }

  /*CUSTOM FUNCTIONS*/
  displayQuestions(){

    if(this.state.questions.length !== 0){
      return this.state.questions.map((question, index)=>{
        return (
          <Question key={index} question={question} outcomes={this.state.outcomes}/>
        )
      });
    }
    else if(!this.state.newQuestion){
      let noteStyle = {
        fontSize: '24px',
        color: '#CF0000',
        border: '1px solid #CF0000',
        padding: '15px'
      };
      let btnStyle = _.merge({}, Style.styles().addQuestionBtn, {borderRadius: '0', fontSize: '24px', padding: '0px 15px', margin:'0px', width: 'inherit'});
      return (<li style={noteStyle}> You currently don't have any quiz questions. Please click <button style={btnStyle} className='btn btn-sm' onClick={this.handleAddQuestion} >Here</button> to create one :)</li>)
    }
  }

  btnAreaStyle(){
    let windowWidth = this.state.windowWidth;
    let styles = {};
    if(windowWidth <= 1000){
      styles = {
        flexDirection: "column",
        justifyContent: "center",
        alignItems: 'center',
        margin: '20px auto 0px'
      }
    }

    return styles;
  }

  questionLblStyle(){
    let windowWidth = this.state.windowWidth;
    let styles = {};
    if(windowWidth <= 1000){
      styles = {
        marginLeft: '30%',
        width: '40%'
      }
    }

    return styles;
  }
};

module.export = Edit;
