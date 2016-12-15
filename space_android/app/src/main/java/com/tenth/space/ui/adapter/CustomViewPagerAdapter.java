package com.tenth.space.ui.adapter;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.view.ViewGroup;

import com.tenth.space.ui.fragment.HomeItemFragment2;

import java.util.ArrayList;

/**
 * Created by Administrator on 2016/11/7.
 */

public class CustomViewPagerAdapter extends FragmentPagerAdapter {
    private  FragmentManager fm;
    private  ArrayList<HomeItemFragment2> fragments;

    public CustomViewPagerAdapter(FragmentManager fm, ArrayList<HomeItemFragment2> fragments) {
        super(fm);
        this.fragments=fragments;
        this.fm=fm;
    }
//
//    @Override
//    public Fragment getItem(int position) {
//        return fragments.get(position);
//    }
//
//    @Override
//    public int getCount() {
//        return fragments.size();
//    }
    @Override
    public Fragment getItem(int position) {
        Fragment fragment = null;
        fragment = fragments.get(position);
        Bundle bundle = new Bundle();
        bundle.putString("id",""+position);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public int getCount() {
        return fragments.size();
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        Fragment fragment = (Fragment)super.instantiateItem(container,position);
        fm.beginTransaction().show(fragment).commit();
        return fragment;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
              // super.destroyItem(container, position, object);
        Fragment fragment = fragments.get(position);
        fm.beginTransaction().hide(fragment).commit();

    }
}
