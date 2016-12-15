package com.tenth.space.utils;

import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

/**
 * Created by Administrator on 2016/11/16.
 */

public class SpacesItemDecoration extends RecyclerView.ItemDecoration {
    private  int space;

    public SpacesItemDecoration(int space) {
        this.space = space;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        outRect.left = space;
        outRect.bottom = space;

        // Add top margin only for the first item to avoid double space between items
         if(parent.getChildLayoutPosition(view) == 0||parent.getChildLayoutPosition(view) == 1){
            outRect.top = space;
        }
      if (parent.getChildLayoutPosition(view)%2==1){
          outRect.right=space;
      }

    }
}
