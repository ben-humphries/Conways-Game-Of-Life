//Recommended that screenSize is divisible by 100
final int screenSize = 800;

//Performance for numCells over 100 is very CPU intensive.
final int numCells = 100;
final int cellSize = screenSize/numCells;

//Set noStroke to true if the cellSize is too small to see with the grid outline.
final boolean noStroke = true;

//Array that holds the values of each cell in the grid. True is alive, false is dead.
boolean[][] cells;

//Timer variables for the running phase.
float lastGenerationTime;
float generationDeltaTime = 1000f; // 1 second

//Variables for walking the grid, filling in lines when fps can't keep up with drawing.
int lastGridX;
int lastGridY;
boolean lastMousePressed = false;

//Is the input box selected?
boolean openFileSelected;
boolean saveFileSelected;

//Saves text in input boxes.
String openFileText = "";
String saveFileText = "";

//current generation of the game
int currentGeneration = 0;

//Is the game running automatically?
boolean running = false;

void settings(){
   size(screenSize,screenSize + 200);
}
void setup(){
  cells = new boolean[numCells][numCells];
  
  lastGenerationTime = millis();
  
  background(100);
  
  drawGeneration();
  drawUI(false, false);
  drawGenCounter();
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
      
      //If mouse is within the bounds of the grid
      if((mouseX < screenSize && mouseX >= 0) && (mouseY < screenSize && mouseY >= 0)){
        
        //Left click switches cells to alive.
        if(mouseButton == LEFT){
          paintCells(true);
        }
        //Right click switches cells to dead.
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
  //If key pressed isn't any operator keys
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
  //Open File Selection Box
  if(overButton(175, screenSize + 32, 400, 40)){
      drawUI(true, false);
      openFileSelected = true;
      saveFileSelected = false;
    }
    //Save File Selected Box
   else if(overButton(175 + 40, screenSize + 64 + 10, 400, 40)){
     drawUI(false, true);
     openFileSelected = false;
     saveFileSelected = true;
   }
   //Clear Button
   else if(overButton(0, screenSize + 96 + 20, 100, 40)){
     clearGrid();
     currentGeneration = 0;
     drawGenCounter();
     drawUI(false, false);
     openFileSelected = false;
     saveFileSelected = false;
   }
   //Open File Button
   else if(overButton(0, screenSize + 32, 170, 40)){
     openFile(openFileText);
     currentGeneration = 0;
     drawGenCounter();
     openFileSelected = false;
     saveFileSelected = false;
   }
   //Save File Button
   else if(overButton(0, screenSize + 64 + 10, 210, 40)){
     saveFileAs(saveFileText);
     openFileSelected = false;
     saveFileSelected = false;
   }
   //Random Button
   else if(overButton(110, screenSize + 96 + 20, 150, 40)){
     randomGrid();
     currentGeneration = 0;
     drawGenCounter();
     openFileSelected = false;
     saveFileSelected = false;
   }
   else{
     drawUI(false, false);
     openFileSelected = false;
     saveFileSelected = false;
   }
}

//Is the mouse currently over a button?
boolean overButton(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

//Draws gen counter separately from the other UI elements
//(so the whole UI doesn't flash when drawing at high speeds)
void drawGenCounter(){
  
  fill(100);
  noStroke();
  rect(300 + 200, screenSize + 96 + 20, 100, 40);
  fill(255);
  text("" + currentGeneration, 300 + 200, screenSize + 96 + 20, 300, 40); 
  
}
//Assign random values to each cell in the grid.
void randomGrid(){
  
    for(int x = 0; x< cells.length; x++){
      for(int y = 0; y < cells.length; y++){
        cells[x][y] = (random(0,1) > 0.5) ? true : false;
      }
    }
    
    drawGeneration();
    
}
//Open .CSV file with directory "dir".
void openFile(String dir){
  println("OPENING FILE: " + dir);
  
  String[] lines = loadStrings(dir); 
  String text = "";
  
  //Read .CSV file and parse it to a string of 1's and 0's like this: "0011001011010011101" 
  //with "|" to denote a new row.
  
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
      
      //Assign each cell to the corresponding value from the saved file.
      cells[x][y] = text.charAt(i) == '1' ? true : false;
      x++;
    }
  }
  
  drawGeneration();
  
  print("FINISHED OPENING " + dir);
  
}
//Save .CSV file to directory "dir".
void saveFileAs(String dir){
  println("SAVING FILE: " + dir);
  
  PrintWriter saveFile;
  
  saveFile = createWriter(dir);
  
  //Loop through each cell and add its value to the .CSV file.
  for(int y = 0; y< cells.length; y++){
    for(int x = 0; x < cells.length; x++){
      saveFile.print((cells[x][y] ? "1" : "0") + ((x < cells.length - 1) ? ", " : ""));
    }
    //If reached end of the row, go to next line.
    saveFile.print("\n");
  }
  
  saveFile.flush();
  saveFile.close();
  
  println("FINISHED SAVING " + dir);
}

//Clear grid to all dead cells.
void clearGrid(){
  for(int x = 0; x< cells.length; x++){
    for(int y = 0; y < cells.length; y++){
      cells[x][y] = false;
    }
  }
  drawGeneration();
}

//Draw UI Elements.
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
    
    //RANDOM
    fill(225);
    rect(110, screenSize + 96 + 20, 150, 40, 5);
    
    fill(0);
    textSize(32);
    text("RANDOM", 110, screenSize + 96 + 20, 300, 40);
    
    //CURRENT GEN
    
    fill(255);
    textSize(24);
    text("CURRENT GEN:", 300, screenSize + 96 + 20, 300, 40);
  
}

//Update last grid position of the mouse.
void updateLastGrid(){
  
  lastGridX = mouseX / cellSize;
  lastGridY = mouseY / cellSize;
  
}

//Paints cells between currentPosition and lastPosition of the mouse with boolean "alive"
void paintCells(boolean alive){
  
  cells[mouseX / cellSize][mouseY / cellSize] = alive;
  
  walkGrid(mouseX / cellSize, mouseY / cellSize, lastGridX, lastGridY, alive);
  
  drawGeneration();
  
}

//Fill all cells between lastPosition and currentPosition of the mouse.
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

//Redraw the grid.
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
//Advance to the next generation.
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
       //The 4 rules
       if(!cells[x][y]){
         
         if(numNeighbors != 3){
           nextCells[x][y] = false;
         }else{
           nextCells[x][y] = true;
         }
         
       }else{
         
         if(numNeighbors < 2 || numNeighbors > 3){
           nextCells[x][y] = false;
         }else{
           nextCells[x][y] = true;
         }
         
       }

    }
  }
  
  cells = nextCells;
  currentGeneration++;
  
  drawGenCounter();
  
}