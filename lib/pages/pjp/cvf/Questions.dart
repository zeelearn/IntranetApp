class Question {
  final int id, answer;
  final String question;
  final List<String> options;

  Question({required this.id,required  this.question,required  this.answer,required  this.options});
}

const List sample_data = [
  {
    "id": 1,
    "question":
        "The School Are is Clean ______",
    "options": ['Very Good', 'Good', 'Poor', 'Other'],
    "answer_index": 1,
  },
  {
    "id": 2,
    "question": "Is School Calendar is displayed in the School",
    "options": ['Yes', 'No', 'Other'],
    "answer_index": 2,
  },
  {
    "id": 3,
    "question": "Attendance captured daily basis.",
    "options": ['Yes', 'No', 'Other'],
    "answer_index": 2,
  },
  {
    "id": 4,
    "question": "What command do you use to output data to the screen?",
    "options": ['Cin', 'Count>>', 'Cout', 'Output>>'],
    "answer_index": 2,
  },
  {
    "id": 1,
    "question":
        "The School Are is Clean ______",
    "options": ['Very Good', 'Good', 'Poor', 'Other'],
    "answer_index": 1,
  },
  {
    "id": 2,
    "question": "Is School Calendar is displayed in the School",
    "options": ['Yes', 'No', 'Other'],
    "answer_index": 2,
  },
  {
    "id": 3,
    "question": "Attendance captured daily basis.",
    "options": ['Yes', 'No', 'Other'],
    "answer_index": 2,
  },
  {
    "id": 4,
    "question": "What command do you use to output data to the screen?",
    "options": ['Cin', 'Count>>', 'Cout', 'Output>>'],
    "answer_index": 2,
  },
];
