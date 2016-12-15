package com.tenth.space.utils;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.widget.Toast;

import com.tenth.space.app.IMApplication;

/**
 * Copyright © 2015 蓝色互动. All rights reserved.
 *
 * @author wujm
 * @Description 土丝工具类
 * @CreateDate 2015-5-6 下午5:02:30
 * @ModifiedBy 修改人中文名或拼音缩写
 * @ModifiedDate 修改日期格式YYYY-MM-DD
 * @WhyModified 改原因描述
 */
public class ToastUtils {

    /**
     * 土丝显示间隔
     */
    private static long intervalTime = 1000;
    /**
     * 上一次显示时间
     */
    private static long lastTime;
    private static Handler handler = new Handler(Looper.getMainLooper());

    /**
     * 土丝提示
     *
     * @param context
     * @param text
     */
    public static void show(Context context, String text) {
        long nowTime = System.currentTimeMillis();
        if (nowTime - lastTime < intervalTime) {
            return;
        }
        lastTime = nowTime;
        if (context != null) {
            Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
        }
    }

    //任何线程
    public static void show(final String text) {
        long nowTime = System.currentTimeMillis();
        if (nowTime - lastTime < intervalTime) {
            return;
        }

        lastTime = nowTime;
        final Context context = IMApplication.app.getApplicationContext();
        handler.post(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
            }
        });

    }

    /**
     * 土丝提示
     *
     * @param context
     * @param id
     */
    public static void show(Context context, int id) {
        long nowTime = System.currentTimeMillis();
        if (nowTime - lastTime < intervalTime) {
            return;
        }
        lastTime = nowTime;
        Toast.makeText(context, context.getResources().getString(id),
                Toast.LENGTH_SHORT).show();
    }

}
