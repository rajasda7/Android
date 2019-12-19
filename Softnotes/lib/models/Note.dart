
class Note{
  int _id;
  String _title, _description, _date;

  Note(this._title, this._description, this._date);
  Note.withId(this._id, this._title, this._description, this._date);

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;

  set title(newTitle){
    this._title = newTitle;
  }

  set description(newDescription){
    this._description = newDescription;
  }

  set date(newDate){
    this._date = newDate;
  }

  //Convert note object into map object
Map<String, dynamic> noteToMap(){
    var map = Map<String, dynamic>();
    if(id != null){
      map['id']  = this._id;
    }
    map['title'] = this._title;
    map['description'] = this._description;
    map['date'] = this._date;
    return map;
}

// Convert map object into note
 Note.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._date = map['date'];
}

}