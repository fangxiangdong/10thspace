package com.tenth.space.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.DisplayMetrics;
import android.view.WindowManager;
import android.widget.AbsListView;

import com.tenth.space.R;
import com.tenth.space.config.SysConstant;
import com.tenth.space.ui.helper.CircleBitmapDisplayer;
import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.cache.disc.naming.Md5FileNameGenerator;
import com.nostra13.universalimageloader.cache.memory.impl.UsingFreqLimitedMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;
import com.nostra13.universalimageloader.core.listener.PauseOnScrollListener;
import com.nostra13.universalimageloader.utils.StorageUtils;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by zhujian on 15/1/14.
 */
public class ImageLoaderUtil {
    private static Logger logger = Logger.getLogger(ImageLoaderUtil.class);
    private static ImageLoaderConfiguration IMImageLoaderConfig;
    private static ImageLoader IMImageLoadInstance;
    private static Map<Integer, Map<Integer, DisplayImageOptions>> avatarOptionsMaps = new HashMap<Integer, Map<Integer, DisplayImageOptions>>();
    public final static int CIRCLE_CORNER = -10;

    public static void initImageLoaderConfig(Context context) {
        try {
            File cacheDir = StorageUtils.getOwnCacheDirectory(context, CommonUtil.getSavePath(SysConstant.FILE_SAVE_TYPE_IMAGE));
            File reserveCacheDir = StorageUtils.getCacheDirectory(context);

            int maxMemory = (int) (Runtime.getRuntime().maxMemory());
            // 使用最大可用内存值的1/8作为缓存的大小。
            int cacheSize = maxMemory / 8;
            DisplayMetrics metrics = new DisplayMetrics();
            WindowManager mWm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            mWm.getDefaultDisplay().getMetrics(metrics);

            IMImageLoaderConfig = new ImageLoaderConfiguration.Builder(context)
                    .memoryCacheExtraOptions(metrics.widthPixels, metrics.heightPixels)
                    .threadPriority(Thread.NORM_PRIORITY - 2)
                    .threadPoolSize(3)
//                    .denyCacheImageMultipleSizesInMemory()
                    .memoryCache(new UsingFreqLimitedMemoryCache(cacheSize))
                    .diskCacheFileNameGenerator(new Md5FileNameGenerator())
//                    .discCacheFileNameGenerator(new Md5FileNameGenerator() {//可以自定义ImageLoader缓存的KEY
//                        @Override
//                        public String generate(String imageUri) {
//                            String imageName = imageUri;
//                            try {
//                                //imageName = imageUri.split("[?]0SS")[0];
//                                if (imageUri.contains("?OSSAccessKeyId=")){
//                                    imageName = imageUri.split("[?]OSSAccessKeyId=")[0];
//                                }
//
//                            } catch (Exception e) {
//                                // e.printStackTrace();
//                            }
//                            return super.generate(imageName);
//                        }
//                    })
                    .tasksProcessingOrder(QueueProcessingType.LIFO)
                    .diskCacheExtraOptions(metrics.widthPixels, metrics.heightPixels, null)
                    .diskCache(new UnlimitedDiscCache(cacheDir, reserveCacheDir, new Md5FileNameGenerator()))
                    .diskCacheSize(1024 * 1024 * 1024)
                    .diskCacheFileCount(1000)
                    .build();

            IMImageLoadInstance = ImageLoader.getInstance();
            IMImageLoadInstance.init(IMImageLoaderConfig);
        } catch (Exception e) {
            logger.e(e.toString());
        }
    }

    public static ImageLoader instance() {
        return IMImageLoadInstance;
    }

    public static DisplayImageOptions getNoCache() {
        DisplayImageOptions options = new DisplayImageOptions.Builder()
                // 设置图片在下载期间显示的图片
              // .showImageOnLoading(R.drawable.toux)
                // 设置图片Uri为空或是错误的时候显示的图片
             //   .showImageForEmptyUri(R.mipmap.faild)
                // 设置图片加载/解码过程中错误时候显示的图片
              //  .showImageOnFail(R.mipmap.faild)
                // 设置下载的图片是否缓存在内存中
                .cacheInMemory(false)
                // 设置下载的图片是否缓存在SD卡中
                .cacheOnDisk(false)
                // 保留Exif信息
                .considerExifParams(false)
                // 设置图片以如何的编码方式显示
                .imageScaleType(ImageScaleType.EXACTLY_STRETCHED)
                // 设置图片的解码类型
                .bitmapConfig(Bitmap.Config.ARGB_8888)
                // .decodingOptions(android.graphics.BitmapFactory.Options
                // decodingOptions)//设置图片的解码配置
                .considerExifParams(true)
                // 设置图片下载前的延迟
                .delayBeforeLoading(0)// int
                // delayInMillis为你设置的延迟时间
                // 设置图片加入缓存前，对bitmap进行设置
                // .preProcessor(BitmapProcessor preProcessor)
                .resetViewBeforeLoading(false)// 设置图片在下载前是否重置，复位
                // .displayer(new RoundedBitmapDisplayer(20))//是否设置为圆角，弧度为多少
                // .displayer(new FadeInBitmapDisplayer(100))// 淡入
                .build();
        return options;
    }

    public static DisplayImageOptions getNoCacheUseDrawable() {
        DisplayImageOptions options = new DisplayImageOptions.Builder()
                // 设置图片在下载期间显示的图片
                .showImageOnLoading(R.drawable.toux)
                // 设置图片Uri为空或是错误的时候显示的图片
                //   .showImageForEmptyUri(R.mipmap.faild)
                // 设置图片加载/解码过程中错误时候显示的图片
                //  .showImageOnFail(R.mipmap.faild)
                // 设置下载的图片是否缓存在内存中
                .cacheInMemory(false)
                // 设置下载的图片是否缓存在SD卡中
                .cacheOnDisk(false)
                // 保留Exif信息
                .considerExifParams(false)
                // 设置图片以如何的编码方式显示
                .imageScaleType(ImageScaleType.EXACTLY_STRETCHED)
                // 设置图片的解码类型
                .bitmapConfig(Bitmap.Config.ARGB_8888)
                // .decodingOptions(android.graphics.BitmapFactory.Options
                // decodingOptions)//设置图片的解码配置
                .considerExifParams(true)
                // 设置图片下载前的延迟
                .delayBeforeLoading(0)// int
                // delayInMillis为你设置的延迟时间
                // 设置图片加入缓存前，对bitmap进行设置
                // .preProcessor(BitmapProcessor preProcessor)
                .resetViewBeforeLoading(false)// 设置图片在下载前是否重置，复位
                // .displayer(new RoundedBitmapDisplayer(20))//是否设置为圆角，弧度为多少
                // .displayer(new FadeInBitmapDisplayer(100))// 淡入
                .build();
        return options;
    }
    //blogImages
    public static DisplayImageOptions getBlogOptions() {
        DisplayImageOptions options = new DisplayImageOptions.Builder()
                .delayBeforeLoading(10)
                .cacheInMemory(true) // default
                .cacheOnDisk(true) // default
                .imageScaleType(ImageScaleType.EXACTLY) // default
                .bitmapConfig(Bitmap.Config.RGB_565) // default
                .displayer(new FadeInBitmapDisplayer(500)) // default
                .build();
        return options;
    }

//    //头像
//    public static DisplayImageOptions getAvatarOptions2() {
//        DisplayImageOptions newDisplayOption = new DisplayImageOptions.Builder()
//                .showImageOnFail(R.drawable.tt_default_user_portrait_corner)
//                .showImageForEmptyUri(R.drawable.tt_default_user_portrait_corner)
//                .showImageOnLoading(R.drawable.tt_default_user_portrait_corner)
//                .cacheInMemory(true)
//                .resetViewBeforeLoading(true)
//                .bitmapConfig(Bitmap.Config.RGB_565)
//                .displayer(new CircleBitmapDisplayer())
//                .build();
//        return newDisplayOption;
//    }

    //头像
    public static DisplayImageOptions getAvatarOptions(int corner, int defaultRes) {
        if (defaultRes <= 0) {
            defaultRes = R.drawable.tt_default_user_portrait_corner;
        }
        if (avatarOptionsMaps.containsKey(defaultRes)) {
            Map<Integer, DisplayImageOptions> displayOption = avatarOptionsMaps.get(defaultRes);
            if (displayOption.containsKey(corner)) {
                DisplayImageOptions displayImageOptions = displayOption.get(corner);
                return displayImageOptions;
            }
        }
        DisplayImageOptions newDisplayOption = null;
        if (corner == CIRCLE_CORNER) {
            newDisplayOption = new DisplayImageOptions.Builder()
                    .showImageOnFail(defaultRes)
                    .showImageForEmptyUri(defaultRes)
                    .cacheInMemory(true)
                    .resetViewBeforeLoading(true)
                    .bitmapConfig(Bitmap.Config.RGB_565)
                    .displayer(new CircleBitmapDisplayer())
                    .build();
        } else {
            if (corner < 0) {
                corner = 0;
            }
            newDisplayOption = new DisplayImageOptions.Builder()
                    .showImageOnLoading(defaultRes)
                    .showImageForEmptyUri(defaultRes)
                    .showImageOnFail(defaultRes)
                    .cacheInMemory(true)
                    .cacheOnDisk(true)
                    .considerExifParams(true)
                    .imageScaleType(ImageScaleType.EXACTLY)
                    .bitmapConfig(Bitmap.Config.RGB_565)
                    .resetViewBeforeLoading(false)
                    .displayer(new RoundedBitmapDisplayer(corner))
                    .build();
        }

        Map<Integer, DisplayImageOptions> cornerDisplayOptMap = new HashMap<Integer, DisplayImageOptions>();
        cornerDisplayOptMap.put(corner, newDisplayOption);
        avatarOptionsMaps.put(defaultRes, cornerDisplayOptMap);
        return newDisplayOption;
    }

    /**
     * 清除缓存
     */
    public static void clearCache() {
        try {
            if (IMImageLoadInstance != null) {
                IMImageLoadInstance.clearMemoryCache();
                IMImageLoadInstance.clearDiskCache();
            }
            if (null != avatarOptionsMaps) {
                avatarOptionsMaps.clear();
            }
        } catch (Exception e) {
            logger.e(e.toString());
        }
    }

    static PauseOnScrollListener pauseOnScrollListener = new PauseOnScrollListener(ImageLoaderUtil.instance(), true, true);

    public static AbsListView.OnScrollListener getPauseOnScrollLoader() {
        return pauseOnScrollListener;
    }
}
