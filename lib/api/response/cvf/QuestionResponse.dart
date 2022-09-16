class QuestionResponse {
  late String responseMessage;
  late int statusCode;
  late List<QuestionMaster> responseData;

  QuestionResponse({required this.responseMessage,required this.statusCode,required this.responseData});

  QuestionResponse.fromJson(Map<String, dynamic> json) {
    responseMessage = json['responseMessage'];
    statusCode = json['statusCode'];
    responseData = <QuestionMaster>[];
    if (json['responseData'] is List) {
      print('inni');
      json['responseData'].forEach((v) {
        responseData.add(new QuestionMaster.fromJson(v));
      });
    }else{
      print('asdkasbdjk');
      responseData.add(new QuestionMaster.fromJson(json['responseData']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseMessage'] = this.responseMessage;
    data['statusCode'] = this.statusCode;
    if (this.responseData != null) {
      data['responseData'] = this.responseData.map((v) => v.toJson()).toList();
    }
    return data;
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
        json['allquestion'].forEach((v) {
          allquestion.add(new Allquestion.fromJson(v));
        });
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

  Allquestion(
      {required this.Question_Id, required this.question,required this.businessId,required this.isCompulsory,required this.SelectedAnswer,required this.files, required this.categoryName,required this.answers});

  Allquestion.fromJson(Map<String, dynamic> json) {
    Question_Id = json['Question_Id'];
    question = json['Question'];
    businessId = json['Business_Id'];
    categoryName = json['Category_Name'];
    isCompulsory = json['isCompulsory'] ?? '';
    SelectedAnswer = json['SelectedAnswer'] ?? '';
    files = json['files'] ?? '';
    /*if (json['answers'] != null) {
      answers = <Answers>[];
      *//*if(json['answers'].toString().contains('[')) {
        json['answers'].forEach((v) {
          answers.add(new Answers.fromJson(v));
        });
      }else{
        answers.add(new Answers.fromJson(json['answers']));
      }*//*
    }*/
    print('Data from model');
    print(json['answers']);
    answers = <Answers>[];
    if (json.containsKey('answers')) {
      print('key found');
      if( json['answers'] is List) {
        print('key found -- list');
        json['answers'].forEach((v) {
          answers.add(new Answers.fromJson(v));
        });
      }else{
        print('key found Object');
        answers.add(new Answers.fromJson(json['answers']));
      }
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
    if (this.answers != null) {
      data['answers'] = this.answers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Answers {
  late String answerName;
  late String answerType;

  Answers({required this.answerName,required  this.answerType});

  Answers.fromJson(Map<String, dynamic> json) {
    answerName = json['Answer_Name'];
    answerType = json['Answer_Type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Answer_Name'] = this.answerName;
    data['Answer_Type'] = this.answerType;
    return data;
  }
}
