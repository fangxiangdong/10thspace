package com.tenth.space.utils;

import android.util.Log;

import com.tenth.space.config.UrlConstant;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import okhttp3.FormBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * Created by wsq on 2016/11/4.
 */

public class OkHttpUtils {

    public static void request(String jsonString) {
        final OkHttpClient okHttpClient = new OkHttpClient();
//        参数 post -》 arg = {json格式} phone, valid_code, passwd, username
        FormBody.Builder arg = new FormBody.Builder().add("arg", "{\"phone\":\"1\",\"passwd\":\"52c69e3a57331081823331c4e69d3f2e\"}\n");
        final Request request = new Request.Builder().url("http://www.d10gs.com:86/login").post(arg.build()).build();

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Response execute = okHttpClient.newCall(request).execute();
                    Log.i("GTAG","ec"+execute.toString());
                    LogUtils.d("attemptRegister:" + execute.toString());

                } catch (IOException e) {
                    e.printStackTrace();
                }

            }
        }).start();
    }
    public  static void sendLogin(){
        new Thread(){
            @Override
            public void run() {
                super.run();
                try{
                    String urlPath = new String("http://www.d10gs.com:86/login");
                    //String urlPath = new String("http://localhost:8080/Test1/HelloWorld?name=丁丁".getBytes("UTF-8"));
                    String param="arg="+ URLEncoder.encode("{\"phone\":\"1\",\"passwd\":\"52c69e3a57331081823331c4e69d3f2e\"}\n","UTF-8");
                    //建立连接
                    URL url=new URL(urlPath);
                    HttpURLConnection httpConn=(HttpURLConnection)url.openConnection();
                    //设置参数
                    httpConn.setDoOutput(true);   //需要输出
                    httpConn.setDoInput(true);   //需要输入
                    httpConn.setUseCaches(false);  //不允许缓存
                    httpConn.setRequestMethod("POST");   //设置POST方式连接
                    //设置请求属性
                    httpConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                    httpConn.setRequestProperty("Connection", "Keep-Alive");// 维持长连接
                    httpConn.setRequestProperty("Charset", "UTF-8");
                    //连接,也可以不用明文connect，使用下面的httpConn.getOutputStream()会自动connect
                    httpConn.connect();
                    //建立输入流，向指向的URL传入参数
                    DataOutputStream dos=new DataOutputStream(httpConn.getOutputStream());
                    dos.writeBytes(param);
                    dos.flush();
                    dos.close();
                    //获得响应状态
                    int resultCode=httpConn.getResponseCode();
                    Log.i("GTAG","recde="+resultCode);

        if(HttpURLConnection.HTTP_OK==resultCode){
            StringBuffer sb=new StringBuffer();
            String readLine=new String();
            BufferedReader responseReader=new BufferedReader(new InputStreamReader(httpConn.getInputStream(),"UTF-8"));
            while((readLine=responseReader.readLine())!=null){
                sb.append(readLine).append("\n");
            }
            responseReader.close();
            Log.i("GTAG","sb="+sb.toString());
        }
                }catch (Exception e){

                }
            }
        }.start();


    }

}


