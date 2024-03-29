import 'dart:convert';

import 'package:flutter/cupertino.dart';

class QuestionResponse {
  late String responseMessage;
  late int statusCode;
  late List<QuestionMaster> responseData;

  QuestionResponse({required this.responseMessage,required this.statusCode,required this.responseData});

  QuestionResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = <QuestionMaster>[];
    try {
      if (json['responseData'] is List) {
        json['responseData'].forEach((v) {
          responseData.add(new QuestionMaster.fromJson(v));
        });
      } else {
        responseData.add(new QuestionMaster.fromJson(json['responseData']));
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  toJsonMap(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    if (this.responseData != null) {
      data['responseData'] = this.responseData.map((v) => v.toJson()).toList();
    }
    return data;
  }
  toJson() {
    /**/
    return jsonEncode( {
      'responseMessage': this.responseMessage,
      'statusCode': this.statusCode,
      'responseData' : this.responseData.map((v) => v.toJson()).toList()
    });
  }
}

class QuestionMaster {
  late String categoryName;
  late String categoryId;
  late List<Allquestion> allquestion;

  QuestionMaster({required this.categoryName,required  this.categoryId,required  this.allquestion});

  QuestionMaster.fromJson(Map<String, dynamic> json) {
    categoryName = json['Category_Name'];
    categoryId = json['Category_Id'];
    allquestion = <Allquestion>[];
    if (json.containsKey('allquestion')) {
      if( json['allquestion'] is List) {
        try {
          json['allquestion'].forEach((v) {
            allquestion.add(new Allquestion.fromJson(v));
          });
        }catch(e){
          debugPrint('error ${e.toString()}');
        }
      }else{
        allquestion.add(new Allquestion.fromJson(json['allquestion']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Category_Name'] = this.categoryName;
    data['Category_Id'] = this.categoryId;
    if (this.allquestion != null) {
      data['allquestion'] = this.allquestion.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Allquestion {
  late String Question_Id;
  late String question;
  late String businessId;
  late String isCompulsory;
  late String SelectedAnswer;
  late String files;
  late String categoryName;
  late List<Answers> answers;
  late String userAnswers='';
  late String Remarks='';
  late String IsProgressive='';
  late String startDate='';
  late String endDate='';

  toStartDateXml(){
    if(this.startDate.isEmpty || this.startDate=='NA')
      return '';
    else return '<StartDate>${this.startDate}</StartDate>';
  }

  toEndDateXml(){
    if(this.endDate.isEmpty || this.endDate=='NA')
      return  '';
    else return '<EndDate>${this.endDate}</EndDate>';
  }

  Allquestion(
      {required this.Question_Id, required this.question,required this.businessId,required this.isCompulsory,required this.SelectedAnswer,required this.files, required this.categoryName,required this.answers, required this.Remarks,required this.IsProgressive,required this.startDate,required this.endDate});

  Allquestion.fromJson(Map<String, dynamic> json) {
    try {
      Question_Id = json['Question_Id'];
      question = json['Question'];
      businessId = json['Business_Id'];
      categoryName = json['Category_Name'];
      isCompulsory = json['isCompulsory'] ?? '';
      SelectedAnswer = json['SelectedAnswer'] ?? '';
      files = json['files'] ?? '';
      Remarks = json['Remarks'] ?? '';
      IsProgressive = json['IsProgressive'] ?? '0';
      startDate = json['StartDate'] ?? 'NA';
      endDate = json['EndDate'] ?? 'NA';
      answers = <Answers>[];
      if (json.containsKey('answers')) {
        if (json['answers'] is List) {
          json['answers'].forEach((v) {
            answers.add(new Answers.fromJson(v));
          });
        } else {
          answers.add(new Answers.fromJson(json['answers']));
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Question_Id'] = this.Question_Id;
    data['Question'] = this.question;
    data['Business_Id'] = this.businessId;
    data['Category_Name'] = this.categoryName;
    data['isCompulsory'] = this.isCompulsory;
    data['SelectedAnswer'] = this.SelectedAnswer;
    data['files'] = this.files;
    data['Remarks'] = this.Remarks;
    data['IsProgressive'] = this.IsProgressive;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    if (this.answers != null) {
      data['answers'] = this.answers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Answers {
  late String answerName;
  late String answerType;
  late String answerId;
  late String rating;

  Answers({required this.answerName,required  this.answerType});

  Answers.fromJson(Map<String, dynamic> json) {
    answerName = json['Answer_Name'];
    answerType = json['Answer_Type'];
    answerId = json['Answer_Id'];
    rating = json['Rating'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Answer_Name'] = this.answerName;
    data['Answer_Type'] = this.answerType;
    data['Answer_Id'] = this.answerId;
    data['Rating'] = this.rating;
    return data;
  }
}
