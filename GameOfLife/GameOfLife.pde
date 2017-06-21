
boolean[][] cells;
int screenSize = 1000;
int numCells = 100;
int cellSize = screenSize/numCells;

float lastGenerationTime;
float generationDeltaTime = 1000f; // 1 second

boolean running = false;


void setup(){
  size(600,600);
  
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
      
      if((mouseX < screenSize && mouseX >= 0) && (mouseY < screenSize && mouseY >= 0)){
        
        if(mouseButton == LEFT){
          cells[mouseX / cellSize][mouseY / cellSize] = true;
          drawGeneration();
        }
        else if(mouseButton == RIGHT){
          cells[mouseX / cellSize][mouseY / cellSize] = false;
          drawGeneration();
        }
      }
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