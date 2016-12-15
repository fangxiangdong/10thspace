package com.tenth;

import de.greenrobot.daogenerator.DaoGenerator;
import de.greenrobot.daogenerator.Entity;
import de.greenrobot.daogenerator.Index;
import de.greenrobot.daogenerator.Property;
import de.greenrobot.daogenerator.Schema;

/**
 * @author : yingmu on 14-12-31.
 * @email : yingmu@mogujie.com.
 *
 * 其中UserEntity、 GroupEntity 继承PeerEntity
 * 由于 UserEntity、 GroupEntity是自动生成，PeerEntity会有重复字段，所以每次生成之后要处理下成员变量。
 * PeerEntity成员变量名与子类统一。
 *
 * 【备注】session表中的create与update字段没有特别的区分，主要是之前服务端的习惯。。。
 */
public class GreenDaoGenerator {
    private static String entityPath = "com.tenth.space.entity";

    public static void main(String[] args) throws Exception {
        int dbVersion = 12;
        Schema schema = new Schema(dbVersion, "com.tenth.space.DB.dao");

        schema.enableKeepSectionsByDefault();
        addDepartment(schema);
        addUserInfo(schema);
        addGroupInfo(schema);
        addMessage(schema);
        addSessionInfo(schema);
        addBlogInfo(schema);
        addCommentInfo(schema);
        addRequestFriendUser(schema);
        // todo 绝对路径,根据自己的路径设定，例子如下
//        String path = "C:\\workSpace\\studio\\IM\\im_1\\app\\src\\main\\java";
        String path = "D:\\im\\dao";
        new DaoGenerator().generateAll(schema, path);
    }

    private static void addDepartment(Schema schema) {
        Entity department = schema.addEntity("DepartmentEntity");
        department.setTableName("Department");
        department.setClassNameDao("DepartmentDao");
        department.setJavaPackage(entityPath);

        department.addIdProperty().autoincrement();
        department.addIntProperty("departId").unique().notNull().index();
        department.addStringProperty("departName").unique().notNull().index();
        department.addIntProperty("priority").notNull();
        department.addIntProperty("status").notNull();

        department.addIntProperty("created").notNull();
        department.addIntProperty("updated").notNull();

        department.setHasKeepSections(true);
    }
    private static  void addRequestFriendUser(Schema schema){
        Entity requesterInfo = schema.addEntity("RequesterEntity");
        requesterInfo.setTableName("RequesterInfo");
        requesterInfo.setClassNameDao("RequesterDao");
        requesterInfo.setJavaPackage(entityPath);

        requesterInfo.addIdProperty().autoincrement();
        requesterInfo.addStringProperty("avatar_url");
        requesterInfo.addLongProperty("created");
        requesterInfo.addBooleanProperty("isRead");
        requesterInfo.addStringProperty("nick_name").notNull();
        requesterInfo.addIntProperty("fromUserId").notNull().index().unique();
        requesterInfo.addStringProperty("addition_msg");
        requesterInfo.addIntProperty("agree_states").notNull();
        requesterInfo.setHasKeepSections(true);
    }
    private static void addUserInfo(Schema schema) {
        Entity userInfo = schema.addEntity("UserEntity");
        userInfo.setTableName("UserInfo");
        userInfo.setClassNameDao("UserDao");
        userInfo.setJavaPackage(entityPath);
        userInfo.addStringProperty("relation");
        userInfo.addIdProperty().autoincrement();
        userInfo.addIntProperty("peerId").unique().notNull().index();
        userInfo.addIntProperty("gender").notNull();
        userInfo.addStringProperty("mainName").notNull();
        // 这个可以自动生成pinyin
        userInfo.addStringProperty("pinyinName").notNull();
        userInfo.addStringProperty("realName").notNull();
        userInfo.addStringProperty("avatar").notNull();
        userInfo.addStringProperty("phone").notNull();
        userInfo.addStringProperty("email").notNull();
        userInfo.addIntProperty("departmentId").notNull();

        userInfo.addIntProperty("status").notNull();
        userInfo.addIntProperty("created").notNull();
        userInfo.addIntProperty("updated").notNull();
        userInfo.addIntProperty("fansCnt").notNull();

        userInfo.setHasKeepSections(true);

        //todo 索引还没有设定
        // 一对一 addToOne 的使用
        // 支持protobuf
        // schema.addProtobufEntity();
    }

    private static void addCommentInfo(Schema schema) {
        Entity commentInfo = schema.addEntity("CommentEntity");
        commentInfo.setTableName("CommentInfo");
        commentInfo.setClassNameDao("CommentDao");
        commentInfo.setJavaPackage(entityPath);

        /**
         * comment数据类型：(这里需要的一条评论的信息，即msgList_中的一行的数据)
         * blogId_
         * msgList_
         *      msgId(commentId)
         *      fromSessionId_
         *      msgData_
         *      msgType_(MSG_TYPE_COMMENT)
         *
         *      createTime_(和其他的不对应)
         *      缺少：
         *          用户信息
         *              头像，昵称
         *          created
         *          updated(应该不需要)
         * updateTime_
         * userId
         */
        commentInfo.addIdProperty().autoincrement();
        commentInfo.addIntProperty("commentId").unique().notNull().index();
        commentInfo.addIntProperty("fromSessionId").notNull();
        commentInfo.addStringProperty("msgData").notNull();
        commentInfo.addStringProperty("msgType").notNull();
        commentInfo.addStringProperty("avatarUrl");
        commentInfo.addStringProperty("nickName");
        commentInfo.addLongProperty("writer_user_id");

        commentInfo.addIntProperty("created").notNull();
        commentInfo.addIntProperty("updated").notNull();

        commentInfo.setHasKeepSections(true);
    }

    private static void addGroupInfo(Schema schema) {
        Entity groupInfo = schema.addEntity("GroupEntity");
        groupInfo.setTableName("GroupInfo");
        groupInfo.setClassNameDao("GroupDao");
        groupInfo.setJavaPackage(entityPath);

        groupInfo.addIdProperty().autoincrement();
        groupInfo.addIntProperty("peerId").unique().notNull();
        groupInfo.addIntProperty("groupType").notNull();
        groupInfo.addStringProperty("mainName").notNull();
        groupInfo.addStringProperty("avatar").notNull();
        groupInfo.addIntProperty("creatorId").notNull();
        groupInfo.addIntProperty("userCnt").notNull();

        groupInfo.addStringProperty("userList").notNull();
        groupInfo.addIntProperty("version").notNull();
        groupInfo.addIntProperty("status").notNull();
        groupInfo.addIntProperty("created").notNull();
        groupInfo.addIntProperty("updated").notNull();

        groupInfo.setHasKeepSections(true);
    }

    private static void addMessage(Schema schema) {
        Entity message = schema.addEntity("MessageEntity");
        message.setTableName("Message");
        message.setClassNameDao("MessageDao");
        message.setJavaPackage(entityPath);

        message.implementsSerializable();
        message.addIdProperty().autoincrement();
        Property msgProId = message.addIntProperty("msgId").notNull().getProperty();
        message.addIntProperty("fromId").notNull();
        message.addIntProperty("toId").notNull();
        // 是不是需要添加一个sessionkey标示一下，登陆的用户在前面
        Property sessionPro = message.addStringProperty("sessionKey").notNull().getProperty();
        message.addStringProperty("content").notNull();
        message.addIntProperty("msgType").notNull();
        message.addIntProperty("displayType").notNull();

        message.addIntProperty("status").notNull().index();
        message.addIntProperty("created").notNull().index();
        message.addIntProperty("updated").notNull();

        Index index = new Index();
        index.addProperty(msgProId);
        index.addProperty(sessionPro);
        index.makeUnique();
        message.addIndex(index);

        message.setHasKeepSections(true);
    }

    private static void addSessionInfo(Schema schema) {
        Entity sessionInfo = schema.addEntity("SessionEntity");
        sessionInfo.setTableName("Session");
        sessionInfo.setClassNameDao("SessionDao");
        sessionInfo.setJavaPackage(entityPath);

        //point to userId/groupId need sessionType 区分
        sessionInfo.addIdProperty().autoincrement();
        sessionInfo.addStringProperty("sessionKey").unique().notNull(); //.unique()
        sessionInfo.addIntProperty("peerId").notNull();
        sessionInfo.addIntProperty("peerType").notNull();

        sessionInfo.addIntProperty("latestMsgType").notNull();
        sessionInfo.addIntProperty("latestMsgId").notNull();
        sessionInfo.addStringProperty("latestMsgData").notNull();

        sessionInfo.addIntProperty("talkId").notNull();
        sessionInfo.addIntProperty("created").notNull();
        sessionInfo.addIntProperty("updated").notNull();

        sessionInfo.setHasKeepSections(true);
    }

    private static void addBlogInfo(Schema schema) {
//        String avatarUrl = blogInfo.getAvatarUrlBytes().toStringUtf8();
//        String nickName = blogInfo.getNickNameBytes().toStringUtf8();
//        int commentCnt = blogInfo.getCommentCnt();
//        int likeCnt = blogInfo.getLikeCnt();
//        int writerUserId = blogInfo.getWriterUserId();
        Entity blogInfo = schema.addEntity("BlogEntity");
        blogInfo.setTableName("Blog");
        blogInfo.setClassNameDao("BlogDao");
        blogInfo.setJavaPackage(entityPath);

        blogInfo.addIdProperty().autoincrement();
        blogInfo.addIntProperty("blogId").unique().notNull().index();
        blogInfo.addStringProperty("blogText");
        blogInfo.addStringProperty("blogAudio");
        blogInfo.addStringProperty("blogImages");
        blogInfo.addStringProperty("avatarUrl");
        blogInfo.addStringProperty("nickName");
        blogInfo.addIntProperty("commentCnt");
        blogInfo.addIntProperty("likeCnt");
        blogInfo.addLongProperty("writerUserId");


        blogInfo.addIntProperty("created").notNull();
        blogInfo.addIntProperty("updated").notNull();

        blogInfo.setHasKeepSections(true);
    }
}
