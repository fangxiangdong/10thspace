package com.tenth.space.moments;

import android.app.Activity;
import android.os.Bundle;

import com.tenth.space.R;

/**
 * Created by Administrator on 2016/11/16.
 */
public class MomentsBaseActivity extends Activity{
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        overridePendingTransition(R.anim.activity_right_in, R.anim.activity_left_out);


    }

    @Override
    protected void onPause() {
        super.onPause();
        overridePendingTransition(R.anim.activity_right_in, R.anim.activity_left_out);
    }

}
