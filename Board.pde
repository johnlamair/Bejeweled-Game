import java.util.Random;

/**
 * The Board class represents the game board for a gem-matching game.
 * It initializes the board, populates it with random gems, and provides methods
 * to manipulate and display the board.
 * 
 * @author John LaMair
 * @version 02/18/2025
 */
public class Board {
    private int size;          // Size of the board (number of rows and columns)
    private char[][] board;   // 2D array representing the board

    /**
     * Constructs a new Board object with the specified size.
     * Initializes the board with empty spaces.
     *
     * @param size The size of the board (number of rows and columns).
     */
    public Board(int size) {
        this.size = size;
        this.board = new char[size][size];
        initializeEmptyBoard();
    }

    /**
     * Initializes the board with empty spaces.
     */
    private void initializeEmptyBoard() {
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                this.board[i][j] = ' ';
            }
        }
    }

    /**
     * Fills the board with randomly colored gems, ensuring no three gems of the same color
     * are adjacent in a row or column.
     */
    public void initializeRandomly() {
        char[] gemTypes = {'R', 'G', 'B', 'Y', 'P'}; // Possible gem colors
        Random random = new Random();

        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                char selectedGem;
                boolean valid;

                // Ensure no three gems of the same color are adjacent
                do {
                    valid = true;
                    selectedGem = gemTypes[random.nextInt(gemTypes.length)];

                    // Check horizontal adjacency
                    if (j >= 2 && board[i][j - 1] == selectedGem && board[i][j - 2] == selectedGem) {
                        valid = false;
                    }
                    // Check vertical adjacency
                    if (i >= 2 && board[i - 1][j] == selectedGem && board[i - 2][j] == selectedGem) {
                        valid = false;
                    }
                } while (!valid);

                board[i][j] = selectedGem; // Assign the valid gem
            }
        }
    }

    /**
     * Prints the board to the console in a formatted grid.
     */
    public void printBoard() {
        System.out.println("Board:");
        System.out.print(" ");
        for (int a = 65; a < size + 65; a++) {
            System.out.print(" | " + (char) a); // Print column headers (A, B, C, ...)
        }
        System.out.println();
        System.out.print("--+");
        for (int border = 0; border < size; border++) {
            System.out.print("---+"); // Print top border
        }
        System.out.println();

        // Print each row of the board
        for (int i = 0; i < size; i++) {
            System.out.print(i); // Print row number
            for (int j = 0; j < size; j++) {
                System.out.print(" | " + board[i][j]); // Print gem
            }
            System.out.println();
            System.out.print("--+");
            for (int border = 0; border < size; border++) {
                System.out.print("---+"); // Print row border
            }
            System.out.println();
        }
    }

    /**
     * Returns the 2D array representing the board.
     *
     * @return The 2D array of the board.
     */
    public char[][] getBoard() {
        return board;
    }

    /**
     * Swaps the positions of two gems on the board.
     *
     * @param x1 The row index of the first gem.
     * @param y1 The column index of the first gem.
     * @param x2 The row index of the second gem.
     * @param y2 The column index of the second gem.
     */
    public void swap(int x1, int y1, int x2, int y2) {
        char temp = board[x1][y1];
        board[x1][y1] = board[x2][y2];
        board[x2][y2] = temp;
    }
}