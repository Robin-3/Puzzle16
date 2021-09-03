int size_x, size_y;
Cell board[][];
boolean re_draw, show_numbers, all_size;
int n_moves;
int mouse_x, mouse_y;
int[] index, cell_no_exist;
PImage img;

void setup() {
  size(640, 640, P2D);
  surface.setResizable(true);
  mouse_x = 0;
  mouse_y = 0;
  index = new int[2];
  cell_no_exist = new int[2];
  re_draw = true;
  n_moves = 0;
  textAlign(LEFT, TOP);
  textureMode(NORMAL);
  strokeWeight(2);
  start_data();
}
void start_data() {
  int _x = 0;
  int _y = 0;
  String img_name = "";
  String[] data = loadStrings("data/Settings.txt");
  
  for (int i = 0; i < data.length; i++) {
    String[] _d = split(data[i], ":");
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("columns")) {
      size_x = int(_d[1].replaceAll("\\s", ""));
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("rows")) {
      size_y = int(_d[1].replaceAll("\\s", ""));
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("imagename")) {
      img_name = _d[1].replaceAll("\\s", "");
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("startx")) {
      _x = int(_d[1].replaceAll("\\s", ""));
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("starty")) {
      _y = int(_d[1].replaceAll("\\s", ""));
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("fullsize")) {
      all_size = _d[1].toLowerCase().replaceAll("\\s", "") == "true";
    }
  }
  _x = floor(clamp(_x, -1, size_x-1));
  _y = floor(clamp(_y, -1, size_y-1));
  if (_x == -1) _x = floor(random(size_x));
  if (_y == -1) _y = floor(random(size_y));
  board = new Cell[size_x][size_y];
  img = loadImage("data/"+img_name);
  for (int j = 0; j < size_y; j++) {
    for (int i = 0; i < size_x; i++) {
      board[i][j] = new Cell(i + j*size_x + 1, i, j);
    }
  }
  show_numbers = true;
  board[_x][_y].no_exist = true;
  cell_no_exist[0] = _x;
  cell_no_exist[1] = _y;
  Generate(floor(pow(size_x * size_y, 2)));
  n_moves = 0;
}

void draw() {
  float w = width/(float) size_x;
  float h = height/(float) size_y;
  float offset_x = 0;
  float offset_y = 0;
  if (!all_size) {
    w = map(img.width, 0, img.height, 0, height)/(float) size_x;
    h = map(img.height, 0, img.height, 0, height)/(float) size_y;
    if (w * size_x > width) {
      w = map(img.width, 0, img.width, 0, width)/(float) size_x;
      h = map(img.height, 0, img.width, 0, width)/(float) size_y;
    }
  }  
  offset_x = (width - w*size_x)/2;
  offset_y = (height - h*size_y)/2;
  mouse_x = floor(clamp(map(mouseX, offset_x, w * size_x + offset_x, 0, size_x), 0, size_x-1));
  mouse_y = floor(clamp(map(mouseY, offset_y, h * size_y + offset_y, 0, size_y), 0, size_y-1));
  if (!all_size) translate(offset_x, offset_y);
  for (int j = 0; j < size_y; j++) {
    for (int i = 0; i < size_x; i++) {
      if (board[i][j].no_exist) {
        index[0] = i;
        index[1] = j;
        i = size_x;
        j = size_y;
      }
    }
  }
  if (re_draw) {
    background(0);
    surface.setTitle("Move #"+n_moves+" FPS: "+frameRate);
    for (int j = 0; j < size_y; j++) {
      for (int i = 0; i < size_x; i++) {
        noStroke();
        noFill();
        if (board[i][j].no_exist) {
          index[0] = i;
          index[1] = j;
          if (show_numbers) {
            stroke(255, 255/2);
            ellipse(i*w + w/2, j*h + h/2, w, h);
            rect(i*w, j*h, w, h);
          }
        } else {
          beginShape();
          texture(img);
          vertex(i*w, j*h, map(board[i][j].x, 0, size_x, 0, 1), map(board[i][j].y, 0, size_y, 0, 1));
          vertex(i*w + w, j*h, map(board[i][j].x+1, 0, size_x, 0, 1), map(board[i][j].y, 0, size_y, 0, 1));
          vertex(i*w + w, j*h + h, map(board[i][j].x+1, 0, size_x, 0, 1), map(board[i][j].y+1, 0, size_y, 0, 1));
          vertex(i*w, j*h + h, map(board[i][j].x, 0, size_x, 0, 1), map(board[i][j].y+1, 0, size_y, 0, 1));
          endShape(CLOSE);
          if (show_numbers) {
            fill(255, 255/2);
            stroke(255, 255/2);
            rect(i*w, j*h, 8*str(board[i][j].number).length(), 16, 2);
            fill(0);
            text(board[i][j].number, i*w, j*h);
          }
        }
      }
    }
    if (show_numbers) {
      noFill();
      stroke(255, 255/2);
      rect(0, 0, w*size_x, h*size_y);
    }
  }
}
void mousePressed() {
  //0 = Der || 1 = Arr || 2 = Izq || 3 = Aba//
  if (mouse_x > index[0] && mouse_y == index[1])
    change(0, index[0], index[1]);
  if (mouse_x == index[0] && mouse_y < index[1])
    change(1, index[0], index[1]);
  if (mouse_x < index[0] && mouse_y == index[1])
    change(2, index[0], index[1]);
  if (mouse_x == index[0] && mouse_y > index[1])
    change(3, index[0], index[1]);
  re_draw = true;
}

void mouseReleased() {
  re_draw = false;
}

void keyPressed() {
  if (key == 'g' || key == 'G' || key == 's' || key == 'S') {
    String number_grid_txt = "";
    for (int j = 0; j < size_y; j++) {
      for (int i = 0; i < size_x; i++) {
        number_grid_txt += (board[i][j].no_exist)? "": board[i][j].number;
        if (i < size_x-1)
          number_grid_txt += ",";
      }
      if (j < size_y-1)
        number_grid_txt += "\n";
    }
    String[] n_grid_txt = split(number_grid_txt, "\n");
    saveStrings("data/"+year()+"_"+month()+"_"+day()+"/number_grid_"+n_moves+".csv", n_grid_txt);
  }
  if (key == 'i' || key == 'I' || key == 's' || key == 'S') {
    save("data/"+year()+"_"+month()+"_"+day()+"/img_"+n_moves+".jpg");
  }
  if (key == 'n' || key == 'N') {
    show_numbers = !show_numbers;
    re_draw = true;
  }
  if (key == 'r' || key == 'R') {
    start_data();
    re_draw = true;
  }
}

void Generate(int _n) {
  for (int k = 0; k < _n; k++) {
    int i = cell_no_exist[0];
    int j = cell_no_exist[1];
    boolean changed = false;
    //0 = Der || 1 = Arr || 2 = Izq || 3 = Aba//
    int _dir = -1;
    while (!changed) {
      _dir = floor(random(4));
      switch(_dir) {
      case 0:
        if (i < size_x-1) changed = true;
        break;
      case 1:
        if (j > 0) changed = true;
        break;
      case 2:
        if (i > 0) changed = true;
        break;
      case 3:
        if (j < size_y-1) changed = true;
        break;
      }
    }
    change(_dir, i, j);
  }
}

void change(int _dir, int x, int y) {
  n_moves++;
  Cell temp_c = board[x][y];
  switch(_dir) {
  case 0: //0 = Der
    board[x][y] = board[x+1][y];
    board[x+1][y] = temp_c;
    temp_c = board[x][y];
    break;
  case 1: //1 = Arr
    board[x][y] = board[x][y-1];
    board[x][y-1] = temp_c;
    temp_c = board[x][y];
    break;
  case 2: //2 = Izq
    board[x][y] = board[x-1][y];
    board[x-1][y] = temp_c;
    temp_c = board[x][y];
    break;
  case 3: //3 = Aba
    board[x][y] = board[x][y+1];
    board[x][y+1] = temp_c;
    temp_c = board[x][y];
    break;
  }
  cell_no_exist[0] = temp_c.x;
  cell_no_exist[1] = temp_c.y;
}

float clamp(float val, float min, float max) {
  if (val < min) val = min;
  if (val > max) val = max;
  return val;
}
