package com.tenth.space.imservice.entity;

import android.text.TextUtils;

import com.tenth.space.DB.entity.BlogEntity;
import com.tenth.space.DB.entity.CommentEntity;
import com.tenth.space.DB.entity.MessageEntity;
import com.tenth.space.aliyun.Config;
import com.tenth.space.config.DBConstant;
import com.tenth.space.config.MessageConstant;
import com.tenth.space.protobuf.IMBaseDefine;
import com.tenth.space.protobuf.helper.ProtoBuf2JavaBean;
import com.tenth.space.utils.Logger;
import com.tenth.space.utils.pinyin.AESUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * @author : yingmu on 15-1-6.
 * @email : yingmu@mogujie.com.
 *
 * historical reasons,没有充分利用msgType字段
 * 多端的富文本的考虑
 */
public class MsgAnalyzeEngine {
    private static Logger logger = Logger.getLogger(MsgAnalyzeEngine.class);

    public static String analyzeMessageDisplay(String content) {
        String finalRes = content;
        String originContent = content;
        while (!originContent.isEmpty()) {
            int nStart = originContent.indexOf(MessageConstant.IMAGE_MSG_START);
            if (nStart < 0) {// 没有头
                break;
            } else {
                String subContentString = originContent.substring(nStart);
                int nEnd = subContentString.indexOf(MessageConstant.IMAGE_MSG_END);
                if (nEnd < 0) {// 没有尾
                    String strSplitString = originContent;
                    break;
                } else {// 匹配到
                    String pre = originContent.substring(0, nStart);

                    originContent = subContentString.substring(nEnd
                            + MessageConstant.IMAGE_MSG_END.length());

                    if (!TextUtils.isEmpty(pre) || !TextUtils.isEmpty(originContent)) {
                        finalRes = DBConstant.DISPLAY_FOR_MIX;
                    } else {
                        finalRes = DBConstant.DISPLAY_FOR_IMAGE;
                    }
                }
            }
        }
        return finalRes;
    }


    // 抽离放在同一的地方
    public static MessageEntity analyzeMessage(IMBaseDefine.MsgInfo msgInfo) {
        MessageEntity messageEntity = new MessageEntity();

        messageEntity.setCreated(msgInfo.getCreateTime());
        messageEntity.setUpdated(msgInfo.getCreateTime());
        messageEntity.setFromId(msgInfo.getFromSessionId());
        messageEntity.setMsgId(msgInfo.getMsgId());
        messageEntity.setMsgType(ProtoBuf2JavaBean.getJavaMsgType(msgInfo.getMsgType()));
        messageEntity.setStatus(MessageConstant.MSG_SUCCESS);
        messageEntity.setContent(msgInfo.getMsgData().toStringUtf8());
        /**
         * 解密文本信息
         */
        // String desMessage = new String(com.mogujie.tt.Security.getInstance().DecryptMsg(msgInfo.getMsgData().toStringUtf8()));
       String desMessage = AESUtils.decrypt(msgInfo.getMsgData().toStringUtf8(), Config.getKA());
        messageEntity.setContent(desMessage);
        // 文本信息不为空
        if (!TextUtils.isEmpty(desMessage)) {
            List<MessageEntity> msgList = textDecode(messageEntity);
            if (msgList.size() > 1) {
                // 混合消息
                MixMessage mixMessage = new MixMessage(msgList);
                return mixMessage;
            } else if (msgList.size() == 0) {
                // 可能解析失败 默认返回文本消息
                return TextMessage.parseFromNet(messageEntity);
            } else {
                //简单消息，返回第一个
                return msgList.get(0);
            }
        }
        else {
            // 如果为空
            return TextMessage.parseFromNet(messageEntity);
        }
    }

    public static CommentEntity analyzeComment(IMBaseDefine.BlogInfo blogInfo) {
        CommentEntity commentEntity = new CommentEntity();
        commentEntity.setCreated(blogInfo.getCreateTime());
        commentEntity.setUpdated(blogInfo.getCreateTime());

        /**
         * 解密文本信息
         */
//        String desMessage = new String(com.mogujie.tt.Security.getInstance().DecryptMsg(msgInfo.getMsgData().toStringUtf8()));
        int msgId = blogInfo.getBlogId();
        int createTime = blogInfo.getCreateTime();
        int writerUserId = blogInfo.getWriterUserId();
        String avatarUrl = blogInfo.getAvatarUrl();
        String nickName = blogInfo.getNickName();
        String msgData = blogInfo.getBlogData().toStringUtf8();

        commentEntity.setAvatarUrl(avatarUrl);
        commentEntity.setNickName(nickName);
        commentEntity.setCommentId(msgId);
        commentEntity.setMsgData(msgData);
        commentEntity.setCreated(createTime);
        commentEntity.setWriter_user_id(writerUserId);

        return commentEntity;
    }

    public static BlogEntity analyzeBlog(IMBaseDefine.BlogInfo blogInfo) {
        BlogEntity blogEntity = new BlogEntity();

        blogEntity.setCreated(blogInfo.getCreateTime());
        blogEntity.setUpdated(blogInfo.getCreateTime());

        /**
         * 解密文本信息
         */
//        String desMessage = new String(com.mogujie.tt.Security.getInstance().DecryptMsg(msgInfo.getMsgData().toStringUtf8()));
        String avatarUrl = blogInfo.getAvatarUrlBytes().toStringUtf8();
        String nickName = blogInfo.getNickNameBytes().toStringUtf8();
        int blogId = blogInfo.getBlogId();
        int commentCnt = blogInfo.getCommentCnt();
        int likeCnt = blogInfo.getLikeCnt();
        long writerUserId = blogInfo.getWriterUserId();

        blogEntity.setAvatarUrl(avatarUrl);
        blogEntity.setNickName(nickName);
        blogEntity.setBlogId(blogId);
        blogEntity.setCommentCnt(commentCnt);
        blogEntity.setLikeCnt(likeCnt);
        blogEntity.setWriterUserId(writerUserId);

//        LogUtils.d("MsgAnalyzeEngine------analyzeBlog解密前：" + msgInfo.getMsgData().toStringUtf8());
//        LogUtils.d("MsgAnalyzeEngine------analyzeBlog解密后：" + desMessage);

        String desMessage = blogInfo.getBlogData().toStringUtf8();
        try {
//            logger.e(desMessage);
            JSONObject obj = new JSONObject(desMessage);

            //存储BlogText
            String blogText = obj.getString("BlogText");
            if (blogText != null) {
                blogEntity.setBlogText(blogText);
//                LogUtils.d("MsgAnalyzeEngine----------BlogText-----------:" + blogText);
            }
            //存储BlogImages
            JSONArray images = obj.getJSONArray("BlogImages");
            if (images != null) {
//                LogUtils.d("MsgAnalyzeEngine----------BlogImages-----------:" + images.toString());
                blogEntity.setBlogImages(images.toString());
            }
        } catch (JSONException e1) {
            e1.printStackTrace();
        }

            /*if (obj.getString("blogaudio") != null) {
                blogEntity.setBlogAudio(obj.getString("blogaudio"));
            }*/

        // 文本信息不为空
        /*if(!TextUtils.isEmpty(desMessage)){
            List<MessageEntity> msgList =  textDecode(messageEntity);
            if(msgList.size()>1){
                // 混合消息
                MixMessage mixMessage = new MixMessage(msgList);
                return mixMessage;
            }else if(msgList.size() == 0){
                // 可能解析失败 默认返回文本消息
                return TextMessage.parseFromNet(messageEntity);
            }else{
                //简单消息，返回第一个
                return msgList.get(0);
            }
        }else{
            // 如果为空
            return TextMessage.parseFromNet(messageEntity);
        }*/

        return blogEntity;
    }


    /**
     * todo 优化字符串分析
     *
     * @param msg
     *
     * @return
     */
    private static List<MessageEntity> textDecode(MessageEntity msg) {
        List<MessageEntity> msgList = new ArrayList<>();

        String originContent = msg.getContent();
        while (!TextUtils.isEmpty(originContent)) {
            int nStart = originContent.indexOf(MessageConstant.IMAGE_MSG_START);
            if (nStart < 0) {// 没有头
                String strSplitString = originContent;

                MessageEntity entity = addMessage(msg, strSplitString);
                if (entity != null) {
                    msgList.add(entity);
                }

                originContent = "";
            } else {
                String subContentString = originContent.substring(nStart);
                int nEnd = subContentString.indexOf(MessageConstant.IMAGE_MSG_END);
                if (nEnd < 0) {// 没有尾
                    String strSplitString = originContent;


                    MessageEntity entity = addMessage(msg, strSplitString);
                    if (entity != null) {
                        msgList.add(entity);
                    }

                    originContent = "";
                } else {// 匹配到
                    String pre = originContent.substring(0, nStart);
                    MessageEntity entity1 = addMessage(msg, pre);
                    if (entity1 != null) {
                        msgList.add(entity1);
                    }

                    String matchString = subContentString.substring(0, nEnd
                            + MessageConstant.IMAGE_MSG_END.length());

                    MessageEntity entity2 = addMessage(msg, matchString);
                    if (entity2 != null) {
                        msgList.add(entity2);
                    }

                    originContent = subContentString.substring(nEnd
                            + MessageConstant.IMAGE_MSG_END.length());
                }
            }
        }

        return msgList;
    }


    public static MessageEntity addMessage(MessageEntity msg, String strContent) {
        if (TextUtils.isEmpty(strContent.trim())) {
            return null;
        }
        msg.setContent(strContent);

        if (strContent.startsWith(MessageConstant.IMAGE_MSG_START)
                && strContent.endsWith(MessageConstant.IMAGE_MSG_END)) {
            try {
                ImageMessage imageMessage = ImageMessage.parseFromNet(msg);
                return imageMessage;
            } catch (JSONException e) {
                // e.printStackTrace();
                return null;
            }
        } else {
            return TextMessage.parseFromNet(msg);
        }
    }
}
