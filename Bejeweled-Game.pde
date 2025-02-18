/** 
 * This class is the program displaying and running the game board.
 * The program is interactive and allows the user to play a gem-matching game.
 * 
 * @author John LaMair
 * @version 02/18/2025
 */

final int COLS = 6;
final int ROWS = 6;
final int GEM_SIZE = 50;
final int ANIMATION_SPEED = 5;
final int INITIAL_SCORE_THRESHOLD = 20;
final int THRESHOLD_INCREMENT = 22;

Board board;
int offsetX;      // horizontal offset
int offsetY = 20; // vertical offset

CustomTimer gameTimer;

int[] selectedGem = null;    // Store the currently dragged gem (column, row)
boolean isDragging = false;  // Whether the user is dragging a gem
boolean consecutiveClear = false; // Tracks consecutive clears

enum GameState {
    IDLE, MATCHING, CLEARING, FALLING, REFILLING, GAME_OVER
}

GameState currentState = GameState.IDLE;

int scoreThreshold = INITIAL_SCORE_THRESHOLD; 
int thresholdIncrement = THRESHOLD_INCREMENT;
int animationStep = 0;
int level = 1;          
int score = 0;              // total score
int scoreMultiplier = 1;    // multiplier for consecutive clears

/**
 * Initializes the game board, centers the board, and sets up the game timer.
 */
void setup() {
  size(400, 640);
  board = new Board(COLS); 
  board.initializeRandomly(); 
  calculateOffsets();
  
  gameTimer = new CustomTimer(60); 
  gameTimer.setCountUp(false); 
  gameTimer.start();
}

/**
 * Calculates the horizontal and vertical offsets to center the grid on the screen.
 */
void calculateOffsets() {
  // Calculate offsets to center the grid
  offsetX = (width - COLS * GEM_SIZE) / 2;
  offsetY = int(GEM_SIZE * 0.4); // Vertical margin (40% of gem size)
}

/**
 * Draws the game board, handles animations, and updates the game state.
 */
void draw() {
    background(255);
    drawGrid(); 
    
    displayGameStats();

    if (isDragging && selectedGem != null) {
        int col = selectedGem[0];
        int row = selectedGem[1];
        char type = board.getBoard()[row][col];
        drawGem(mouseX - GEM_SIZE / 2, mouseY - GEM_SIZE / 2, type, false);
    }

    handleGameState();
    checkGameOver();    
}

/**
 * Displays the game statistics (time, score, and next level threshold).
 */
void displayGameStats() {
    fill(0);
    textSize(24);
    textAlign(CENTER, BOTTOM);
    text("Time: " + (int) gameTimer.getTime(), width / 2, height - 265);
    text("Score: " + score, width / 2, height - 230);
    text("Next Level: " + scoreThreshold, width / 2, height - 195);
}

/**
 * Handles the current game state and performs corresponding actions.
 */
void handleGameState() {
   switch (currentState) {
        case MATCHING:
            animateMatching();
            break;
        case CLEARING:
            animateClearing();
            break;
        case FALLING:
            animateFalling();
            break;
        case REFILLING:
            animateRefilling();
            break;
        case GAME_OVER:
            gameOverScreen();
            break;
        default:
            break;
    }
}

void checkGameOver() {
  if (gameTimer.getTime() <= 0 && currentState != GameState.GAME_OVER) {
        currentState = GameState.GAME_OVER;
        gameTimer.stop();
    }
}

/**
 * Animates the matching process by incrementing the animation step.
 */
void animateMatching() {
    if (frameCount % ANIMATION_SPEED == 0) {
        animationStep++;
        if (animationStep > 4) { 
            currentState = GameState.CLEARING;
            animationStep = 0;
        }
    }
}

/**
 * Animates the clearing process by flashing matched gems to gray.
 */
void animateClearing() {
    if (frameCount % ANIMATION_SPEED == 0) {
        animationStep++;
        if (animationStep > 6) {
            boolean matchCleared = clearMatches();
            if (matchCleared) {
                if (consecutiveClear) {
                    scoreMultiplier *= 2; 
                } else {
                    scoreMultiplier = 1; 
                }
                score += scoreMultiplier;   
                consecutiveClear = true;        
                checkLevelProgression(); 

            } else {
                scoreMultiplier = 1;        
                consecutiveClear = false;  
            }
            currentState = GameState.FALLING;
            animationStep = 0;
        }
    }
}

/**
 * Animates the falling of gems after matches are cleared.
 */
void animateFalling() {
    if (frameCount % ANIMATION_SPEED == 0) {
        boolean stillFalling = shiftGemsDown();
        if (!stillFalling) {
            currentState = GameState.REFILLING;
            animationStep = 0;
        }
    }
}

/**
 * Animates the refilling of gems after falling and checks for new matches.
 */
void animateRefilling() {
    if (frameCount % ANIMATION_SPEED == 0) { 
        generateNewGems(); 
        currentState = GameState.IDLE; 
        animationStep = 0;

        if (checkForMatch()) {
            currentState = GameState.MATCHING;
        } else {
            consecutiveClear = false; 
        }
    }
}

/**
 * Draws the game grid with gems.
 */
void drawGrid() {
  char[][] currentBoard = board.getBoard(); 
  for (int i = 0; i < COLS; i++) {
    for (int j = 0; j < ROWS; j++) {
      if (selectedGem != null && selectedGem[0] == i && selectedGem[1] == j) continue;
      char type = currentBoard[j][i];
      drawGem(offsetX + i * GEM_SIZE, offsetY + j * GEM_SIZE, type, true);
    }
  }
}
    
/**
 * Draws a gem at the specified position.
 *
 * @param x The x-coordinate of the gem.
 * @param y The y-coordinate of the gem.
 * @param type The type of gem (R, G, B, Y, P).
 * @param staticPosition Whether the gem is in a static position.
*/
void drawGem(int x, int y, char type, boolean staticPosition) {
  int cornerRadius = GEM_SIZE / 4;
  
  int alpha = (currentState == GameState.CLEARING) 
              ? int(map(animationStep, 0, 5, 255, 0)) : 255;
 
  switch (type) {
    case 'R':
      fill(255, 0, 0, alpha);
      break;
    case 'G':
      fill(0, 255, 0, alpha);
      break;
    case 'B':
      fill(0, 0, 255, alpha);
      break;
    case 'Y':
      fill(255, 255, 0, alpha);
      break;
    case 'P':
      fill(255, 0, 255, alpha);
      break;
    default:
      fill(200, alpha);
      break;
  }
  
  rect(x, y, GEM_SIZE, GEM_SIZE, cornerRadius);
}

/**
 * Handles mouse press events to select a gem.
 */
void mousePressed() {
  if (currentState != GameState.IDLE) return;
  
  int col = (mouseX - offsetX) / GEM_SIZE;
  int row = (mouseY - offsetY) / GEM_SIZE;

  if (col >= 0 && col < COLS && row >= 0 && row < ROWS) {
    selectedGem = new int[]{col, row};
    isDragging = true;
  }
}

/**
 * Handles mouse release events to swap gems and check for matches.
 */
void mouseReleased() {
  if (currentState != GameState.IDLE || selectedGem == null) return;

  int col = (mouseX - offsetX) / GEM_SIZE;
  int row = (mouseY - offsetY) / GEM_SIZE;

  if (col >= 0 && col < COLS && row >= 0 && row < ROWS) {
    int[] original = selectedGem;

    if ((Math.abs(col - original[0]) == 1 && row == original[1]) || 
        (Math.abs(row - original[1]) == 1 && col == original[0])) {

      if (isValidMove(original[1], original[0], row, col)) {
        board.swap(original[1], original[0], row, col);
        currentState = GameState.MATCHING;
      }
    }
  }

  selectedGem = null;
  isDragging = false;
}

/**
 * Handles key press events to restart the game.
 */
void keyPressed() {
    // Check for R key to restart the game
    if (key == 'r' || key == 'R') {
        restartGame();
    }
}

/**
 * Clears matched gems from the board and updates the score.
 *
 * @return True if matches were found and cleared, false otherwise.
 */
boolean clearMatches() {
    char[][] currentBoard = board.getBoard();
    boolean[][] toClear = new boolean[ROWS][COLS];
    boolean matchFound = false; // Declare and initialize matchFound

    // Detect horizontal matches
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j <= COLS - 3; j++) {
            if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i][j + 1] &&
                currentBoard[i][j] == currentBoard[i][j + 2]) {
                toClear[i][j] = toClear[i][j + 1] = toClear[i][j + 2] = true;
                matchFound = true; // Set matchFound to true if a match is found
            }
        }
    }

    // Detect vertical matches
    for (int j = 0; j < COLS; j++) {
        for (int i = 0; i <= ROWS - 3; i++) {
            if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i + 1][j] &&
                currentBoard[i][j] == currentBoard[i + 2][j]) {
                toClear[i][j] = toClear[i + 1][j] = toClear[i + 2][j] = true;
                matchFound = true; // Set matchFound to true if a match is found
            }
        }
    }

    // Clear matched gems
    if (matchFound) {
        for (int i = 0; i < ROWS; i++) {
            for (int j = 0; j < COLS; j++) {
                if (toClear[i][j]) {
                    currentBoard[i][j] = ' '; // Mark as empty
                }
            }
        }
    }

    return matchFound; // Return whether any matches were found
}

/**
 * Shifts gems down to fill empty spaces after matches are cleared.
 *
 * @return True if gems were moved, false otherwise.
 */
boolean shiftGemsDown() {
  boolean gemsMoved = false;
  char[][] currentBoard = board.getBoard();

  for (int j = 0; j < COLS; j++) {
    for (int i = ROWS - 1; i > 0; i--) {
      if (currentBoard[i][j] == ' ') {
        for (int k = i - 1; k >= 0; k--) {
          if (currentBoard[k][j] != ' ') {
            currentBoard[i][j] = currentBoard[k][j];
            currentBoard[k][j] = ' ';
            gemsMoved = true;
            break;
          }
        }
      }
    }
  }

  return gemsMoved;
}

/**
 * Generates new gems to fill empty spaces on the board.
 */
void generateNewGems() {
  char[] gemTypes = {'R', 'G', 'B', 'Y', 'P'};
  Random random = new Random();

  char[][] currentBoard = board.getBoard();

  for (int j = 0; j < COLS; j++) {
    for (int i = 0; i < ROWS; i++) {
      if (currentBoard[i][j] == ' ') {
        currentBoard[i][j] = gemTypes[random.nextInt(gemTypes.length)]; // Generate a new gem
      }
    }
  }
}

/**
 * Checks if swapping two gems will result in a valid match.
 *
 * @param row1 The row of the first gem.
 * @param col1 The column of the first gem.
 * @param row2 The row of the second gem.
 * @param col2 The column of the second gem.
 * @return True if the swap results in a valid match, false otherwise.
 */
boolean isValidMove(int row1, int col1, int row2, int col2) {
  board.swap(row1, col1, row2, col2); // Perform a temporary swap

  boolean matchExists = checkForMatch(); // Calling the checkForMatch method

  board.swap(row1, col1, row2, col2); // Revert the swap

  return matchExists; // Return whether a match exists
}

/**
 * Checks the board for any matches.
 *
 * @return True if a match is found, false otherwise.
 */
boolean checkForMatch() {
  char[][] currentBoard = board.getBoard();

  // Check for horizontal matches
  for (int i = 0; i < ROWS; i++) {
    for (int j = 0; j <= COLS - 3; j++) {
      if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i][j + 1] &&
          currentBoard[i][j] == currentBoard[i][j + 2]) {
        return true; // Match found
      }
    }
  }

  // Check for vertical matches
  for (int j = 0; j < COLS; j++) {
    for (int i = 0; i <= ROWS - 3; i++) {
      if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i + 1][j] &&
          currentBoard[i][j] == currentBoard[i + 2][j]) {
        return true; // Match found
      }
    }
  }

  return false; // No match found
}

/**
 * Displays the game over screen with the final score.
 */
void gameOverScreen() {
    fill(0);
    textSize(48);
    textAlign(CENTER, CENTER);
    text("Game Over!", width / 2, height / 2+ 170);
    textSize(24);
    text("Final Score: " + score, width / 2, height / 2 + 210);
    noLoop();
    text("Press R to play again", width / 2, height / 2 + 240);
}

/**
 * Restarts the game by resetting the score, timer, and board.
 */
void restartGame() {
    // Reset game parameters
    score = 0;                
    scoreMultiplier = 1;      
    currentState = GameState.IDLE;  
    
    level = 1;               
    scoreThreshold = 20;     
    thresholdIncrement = 22;  

    gameTimer.reset(60);
    gameTimer.start();
    board.initializeRandomly();

    loop();
}

/**
 * Checks if the player has progressed to the next level based on their score.
 */
void checkLevelProgression() {
    if (score >= scoreThreshold) {        
        level++; 
        scoreThreshold += thresholdIncrement; 
        thresholdIncrement += 2; 
        
        resetForNextLevel(); 
    }
}

/**
 * Resets the board and timer for the next level.
 */
void resetForNextLevel() {
    println("Level Up! Moving to Level " + level);

    currentState = GameState.IDLE; 
    gameTimer.reset(60);           
    gameTimer.start();             // Restart the timer
    board.initializeRandomly();    // Generate a new random board
    scoreMultiplier = 1;           // Reset the multiplier

    // Optionally, display a level-up message
    background(255);
    fill(0);
    textSize(36);
    textAlign(CENTER, CENTER);
    text("Level " + level, width / 2, height / 2);
    delay(1000); // Small delay to display the level-up message
}