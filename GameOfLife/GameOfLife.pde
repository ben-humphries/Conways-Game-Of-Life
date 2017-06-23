
boolean[][] cells;
int screenSize = 1000;
int numCells = 100;
int cellSize = screenSize/numCells;

float lastGenerationTime;
float generationDeltaTime = 1000f; // 1 second

int lastGridX;
int lastGridY;
boolean lastMousePressed = false;

boolean running = false;


void setup(){
  size(600,600);
  frameRate(60);
  cells = new boolean[numCells][numCells];
  
  //for(int x = 0; x< cells.length; x++){
  //  for(int y = 0; y < cells.length; y++){
  //    cells[x][y] = (random(0,1) > 0.5) ? true : false;
  //  }
  //}
  
  lastGenerationTime = millis();
  
  drawGeneration();
}

void draw(){

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
  if(key == ' ' && !running){
    nextGeneration();
    drawGeneration();
  }
  
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
  
  background(0);
  
  
  for(int x = 0; x< cells.length; x++){
    for(int y = 0; y < cells.length; y++){
      
      if(cells[x][y]){
        stroke(50);
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