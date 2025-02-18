import java.util.Timer;
import java.util.TimerTask;

/**
 * The CustomTimer class represents a customizable timer that can count up or down.
 * It provides methods to start, stop, reset, and check the status of the timer.
 * 
 * @author John LaMair
 * @version 02/18/2025
 */
public class CustomTimer {
    private float time;       // Current time value
    private boolean running; // Whether the timer is running
    private boolean countUp; // Whether the timer counts up or down
    private Timer timer;     // Timer object for scheduling tasks

    /**
     * Constructs a new CustomTimer object with the specified initial time.
     *
     * @param initialTime The initial time value for the timer.
     */
    public CustomTimer(float initialTime) {
        this.time = initialTime;
        this.running = false;
        this.countUp = true;
        this.timer = new Timer();
    }

    /**
     * Starts the timer if it is not already running.
     * The timer will count up or down based on the `countUp` setting.
     */
    public void start() {
        if (!running) {
            running = true;
            timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    if (countUp) {
                        time += 1.0f; // Increment time if counting up
                    } else {
                        time -= 1.0f; // Decrement time if counting down
                        if (time < 0) time = 0; // Ensure time doesn't go below 0
                    }
                }
            }, 0, 1000); // Schedule task to run every 1000ms (1 second)
        }
    }

    /**
     * Stops the timer if it is running and resets the timer object.
     */
    public void stop() {
        if (running) {
            running = false;
            timer.cancel();
            timer = new Timer(); // Reset the timer for potential future use
        }
    }

    /**
     * Resets the timer to a new time value and stops the timer.
     *
     * @param newTime The new time value to reset the timer to.
     */
    public void reset(float newTime) {
        stop();
        time = newTime;
    }

    /**
     * Sets whether the timer should count up or down.
     *
     * @param up True to count up, false to count down.
     */
    public void setCountUp(boolean up) {
        countUp = up;
    }

    /**
     * Returns the current time value of the timer.
     *
     * @return The current time value.
     */
    public float getTime() {
        return time;
    }

    /**
     * Checks if the timer is currently running.
     *
     * @return True if the timer is running, false otherwise.
     */
    public boolean isRunning() {
        return running;
    }
}