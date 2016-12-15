package com.tenth.space.moments;

import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.tenth.space.utils.LogUtils;

/**
 * 条目上下的间距装饰器
 *
 * Created by wsq on 2016/11/10.
 */

public class MomentsItemDecoration extends RecyclerView.ItemDecoration {
    private final int topPixs;
    private final int bottomPixs;
    private final int leftPixs;
    private final int rightPixs;
    private int mTag;

    /**
     * @param topPixs    传入的值，其单位视为pix
     * @param bottomPixs 传入的值，其单位视为pix
     * @param leftPixs   传入的值，其单位视为pix
     * @param rightPixs  传入的值，其单位视为pix
     */
    public MomentsItemDecoration(int topPixs, int bottomPixs, int leftPixs, int rightPixs) {
        this.topPixs = topPixs;
        this.bottomPixs = bottomPixs;
        this.leftPixs = leftPixs;
        this.rightPixs = rightPixs;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        int itemCount = parent.getAdapter().getItemCount();
        int position = parent.getChildAdapterPosition(view);
//        LogUtils.d("itemCount>>" + itemCount + ";Position>>" + position);

        outRect.left = leftPixs;
        outRect.right = rightPixs;

        LogUtils.d("itemCount=" + itemCount + ",tag=" + mTag);
        if (itemCount <= 2) {
            outRect.top = 0;
            outRect.bottom = 0;
            return;
        }
//        LogUtils.d("itemCount2:" + itemCount);
        if (position == 0 || position == (itemCount - 1)) {
            //头和尾，不要间距
            outRect.top = 0;
            outRect.bottom = 0;
        } else if (position == 1) {
            //第一条，只要下面间距
            outRect.top = 0;
            outRect.bottom = bottomPixs;
        } else if (position == (itemCount - 2)) {
            //最后一条，只要上面间距
            outRect.top = topPixs;
            outRect.bottom = 0;
        } else {
            //中间条目，上下间距都要
            outRect.top = topPixs;
            outRect.bottom = bottomPixs;
        }
    }

    public void setTag(int tag) {
        mTag = tag;
    }
}
