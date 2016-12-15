/*
 * Copyright 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.tenth.space.ui.fragment;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Point;
import android.graphics.RectF;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.ImageReader;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.util.Size;
import android.util.SparseIntArray;
import android.view.LayoutInflater;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.RadioButton;

import com.alibaba.sdk.android.oss.ClientException;
import com.alibaba.sdk.android.oss.OSSClient;
import com.alibaba.sdk.android.oss.model.PutObjectResult;
import com.tenth.space.R;
import com.tenth.space.aliyun.AliyunUpload;
import com.tenth.space.aliyun.Config;
import com.tenth.space.aliyun.STSGetter;
import com.tenth.space.app.IMApplication;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.ui.adapter.CustomViewPagerAdapter;
import com.tenth.space.ui.widget.AutoFitTextureView;
import com.tenth.space.utils.ToastUtils;
import com.tenth.space.utils.Utils;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;


public class HomeFragment extends MainFragment implements View.OnClickListener,ViewPager.OnPageChangeListener {
    private static final SparseIntArray ORIENTATIONS = new SparseIntArray();
        public  boolean isFirstPicture=true;
    public   boolean globleCheckState=false;
    private static final int REQUEST_CAMERA_PERMISSION = 1;//请求camare权限
    static {
        ORIENTATIONS.append(Surface.ROTATION_0, 90);
        ORIENTATIONS.append(Surface.ROTATION_90, 0);
        ORIENTATIONS.append(Surface.ROTATION_180, 270);
        ORIENTATIONS.append(Surface.ROTATION_270, 180);
    }
    private static final String TAG = "HomeFragment";
    public static boolean CamareStateOpened=false;
    private static final int MAX_PREVIEW_WIDTH = 1920;
    private static final int MAX_PREVIEW_HEIGHT = 1080;
    private final TextureView.SurfaceTextureListener mSurfaceTextureListener
            = new TextureView.SurfaceTextureListener() {

        @Override
        public void onSurfaceTextureAvailable(SurfaceTexture texture, int width, int height) {
          openCamera(width, height);
        }

        @Override
        public void onSurfaceTextureSizeChanged(SurfaceTexture texture, int width, int height) {
            configureTransform(width, height);
        }

        @Override
        public boolean onSurfaceTextureDestroyed(SurfaceTexture texture) {
            return true;
        }

        @Override
        public void onSurfaceTextureUpdated(SurfaceTexture texture) {
        }

    };
    private AutoFitTextureView mTextureView;
    private CameraCaptureSession mCaptureSession;
    private CameraDevice mCameraDevice;
    private Size mPreviewSize;
    private final CameraDevice.StateCallback mStateCallback = new CameraDevice.StateCallback() {

        @Override
        public void onOpened(@NonNull CameraDevice cameraDevice) {
            mCameraOpenCloseLock.release();
            mCameraDevice = cameraDevice;
            createCameraPreviewSession();
        }

        @Override
        public void onDisconnected(@NonNull CameraDevice cameraDevice) {
            mCameraOpenCloseLock.release();
            cameraDevice.close();
            mCameraDevice = null;
        }

        @Override
        public void onError(@NonNull CameraDevice cameraDevice, final int error) {
            mCameraOpenCloseLock.release();
            cameraDevice.close();
            mCameraDevice = null;
            switch (error){
                case ERROR_CAMERA_DISABLED:
                    ToastUtils.show("相机未授权！");
                   // requestPermissions(new String[]{Manifest.permission.CAMERA,Manifest.permission.LOCATION_HARDWARE},REQUEST_CAMERA_PERMISSION);
                   // requestPermissions(new String[]{Manifest.permission.LOCATION_HARDWARE},2);
                    break;
            }
        }

    };
    private HandlerThread mBackgroundThread;
    private Handler mBackgroundHandler;
    private ImageReader mImageReader;
    private CaptureRequest.Builder mPreviewRequestBuilder;
    private CaptureRequest mPreviewRequest;
    private Semaphore mCameraOpenCloseLock = new Semaphore(1);
    private boolean mFlashSupported;
    private int mSensorOrientation;

    public Bitmap cusbitmap;
    private CameraCaptureSession.CaptureCallback mCaptureCallback = new CameraCaptureSession.CaptureCallback() {


        @Override
        public void onCaptureCompleted(@NonNull CameraCaptureSession session,
                                       @NonNull CaptureRequest request,
                                       @NonNull TotalCaptureResult result) {
            if (!isFirstPicture){
                cusbitmap = mTextureView.getBitmap();
                if (cusbitmap!=null) {
                    IMApplication.app.getThreadPool().execute(new Runnable() {//线程池中取线程上传
                        @Override
                        public void run() {
                            upLoadToAliYUN(cusbitmap);
                        }
                    });

                }
            }


        }


    };

    private Timer timer;
    private CustomTimerTask timetask;
    private View view;
  //  private LRecyclerView lr_recycle;
    private ArrayList<Integer> lists= new ArrayList<>();
    private RadioButton rb_01,rb_02,rb_03;
    private ViewPager viewPager;
    private ArrayList<HomeItemFragment2> fragmentLists;
    private CustomViewPagerAdapter viewpagerAdapter;

    private static Size chooseOptimalSize(Size[] choices, int textureViewWidth,
            int textureViewHeight, int maxWidth, int maxHeight, Size aspectRatio) {
        // Collect the supported resolutions that are at least as big as the preview Surface
        List<Size> bigEnough = new ArrayList<>();
        // Collect the supported resolutions that are smaller than the preview Surface
        List<Size> notBigEnough = new ArrayList<>();
        int w = aspectRatio.getWidth();
        int h = aspectRatio.getHeight();
        for (Size option : choices) {
            if (option.getWidth() <= maxWidth && option.getHeight() <= maxHeight &&
                    option.getHeight() == option.getWidth() * h / w) {
                if (option.getWidth() >= textureViewWidth &&
                    option.getHeight() >= textureViewHeight) {
                    bigEnough.add(option);
                } else {
                    notBigEnough.add(option);
                }
            }
        }
        if (bigEnough.size() > 0) {
            return Collections.min(bigEnough, new CompareSizesByArea());
        } else if (notBigEnough.size() > 0) {
            return Collections.max(notBigEnough, new CompareSizesByArea());
        } else {
            Log.e(TAG, "Couldn't find any suitable preview size");
            return choices[0];
        }
    }
    private void upLoadToAliYUN(Bitmap btm) {
        //上传到aliyun服务器
       //OSSClient ossClient = new OSSClient(getActivity(), Config.endpoint, STSGetter.instance(), Config.getAliClientConf());
        OSSClient ossClient=IMApplication.app.GetGlobleOSSClent();
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
       // PutObjectResult resultCode = new AliyunUpload(ossClient, Config.bucketName, Config.livePicsPath + imageName, null, null, null).uploadBytes(result);
        PutObjectResult resultCode = new AliyunUpload(ossClient, Config.privateBucketName, Config.livePicsPath + imageName, null, null, null).uploadBytes(result);
        //签名后的url可用于第三方直接访问
     //   Log.i("GTAG","普通url="+Config.endpointExtra+Config.livePicsPath + imageName);
    }
    public static HomeFragment newInstance() {
        return new HomeFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActivity().getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);//保持屏幕不熄灭
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view=inflater.inflate(R.layout.tt_fragment_home, container, false);
        showBrightnessAdjustDalog();
        return view;
    }

    private void showBrightnessAdjustDalog() {
        final SharedPreferences preferences = getActivity().getSharedPreferences("showBrightnessAdjustDalog", Context.MODE_PRIVATE);
        boolean needShow = preferences.getBoolean("needShow", true);
        if(needShow){
            new AlertDialog.Builder(getActivity(),AlertDialog.THEME_HOLO_LIGHT)
                    .setTitle("温馨提示")
                    .setMessage("建议将手机亮度调低！")
                    .setNegativeButton("不再提示", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            SharedPreferences.Editor editor = preferences.edit();
                            editor.putBoolean("needShow",false);
                            editor.commit();
                        }
                    })
                    .setPositiveButton("我知道啦",null)
                    .create().show();
        }
    }

    @Override
    protected void initHandler() {

    }

    @Override
    public void onViewCreated(final View view, Bundle savedInstanceState) {
        mTextureView = (AutoFitTextureView) view.findViewById(R.id.texture);
       // lr_recycle=(LRecyclerView)view.findViewById(R.id.lr_recycle_view);
        rb_01=(RadioButton)view.findViewById(R.id.rb_01);
        rb_01.setChecked(true);
        rb_01.setOnClickListener(this);
        rb_02=(RadioButton)view.findViewById(R.id.rb_02);
        rb_02.setOnClickListener(this);
        rb_03=(RadioButton)view.findViewById(R.id.rb_03);
        rb_03.setOnClickListener(this);
        viewPager=(ViewPager)view.findViewById(R.id.view_pager);
        viewPager.addOnPageChangeListener(this);
        initFragment();
      //  initRecycleView();


    }

    private void initFragment() {
        //添加fragment
        fragmentLists=new ArrayList<HomeItemFragment2>();
        fragmentLists.add(new HomeItemFragment2(IMBaseDefine.UserRelationType.RELATION_RECOMMEND,this));//0
        fragmentLists.add(new HomeItemFragment2(IMBaseDefine.UserRelationType.RELATION_FRIEND,this));//1
        fragmentLists.add(new HomeItemFragment2(IMBaseDefine.UserRelationType.RELATION_FOLLOW,this));//2
         viewpagerAdapter=new CustomViewPagerAdapter(getChildFragmentManager(),fragmentLists);
        viewPager.setAdapter(viewpagerAdapter);


    }

    //打开相机
    public void doOpenCamare(){
        if (CamareStateOpened) {
            if (mTextureView.isAvailable()) {
                openCamera(mTextureView.getWidth(), mTextureView.getHeight());
            } else {
                mTextureView.setSurfaceTextureListener(mSurfaceTextureListener);
            }
            startTimer();
            startBackgroundThread();
        }
    }
//关闭相机
    public void doCloseCamare(){
        if (CamareStateOpened){
            stopTimer();
            closeCamera();
            stopBackgroundThread();
        }
    }

//    public void onEventMainThread(OnorDownEvent event){
//        //收到消息后处理pictureEntity实体集合处理
//       // List<IMSystem.IMSystemUserOnline> friendsList = event.friendsList;
//        Log.i("GTAG","onfriendlist2="+IMApplication.app.messageOnlineList.size());
//        Log.i("GTAG","downfriendlist2="+IMApplication.app.messageDownlineList.size());
//
////推荐
//        HomeItemFragment currentItem1 = fragmentLists.get(0);
//        ArrayList<PictureEntity> currentItemlists1 = currentItem1.lists;
//        CustomRecycleAdapter currentItemAdapter1 = currentItem1.customadapter;
////好友
//        HomeItemFragment currentItem2 = fragmentLists.get(1);
//        ArrayList<PictureEntity> currentItemlists2= currentItem2.lists;
//        CustomRecycleAdapter currentItemAdapter2 = currentItem2.customadapter;
////关注
//        HomeItemFragment currentItem3 = fragmentLists.get(2);
//        ArrayList<PictureEntity> currentItemlists3= currentItem3.lists;
//        CustomRecycleAdapter currentItemAdapter3 = currentItem3.customadapter;
//
//        switch (event.event){
//            case ONLINE:
//                //便利结合判断类型，添加到各自的fragment中集合
//                Iterator<PictureEntity> onLineiterator = IMApplication.app.messageOnlineList.iterator();
//                while (onLineiterator.hasNext()){
//                    PictureEntity pictureEntity = onLineiterator.next();
//                    switch (pictureEntity.getType()){
//                        case RECOMMEND:
//                            checkAndAdd(currentItemlists1,pictureEntity);
//                            //推荐
//                            break;
//                        case FRIEND:
//                            //好友
//                            checkAndAdd(currentItemlists2,pictureEntity);
//                            break;
//                        case FOLLOW:
//                            checkAndAdd(currentItemlists3,pictureEntity);
//                            //关注
//                            break;
//                    }
//
//                }
//                //分解判断完成后，清空全局集合
//                IMApplication.app.messageOnlineList.clear();
//
//                break;
//            case DOWNLINE:
//                Iterator<PictureEntity> downLineiterator = IMApplication.app.messageDownlineList.iterator();
//                while (downLineiterator.hasNext()){
//                    PictureEntity pictureEntity = downLineiterator.next();
//                    switch (pictureEntity.getType()){
//                        case RECOMMEND:
//                            checkAndDelete(currentItemlists1,pictureEntity);
//                            //推荐
//                            break;
//                        case FRIEND:
//                            checkAndDelete(currentItemlists2,pictureEntity);
//                            //好友
//                            break;
//                        case FOLLOW:
//                            checkAndDelete(currentItemlists3,pictureEntity);
//                            //关注
//                            break;
//                    }
//                }
//                //分解判断完成后，清空全局集合
//                IMApplication.app.messageDownlineList.clear();
//                break;
//        }
//
//        //通知更新
//        int currentItem = viewPager.getCurrentItem();
//        switch (currentItem){
//            case 0:
//                if (currentItemAdapter1!=null) {
//                    currentItemAdapter1.notifyDataSetChanged();
//                }
//                if (currentItem1.tv_total_count!=null){
//                    currentItem1.tv_total_count.setText(getString(R.string.online_friends_count)+(currentItemlists1.size()-1>=0?currentItemlists1.size()-1:0));
//                }
//                //更新数字
//                break;
//            case 1:
//                if (currentItemAdapter2!=null) {
//                    currentItemAdapter2.notifyDataSetChanged();
//                }
//                if (currentItem1.tv_total_count!=null){
//                    currentItem2.tv_total_count.setText(getString(R.string.online_friends_count)+(currentItemlists2.size()-1>=0?currentItemlists2.size()-1:0));
//                }
//
//                break;
//            case 2:
//                if (currentItemAdapter3!=null) {
//                    currentItemAdapter3.notifyDataSetChanged();
//                }
//                if (currentItem1.tv_total_count!=null){
//                    currentItem3.tv_total_count.setText(getString(R.string.online_friends_count)+(currentItemlists3.size()-1>=0?currentItemlists3.size()-1:0));
//                }
//                break;
//        }
//    }
//
//    private void checkAndDelete(ArrayList<PictureEntity> currentItemlists, PictureEntity pictureEntity) {
//        boolean isexist=false;
//        int currentInt = -1;
//        for (int i=0;i<currentItemlists.size();i++){
//            if (currentItemlists.get(i).getFriendId().equals(pictureEntity.getFriendId())){
//                isexist=true;
//                currentInt=i;
//                break;
//            }
//        }
//          if (isexist&&currentInt!=-1){
//              currentItemlists.remove(currentInt);
//         }
//    }
//
//    private void checkAndAdd(ArrayList<PictureEntity> currentItemlist, PictureEntity pictureEntity) {
//                          //  boolean isAdded=false;
//                            for (int i=0;i<currentItemlist.size();i++){
//                                if (currentItemlist.get(i).getFriendId().equals(pictureEntity.getFriendId())){
//                                   // isAdded=true;
//                                    return;
//                                }
//                            }
//        currentItemlist.add(pictureEntity);
//                          //  if (!isAdded){
//                                //添加
//
//                           // }
//    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopTimer();
        closeCamera();
        stopBackgroundThread();
    }

    /**
     * Sets up member variables related to camera.
     *
     * @param width  The width of available size for camera preview
     * @param height The height of available size for camera preview
     */
    private void setUpCameraOutputs(int width, int height) {
        Activity activity = getActivity();
        CameraManager manager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
        try {
            for (String cameraId : manager.getCameraIdList()) {
                CameraCharacteristics characteristics
                        = manager.getCameraCharacteristics(cameraId);

                // We don't use a front facing camera in this sample.
                Integer facing = characteristics.get(CameraCharacteristics.LENS_FACING);
                if (facing != null && facing == CameraCharacteristics.LENS_FACING_FRONT) {
                    continue;
                }

                StreamConfigurationMap map = characteristics.get(
                        CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
                if (map == null) {
                    continue;
                }

                // For still image captures, we use the largest available size.
                Size largest = Collections.max(
                        Arrays.asList(map.getOutputSizes(ImageFormat.JPEG)),
                        new CompareSizesByArea());
               // mImageReader = ImageReader.newInstance(largest.getWidth(), largest.getHeight(), ImageFormat.JPEG, /*maxImages*/2);
               // mImageReader.setOnImageAvailableListener(mOnImageAvailableListener, mBackgroundHandler);

                // Find out if we need to swap dimension to get the preview size relative to sensor
                // coordinate.
                int displayRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
                //noinspection ConstantConditions
                mSensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
                boolean swappedDimensions = false;
                switch (displayRotation) {
                    case Surface.ROTATION_0:
                    case Surface.ROTATION_180:
                        if (mSensorOrientation == 90 || mSensorOrientation == 270) {
                            swappedDimensions = true;
                        }
                        break;
                    case Surface.ROTATION_90:
                    case Surface.ROTATION_270:
                        if (mSensorOrientation == 0 || mSensorOrientation == 180) {
                            swappedDimensions = true;
                        }
                        break;
                    default:
                        Log.e(TAG, "Display rotation is invalid: " + displayRotation);
                }

                Point displaySize = new Point();
                activity.getWindowManager().getDefaultDisplay().getSize(displaySize);
                int rotatedPreviewWidth = width;
                int rotatedPreviewHeight = height;
                int maxPreviewWidth = displaySize.x;
                int maxPreviewHeight = displaySize.y;

                if (swappedDimensions) {
                    rotatedPreviewWidth = height;
                    rotatedPreviewHeight = width;
                    maxPreviewWidth = displaySize.y;
                    maxPreviewHeight = displaySize.x;
                }

                if (maxPreviewWidth > MAX_PREVIEW_WIDTH) {
                    maxPreviewWidth = MAX_PREVIEW_WIDTH;
                }

                if (maxPreviewHeight > MAX_PREVIEW_HEIGHT) {
                    maxPreviewHeight = MAX_PREVIEW_HEIGHT;
                }

                // Danger, W.R.! Attempting to use too large a preview size could  exceed the camera
                // bus' bandwidth limitation, resulting in gorgeous previews but the storage of
                // garbage capture data.
                mPreviewSize = chooseOptimalSize(map.getOutputSizes(SurfaceTexture.class),
                        rotatedPreviewWidth, rotatedPreviewHeight, maxPreviewWidth,
                        maxPreviewHeight, largest);

                // We fit the aspect ratio of TextureView to the size of preview we picked.
                int orientation = getResources().getConfiguration().orientation;
                if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
                    mTextureView.setAspectRatio(
                            mPreviewSize.getWidth(), mPreviewSize.getHeight());
                } else {
                    mTextureView.setAspectRatio(
                            mPreviewSize.getHeight(), mPreviewSize.getWidth());
                }

                // Check if the flash is supported.
                Boolean available = characteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE);
                mFlashSupported = available == null ? false : available;

              //  mCameraId = cameraId;
                return;
            }
        } catch (CameraAccessException e) {
            e.printStackTrace();
        } catch (NullPointerException e) {
           // ErrorDialog.newInstance("相机打开错误").show(getChildFragmentManager(), FRAGMENT_DIALOG);
        }
    }
    private void openCamera(int width, int height) {
//        if (ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
//                ){
//            new AlertDialog.Builder(getActivity(),AlertDialog.THEME_DEVICE_DEFAULT_LIGHT)
//            .setTitle("需要打开摄像头！")
//            .setPositiveButton("打开", new DialogInterface.OnClickListener() {
//                 @Override
//                public void onClick(DialogInterface dialog, int which) {
//                    Log.i("GTAG","未授权");
//                    requestPermissions(new String[]{Manifest.permission.CAMERA,Manifest.permission.LOCATION_HARDWARE},REQUEST_CAMERA_PERMISSION);
//                    requestPermissions(new String[]{Manifest.permission.LOCATION_HARDWARE},2);
//                    ToastUtils.show("相机权限未打开！");
//                }
//            })
//            .setNegativeButton("取消",null)
//            .create()
//            .show();
//        }
            setUpCameraOutputs(width, height);
        configureTransform(width, height);
        Activity activity = getActivity();
        CameraManager manager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
        try {
            if (!mCameraOpenCloseLock.tryAcquire(2500, TimeUnit.MILLISECONDS)) {
                throw new RuntimeException("Time out waiting to lock camera opening.");
            }
            manager.openCamera("1", mStateCallback, mBackgroundHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            throw new RuntimeException("Interrupted while trying to lock camera opening.", e);
        }
    }
    /**
     * Closes the current {@link CameraDevice}.
     */
    private void closeCamera() {
        try {
            mCameraOpenCloseLock.acquire();
            if (null != mCaptureSession) {
                mCaptureSession.close();
                mCaptureSession = null;
            }
            if (null != mCameraDevice) {
                mCameraDevice.close();
                mCameraDevice = null;
            }
            if (null != mImageReader) {
                mImageReader.close();
                mImageReader = null;
            }
        } catch (InterruptedException e) {
            throw new RuntimeException("Interrupted while trying to lock camera closing.", e);
        } finally {
            mCameraOpenCloseLock.release();
        }
    }

    /**
     * Starts a background thread and its {@link Handler}.
     */
    private void startBackgroundThread() {
        mBackgroundThread = new HandlerThread("CameraBackground");
        mBackgroundThread.start();
        mBackgroundHandler = new Handler(mBackgroundThread.getLooper());
    }

    /**
     * Stops the background thread and its {@link Handler}.
     */
    private void stopBackgroundThread() {
        if (mBackgroundThread!=null){
            mBackgroundThread.quitSafely();
           // try {
               // mBackgroundThread.join();//主线程等待子线程终止后才执行
                mBackgroundThread = null;
                mBackgroundHandler = null;
          //  } catch (InterruptedException e) {
              //  e.printStackTrace();
           // }
        }

    }

    /**
     * Creates a new {@link CameraCaptureSession} for camera preview.
     */
    private void createCameraPreviewSession() {
        try {
            SurfaceTexture texture = mTextureView.getSurfaceTexture();
            assert texture != null;

            // We configure the size of default buffer to be the size of camera preview we want.
            texture.setDefaultBufferSize(mPreviewSize.getWidth(), mPreviewSize.getHeight());

            // This is the output Surface we need to start preview.
            Surface surface = new Surface(texture);

            // We set up a CaptureRequest.Builder with the output Surface.
            mPreviewRequestBuilder = mCameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);
            mPreviewRequestBuilder.addTarget(surface);
            mCameraDevice.createCaptureSession(Arrays.asList(surface),
                    new CameraCaptureSession.StateCallback() {

                        @Override
                        public void onConfigured(@NonNull CameraCaptureSession cameraCaptureSession) {
                            updatePreview(cameraCaptureSession,true);

                        }

                        @Override
                        public void onConfigureFailed(
                                @NonNull CameraCaptureSession cameraCaptureSession) {
                          //  showToast("Failed");
                        }
                    }, null
            );
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }

    private void updatePreview(CameraCaptureSession cameraCaptureSession,boolean isfisrt) {
        isFirstPicture=isfisrt;//ture标示预览第一张图片，不取图，很黑看不清楚，false标示定时器更新的图片可以取图
        if (null == mCameraDevice) {
            return;
        }
        // When the session is ready, we start displaying the preview.
        mCaptureSession = cameraCaptureSession;
        try {
            // Auto focus should be continuous for camera preview.
            mPreviewRequestBuilder.set(CaptureRequest.CONTROL_AF_MODE,
                    CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
            // Flash is automatically enabled when necessary.
            setAutoFlash(mPreviewRequestBuilder);

            // Finally, we start displaying the camera preview.
            mPreviewRequest = mPreviewRequestBuilder.build();
            // mCaptureSession.setRepeatingRequest(mPreviewRequest, mCaptureCallback, mBackgroundHandler);
            mCaptureSession.capture(mPreviewRequest, mCaptureCallback, mBackgroundHandler);
        } catch (CameraAccessException e) {
            e.printStackTrace();
        }
    }
    private void configureTransform(int viewWidth, int viewHeight) {
        Activity activity = getActivity();
        if (null == mTextureView || null == mPreviewSize || null == activity) {
            return;
        }
        int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        Matrix matrix = new Matrix();
        RectF viewRect = new RectF(0, 0, viewWidth, viewHeight);
        RectF bufferRect = new RectF(0, 0, mPreviewSize.getHeight(), mPreviewSize.getWidth());
        float centerX = viewRect.centerX();
        float centerY = viewRect.centerY();
        if (Surface.ROTATION_90 == rotation || Surface.ROTATION_270 == rotation) {
            bufferRect.offset(centerX - bufferRect.centerX(), centerY - bufferRect.centerY());
            matrix.setRectToRect(viewRect, bufferRect, Matrix.ScaleToFit.FILL);
            float scale = Math.max(
                    (float) viewHeight / mPreviewSize.getHeight(),
                    (float) viewWidth / mPreviewSize.getWidth());
            matrix.postScale(scale, scale, centerX, centerY);
            matrix.postRotate(90 * (rotation - 2), centerX, centerY);
        } else if (Surface.ROTATION_180 == rotation) {
            matrix.postRotate(180, centerX, centerY);
        }
        mTextureView.setTransform(matrix);
    }
    public void stopTimer() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }

        if (timetask != null) {
            timetask.cancel();
            timetask = null;
        }
    }
    private void setAutoFlash(CaptureRequest.Builder requestBuilder) {
        if (mFlashSupported) {
            requestBuilder.set(CaptureRequest.CONTROL_AE_MODE,
                    CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.rb_01:
                viewPager.setCurrentItem(0);
                break;
            case R.id.rb_02:
                viewPager.setCurrentItem(1);
                break;
            case R.id.rb_03:
                viewPager.setCurrentItem(2);
                break;

        }

    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        switch (position){
            case 0:
                rb_01.setChecked(true);
                break;
            case 1:
                rb_02.setChecked(true);
                break;
            case 2:
                rb_03.setChecked(true);
                break;
        }

    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    /**
     * Compares two {@code Size}s based on their areas.
     */
    static class CompareSizesByArea implements Comparator<Size> {

        @Override
        public int compare(Size lhs, Size rhs) {
            // We cast here to ensure the multiplications won't overflow
            return Long.signum((long) lhs.getWidth() * lhs.getHeight() -
                    (long) rhs.getWidth() * rhs.getHeight());
        }

    }
/*
2016.12.12徐波图片捕获
 */
    @Override
    public void onResume() {
        super.onResume();
        doOpenCamare();
    }

    @Override
    public void onPause() {
        super.onPause();
        doCloseCamare();
    }

    public void startTimer() {

        stopTimer();
        if (timer == null) {
            timer = new Timer();
        }
        if (timetask == null) {
            timetask = new CustomTimerTask();
        }

        if (timer != null && timetask != null)
            timer.schedule(timetask, 500, 10000);
    }
    public class CustomTimerTask extends TimerTask {
        @Override
        public void run() {
            if (mCaptureSession!=null) {
                updatePreview(mCaptureSession,false);
            }
        }
    }

}
