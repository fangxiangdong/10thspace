package com.tenth.space.utils;

import android.util.Log;

public class LogUtils {

    private static final String TAG = "LogUtils";
    private static boolean debugFlag = true;

    public static void d(String tag, String msg) {
        if (debugFlag) {
            Log.d(tag, msg);
        }
    }

    public static void d(String msg) {
        if (debugFlag) {
//            Log.e(TAG, msg);
			Log.d(TAG, msg);
        }
    }
    public static void i(String msg) {
        if (debugFlag) {
//            Log.e(TAG, msg);
			Log.i(TAG, msg);
        }
    }

    public static void e(String msg) {
        if (debugFlag) {
            Log.e(TAG, msg);
        }
    }
}
