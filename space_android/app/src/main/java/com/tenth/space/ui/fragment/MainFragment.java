package com.tenth.space.ui.fragment;

import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.ProgressBar;

import com.tenth.space.R;
import com.tenth.space.ui.base.TTBaseFragment;

public abstract class MainFragment extends TTBaseFragment {
    private ProgressBar progressbar;
    private Handler mHandler = new Handler(Looper.getMainLooper());

    public void init(View curView) {
        progressbar = (ProgressBar) curView.findViewById(R.id.progress_bar);
    }

    public void showProgressBar() {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                progressbar.setVisibility(View.VISIBLE);
            }
        });
    }

    public void hideProgressBar() {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                progressbar.setVisibility(View.GONE);
            }
        });
    }

    public void startTimer() {
    }

    public void stopTimer() {
    }

}
