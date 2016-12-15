package com.tenth.space.imservice.manager;

import android.content.Intent;
import android.util.Log;
import android.widget.Switch;

import com.google.protobuf.ByteString;
import com.google.protobuf.CodedInputStream;
import com.tenth.space.DB.DBInterface;
import com.tenth.space.DB.entity.BlogEntity;
import com.tenth.space.DB.entity.CommentEntity;
import com.tenth.space.config.SysConstant;
import com.tenth.space.imservice.callback.Packetlistener;
import com.tenth.space.imservice.entity.BlogMessage;
import com.tenth.space.imservice.event.BlogInfoEvent;
import com.tenth.space.imservice.service.LoadImageService2;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.IMBlog;
import com.tenth.space.protobuf.helper.ProtoBuf2JavaBean;
import com.tenth.space.utils.LogUtils;
import com.tenth.space.utils.Logger;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;

import de.greenrobot.event.EventBus;

import static com.tenth.space.imservice.event.BlogInfoEvent.Event.ADD_COMMENT_OK;
import static com.tenth.space.imservice.event.BlogInfoEvent.Event.GET_COMMENT_LIST_OK;

/**
 * Created by wing on 2016/7/11.
 */
public class IMBlogManager extends IMManager {

    private Logger logger = Logger.getLogger(IMMessageManager.class);
    IMSocketManager imSocketManager = IMSocketManager.instance();
    private DBInterface dbInterface = DBInterface.instance();
    private final long TIMEOUT_MILLISECONDS = 6 * 1000;
    private final long IMAGE_TIMEOUT_MILLISECONDS = 4 * 60 * 1000;
    //private Map<Integer,BlogEntity> blogMap = new ConcurrentHashMap<>();
    private List<BlogEntity> temprecommendBlogList = new ArrayList<>();
    private List<BlogEntity> tempfridendBlogList = new ArrayList<>();
    private List<BlogEntity> tempfollowBlogList = new ArrayList<>();

    ArrayList<CommentEntity> commentEntities = new ArrayList<>();

    public ArrayList<CommentEntity> getCommentEntities() {
        return commentEntities;
    }

    public List<BlogEntity> getRecommendBlogList() {
        return temprecommendBlogList;
    }

    public List<BlogEntity> getFridendBlogList() {
        return tempfridendBlogList;
    }

    public List<BlogEntity> getFollowBlogList() {
        return tempfollowBlogList;
    }


    public IMBlogManager() {
        //因为是单例，所以不考虑反注册
        EventBus.getDefault().register(this);
    }

    @Override
    public void doOnStart() {
    }

    @Override
    public void reset() {
        //userDataReady = false;
        //userMap.clear();
    }

    // 单例
    private static IMBlogManager inst = new IMBlogManager();

    public static IMBlogManager instance() {
        return inst;
    }

    //启动app后获取博客列表（离线登录，在线登录）
    public void reqBlogList(IMBaseDefine.BlogType type,int pager) {
        int userId = IMLoginManager.instance().getLoginId();
        IMBlog.IMBlogGetListReq imGetBlogListReq = IMBlog.IMBlogGetListReq
                .newBuilder()
                .setBlogType(type)
                .setPageSize(8)
                .setPage(pager)
                .setUserId(userId)
                .setUpdateTime(0)
                .build();
        int sid = IMBaseDefine.ServiceID.SID_BLOG_VALUE;
        int cid = IMBaseDefine.BlogCmdID.CID_BLOG_GET_LIST_REQUEST_VALUE;
        imSocketManager.sendRequest(imGetBlogListReq, sid, cid);
    }

    public void onReqBlogList(IMBlog.IMBlogGetListRsp rsp) {

        temprecommendBlogList.clear();
        tempfridendBlogList.clear();
        tempfollowBlogList.clear();
        int userId = rsp.getUserId();
        List<IMBaseDefine.BlogInfo> blogInfos = rsp.getBlogListList();
//        if (blogInfos.size() <= 0) {
//            return;
//        }
        //分类解析，并加入对应列表

        for (IMBaseDefine.BlogInfo info : blogInfos) {
            BlogEntity blogEntity = null;
           // IMBaseDefine.BlogType blogType = info.getBlogType();
            IMBaseDefine.BlogType blogType = rsp.getBlogType();
            switch (blogType) {
                case BLOG_TYPE_RCOMMEND:
                    blogEntity = ProtoBuf2JavaBean.getBlogEntity(info);
                    temprecommendBlogList.add(blogEntity);//此处做判断，过滤自己的好友信息，才能添加到集合中
                    break;

                case BLOG_TYPE_FRIEND:
                    blogEntity = ProtoBuf2JavaBean.getBlogEntity(info);
                    tempfridendBlogList.add(blogEntity);
                    break;

                case BLOG_TYPE_FOLLOWUSER:
                    blogEntity = ProtoBuf2JavaBean.getBlogEntity(info);
                    tempfollowBlogList.add(blogEntity);
                    break;

                default:
                    break;
            }
        }

//        更新数据库
        LogUtils.d("程序位置-IMBlogManager---------插入数据库（已获取博客列表）");
        if (temprecommendBlogList.size()>0){
            dbInterface.batchInsertOrUpdateBlog(temprecommendBlogList);
        }
        if (tempfridendBlogList.size()>0){
            dbInterface.batchInsertOrUpdateBlog(tempfridendBlogList);
        }
        if (tempfollowBlogList.size()>0){
            dbInterface.batchInsertOrUpdateBlog(tempfollowBlogList);
        }

//用回调
        Log.i("GTAG","发送");
        LogUtils.d("程序位置-IMBlogManager---------GET_BLOG_OK（已获取博客列表）事件分发");
        switch (rsp.getBlogType()){
            case BLOG_TYPE_RCOMMEND:
                EventBus.getDefault().post(new BlogInfoEvent(BlogInfoEvent.Event.GET_BLOG_OK,-1));
                break;
            case BLOG_TYPE_FRIEND:
                EventBus.getDefault().post(new BlogInfoEvent(BlogInfoEvent.Event.GET_BLOG_OK,-2));
                break;
            case BLOG_TYPE_FOLLOWUSER:
                EventBus.getDefault().post(new BlogInfoEvent(BlogInfoEvent.Event.GET_BLOG_OK,-3));
                break;
        }

       // EventBus.getDefault().postSticky(new BlogInfoEvent(BlogInfoEvent.Event.GET_BLOG_OK));

    }

    public void sendBlog(final String blogContent, final BlogMessage blogMessage) {
        final long userId = IMLoginManager.instance().getLoginId();
        byte[] sendContent = null;
        try {
//            LogUtils.d("发表的博客，加密前：" + blogContent);
//            String content = new String(com.mogujie.tt.Security.getInstance().EncryptMsg(blogContent));
            String content = blogContent;
//            LogUtils.d("发表的博客，加密后：" + content);

            sendContent = content.getBytes("utf-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        IMBlog.IMBlogSend msgData = IMBlog.IMBlogSend
                .newBuilder()
                .setUserId((int) userId)
                .setBlogData(ByteString.copyFrom(sendContent))  // 这个点要特别注意 todo ByteString.copyFrom
                .build();
        int sid = IMBaseDefine.ServiceID.SID_MSG_VALUE;
        int cid = IMBaseDefine.BlogCmdID.CID_BLOG_SEND_VALUE;

        LogUtils.d("IMBlogManager------sendRequest 上传到IM服务器开始执行");
        //final BlogEntity messageEntity  = msgEntity;
        imSocketManager.sendRequest(msgData, sid, cid, new Packetlistener(IMAGE_TIMEOUT_MILLISECONDS) {
            @Override
            public void onSuccess(Object response) {
                try {
                    IMBlog.IMBlogSendAck blogSendAck = IMBlog.IMBlogSendAck.parseFrom((CodedInputStream) response);
                    logger.i("blog#onAckSendedMsg");
                    if (blogSendAck.getUserId() <= 0) {
                        throw new RuntimeException("Msg ack error,cause by msgId <=0");
                    }

                    //messageEntity.setStatus(MessageConstant.MSG_SUCCESS);
                    //messageEntity.setMsgId(imMsgDataAck.getMsgId());
                    /**主键ID已经存在，直接替换*/
                    //dbInterface.insertOrUpdateMessage(messageEntity);
                    /**更新sessionEntity lastMsgId问题*/

                    //通知AddBlogActivity
                    EventBus.getDefault().postSticky(new BlogInfoEvent(BlogInfoEvent.Event.ACK_SEND_BLOG_OK));
                    LogUtils.d("IMBlogManager------sendRequest:onSuccess:上传到IM服务器完成" +
                            "（BlogId=" + blogSendAck.getBlogId() + ", UserId=" + blogSendAck.getUserId() + "）");

                    //通知InternalFragment刷新发现页的列表
                    blogMessage.setLikeCnt(0);
                    blogMessage.setCommentCnt(0);
                    blogMessage.setCreated(System.currentTimeMillis());//发表时间用
                    blogMessage.setAvatarUrl(IMLoginManager.instance().getLoginInfo().getAvatar());//头像用
                    blogMessage.setWriterUserId(userId);//关注,跳转详情页 需要使用
                    blogMessage.setBlogId(blogSendAck.getBlogId());
                    String mainName = IMLoginManager.instance().getLoginInfo().getMainName();
                    blogMessage.setNickName(mainName);
                    EventBus.getDefault().postSticky(new BlogInfoEvent(BlogInfoEvent.Event.ADD_BLOG_UPDATE_OK, blogMessage));
//                    reqBlogList();

                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFaild() {
                //messageEntity.setStatus(MessageConstant.MSG_FAILURE);
                //dbInterface.insertOrUpdateMessage(messageEntity);

                //通知AddBlogActivity发送失败，提示失败
                EventBus.getDefault().postSticky(new BlogInfoEvent(BlogInfoEvent.Event.ACK_SEND_BLOG_FAILURE));
            }

            @Override
            public void onTimeout() {
                //messageEntity.setStatus(MessageConstant.MSG_FAILURE);
                //dbInterface.insertOrUpdateMessage(messageEntity);

                //通知AddBlogActivity发送失败，提示网络问题
                EventBus.getDefault().postSticky(new BlogInfoEvent(BlogInfoEvent.Event.ACK_SEND_BLOG_TIME_OUT));
            }
        });
    }

    public void reqAddComment(final int blogId, final String data) {
        ByteString bytes = null;
        try {
            bytes = ByteString.copyFrom(data.getBytes("utf-8"));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        if (bytes == null) {
            LogUtils.d("发送博客解码异常，reqAddComment----data.getBytes(\"utf-8\")");
            return;
        }
//        message IMBlogAddCommentReq{
//            //cmd id:		0x0A05
//            required uint32 user_id = 1;
//            required uint32 blog_id = 2;
//            required bytes blog_data = 3;
//            optional bytes attach_data = 20;
//        }
        int userId = IMLoginManager.instance().getLoginId();
        final String mainName = IMLoginManager.instance().getLoginInfo().getMainName();
        final String avatar = IMLoginManager.instance().getLoginInfo().getAvatar();
        IMBlog.IMBlogAddCommentReq addCommentReq = IMBlog.IMBlogAddCommentReq
                .newBuilder()
                .setUserId(userId)
                .setBlogId(blogId)
                .setBlogData(bytes)
                .build();
        int sid = IMBaseDefine.ServiceID.SID_BLOG_VALUE;
        int cid = IMBaseDefine.BlogCmdID.CID_BLOG_ADD_COMMENT_REQUEST_VALUE;
        imSocketManager.sendRequest(addCommentReq, sid, cid, new Packetlistener() {
            @Override
            public void onSuccess(Object response) {
                try {
                    IMBlog.IMBlogAddCommentRsp addCommentRsp = IMBlog.IMBlogAddCommentRsp.parseFrom((CodedInputStream) response);
                    int resultCode = addCommentRsp.getResultCode();
                    if (resultCode == 0) {
                        CommentEntity commentEntity = new CommentEntity();
                        commentEntity.setMsgData(data);
                        commentEntity.setNickName(mainName);
                        commentEntity.setAvatarUrl(avatar);

                        BlogInfoEvent blogInfoEvent = new BlogInfoEvent(ADD_COMMENT_OK);
                        blogInfoEvent.setCommentEntity(commentEntity);
                        EventBus.getDefault().postSticky(blogInfoEvent);
                        LogUtils.d("添加评论成功回调:resultCode:" + resultCode);
                    }

                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFaild() {

            }

            @Override
            public void onTimeout() {

            }
        });
        LogUtils.d("IMBlogManager-----reqAddComment(发送评论执行)");
    }

    public void reqCommentList(int blogId) {
        int userId = IMLoginManager.instance().getLoginId();
        IMBlog.IMBlogGetCommentReq getCommentReq = IMBlog.IMBlogGetCommentReq
                .newBuilder()
                .setUserId(userId)
                .setBlogId(blogId)
                .setUpdateTime(0)
                .build();
        int sid = IMBaseDefine.ServiceID.SID_BLOG_VALUE;
        int cid = IMBaseDefine.BlogCmdID.CID_BLOG_GET_COMMENT_REQUEST_VALUE;
        imSocketManager.sendRequest(getCommentReq, sid, cid);
        LogUtils.d("IMBlogManager-----reqCommentList(请求评论列表)");
    }
/*
评论处有修改2016.12.1xubo********************************************************************************************************************
 */
    public void onRspGetComment(IMBlog.IMBlogGetCommentRsp rsp) {
        commentEntities.clear();

        int userId = rsp.getUserId();
        List<IMBaseDefine.BlogInfo> commentList = rsp.getCommentListList();
        LogUtils.d("获取评论列表返回：msgInfoList:size=" + commentList.size());
        if (commentList.size() <= 0) {
            logger.i("onRspGetComment# have no msgList");
            EventBus.getDefault().postSticky(new BlogInfoEvent(GET_COMMENT_LIST_OK));
            return;
        }
        /**
         * comment数据类型：
         * blogId_
         * msgList_
         *      createTime_
         *      fromSessionId_
         *      msgData_
         *      msgId
         *      msgType_(MSG_TYPE_COMMENT)
         * updateTime_
         * userId
         */

        //解析，并加入列表
        for (IMBaseDefine.BlogInfo info : commentList) {
           // IMBaseDefine.BlogType blogType = info.getBlogType();
            CommentEntity commentEntity = ProtoBuf2JavaBean.getCommentEntity(info);
            commentEntities.add(commentEntity);
        }
//
//        //更新数据库
////        LogUtils.d("程序位置-IMBlogManager---------dbInterface.batchInsertOrUpdateBlog(blogList)");
////        dbInterface.batchInsertOrUpdateBlog(blogList);
//
        LogUtils.d("程序位置-IMBlogManager---------GET_COMMENT_LIST_OK事件分发");
        EventBus.getDefault().postSticky(new BlogInfoEvent(GET_COMMENT_LIST_OK));
    }

    public void onEvent(BlogInfoEvent event) {
        BlogInfoEvent.Event type = event.getEvent();
        switch (type) {
            case IMAGE_UPLOAD_FAILD:
                /*logger.i("pic#onUploadImageFaild");
                ImageMessage imageMessage = (ImageMessage)event.getMessageEntity();
                imageMessage.setLoadStatus(MessageConstant.IMAGE_LOADED_FAILURE);
                imageMessage.setStatus(MessageConstant.MSG_FAILURE);
                dbInterface.insertOrUpdateMessage(imageMessage);*/

                /**通知Activity层 失败*/
                /*event.setEvent(MessageEvent.Event.HANDLER_IMAGE_UPLOAD_FAILD);
                event.setMessageEntity(imageMessage);
                triggerEvent(event);*/
                break;

            case IMAGE_UPLOAD_SUCCESS:
                onImageUploadSuccess(event);
//                EventBus.getDefault().unregister(this);
                break;
        }
    }

    public void sendBlogCmd(BlogMessage blog) {
        logger.i("chat#text#textMessage");

        if (blog.getPathList().size() != 0) {//上传图片到阿里服务器(有图的情况)

            //DBInterface.instance().batchInsertOrUpdateBlog(blogList);

            Intent inent = new Intent(ctx, LoadImageService2.class);
            inent.putExtra(SysConstant.UPLOAD_IMAGE_INTENT_PARAMS, blog);
            ctx.startService(inent);
        } else {//上传内容到本地服务器(无图的情况)
            LogUtils.d("发表朋友圈信息，上传到本地服务器数据库:" + blog.getBlogContent());
            sendBlog(blog.getBlogContent(), blog);
        }
    }

    private void onImageUploadSuccess(BlogInfoEvent blogInfoEvent) {
        BlogMessage blogMessage = (BlogMessage) blogInfoEvent.getBlogMessage();

        List<String> urlList = blogMessage.getUrlList();
        for (int i = 0; i < urlList.size(); i++) {
            try {
                //解码url http:\/\/maomaojiang.oss-cn-shenzhen.aliyuncs.com\/IM\/2016\/10\/1477887043564.png
                // => http://maomaojiang.oss-cn-shenzhen.aliyuncs.com/IM/2016/10/1477887043564.png
                urlList.set(i, URLDecoder.decode(urlList.get(i), "utf-8"));
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }
//        for (String url : blogMessage.getUrlList()) {
//            String realImageURL = "";
//            try {
//                realImageURL = URLDecoder.decode(url, "utf-8");
//                LogUtils.d("URLDecoder:" + realImageURL);
//                logger.i("pic#realImageUrl:%s", realImageURL);
//            } catch (UnsupportedEncodingException e) {
//                logger.e(e.toString());
//            }

        //存本地sqlite
            /*imageMessage.setUrl(realImageURL);
            imageMessage.setStatus(MessageConstant.MSG_SUCCESS);
            imageMessage.setLoadStatus(MessageConstant.IMAGE_LOADED_SUCCESS);
            dbInterface.insertOrUpdateMessage(imageMessage);*/
//    }

//        /**通知Activity层 成功 ， 事件通知*/

        //照片上传成功的事件变更
        blogInfoEvent.setEvent(BlogInfoEvent.Event.HANDLER_IMAGE_UPLOAD_SUCCESS);
        //imageEvent.setMessageEntity(imageMessage);

        //这个触发，告诉AddBlogActivity图片已经上传完了(无实际意义的任何操作)
        EventBus.getDefault().postSticky(blogInfoEvent);

        //不加这个IMAGE_MSG_START,用json来做
        /*imageMessage.setContent(MessageConstant.IMAGE_MSG_START
                + realImageURL + MessageConstant.IMAGE_MSG_END);*/

        //上传内容到本地服务器(有图的情况)
        LogUtils.d("发表朋友圈信息，上传到本地服务器数据库:" + blogMessage.getBlogContent());
        sendBlog(blogMessage.getBlogContent(), blogMessage);
    }

    /*public void sendVoice(AudioMessage audioMessage) {
        logger.i("chat#audio#sendVoice");
        audioMessage.setStatus(MessageConstant.MSG_SENDING);
        long pkId =  DBInterface.instance().insertOrUpdateMessage(audioMessage);
        sessionManager.updateSession(audioMessage);
        sendMessage(audioMessage);
    }*/


    /*public void sendSingleImage(ImageMessage msg){
        logger.i("ImMessageManager#sendImage ");
        ArrayList<ImageMessage> msgList = new ArrayList<>();
        msgList.add(msg);
        sendImages(msgList);
    }*/

//    public void sendImages(BlogMessage blog) {
//        logger.i("blog#sendImages");
//
//        //DBInterface.instance().batchInsertOrUpdateBlog(blogList);
//
//        Intent inent = new Intent(ctx, LoadImageService2.class);
//        inent.putExtra(SysConstant.UPLOAD_IMAGE_INTENT_PARAMS, blog);
//        ctx.startService(inent);
//
//    }
}