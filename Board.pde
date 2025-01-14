import java.util.*;

public class Board {
    private int size;
    private char[][] Board;

    // constructor method, initalizes board     
    public Board(int size) {
        this.Board = new char[size][size];
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                this.Board[i][j] = ' '; // Internal board
            }
        }
    }

    // name: initializeRandomly
    // function: fill the empty board array with gems of random color
    // inputs: none
    public void initializeRandomly() {
        
        // array of possible gem colors
        char[] gemTypes = {'R', 'G', 'B', 'Y', 'P'};
        Random random = new Random();
        
        // for each spot in board array, place a gem of random color
        for (int i = 0; i < Board.length; i++) {
            for (int j = 0; j < Board[i].length; j++) {
                char selectedGem;
                
                // make sure gems don't populate in rows or columns of the same color greater than two
                boolean valid;
                do {
                    valid = true;
                    selectedGem = gemTypes[random.nextInt(gemTypes.length)];

                    if (j >= 2 && Board[i][j - 1] == selectedGem && Board[i][j - 2] == selectedGem) {
                        valid = false;
                    }
                    if (i >= 2 && Board[i - 1][j] == selectedGem && Board[i - 2][j] == selectedGem) {
                        valid = false;
                    }
                } while (!valid);

                Board[i][j] = selectedGem; // Assign gem if valid
            }
        }
    }
    
    // name: printBoard
    // function: print the board to Processing
    // inputs: none
    public void printBoard() {
        System.out.println("Board:");
        System.out.print(" ");
        for (int a = 65; a < Board.length + 65; a++) {
            System.out.print(" | " + (char) a);
        }
        System.out.println();
        System.out.print("--+");
        for (int border = 0; border < Board[0].length; border++) {
            System.out.print("---+");
        }
        System.out.println();

        for (int i = 0; i < Board.length; i++) {
            System.out.print(i);
            for (int j = 0; j < Board[i].length; j++) {
                System.out.print(" | " + Board[i][j]);
            }
            System.out.println();
            System.out.print("--+");
            for (int border = 0; border < Board[i].length; border++) {
                System.out.print("---+");
            }
            System.out.println();
        }
    }

    // name: getBoard
    // function: return the Board instance variable array
    // inputs: none
    public char[][] getBoard() {
        return Board;
    }
    
    // name: swap
    // function: swap the x and y coordinates of two spots on the board array
    // input: (
    public void swap(int x1, int y1, int x2, int y2) {
        char temp = Board[x1][y1];
        Board[x1][y1] = Board[x2][y2];
        Board[x2][y2] = temp;
        
    }
}
