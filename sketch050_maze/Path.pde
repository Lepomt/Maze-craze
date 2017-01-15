class Path {
  Field start;
  Field end;
  float len;
  
  Path(Field s, Field e, float l) {
    start = s;
    end = e;
    len = l;
  }
};