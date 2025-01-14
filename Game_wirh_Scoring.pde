int cols = 6;  // Number of columns
int rows = 6;  // Number of rows
int gemSize = 50;  // Size of each gem
Board board;

int offsetX;  // Horizontal offset
int offsetY = 20;  // Vertical offset

int[] selectedGem = null;  // Store the currently dragged gem (column, row)
boolean isDragging = false;  // Whether the user is dragging a gem

enum GameState {
    IDLE, MATCHING, CLEARING, FALLING, REFILLING, GAME_OVER
}

GameState currentState = GameState.IDLE;
int animationStep = 0;
int animationSpeed = 5; // Adjust this to control animation speed
CustomTimer gameTimer;
int level = 1;          // Starting level
int scoreThreshold = 20; // Initial threshold for level progression
int thresholdIncrement = 22; // Increment starts at 22


int score = 0;            // Total score
int scoreMultiplier = 1;  // Multiplier for consecutive clears

// name: setup
// function: initialize a board with gems, center the board
// inputs: none
void setup() {
  size(400, 630);
  board = new Board(cols); // Initialize Board object
  board.initializeRandomly(); // Randomize gems
  calculateOffsets();
  
  gameTimer = new CustomTimer(60); // Start with 60 seconds
  gameTimer.setCountUp(false); // Timer counts down
  gameTimer.start();
}

// name: calculateOffsets
// function: calculate offsets from the board to center the grid
// inputs: none
void calculateOffsets() {
  // Calculate offsets to center the grid
  offsetX = (width - cols * gemSize) / 2;
  offsetY = int(gemSize * 0.4); // Vertical margin (40% of gem size)
}

// name: draw
// function: draw the board array in Processing, display game stats, perform animations, handle game management
// inputs: none
void draw() {
    background(255);
    drawGrid(); // Draw the game grid
    
    // Display game stats
    fill(0);
    textSize(24);
    textAlign(CENTER, BOTTOM);
    text("Time: " + (int) gameTimer.getTime(), width / 2, height - 265);
    text("Score: " + score, width / 2, height - 230);
    text("Next Level: " + scoreThreshold, width / 2, height - 195);

    // Handle dragging visual
    if (isDragging && selectedGem != null) {
        int col = selectedGem[0];
        int row = selectedGem[1];
        char type = board.getBoard()[row][col];
        drawGem(mouseX - gemSize / 2, mouseY - gemSize / 2, type, false);
    }

    // Game state management
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

    // Check for game over condition
    if (gameTimer.getTime() <= 0 && currentState != GameState.GAME_OVER) {
        currentState = GameState.GAME_OVER;
        gameTimer.stop();
    }
}

// name: animateMatching
// function: 
// inputs: none
void animateMatching() {
    if (frameCount % animationSpeed == 0) {
        animationStep++;
        if (animationStep > 4) { // Increased from 2 to 4 for a slower transition
            currentState = GameState.CLEARING;
            animationStep = 0;
        }
    }
}

boolean consecutiveClear = false; // Tracks consecutive clears

// name: animateClearing
// function: flash pieces to gray when a row of the same color is completed
// inputs: none
void animateClearing() {
    if (frameCount % animationSpeed == 0) {
        animationStep++;
        if (animationStep > 6) { // Increased from 3 to 6 for a slower transition
            boolean matchCleared = clearMatches();
            if (matchCleared) {
                if (consecutiveClear) {
                    scoreMultiplier *= 2; // Double the multiplier for consecutive clears
                } else {
                    scoreMultiplier = 1; // Reset to 1 on the first clear
                }
                score += scoreMultiplier;   // Update score
                consecutiveClear = true;    // Mark this clear as successful for the next check
                
                checkLevelProgression(); // Check if level threshold is passed

            } else {
                scoreMultiplier = 1;        // Reset multiplier if no match cleared
                consecutiveClear = false;   // No consecutive clear
            }
            currentState = GameState.FALLING;
            animationStep = 0;
        }
    }
}

// name: animateFalling
// function: animate the new gems moving from the top of the board array to the bottom
// inputs: none
void animateFalling() {
    // Move gems down
    if (frameCount % animationSpeed == 0) {
        boolean stillFalling = shiftGemsDown();
        if (!stillFalling) {
            currentState = GameState.REFILLING;
            animationStep = 0;
        }
    }
}

// name: animateRefilling
// function: animate gems filling in spaces cleared by match, check if new matches are made
// inputs: none
void animateRefilling() {
    if (frameCount % animationSpeed == 0) { // Animation frame timing
        generateNewGems(); // Refill empty positions
        currentState = GameState.IDLE; // Reset to IDLE for player interaction
        animationStep = 0;

        // Check for matches after refilling
        if (checkForMatch()) {
            currentState = GameState.MATCHING;
        } else {
            consecutiveClear = false; // Reset consecutive clear flag if no new matches
        }
    }
}

void drawGrid() {
  char[][] currentBoard = board.getBoard(); // Get board data
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      // Skip drawing the gem being dragged
      if (selectedGem != null && selectedGem[0] == i && selectedGem[1] == j) continue;
      char type = currentBoard[j][i];
      drawGem(offsetX + i * gemSize, offsetY + j * gemSize, type, true);
    }
  }
}

// name: drawGem
// function: make an image for each gem in the board array in processing
// inputs: (x,y) coordinates, color of gem, if gem is static
void drawGem(int x, int y, char type, boolean staticPosition) {
  int cornerRadius = gemSize / 4;
  
  // Adjust alpha for fading effect during clearing
  int alpha = 255;
  if (currentState == GameState.CLEARING) {
    alpha = int(map(animationStep, 0, 5, 255, 0));
  }

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

  if (staticPosition) {
    rect(x, y, gemSize, gemSize, cornerRadius);
  } else {
    rect(x, y, gemSize, gemSize, cornerRadius);
  }
}

// name: mousePressed
// function: select gem when mouse is pressed
// inputs: none
void mousePressed() {
  if (currentState != GameState.IDLE) return;
  
  int col = (mouseX - offsetX) / gemSize;
  int row = (mouseY - offsetY) / gemSize;

  if (col >= 0 && col < cols && row >= 0 && row < rows) {
    selectedGem = new int[]{col, row};
    isDragging = true;
  }
}

// name: mouseReleased
// function: ensure valid moves, check for matches, shift gems and generate new ones, when mouse is released
// inputs: none
void mouseReleased() {
  if (currentState != GameState.IDLE || selectedGem == null) return;

  int col = (mouseX - offsetX) / gemSize;
  int row = (mouseY - offsetY) / gemSize;

  if (col >= 0 && col < cols && row >= 0 && row < rows) {
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

// name: keyPressed
// function: determine if "r" key has been pressed, restart game if it has
// inputs: none
void keyPressed() {
    // Check for R key to restart the game
    if (key == 'r' || key == 'R') {
        restartGame();
    }
}

// name: clearMatches
// function: if matches are found horizontally or vertically, increment up the score and remove gem characters from the board
// inputs: none
boolean clearMatches() {
    char[][] currentBoard = board.getBoard();
    boolean[][] toClear = new boolean[rows][cols];
    boolean matchFound = false; // Declare and initialize matchFound

    // Detect horizontal matches
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j <= cols - 3; j++) {
            if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i][j + 1] &&
                currentBoard[i][j] == currentBoard[i][j + 2]) {
                toClear[i][j] = toClear[i][j + 1] = toClear[i][j + 2] = true;
                matchFound = true; // Set matchFound to true if a match is found
            }
        }
    }

    // Detect vertical matches
    for (int j = 0; j < cols; j++) {
        for (int i = 0; i <= rows - 3; i++) {
            if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i + 1][j] &&
                currentBoard[i][j] == currentBoard[i + 2][j]) {
                toClear[i][j] = toClear[i + 1][j] = toClear[i + 2][j] = true;
                matchFound = true; // Set matchFound to true if a match is found
            }
        }
    }

    // Clear matched gems
    if (matchFound) {
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                if (toClear[i][j]) {
                    currentBoard[i][j] = ' '; // Mark as empty
                }
            }
        }
    }

    return matchFound; // Return whether any matches were found
}

// name: shiftGemsDown
// function: move gems down when a row or column is cleared, check for new matches
// inputs: none
boolean shiftGemsDown() {
  boolean gemsMoved = false;
  char[][] currentBoard = board.getBoard();

  for (int j = 0; j < cols; j++) {
    for (int i = rows - 1; i > 0; i--) {
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

// name: generateNewGems
// function: when row or column is cleared, generate new gems to take their place
// inputs: none
void generateNewGems() {
  char[] gemTypes = {'R', 'G', 'B', 'Y', 'P'};
  Random random = new Random();

  char[][] currentBoard = board.getBoard();

  for (int j = 0; j < cols; j++) {
    for (int i = 0; i < rows; i++) {
      if (currentBoard[i][j] == ' ') {
        currentBoard[i][j] = gemTypes[random.nextInt(gemTypes.length)]; // Generate a new gem
      }
    }
  }
}

// name: isValidMove
// function: determine if swap of two gems is valid dependent on if matches can be made
// inputs: (x,y) coordinates of two gems
boolean isValidMove(int row1, int col1, int row2, int col2) {
  board.swap(row1, col1, row2, col2); // Perform a temporary swap

  boolean matchExists = checkForMatch(); // Calling the checkForMatch method

  board.swap(row1, col1, row2, col2); // Revert the swap

  return matchExists; // Return whether a match exists
}

// name: checkForMatch
// function: check to see if a match has been made between two gems
// inputs: none
boolean checkForMatch() {
  char[][] currentBoard = board.getBoard();

  // Check for horizontal matches
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j <= cols - 3; j++) {
      if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i][j + 1] &&
          currentBoard[i][j] == currentBoard[i][j + 2]) {
        return true; // Match found
      }
    }
  }

  // Check for vertical matches
  for (int j = 0; j < cols; j++) {
    for (int i = 0; i <= rows - 3; i++) {
      if (currentBoard[i][j] != ' ' && currentBoard[i][j] == currentBoard[i + 1][j] &&
          currentBoard[i][j] == currentBoard[i + 2][j]) {
        return true; // Match found
      }
    }
  }

  return false; // No match found
}

// name: gameOverScreen
// function: display end-game screen
// inputs: none
void gameOverScreen() {
    fill(0);
    textSize(48);
    textAlign(CENTER, CENTER);
    text("Game Over!", width / 2, height / 2+ 134.5);
    textSize(24);
    text("Final Score: " + score, width / 2, height / 2 + 170);
    noLoop();
    text("Press R to play again", width / 2, height / 2 + 195);
}

// name: restartGame
// function: restart the game if user chooses, reset score and set game to idle
// inputs: none
void restartGame() {
    // Reset game parameters
    score = 0;                // Reset score
    scoreMultiplier = 1;      // Reset score multiplier
    currentState = GameState.IDLE;  // Set game state to IDLE

    // Reset level progression variables
    level = 1;                // Reset to level 1
    scoreThreshold = 20;      // Reset first level threshold
    thresholdIncrement = 22;  // Reset the threshold increment

    // Timer and board reset
    gameTimer.reset(60);
    gameTimer.start();
    board.initializeRandomly();

    loop();
}

// name: checkLevelProgression
// function: determine if user has progressed between levels
// inputs: none
void checkLevelProgression() {
    if (score >= scoreThreshold) {
        // Update highest score for the current level
        
        level++; // Move to the next level
        scoreThreshold += thresholdIncrement; // Increase threshold by fixed increment
        thresholdIncrement += 2; // Increment grows by 2 for the next level
        
        resetForNextLevel(); // Reset for next level
    }
}

// name: resetForNextLevel
// function: reset the board when user moves up levels
// inputs: none
void resetForNextLevel() {
    println("Level Up! Moving to Level " + level);

    currentState = GameState.IDLE; // Set game state to IDLE
    gameTimer.reset(60);           // Reset the timer for 60 seconds
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
