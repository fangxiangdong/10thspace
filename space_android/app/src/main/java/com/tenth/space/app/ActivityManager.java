package com.tenth.space.app;

import android.app.Activity;

import java.util.Stack;

/**
 * Created by wsq on 2016/11/9.
 */

public class ActivityManager {

    private static ActivityManager instance;
    private static Stack<Activity> activityStack;

    synchronized public static ActivityManager getAppManager() {
        if (instance == null) {
            instance = new ActivityManager();
        }
        return instance;
    }

    public void addActivity(Activity activity) {
        if (activityStack == null) {
            activityStack = new Stack<Activity>();
        }
        activityStack.add(activity);
    }

    //按对象删除activity
    public void finishActivity(Activity activity) {
        if (activity != null) {
            activityStack.remove(activity);
            activity.finish();
            activity = null;
        }
    }

    //按类名删除activity
    public void finishActivity(Class<?> cls) {
        Activity activity = null;
        for (Activity a : activityStack) {
            if (a.getClass().equals(cls)) {
                activity = a;
                break;
            }
        }
        if (activity != null)
            finishActivity(activity);
    }

}
