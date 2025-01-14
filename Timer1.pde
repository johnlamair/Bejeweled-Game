import java.util.Timer;
import java.util.TimerTask;


public class CustomTimer {
    private float time;
    private boolean running;
    private boolean countUp;
    private Timer timer;

    // constructor method
    public CustomTimer(float initialTime) {
        this.time = initialTime;
        this.running = false;
        this.countUp = true;
        this.timer = new Timer();
    }

    // name: start
    // function: if clock hasn't started, start the clock counting. Count up or
    // down dependent on "countUp" boolean
    // inputs: none
    public void start() {
        if (!running) {
            running = true;
            timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    if (countUp) {
                        time += 1.0f;
                    } else {
                        time -= 1.0f;
                        if (time < 0) time = 0;
                    }
                }
            }, 0, 1000); // Delay 0ms, repeat every 1000ms (1 second)
        }
    }

    // name: stop
    // function: if clock is running, cancel the timer and reset
    // inputs: none
    public void stop() {
        if (running) {
            running = false;
            timer.cancel();
            timer = new Timer(); // Reset the timer for potential future use
        }
    }

    // name: reset
    // function: reset the clock's time to a provided time
    // inputs: new time for clock
    public void reset(float newTime) {
        stop();
        time = newTime;
    }

    // name: setCountUp
    // function: set "countUp" boolean to provided boolean
    // inputs: boolean to replace "countUp"
    public void setCountUp(boolean up) {
        countUp = up;
    }

    // name: getTime
    // function: return time
    // inputs: none
    public float getTime() {
        return time;
    }

    // name: isRunning
    // function: return boolean based on if clock is running
    // inputs: none
    public boolean isRunning() {
        return running;
    }
}
