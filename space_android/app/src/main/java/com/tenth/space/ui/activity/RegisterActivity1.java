package com.tenth.space.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.tenth.space.R;
import com.tenth.space.config.UrlConstant;
import com.tenth.space.utils.ImageLoaderUtil;
import com.tenth.space.utils.ToastUtils;
import com.tenth.tools.EncryptTools;

import org.apache.http.client.CookieStore;
import org.apache.http.impl.client.BasicCookieStore;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.net.CookieHandler;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import okhttp3.Cookie;
import okhttp3.CookieJar;
import okhttp3.FormBody;
import okhttp3.Headers;
import okhttp3.HttpUrl;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import static android.R.id.message;

public class RegisterActivity1 extends Activity {

    private EditText num;
    private EditText code;
    private TextView next;
    private ImageView imCode;
    private OkHttpClient client;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register1);
        num=(EditText)findViewById(R.id.et_phone);
        code=(EditText)findViewById(R.id.et_code);
        imCode=(ImageView)findViewById(R.id.iv_code);
        next=(TextView)findViewById(R.id.tv_sure);
        findViewById(R.id.back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        client = new OkHttpClient().newBuilder()
                .cookieJar(new CookieJar() {
            private final HashMap<HttpUrl, List<Cookie>> cookieStore = new HashMap<>();

            @Override
            public void saveFromResponse(HttpUrl url, List<Cookie> cookies) {
                cookieStore.put(url, cookies);
            }

            @Override
            public List<Cookie> loadForRequest(HttpUrl url) {
                List<Cookie> cookies = cookieStore.get(url);
                return cookies != null ? cookies : new ArrayList<Cookie>();
            }
        })
         .build();
        setImCode();
//        if(!num.getText().toString().matches("[1][358]\\d{9}")){
//            ToastUtils.show("请输入正确的手机号码");
//        }else {
//
//        }
        imCode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setImCode();
            }
        });
        next.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!num.getText().toString().matches("[1][358]\\d{9}")){
            ToastUtils.show("请输入正确的手机号码");
        }else {
          goToNext(num.getText().toString(),code.getText().toString());
        }
            }
        });
    }
    public void receiveHeaders(Headers headers) throws IOException {
        if (client.cookieJar() == CookieJar.NO_COOKIES) return;

        HttpUrl httpUrl = HttpUrl.parse(UrlConstant.CODE_SERVER);
        List<Cookie> cookies = Cookie.parseAll(httpUrl,headers);
        if (cookies.isEmpty()) return;
        client.cookieJar().saveFromResponse(httpUrl, cookies);
    }
    private String cookieHeader(List cookies) {
        StringBuilder cookieHeader = new StringBuilder();
        for (int i = 0, size = cookies.size(); i < size; i++) {
            if (i > 0) {
                cookieHeader.append(";" );
            }
            Cookie cookie = (Cookie) cookies.get(i);
            cookieHeader.append(cookie.name()).append('=').append(cookie.value());
        }
        return cookieHeader.toString();
    }
    private Request networkRequest(Request request) throws IOException {
        Request.Builder result = request.newBuilder();

        //例行省略....

        List<Cookie> cookies = client.cookieJar().loadForRequest(request.url());
        if (!cookies.isEmpty()) {
            result.header("Cookie", cookieHeader(cookies));
        }

        //例行省略....

        return result.build();
    }
    private void setImCode() {

//        ImageLoader.getInstance().displayImage(UrlConstant.CODE_SERVER,imCode, ImageLoaderUtil.getNoCache());
//        HttpUrl httpUrl = HttpUrl.parse(UrlConstant.CODE_SERVER);
//        List<Cookie> cookies = client.cookieJar().loadForRequest(httpUrl);
        final Request request = new Request.Builder()
                .url(UrlConstant.CODE_SERVER)
                .get()
                .build();
//        Headers headers =request.headers();
//        try {
//            receiveHeaders(headers);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//        try {
//            networkRequest(request);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Response response = client.newCall(request).execute();
                int code = response.code();
                    if (code == 200) {
                        InputStream inputStream = response.body().byteStream();
                        final Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
                         runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                imCode.setImageBitmap(bitmap);
//                                Toast.makeText(RegisterActivity1.this, "已发送短信，请注意查收", Toast.LENGTH_SHORT).show();
                            }
                        });
                    } else {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(RegisterActivity1.this, "请求错误", Toast.LENGTH_SHORT).show();
                            }
                        });
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }
    private void goToNext(final String num, String code) {
//        String pa = "{\"phone\": " + num +",\"valid_code2\":"+code+ " }";
        JSONObject json = new JSONObject();
        try {
            json.put("valid_code2", code);
            json.put("phone", num);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        RequestBody body = new FormBody.Builder().add("arg", json.toString() ).build();
        final Request request = new Request.Builder()
                .url(UrlConstant.PHONE_VALID_CODE)
                .addHeader("Cookie", cookieHeader(client.cookieJar().loadForRequest(HttpUrl.parse(UrlConstant.CODE_SERVER))))
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
                                Intent intent  = new Intent(RegisterActivity1.this,RegisterActivity.class);
                                intent.putExtra("phone",num);
                                startActivity(intent);
                                finish();
                            }
                        });

                    } else if(code==1 || code==2) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(RegisterActivity1.this, message, Toast.LENGTH_SHORT).show();
                                setImCode();
                            }
                        });
                    }else if(code==3 || code==4){
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(RegisterActivity1.this, message, Toast.LENGTH_SHORT).show();
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
}
