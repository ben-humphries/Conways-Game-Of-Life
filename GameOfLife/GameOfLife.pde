
boolean[][] cells;
int screenSize = 800;
int numCells = 100;
int cellSize = screenSize/numCells;
boolean noStroke = true;

float lastGenerationTime;
float generationDeltaTime = 1000f; // 1 second

int lastGridX;
int lastGridY;
boolean lastMousePressed = false;

boolean openFileSelected;
boolean saveFileSelected;

String openFileText = "";
String saveFileText = "";

boolean running = false;

void settings(){
   size(screenSize,screenSize + 200);
}
void setup(){
  cells = new boolean[numCells][numCells];
  
  //for(int x = 0; x< cells.length; x++){
  //  for(int y = 0; y < cells.length; y++){
  //    cells[x][y] = (random(0,1) > 0.5) ? true : false;
  //  }
  //}
  
  lastGenerationTime = millis();
  
  background(100);
  drawGeneration();
  drawUI(false, false);
}

void draw(){
  
  //print(frameRate + "\n");

  if(running){
    if(millis() - lastGenerationTime >= generationDeltaTime){
      
      nextGeneration();
      drawGeneration();
      
      lastGenerationTime = millis();
    
    }
  }else{
    
    if(mousePressed){
      
      if(!lastMousePressed){
        updateLastGrid();
      }
      
      if((mouseX < screenSize && mouseX >= 0) && (mouseY < screenSize && mouseY >= 0)){
        
        if(mouseButton == LEFT){
          paintCells(true);
        }
        else if(mouseButton == RIGHT){
          paintCells(false);
        }
      }
      
      updateLastGrid();
      lastMousePressed = true;
    }else{
      lastMousePressed = false;
    }
  }
  
}
void keyPressed(){
  
  if(key == ENTER){
    running = !running;
  }
  else if(key == ' ' && !running){
    nextGeneration();
    drawGeneration();
  }
  else if( key != DELETE && key != SHIFT && key != CONTROL && key != ALT){
    if(openFileSelected){
      if(key == BACKSPACE && openFileText.length() > 0){
        openFileText = openFileText.substring(0, openFileText.length()-1);
      }else{
        openFileText += key;
      }
    }
    else if(saveFileSelected){
      if(key == BACKSPACE && saveFileText.length() > 0){
        saveFileText = saveFileText.substring(0, saveFileText.length()-1);
      }else{
        saveFileText += key;
      }
    }
    drawUI(openFileSelected, saveFileSelected);
  }
  
}

void mousePressed(){
  if(overButton(175, screenSize + 32, 400, 40)){
      drawUI(true, false);
      openFileSelected = true;
      saveFileSelected = false;
    }
   else if(overButton(175 + 40, screenSize + 64 + 10, 400, 40)){
     drawUI(false, true);
     openFileSelected = false;
     saveFileSelected = true;
   }
   else if(overButton(0, screenSize + 96 + 20, 100, 40)){
      clearGrid();
      drawUI(false, false);
      openFileSelected = false;
      saveFileSelected = false;
   }
   else if(overButton(0, screenSize + 32, 170, 40)){
      openFile(openFileText);
   }
   else if(overButton(0, screenSize + 64 + 10, 210, 40)){
      saveFileAs(saveFileText);
   }
   else{
      drawUI(false, false);
      openFileSelected = false;
      saveFileSelected = false;
   }
}

boolean overButton(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void openFile(String dir){
  println("OPENING FILE: " + dir);
  
  String[] lines = loadStrings(dir); 
  String text = "";
  
  if(lines != null){
    for(String line : lines){
      String[] pieces = line.split("\\s*,\\s*");
      for(int i = 0; i < pieces.length; i++){
        text += pieces[i];
      }
      text += "|";
    }
    
    int x = 0;
    int y = 0;
    for(int i = 0; i < text.length(); i++){
      if(text.charAt(i) == '|'){
        x = 0;
        y ++;
        continue;
      }
      
      cells[x][y] = text.charAt(i) == '1' ? true : false;
      x++;
    }
  }
  
  drawGeneration();
  
  print("FINISHED OPENING " + dir);
  
}
void saveFileAs(String dir){
  println("SAVING FILE: " + dir);
  
  PrintWriter saveFile;
  
  saveFile = createWriter(dir);
  
  for(int y = 0; y< cells.length; y++){
    for(int x = 0; x < cells.length; x++){
      saveFile.print((cells[x][y] ? "1" : "0") + ((x < cells.length - 1) ? ", " : ""));
    }
    saveFile.print("\n");
  }
  
  saveFile.flush();
  saveFile.close();
  
  println("FINISHED SAVING " + dir);
}

void clearGrid(){
  for(int x = 0; x< cells.length; x++){
    for(int y = 0; y < cells.length; y++){
      cells[x][y] = false;
    }
  }
  drawGeneration();
}

void drawUI(boolean openFileSelected, boolean saveFileAsSelected){
  
    //OPEN FILE
    fill(210);
    rect(0, screenSize + 32, 170, 40, 5);
    
    fill(0);
    textSize(32);
    text("OPEN FILE:", 0, screenSize + 32, 300, 40);
    
    fill(openFileSelected ? 150 : 255);
    rect(175, screenSize + 32, 400, 40, 5);
    fill(0);
    text(openFileText, 175, screenSize + 32, 400, 40);
    
    //SAVE FILE AS
    fill(210);
    rect(0, screenSize + 64 + 10, 210, 40, 5);
    
    fill(0);
    textSize(32);
    text("SAVE FILE AS:", 0, screenSize + 64 + 10, 210, 40);
    
    fill(saveFileAsSelected ? 150 : 255);
    rect(175 + 40, screenSize + 64 + 10, 400, 40, 5);
    fill(0);
    text(saveFileText, 175 + 40, screenSize + 64 + 10, 400, 40);

    
    //CLEAR
    fill(225);
    rect(0, screenSize + 96 + 20, 100, 40, 5);
    
    fill(0);
    textSize(32);
    text("CLEAR", 0, screenSize + 96 + 20, 300, 40);
  
}

void updateLastGrid(){
  
  lastGridX = mouseX / cellSize;
  lastGridY = mouseY / cellSize;
  
}

void paintCells(boolean alive){
  
  cells[mouseX / cellSize][mouseY / cellSize] = alive;
  
  walkGrid(mouseX / cellSize, mouseY / cellSize, lastGridX, lastGridY, alive);
  
  drawGeneration();
  
}

void walkGrid(int x0, int y0, int x1, int y1, boolean alive){

  
  int dx = x1 - x0;
  int dy = y1 - y0;
  
  int signX = dx > 0 ? 1 : -1, signY = dy > 0 ? 1 : -1;
  
  int nx = abs(dx);
  int ny = abs(dy);
  
  if(nx <= 1 && ny <= 1){
    return;
  }
  
  int nextX = x0, nextY = y0;
  
  for(int ix = 0, iy = 0; ix < nx || iy < ny;){
    if((0.5+ix)/nx < (0.5+iy)/ny){
      //horizontal step
      nextX += signX;
      ix++;
    }else{
      //vertical step
      nextY += signY;
      iy++;
    }
    
    nextX = constrain(nextX, 0, numCells-1);
    nextY = constrain(nextY, 0, numCells-1);
    
    cells[nextX][nextY] = alive;
  }
}

void drawGeneration(){
  
  
  for(int x = 0; x< cells.length; x++){
    for(int y = 0; y < cells.length; y++){
      
      if(noStroke){
          noStroke();
        }else{
          stroke(50);
        }
      
      if(cells[x][y]){
        fill(255);
      }else{
        stroke(50);
        fill(0);
      }
      
        rect(x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
}
void nextGeneration(){
  
  boolean[][] nextCells = new boolean[numCells][numCells];
  
  for(int x = 0; x< cells.length; x++){
    for(int y = 0; y < cells.length; y++){
      
       int numNeighbors = 0;
       
       for(int i = x-1; i <= x+1; i++){
         for(int j = y-1; j <= y+1; j++){
           
           if((i == x && j == y) || i < 0 || i > numCells-1 || j < 0 || j > numCells-1){
             continue;
           }
           
           if(cells[i][j]){
             numNeighbors++;
           }
           
         }
       }
       
       if(cells[x][y]){
         
         if(numNeighbors < 2 || numNeighbors > 3){
           nextCells[x][y] = false;
         }else{
           nextCells[x][y] = true;
         }
         
       }else{
         
         if(numNeighbors == 3){
           nextCells[x][y] = true;
         }else{
           nextCells[x][y] = false;
         }
         
       }

    }
  }
  
  cells = nextCells;
  
}