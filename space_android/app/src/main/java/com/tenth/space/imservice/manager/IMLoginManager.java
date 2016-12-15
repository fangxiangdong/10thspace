package com.tenth.space.imservice.manager;

import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.google.protobuf.CodedInputStream;
import com.tenth.space.R;
import com.tenth.space.aliyun.Config;
import com.tenth.space.app.IMApplication;
import com.tenth.space.config.UrlConstant;
import com.tenth.space.ui.activity.RegisterActivity;
import com.tenth.space.utils.OkHttpUtils;
import com.tenth.space.utils.Utils;
import com.tenth.tools.EncryptTools;
import com.tenth.space.DB.DBInterface;
import com.tenth.space.DB.entity.UserEntity;
import com.tenth.space.DB.sp.LoginSp;
import com.tenth.space.imservice.callback.Packetlistener;
import com.tenth.space.imservice.event.LoginEvent;
import com.tenth.space.protobuf.helper.ProtoBuf2JavaBean;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.IMBuddy;
import com.tenth.space.protobuf.IMLogin;
import com.tenth.space.utils.Logger;

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



/**
 * 很多情况下都是一种权衡
 * 登陆控制
 *
 * @yingmu
 */
public class IMLoginManager extends IMManager {
    private Logger logger = Logger.getLogger(IMLoginManager.class);

    /**
     * 单例模式
     */
    private static IMLoginManager inst = new IMLoginManager();
    private String userName;
    private String password;

    public static IMLoginManager instance() {
        return inst;
    }

    public IMLoginManager() {
        logger.i("login#creating IMLoginManager");
    }

    IMSocketManager imSocketManager = IMSocketManager.instance();

    /**
     * 登陆参数 以便重试
     */
    private String loginUserName;
    private String loginPwd;
    private int loginId;
    private UserEntity loginInfo;


    /**
     * loginManger 自身的状态 todo 状态太多就采用enum的方式
     */
    private boolean identityChanged = false;
    private boolean isKickout = false;
    private boolean isPcOnline = false;
    //以前是否登陆过，用户重新登陆的判断
    private boolean everLogined = false;

    //本地包含登陆信息了[可以理解为支持离线登陆了]
    private boolean isLocalLogin = false;

    private LoginEvent loginStatus = LoginEvent.NONE;

    /**
     * -------------------------------功能方法--------------------------------------
     */

    @Override
    public void doOnStart() {
    }

    @Override
    public void reset() {
        loginUserName = null;
        loginPwd = null;
        loginId = -1;
        loginInfo = null;
        identityChanged = false;
        isKickout = false;
        isPcOnline = false;
        everLogined = false;
        loginStatus = LoginEvent.NONE;
        isLocalLogin = false;
    }

    /**
     * 实现自身的事件驱动
     *
     * @param event
     */
    public void triggerEvent(LoginEvent event) {
        loginStatus = event;
        EventBus.getDefault().postSticky(event);
    }

    /**
     * if not login, do nothing
     * send logOuting message, so reconnect won't react abnormally
     * but when reconnect start to work again?use isEverLogined
     * close the socket
     * send logOuteOk message
     * mainactivity jumps to login page
     */
    public void logOut() {
        logger.i("login#logOut");
        logger.i("login#stop reconnecting");
        //		everlogined is enough to stop reconnecting
        everLogined = false;
        isLocalLogin = false;
        reqLoginOut();
    }

    /**
     * 退出登陆
     */
    private void reqLoginOut() {
        IMLogin.IMLogoutReq imLogoutReq = IMLogin.IMLogoutReq.newBuilder()
                .build();
        int sid = IMBaseDefine.ServiceID.SID_LOGIN_VALUE;
        int cid = IMBaseDefine.LoginCmdID.CID_LOGIN_REQ_LOGINOUT_VALUE;
        try {
            imSocketManager.sendRequest(imLogoutReq, sid, cid);
        } catch (Exception e) {
            logger.e("#reqLoginOut#sendRequest error,cause by" + e.toString());
        } finally {
            LoginSp.instance().setLoginInfo(userName, null, loginId);
            logger.i("login#send logout finish message");
            triggerEvent(LoginEvent.LOGIN_OUT);
        }
    }

    /**
     * 现在这种模式 req与rsp之间没有必然的耦合关系。是不是太松散了
     *
     * @param imLogoutRsp
     */
    public void onRepLoginOut(IMLogin.IMLogoutRsp imLogoutRsp) {
        int code = imLogoutRsp.getResultCode();
        logger.i("login#send logout finish message");
    }

    /**
     * 重新请求登陆 IMReconnectManager
     * 1. 检测当前的状态
     * 2. 请求msg server的地址
     * 3. 建立链接
     * 4. 验证登陆信息
     *
     * @return
     */
    public void relogin() {
        login(userName,password);
//        if (!TextUtils.isEmpty(loginUserName) && !TextUtils.isEmpty(loginPwd)) {
//            logger.i("reconnect#login#relogin");
//            imSocketManager.reqMsgServerAddrs(return_server);
//        } else {
//            logger.i("reconnect#login#userName or loginPwd is null!!");
//            everLogined = false;
//            triggerEvent(LoginEvent.LOGIN_AUTH_FAILED);
//        }
    }

    // 自动登陆流程
    public void login(LoginSp.SpLoginIdentity identity){
        if (identity == null) {
            triggerEvent(LoginEvent.LOGIN_AUTH_FAILED);
            return;
        }
        String loginName = identity.getLoginName();
        String pwd = identity.getPwd();
        login(loginName,pwd);
//        loginUserName = identity.getLoginUserName();
//        loginPwd = identity.getPwd();
////        return_server = identity.getReturn_server();
//        identityChanged = false;
//
//        int mLoginId = identity.getLoginId();
//        // 初始化数据库，查询对应用户数据UserEntity
//        DBInterface.instance().initDbHelp(ctx, mLoginId);
//        UserEntity loginEntity = DBInterface.instance().getByLoginId(mLoginId);
//        do {
//            if (loginEntity == null) {
//                break;
//            }
//            loginInfo = loginEntity;
//            loginId = loginEntity.getPeerId();
//
//            // 这两个状态不要忘记掉?
//            isLocalLogin = true;
//            everLogined = true;
//
//            triggerEvent(LoginEvent.LOCAL_LOGIN_SUCCESS);
//        } while (false);
//        // 开始请求网络
//        imSocketManager.reqMsgServerAddrs(return_server);
    }

    private String return_server;
    public Handler handler=new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what){
                case 0:
                    JSONObject jsonObject = (JSONObject) msg.obj;
                    return_server = jsonObject.optString("return_server");
//                    JSONObject jsonObject1= null;
//                    try {
////                        jsonObject1 = new JSONObject(return_server);
//                    } catch (JSONException e) {
//                        e.printStackTrace();
//                    }
//                    priorIP = jsonObject1.optString("priorIP");
//                    internetPort = jsonObject1.optInt("port");
                    String return_message = jsonObject.optString("return_message");
                    Config.EndAliyun=return_message;
                    String password = jsonObject.optString("password");
//                    LoginSp.SpLoginIdentity identity = LoginSp.instance().getLoginIdentity();
//                    if (identity != null && !TextUtils.isEmpty(identity.getPwd())) {
//                        if (identity.getPwd().equals(password) && identity.getLoginName().equals(userName)) {
//                            login(identity);
//                            return;
//                        }
//                    }
                    //test end
                        loginUserName =return_message;

                    loginPwd =password;
                    identityChanged = true;
                        imSocketManager.reqMsgServerAddrs(return_server);
                    break;
            }
        }
    };
    public void login(final String userName, final String password) {

        this.userName=userName;
        this.password=password;
        try {
            String desPwd = EncryptTools.instance().toMD5(password);
            JSONObject object = new JSONObject();
            object.put("phone",userName);
            object.put("passwd",desPwd);
            object.put("server_type","test");
            final OkHttpClient client = new OkHttpClient();
            RequestBody body = new FormBody.Builder().add("arg", object.toString()).build();
            //保存账号密码的，请求token会用到
            Config.nameAndPaw=object.toString();
            final Request request = new Request.Builder()
                    .url(UrlConstant.LOIN)
                    .post(body)
                    .build();
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    triggerEvent(LoginEvent.LOGIN_INNER_FAILED);
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    try {
                        if(response.code()==200) {
                            JSONObject jsonObject = new JSONObject(response.body().string());
                            if(jsonObject.optInt("return_code")==0){
                                Message messages = handler.obtainMessage();
                                jsonObject.put("password",password);
                                messages.obj=jsonObject;
                                messages.what=0;
                                handler.sendMessage(messages);
                            }else {
                                triggerEvent(LoginEvent.LOGIN_AUTH_FAILED);
                            }
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });
        }
        catch (JSONException e) {
            e.printStackTrace();
        }

    }

    /**
     * 链接成功之后
     */
    public void reqLoginMsgServer() {
        logger.i("login#reqLoginMsgServer");
        triggerEvent(LoginEvent.LOGINING);
        /** 加密 */
      // String desPwd = new String(com.mogujie.tt.Security.getInstance().EncryptPass(loginPwd));
       String desPwd = EncryptTools.instance().toMD5(loginPwd);

        IMLogin.IMLoginReq imLoginReq = IMLogin.IMLoginReq.newBuilder()
                .setUserName(loginUserName)
                .setPassword(desPwd)
                .setOnlineStatus(IMBaseDefine.UserStatType.USER_STATUS_ONLINE)
                .setClientType(IMBaseDefine.ClientType.CLIENT_TYPE_ANDROID)
                .setClientVersion("1.0.0").build();

        int sid = IMBaseDefine.ServiceID.SID_LOGIN_VALUE;
        int cid = IMBaseDefine.LoginCmdID.CID_LOGIN_REQ_USERLOGIN_VALUE;
        imSocketManager.sendRequest(imLoginReq, sid, cid, new Packetlistener() {
            @Override
            public void onSuccess(Object response) {
                try {
                    IMLogin.IMLoginRes imLoginRes = IMLogin.IMLoginRes.parseFrom((CodedInputStream) response);
                    onRepMsgServerLogin(imLoginRes);
                } catch (IOException e) {
                    triggerEvent(LoginEvent.LOGIN_INNER_FAILED);
                    logger.e("login failed,cause by %s", e.getCause());
                }
            }

            @Override
            public void onFaild() {
                triggerEvent(LoginEvent.LOGIN_INNER_FAILED);
            }

            @Override
            public void onTimeout() {
                triggerEvent(LoginEvent.LOGIN_INNER_FAILED);
            }
        });
    }

    /**
     * 验证登陆信息结果
     *
     * @param loginRes
     */
    public void onRepMsgServerLogin(IMLogin.IMLoginRes loginRes) {
        logger.i("login#onRepMsgServerLogin");

        if (loginRes == null) {
            logger.e("login#decode LoginResponse failed");
            triggerEvent(LoginEvent.LOGIN_AUTH_FAILED);
            return;
        }

        IMBaseDefine.ResultType code = loginRes.getResultCode();
        switch (code) {
            case REFUSE_REASON_NONE: {
                IMBaseDefine.UserStatType userStatType = loginRes.getOnlineStatus();
                IMBaseDefine.UserInfo userInfo = loginRes.getUserInfo();
                loginId = userInfo.getUserId();
                loginInfo = ProtoBuf2JavaBean.getUserEntity(userInfo);
                logger.i("neil " + loginInfo.getAvatar());
                onLoginOk();
            }
            break;

            case REFUSE_REASON_DB_VALIDATE_FAILED: {
                logger.e("login#login msg server failed, result:%s", code);
                triggerEvent(LoginEvent.LOGIN_AUTH_FAILED);
            }
            break;

            default: {
                logger.e("login#login msg server inner failed, result:%s", code);
                triggerEvent(LoginEvent.LOGIN_INNER_FAILED);
            }
            break;
        }
    }

    public void onLoginOk() {
        logger.i("login#onLoginOk");
        everLogined = true;
        isKickout = false;

        // 判断登陆的类型
        if (isLocalLogin) {
            triggerEvent(LoginEvent.LOCAL_LOGIN_MSG_SERVICE);
        } else {
            isLocalLogin = true;
            triggerEvent(LoginEvent.LOGIN_OK);
        }

        // 发送token
//        reqDeviceToken();
        if (identityChanged) {
            LoginSp.instance().setLoginInfo(userName, loginPwd, loginId);
            identityChanged = false;
        }
    }


    private void reqDeviceToken() {
//        String token = PushManager.getInstance().getToken();
//        IMLogin.IMDeviceTokenReq req = IMLogin.IMDeviceTokenReq.newBuilder()
//                .setUserId(loginId)
//                .setClientType(IMBaseDefine.ClientType.CLIENT_TYPE_ANDROID)
//                .setDeviceToken(token)
//                .build();
//        int sid = IMBaseDefine.ServiceID.SID_LOGIN_VALUE;
//        int cid = IMBaseDefine.LoginCmdID.CID_LOGIN_REQ_DEVICETOKEN_VALUE;
//
//        imSocketManager.sendRequest(req,sid,cid,new Packetlistener() {
//            @Override
//            public void onSuccess(Object response) {
//                //?? nothing to do
////                try {
////                    IMLogin.IMDeviceTokenRsp rsp = IMLogin.IMDeviceTokenRsp.parseFrom((CodedInputStream) response);
////                    int userId = rsp.getUserId();
////                } catch (IOException e) {
////                    e.printStackTrace();
////                }
//            }
//
//            @Override
//            public void onFaild() {}
//
//            @Override
//            public void onTimeout() {}
//        });
    }


    public void onKickout(IMLogin.IMKickUser imKickUser) {
        logger.i("login#onKickout");
        int kickUserId = imKickUser.getUserId();
        IMBaseDefine.KickReasonType reason = imKickUser.getKickReason();
        isKickout = true;
        imSocketManager.onMsgServerDisconn();
    }


    // 收到PC端登陆的通知，另外登陆成功之后，如果PC端在线，也会立马收到该通知
    public void onLoginStatusNotify(IMBuddy.IMPCLoginStatusNotify statusNotify) {
        int userId = statusNotify.getUserId();
        // todo 由于交互不太友好 暂时先去掉
        if (true || userId != loginId) {
            logger.i("login#onLoginStatusNotify userId ≠ loginId");
            return;
        }

        if (isKickout) {
            logger.i("login#already isKickout");
            return;
        }

        switch (statusNotify.getLoginStat()) {
            case USER_STATUS_ONLINE: {
                isPcOnline = true;
                EventBus.getDefault().postSticky(LoginEvent.PC_ONLINE);
            }
            break;

            case USER_STATUS_OFFLINE: {
                isPcOnline = false;
                EventBus.getDefault().postSticky(LoginEvent.PC_OFFLINE);
            }
            break;
        }
    }

    // 踢出PC端登陆
    public void reqKickPCClient() {
        IMLogin.IMKickPCClientReq req = IMLogin.IMKickPCClientReq.newBuilder()
                .setUserId(loginId)
                .build();
        int sid = IMBaseDefine.ServiceID.SID_LOGIN_VALUE;
        int cid = IMBaseDefine.LoginCmdID.CID_LOGIN_REQ_KICKPCCLIENT_VALUE;
        imSocketManager.sendRequest(req, sid, cid, new Packetlistener() {
            @Override
            public void onSuccess(Object response) {
                triggerEvent(LoginEvent.KICK_PC_SUCCESS);
            }

            @Override
            public void onFaild() {
                triggerEvent(LoginEvent.KICK_PC_FAILED);
            }

            @Override
            public void onTimeout() {
                triggerEvent(LoginEvent.KICK_PC_FAILED);
            }
        });
    }

    /**
     * ------------------状态的 set  get------------------------------
     */
    public int getLoginId() {
        return loginId;
    }

    public void setLoginId(int loginId) {
        logger.i("login#setLoginId -> loginId:%d", loginId);
        this.loginId = loginId;

    }

    public boolean isEverLogined() {
        return everLogined;
    }

    public void setEverLogined(boolean everLogined) {
        this.everLogined = everLogined;
    }

    public UserEntity getLoginInfo() {
        return loginInfo;
    }

    public void setLoginInfo(UserEntity loginInfo) {
        this.loginInfo = loginInfo;
    }

    public LoginEvent getLoginStatus() {
        return loginStatus;
    }

    public boolean isKickout() {
        return isKickout;
    }

    public void setKickout(boolean isKickout) {
        this.isKickout = isKickout;
    }

    public boolean isPcOnline() {
        return isPcOnline;
    }

    public void setPcOnline(boolean isPcOnline) {
        this.isPcOnline = isPcOnline;
    }
}
