public without sharing class CheckRecursive {
    private static boolean run = true;

    public static boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }

    public static void resetRunOnce() {
        run = true;
    }
}