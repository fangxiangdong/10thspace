package com.tenth.space.ui.activity;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.BinaryHttpResponseHandler;
import com.tenth.tools.EncryptTools;
import com.tenth.space.DB.sp.LoginSp;
import com.tenth.space.DB.sp.SystemConfigSp;
import com.tenth.space.R;
import com.tenth.space.config.IntentConstant;
import com.tenth.space.config.UrlConstant;
import com.tenth.space.imservice.event.LoginEvent;
import com.tenth.space.imservice.event.SocketEvent;
import com.tenth.space.imservice.manager.IMLoginManager;
import com.tenth.space.imservice.service.IMService;
import com.tenth.space.imservice.support.IMServiceConnector;
import com.tenth.space.ui.base.TTBaseActivity;
import com.tenth.space.utils.IMUIHelper;
import com.tenth.space.utils.Logger;

import org.apache.http.Header;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

import de.greenrobot.event.EventBus;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import static com.tenth.space.R.id.nick_name;

public class RegisterActivity extends TTBaseActivity implements View.OnFocusChangeListener {

    private Logger logger = Logger.getLogger(LoginActivity.class);
    private Handler uiHandler = new Handler();
    private EditText mTelView;
    private EditText mPasswordView;
    private EditText mRePasswordView;
    private View registerPage;
    private View mLoginStatusView;
    private InputMethodManager intputManager;
    private ImageView mVerificationCodeView;
    private EditText mVerificationCodeText;

    private IMService imService;
    private boolean autoLogin = true;
    private boolean loginSuccess = false;

    //从服务器取验证码图片,http协议。
    private AsyncHttpClient client = new AsyncHttpClient();

    private IMServiceConnector imServiceConnector = new IMServiceConnector() {
        @Override
        public void onServiceDisconnected() {
        }

        @Override
        public void onIMServiceConnected() {
            logger.i("login#onIMServiceConnected");
            imService = imServiceConnector.getIMService();
            try {
                do {
                    if (imService == null) {
                        //后台服务启动链接失败
                        break;
                    }
                    IMLoginManager loginManager = imService.getLoginManager();
                    LoginSp loginSp = imService.getLoginSp();
                    if (loginManager == null || loginSp == null) {
                        // 无法获取登陆控制器
                        break;
                    }

                    LoginSp.SpLoginIdentity loginIdentity = loginSp.getLoginIdentity();
                    if (loginIdentity == null) {
                        // 之前没有保存任何登陆相关的，跳转到登陆页面
                        break;
                    }

                    mTelView.setText(loginIdentity.getLoginName());
                    if (TextUtils.isEmpty(loginIdentity.getPwd())) {
                        // 密码为空，可能是loginOut
                        break;
                    }
                    mPasswordView.setText(loginIdentity.getPwd());

                    if (autoLogin == false) {
                        break;
                    }

                    handleGotLoginIdentity(loginIdentity);
                    return;
                } while (false);

                // 异常分支都会执行这个
                handleNoLoginIdentity();
            } catch (Exception e) {
                // 任何未知的异常
                logger.w("loadIdentity failed");
                handleNoLoginIdentity();
            }
        }
    };
    private EditText num;
    private EditText code;
    private EditText password;
    private EditText reaptpassword;
    private TextView getcode;
    private TextView register;
    private EditText nickname;


    /**
     * 跳转到登陆的页面
     */
    private void handleNoLoginIdentity() {
        logger.i("login#handleNoLoginIdentity");
        uiHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                showLoginPage();
            }
        }, 1000);
    }

    /**
     * 自动登陆
     */
    private void handleGotLoginIdentity(final LoginSp.SpLoginIdentity loginIdentity) {
        logger.i("login#handleGotLoginIdentity");

        uiHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                logger.i("login#start auto login");
                if (imService == null || imService.getLoginManager() == null) {
                    Toast.makeText(RegisterActivity.this, getString(R.string.login_failed), Toast.LENGTH_SHORT).show();
                    showLoginPage();
                }
                imService.getLoginManager().login(loginIdentity);
            }
        }, 500);
    }

    private void showLoginPage() {
        registerPage.setVisibility(View.VISIBLE);
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        intputManager = (InputMethodManager) getSystemService(this.INPUT_METHOD_SERVICE);
        logger.i("register#onCreate");

        SystemConfigSp.instance().init(getApplicationContext());
        if (TextUtils.isEmpty(SystemConfigSp.instance().getStrConfig(SystemConfigSp.SysCfgDimension.VERIFICATIONCODESERVER))) {
            SystemConfigSp.instance().setStrConfig(SystemConfigSp.SysCfgDimension.VERIFICATIONCODESERVER, UrlConstant.VERIFICATION_CODE_SERVER);
        }
        if (TextUtils.isEmpty(SystemConfigSp.instance().getStrConfig(SystemConfigSp.SysCfgDimension.REGISTERSERVER))) {
            SystemConfigSp.instance().setStrConfig(SystemConfigSp.SysCfgDimension.REGISTERSERVER, UrlConstant.REGISTER_SERVER);
        }

        //imServiceConnector.connect(RegisterActivity.this);
        //EventBus.getDefault().register(this);

        setContentView(R.layout.tt_activity_register);

//        mVerificationCodeView = (ImageView) findViewById(R.id.verification_code);
//        mVerificationCodeText = (EditText) findViewById(R.id.verification_code_text);
        init();

//        mTelView = (EditText) findViewById(R.id.tel);
//        mPasswordView = (EditText) findViewById(R.id.password);
//        mPasswordView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
//            @Override
//            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
//
//                if (id == R.id.login || id == EditorInfo.IME_NULL) {
//                    attemptLogin();
//                    return true;
//                }
//                return false;
//            }
//        });
//
        mLoginStatusView = findViewById(R.id.login_status);
        register = (TextView) findViewById(R.id.tv_sure);
        register.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {

                 if ("".equals(password.getText().toString())) {
                    Toast.makeText(RegisterActivity.this, "密码不能为空", Toast.LENGTH_SHORT).show();
                }
                else if (password.getText().length() < 6 || password.getText().length() > 15) {
                    Toast.makeText(RegisterActivity.this, "请输入6-15位密码", Toast.LENGTH_SHORT).show();
                } else if ("".equals(reaptpassword.getText().toString())) {
                    Toast.makeText(RegisterActivity.this, "确认密码不能为空", Toast.LENGTH_SHORT).show();

                } else if (!password.getText().toString().equals(reaptpassword.getText().toString())) {
                    Toast.makeText(RegisterActivity.this, "输入两次密码不一致", Toast.LENGTH_SHORT).show();
                } else
                    attemptRegister();
            }
        });
        initAutoLogin();
        reqVerificationCode();
    }

    private void init() {
        code = (EditText) findViewById(R.id.et_code);
        nickname = (EditText) findViewById(nick_name);
        password = (EditText) findViewById(R.id.et_psw);
        reaptpassword = (EditText) findViewById(R.id.repeat_psw);
        getcode = (TextView) findViewById(R.id.tv_code);
        getcode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                getCode(num.getText().toString());
                TimeCount time = new TimeCount(60000, 1000);
                time.start();
            }
        });
        findViewById(R.id.back).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        password.setOnFocusChangeListener(this);
        reaptpassword.setOnFocusChangeListener(this);
    }

    private void getCode(String num) {
        String pa = "{\"phone\": " + num + " }";
        final OkHttpClient client = new OkHttpClient();
        RequestBody body = new FormBody.Builder().add("arg", pa).build();
        final Request request = new Request.Builder()
                .url(UrlConstant.CODE_SERVER)
                .post(body)
                .build();
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Response response = client.newCall(request).execute();
                    JSONObject jsonObject = new JSONObject(response.body().string());
                    int code = jsonObject.optInt("error_code");
                    final String message = jsonObject.optString("error_message");
                    if (code == 0) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(RegisterActivity.this, "已发送短信，请注意查收", Toast.LENGTH_SHORT).show();
                            }
                        });
                    } else {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(RegisterActivity.this, message, Toast.LENGTH_SHORT).show();
                            }
                        });
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            }
        }).start();
    }

    private void attemptRegister() {
        register.setEnabled(false);
        JSONObject json = new JSONObject();
        try {
//            json.put("nick",nickname.getText().toString());
            json.put("valid_code", code.getText().toString());
            json.put("phone",getIntent().getStringExtra("phone"));
            json.put("passwd", EncryptTools.instance().toMD5(password.getText().toString()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        final OkHttpClient client = new OkHttpClient();
        String s = json.toString();
        RequestBody body = new FormBody.Builder().add("arg", json.toString()).build();
        final Request request = new Request.Builder()
                .url(UrlConstant.REGISTER_SERVER)
                .post(body)
                .build();
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(RegisterActivity.this, "注册异常，请重试", Toast.LENGTH_SHORT).show();
                        register.setEnabled(true);
                    }
                });
            }
            @Override
            public void onResponse(Call call, Response response) throws IOException {
                try {

//                    int code1 = response.code();
//                    String string = response.body().string();
//                    Log.i("gata",string);
                    JSONObject jsonObject = new JSONObject(response.body().string());
                    final int error_code = jsonObject.optInt("error_code");
                    final String message = jsonObject.optString("error_message");
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {

                            switch (error_code){
                                case 0:
                                    Toast.makeText(RegisterActivity.this, "注册成功", Toast.LENGTH_SHORT).show();
                                    finish();
                                    break;
                                case 1:
                                case 2:
                                case 4:
                                case 11:
                                    Toast.makeText(RegisterActivity.this, message, Toast.LENGTH_SHORT).show();
                                    Intent intent = new Intent(RegisterActivity.this,RegisterActivity1.class);
                                    startActivity(intent);
                                    finish();
                                    break;
                                case 3:
                                    code.setText("");
                                    register.setEnabled(true);
                                    Toast.makeText(RegisterActivity.this, message, Toast.LENGTH_SHORT).show();
                                    break;
                            }
                        }
                    });
                } catch (IOException e) {
                    e.printStackTrace();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//                try {
//                    Response response = client.newCall(request).execute();
//                    LogUtils.d("attemptRegister:" + response.toString());
//                    LogUtils.d("attemptRegister:body:" + response.body().string());
//
//                } catch (IOException e) {
//                    e.printStackTrace();
//                }
//
//            }
//        }).start();

    }

    private void initAutoLogin() {
        logger.i("register#initAutoLogin");

        registerPage = findViewById(R.id.register_page);
        autoLogin = shouldAutoLogin();

        registerPage.setVisibility(View.VISIBLE);

        registerPage.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                if (mPasswordView != null) {
                    intputManager.hideSoftInputFromWindow(mPasswordView.getWindowToken(), 0);
                }

                if (mTelView != null) {
                    intputManager.hideSoftInputFromWindow(mTelView.getWindowToken(), 0);
                }

                return false;
            }
        });

        /*if (autoLogin) {
            Animation splashAnimation = AnimationUtils.loadAnimation(this, R.anim.login_splash);
            if (splashAnimation == null) {
                logger.e("login#loadAnimation login_splash failed");
                return;
            }

            splashPage.startAnimation(splashAnimation);
        }*/
    }

    // 主动退出的时候， 这个地方会有值,更具pwd来判断
    private boolean shouldAutoLogin() {
        Intent intent = getIntent();
        if (intent != null) {
            boolean notAutoLogin = intent.getBooleanExtra(IntentConstant.KEY_LOGIN_NOT_AUTO, false);
            logger.i("login#notAutoLogin:%s", notAutoLogin);
            if (notAutoLogin) {
                return false;
            }
        }
        return true;
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();

        imServiceConnector.disconnect(RegisterActivity.this);
        EventBus.getDefault().unregister(this);
        registerPage = null;
    }


    public void attemptLogin() {
        String loginName = mTelView.getText().toString();
        String mPassword = mPasswordView.getText().toString();
        boolean cancel = false;
        View focusView = null;

        if (TextUtils.isEmpty(mPassword)) {
            Toast.makeText(this, getString(R.string.error_pwd_required), Toast.LENGTH_SHORT).show();
            focusView = mPasswordView;
            cancel = true;
        }

        if (TextUtils.isEmpty(loginName)) {
            Toast.makeText(this, getString(R.string.error_name_required), Toast.LENGTH_SHORT).show();
            focusView = mTelView;
            cancel = true;
        }

        if (cancel) {
            focusView.requestFocus();
        } else {
            showProgress(true);
            if (imService != null) {
//				boolean userNameChanged = true;
//				boolean pwdChanged = true;
                loginName = loginName.trim();
                mPassword = mPassword.trim();
                imService.getLoginManager().login(loginName, mPassword);
            }
        }
    }

    //担心性能的问题，不想做数据拷贝。直接放在acitivity中，不放在service(IMSocketManager)中
    public void reqVerificationCode() {
        logger.i("socket#reqMsgServerAddrs.");
        client.setUserAgent("Android-TT");
        String[] allowedContentTypes = new String[]{"image/png;charset=utf8"};
        client.get(SystemConfigSp.instance().getStrConfig(SystemConfigSp.SysCfgDimension.VERIFICATIONCODESERVER), new BinaryHttpResponseHandler(allowedContentTypes) {
            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  byte[] binaryData) {
                logger.i("onSuccess:" + statusCode + " binaryData:"
                        + binaryData.length);
                updateImage(binaryData);
            }

            @Override
            public void onFailure(int statusCode, Header[] headers,
                                  byte[] binaryData, Throwable error) {
                logger.e("onFailure:" + error + " statusCode:" + statusCode);

            }
        });
    }

    public void updateImage(byte[] data) {
        Bitmap b = BitmapFactory.decodeByteArray(data, 0, data.length);
        if (mVerificationCodeView != null) {
            mVerificationCodeView.setImageBitmap(b);
        }
    }

    private void showProgress(final boolean show) {
        if (show) {
            mLoginStatusView.setVisibility(View.VISIBLE);
        } else {
            mLoginStatusView.setVisibility(View.GONE);
        }
    }

    // 为什么会有两个这个
    // 可能是 兼容性的问题 导致两种方法onBackPressed
    @Override
    public void onBackPressed() {
        logger.i("login#onBackPressed");
        //imLoginMgr.cancel();
        // TODO Auto-generated method stub
        super.onBackPressed();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
//        if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
//            LoginActivity.this.finish();
//            return true;
//        }
        return super.onKeyDown(keyCode, event);
    }


    @Override
    protected void onStop() {
        super.onStop();
    }

    /**
     * ----------------------------event 事件驱动----------------------------
     */
    public void onEventMainThread(LoginEvent event) {
        switch (event) {
            case LOCAL_LOGIN_SUCCESS:
            case LOGIN_OK:
                onLoginSuccess();
                break;
            case LOGIN_AUTH_FAILED:
            case LOGIN_INNER_FAILED:
                if (!loginSuccess)
                    onLoginFailure(event);
                break;
        }
    }


    public void onEventMainThread(SocketEvent event) {
        switch (event) {
            case CONNECT_MSG_SERVER_FAILED:
            case REQ_MSG_SERVER_ADDRS_FAILED:
                if (!loginSuccess)
                    onSocketFailure(event);
                break;
        }
    }

    private void onLoginSuccess() {
        logger.i("login#onLoginSuccess");
        loginSuccess = true;
        Intent intent = new Intent(RegisterActivity.this, MainActivity.class);
        startActivity(intent);
        RegisterActivity.this.finish();
    }

    private void onLoginFailure(LoginEvent event) {
        logger.e("login#onLoginError -> errorCode:%s", event.name());
        showLoginPage();
        String errorTip = getString(IMUIHelper.getLoginErrorTip(event));
        logger.i("login#errorTip:%s", errorTip);
        mLoginStatusView.setVisibility(View.GONE);
        Toast.makeText(this, errorTip, Toast.LENGTH_SHORT).show();
    }

    private void onSocketFailure(SocketEvent event) {
        logger.e("login#onLoginError -> errorCode:%s,", event.name());
        showLoginPage();
        String errorTip = getString(IMUIHelper.getSocketErrorTip(event));
        logger.i("login#errorTip:%s", errorTip);
        mLoginStatusView.setVisibility(View.GONE);
        Toast.makeText(this, errorTip, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
            switch (v.getId()) {
                case R.id.et_phone:
                    String telRegex = "[1][358]\\d{9}";
                    if (!num.getText().toString().matches(telRegex)) {
                        Toast.makeText(this, "请输入正确的手机号", Toast.LENGTH_SHORT).show();
                    }
                    break;
                case R.id.et_code:
                    if (code.getText().length() != 6) {
                        Toast.makeText(this, "请输入6位验正确的证码", Toast.LENGTH_SHORT).show();
                    }
                    break;
                case R.id.et_psw:
                    if (password.getText().length() < 6 || password.getText().length() > 10) {
                        Toast.makeText(this, "请输入6-10位密码", Toast.LENGTH_SHORT).show();
                    }
                    break;
                case R.id.repeat_psw:
                    if (!password.getText().toString().equals(reaptpassword.getText().toString())) {
                        Toast.makeText(this, "输入两次密码不一致", Toast.LENGTH_SHORT).show();
                    }
                    break;
            }
        }
    }

    class TimeCount extends CountDownTimer {
        public TimeCount(long millisInFuture, long countDownInterval) {
            super(millisInFuture, countDownInterval);
        }

        @Override
        public void onFinish() {// 计时完毕
            getcode.setText("重新获取验证码");
            getcode.setClickable(true);
        }

        @Override
        public void onTick(long millisUntilFinished) {// 计时过程
            getcode.setClickable(false);//防止重复点击
            getcode.setText(millisUntilFinished / 1000 + "s");
        }
    }
}
