package com.tenth.space.utils;

import android.app.Activity;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Camera;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;

import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.nostra13.universalimageloader.cache.disc.DiskCache;
import com.nostra13.universalimageloader.cache.memory.MemoryCache;
import com.nostra13.universalimageloader.utils.DiskCacheUtils;
import com.nostra13.universalimageloader.utils.MemoryCacheUtils;
import com.tenth.space.R;
import com.tenth.space.aliyun.AliyunUpload;
import com.tenth.space.aliyun.Config;
import com.tenth.space.aliyun.STSGetter;
import com.tenth.space.app.IMApplication;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.SimpleImageLoadingListener;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.Calendar;

/**
 * 工具类
 * Created by linzh01 on 2016/5/12.
 */
public class Utils {

    public static String PNG = ".png";

    /**
     * 格式化小数
     */
    public static String formatDecimal(float f) {
        DecimalFormat df = new DecimalFormat("0.00");
        String format = df.format(f);
        return format;
    }

    /**
     * 图片按照格式保存方法
     *
     * @param original_bitmap
     * @param path
     */
    public static void saveBitmapByFormat(Bitmap original_bitmap, String path, Bitmap.CompressFormat format) {
        File file = new File(path);
        try {
            FileOutputStream out = new FileOutputStream(file);
            if (original_bitmap.compress(format, 100, out)) {
                out.flush();
                out.close();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    //p
    public static boolean isCameraCanUse() {
        boolean canUse = true;
        Camera mCamera = null;
        try {
            // TODO camera驱动挂掉,处理??
            mCamera = Camera.open();
        } catch (Exception e) {
            canUse = false;
        }
        if (canUse) {
            mCamera.release();
            mCamera = null;
        }

        return canUse;
    }

    /**
     * 转换uri为path
     */
    public static String getPathByUri(Activity activity, Uri uri) {
        String[] proj = {MediaStore.Images.Media.DATA};
        Cursor actualimagecursor = activity.managedQuery(uri, proj, null, null, null);
        int actual_image_column_index = actualimagecursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
        actualimagecursor.moveToFirst();
        String path = actualimagecursor.getString(actual_image_column_index);
        return path;
    }

    /**
     * 设置添加屏幕的背景透明度
     *
     * @param bgAlpha
     */
    public static void setBackgroundAlpha(Activity activity, float bgAlpha) {
        WindowManager.LayoutParams lp = activity.getWindow().getAttributes();
        lp.alpha = bgAlpha; //0.0-1.0
        activity.getWindow().setAttributes(lp);
    }

    /*
    获取手机唯一识别码IMEI号
     */
    public static String getPhoneIMEI(Context context) {
        TelephonyManager mTm = (TelephonyManager) context.getSystemService(context.TELEPHONY_SERVICE);
        String imei = mTm.getDeviceId();
        return imei;
    }

    /**
     * 验证手机格式
     */

    public static boolean isMobileNO(String mobiles) {
        /*
        移动：134、135、136、137、138、139、150、151、157(TD)、158、159、187、188
        联通：130、131、132、152、155、156、185、186
        电信：177,133、153、180、189、（1349卫通）
        总结起来就是第一位必定为1，第二位必定为3或5或8，其他位置的可以为0-9
        */
        String telRegex = "[1][3578]\\d{9}";//"[1]"代表第1位为数字1，"[358]"代表第二位可以为3、5、8中的一个，"\\d{9}"代表后面是可以是0～9的数字，有9位。
        if (TextUtils.isEmpty(mobiles))
            return false;
        else
            return mobiles.matches(telRegex);
    }

    /**
     * 获取屏幕宽高
     *
     * @return
     */
    public static int[] getDisplayInfo() {
        WindowManager systemService = (WindowManager) IMApplication.app.getSystemService(Context.WINDOW_SERVICE);
        int width = systemService.getDefaultDisplay().getWidth();
        int height = systemService.getDefaultDisplay().getHeight();
        return new int[]{width, height};

    }

    /**
     * bitmap转为base64
     *
     * @param bitmap
     *
     * @return
     */
    public static String bitmapToBase64(Bitmap bitmap) {

        String result = null;
        ByteArrayOutputStream baos = null;
        try {
            if (bitmap != null) {
                baos = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);

                baos.flush();
                baos.close();

                byte[] bitmapBytes = baos.toByteArray();
                //result = android.util.Base64.encodeToString(bitmapBytes, android.util.Base64.DEFAULT);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (baos != null) {
                    baos.flush();
                    baos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return result;
    }

    /**
     * 此方法用于判断String是否为null，或者长度为0，或者为字符串"null"(忽略大小写)
     *
     * @param str
     *
     * @return
     */
    public static boolean isStringEmpty(String str) {
        if (str == null || str.length() == 0 || str.equalsIgnoreCase("null"))
            return true;
        else
            return false;
    }

    private static long getFileSizes(File file) throws Exception {
        long size = 0;
        if (file.exists()) {
            FileInputStream fis = null;
            fis = new FileInputStream(file);
            size = fis.available();
        }
        return size;
    }

    public static double getFileOrFilesSize(String filePath) {
        File file = new File(filePath);
        long blockSize = 0;
        try {
            if (file.isDirectory()) {
                blockSize = getFileSizes(file);
            } else {
                blockSize = getFileSizes(file);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return FormetFileSize(blockSize, SIZETYPE_B);
    }

    private static String FormetFileSize(long fileS) {
        DecimalFormat df = new DecimalFormat("#.00");
        String fileSizeString = "";
        String wrongSize = "0B";
        if (fileS == 0) {
            return wrongSize;
        }
        if (fileS < 1024) {
            fileSizeString = df.format((double) fileS) + "B";
        } else if (fileS < 1048576) {
            fileSizeString = df.format((double) fileS / 1024) + "KB";
        } else if (fileS < 1073741824) {
            fileSizeString = df.format((double) fileS / 1048576) + "MB";
        } else {
            fileSizeString = df.format((double) fileS / 1073741824) + "GB";
        }
        return fileSizeString;
    }

    /**
     * 转换文件大小,指定转换的类型
     *
     * @param fileS
     * @param sizeType
     * @return
     */
    final static int SIZETYPE_B = 1;
    final static int SIZETYPE_KB = 2;
    final static int SIZETYPE_MB = 3;
    final static int SIZETYPE_GB = 4;

    private static double FormetFileSize(long fileS, int sizeType) {
        DecimalFormat df = new DecimalFormat("#.00");
        double fileSizeLong = 0;
        switch (sizeType) {
            case SIZETYPE_B:

                fileSizeLong = Double.valueOf(df.format((double) fileS));
                break;
            case SIZETYPE_KB:
                fileSizeLong = Double.valueOf(df.format((double) fileS / 1024));
                break;
            case SIZETYPE_MB:
                fileSizeLong = Double.valueOf(df.format((double) fileS / 1048576));
                break;
            case SIZETYPE_GB:
                fileSizeLong = Double.valueOf(df.format((double) fileS / 1073741824));
                break;
            default:
                break;
        }
        return fileSizeLong;
    }

    /**
     * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
     */
    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * 根据手机的分辨率从 px(像素) 的单位 转成为 dp
     */
    public static int px2dip(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    public static byte[] BitmapToStream(Bitmap bitmap) {
        ByteArrayOutputStream output = new ByteArrayOutputStream();//初始化一个流对象
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, output);//把bitmap100%高质量压缩 到 output对象里
        // bitmap.recycle();//自由选择是否进行回收
        byte[] result = output.toByteArray();//转换成功了
        try {
            output.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public static String getPhotoPathFromContentUri(Context context, Uri uri) {
        String photoPath = "";
        if (context == null || uri == null) {
            return photoPath;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && DocumentsContract.isDocumentUri(context, uri)) {
            String docId = DocumentsContract.getDocumentId(uri);
            if (isExternalStorageDocument(uri)) {
                String[] split = docId.split(":");
                if (split.length >= 2) {
                    String type = split[0];
                    if ("primary".equalsIgnoreCase(type)) {
                        photoPath = Environment.getExternalStorageDirectory() + "/" + split[1];
                    }
                }
            } else if (isDownloadsDocument(uri)) {
                Uri contentUri = ContentUris.withAppendedId(Uri.parse("content://downloads/public_downloads"), Long.valueOf(docId));
                photoPath = getDataColumn(context, contentUri, null, null);
            } else if (isMediaDocument(uri)) {
                String[] split = docId.split(":");
                if (split.length >= 2) {
                    String type = split[0];
                    Uri contentUris = null;
                    if ("image".equals(type)) {
                        contentUris = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                    } else if ("video".equals(type)) {
                        contentUris = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                    } else if ("audio".equals(type)) {
                        contentUris = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                    }
                    String selection = MediaStore.Images.Media._ID + "=?";
                    String[] selectionArgs = new String[]{split[1]};
                    photoPath = getDataColumn(context, contentUris, selection, selectionArgs);
                }
            }
        } else if ("file".equalsIgnoreCase(uri.getScheme())) {
            photoPath = uri.getPath();
        } else {
            photoPath = getDataColumn(context, uri, null, null);
        }

        return photoPath;
    }

    private static boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    private static boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    private static boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    private static String getDataColumn(Context context, Uri uri, String selection, String[] selectionArgs) {
        Cursor cursor = null;
        String column = MediaStore.Images.Media.DATA;
        String[] projection = {column};
        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
            if (cursor != null && cursor.moveToFirst()) {
                int index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(index);
            }
        } finally {
            if (cursor != null && !cursor.isClosed())
                cursor.close();
        }
        return null;
    }

    //获取当前是哪一年
    public static String getCurrentYear() {
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        return String.valueOf(year);
    }

    //获取当前是哪一年
    public static String getCurrentMonth() {
        Calendar cal = Calendar.getInstance();
        int month = cal.get(Calendar.MONTH) + 1;
        String currentmonth = "";
        if (month < 10) {
            currentmonth = "0" + month;
        } else if (month >= 10) {
            currentmonth = String.valueOf(month);
        }
        return currentmonth;
    }

    //Json字符串转换JsonArray
    public static JSONArray string2JsonArray(String blogImages) {
        if (!TextUtils.isEmpty(blogImages)) {
            try {
                JSONArray jsonArray = new JSONArray(blogImages);
                return jsonArray;
            } catch (JSONException e) {
                e.printStackTrace();
                return null;
            }
        }
        return null;
    }

    //Json字符串转换JsonObject
    public static JSONObject string2JsonObject(String blogImages) {
        if (!TextUtils.isEmpty(blogImages)) {
            try {
                JSONObject jsonObject = new JSONObject(blogImages);
                return jsonObject;
            } catch (JSONException e) {
                e.printStackTrace();
                return null;
            }
        }
        return null;
    }

    public static String getPhoneModel() {
        return Build.MODEL;
    }
    //上传用户默认头像

    public static void checkAndUpLoadPicture(final Context context) {
        IMApplication.app.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                ImageLoaderUtil.instance().loadImage(IMApplication.app.UrlFormat(Config.endpointExtra+Config.avatarPicsPath+ IMLoginManager.instance().getLoginId()+Utils.PNG),ImageLoaderUtil.getNoCache(),new SimpleImageLoadingListener(){
                    @Override
                    public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
                        super.onLoadingComplete(imageUri, view, loadedImage);
                        //上传bitmap
                        if (loadedImage!=null) {
                            upLoadToAliYUN(loadedImage,context);
                        }
//                        else {
//                            //上传默认头像
//                            Bitmap defaultBitmap = BitmapFactory.decodeResource(IMApplication.app.getResources(), R.drawable.tt_default_user_portrait_corner);
//                            upLoadToAliYUN(defaultBitmap,context);
//                        }

                    }

                    @Override
                    public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
                        super.onLoadingFailed(imageUri, view, failReason);
                        //上传默认头像
                        Bitmap defaultBitmap = BitmapFactory.decodeResource(IMApplication.app.getResources(), R.drawable.toux);
                        upLoadToAliYUN(defaultBitmap,context);
                    }
                });
            }
        });


    }

    public   static void upLoadToAliYUN(Bitmap btm,Context context) {
        //上传到aliyun服务器
        //OSSClient ossClient = new OSSClient(context, Config.endpoint, STSGetter.instance(), Config.getAliClientConf());
        OSSClient ossClient = IMApplication.app.GetGlobleOSSClent();
        final String imageName = IMLoginManager.instance().getLoginId() + Utils.PNG;
        //构建上传请求
        ByteArrayOutputStream output = new ByteArrayOutputStream();//初始化一个流对象
        btm.compress(Bitmap.CompressFormat.JPEG, 50, output);//把bitmap100%高质量压缩 到 output对象里
        byte[] result = output.toByteArray();//转换成功了
        try {
            output.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        PutObjectResult recode = new AliyunUpload(ossClient, Config.privateBucketName, Config.livePicsPath + imageName, null, null, null).uploadBytes(result);
        //Log.i("GTAG","recode="+recode.getStatusCode());
    }
    //清理指定本地缓存和内存缓存

    public  static void clearDiskAndMemoryCache(String pictrueUrl,boolean IsDisk ,boolean IsMemory){
        if (IsDisk){
            DiskCacheUtils.removeFromCache(pictrueUrl, ImageLoaderUtil.instance().getDiskCache());
        }
        if (IsMemory){
            MemoryCacheUtils.removeFromCache(pictrueUrl, ImageLoaderUtil.instance().getMemoryCache());
        }


    }
}
