"use strict";

import React from 'react';
import BaseComponent      from "../base_component";
import UserAssessmentsStore      from "../../stores/user_assessment";
import UserAssessmentActions      from "../../actions/user_assessments";
import {Table, Tr, Td} from 'reactable';
import moment from 'moment';

export default class Attempts extends BaseComponent{
  constructor(props, context){
    super(props, context);
    this.stores = [UserAssessmentsStore];
    this.context = context;
    this.state = this.getState();
    UserAssessmentActions.loadUserAssessments(props.params.contextId, props.params.assessmentId);
  }

  getState() {
    return {
      userAssessments: UserAssessmentsStore.current()
    };
  }

  setAttempts(id, count){
    UserAssessmentActions.updateUserAssessment(id, {attempts: count, context_id: this.props.params.contextId});
  }

  attemptsStuff(ua){
    return <div>
      {ua.attempts.map(function(attempt){
        var score = 'none',
            m = moment(attempt.created_at),
            date_sent = m.format('ddd, MMM Do, h:mm a [GMT] ZZ'),
            relative_time = m.fromNow();
        if(attempt.score){
          score = Math.round(attempt.score) + "%";
        }
      return <p title={date_sent}>Score: {score}</p>
    })}
      </div>
  }
  timeStuff(ua){
    return <div>
      {ua.attempts.map(function(attempt){
        var m = moment(attempt.created_at),
            date_sent = m.format('ddd, MMM Do, h:mm a [GMT] ZZ'),
            relative_time = m.fromNow();
      return <p title={relative_time}>{date_sent}</p>
    })}
      </div>
  }

  actions(ua) {
    if (ua.attempts_left == 1) {
      return <button className="btn btn-info" onClick={()=>{this.setAttempts(ua.id, 0)}}>Grant 1 attempt</button>;
    } else if (ua.attempts_left == 0) {
      return <div>
        <p><button className="btn btn-info" onClick={()=>{this.setAttempts(ua.id, 1)}}>Grant 1 attempt</button></p>
        <p><button className="btn btn-info" onClick={()=>{this.setAttempts(ua.id, 0)}}>Grant 2 attempts</button></p>
      </div>;
    }
  }

  quiz_name(){
    var name = "this quiz";
    if( this.state.userAssessments[0] ){
      name = this.state.userAssessments[0].assessment.name
    }

    return name;
  }

  render(){
    var that = this;
    return <div>
      <h2>Attempts for {this.quiz_name()}</h2>
      <Table
          className="small-12 columns"
          id="attempts_table"
          role="grid"
          style={{tableLayout:"fixed", width: "100%"}}
          filterPlaceholder="Filter by student name..."
          sortable={[
                      'Student Name'
                  ]}
          defaultSort="Student Name"
          filterable={['Student Name']}
          >
        {this.state.userAssessments.map(function (ua) {
          return <Tr key={ua.id}>
            <Td column="Student Name" value={ua.user.name}><span title={ua.user.email}>{ua.user.name}</span></Td>
            <Td column="Attempts">{that.attemptsStuff(ua)}</Td>
            <Td column="Attempts Remaining">{ua.attempts_left}</Td>
            <Td column="Actions">{that.actions(ua)}</Td>
          </Tr>
        })}
      </Table>
    </div>;
  }

};
module.export = Attempts;