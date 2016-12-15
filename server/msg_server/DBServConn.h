/*
 * DBServConn.h
 *
 *  Created on: 2013-7-8
 *      Author: ziteng@mogujie.com
 */

#ifndef DBSERVCONN_H_
#define DBSERVCONN_H_

#include "imconn.h"
#include "ServInfo.h"
#include "RouteServConn.h"

class CDBServConn : public CImConn
{
public:
	CDBServConn();
	virtual ~CDBServConn();

	bool IsOpen() { return m_bOpen; }

	void Connect(const char* server_ip, uint16_t server_port, uint32_t serv_idx);
	virtual void Close();

	virtual void OnConfirm();
	virtual void OnClose();
	virtual void OnTimer(uint64_t curr_tick);

	virtual void HandlePdu(CImPdu* pPdu);
private:
	void _HandleValidateResponse(CImPdu* pPdu);
    void _HandleRecentSessionResponse(CImPdu* pPdu);
    void _HandleAllUserResponse(CImPdu* pPdu);
    void _HandleGetMsgListResponse(CImPdu* pPdu);
    void _HandleGetMsgByIdResponse(CImPdu* pPdu);
    void _HandleMsgData(CImPdu* pPdu);
	void _HandleUnreadMsgCountResponse(CImPdu* pPdu);
    void _HandleGetLatestMsgIDRsp(CImPdu* pPdu);
	void _HandleDBWriteResponse(CImPdu* pPdu);
	void _HandleUsersInfoResponse(CImPdu* pPdu);
	void _HandleStopReceivePacket(CImPdu* pPdu);
	void _HandleRemoveSessionResponse(CImPdu* pPdu);
	void _HandleChangeAvatarResponse(CImPdu* pPdu);
    void _HandleChangeSignInfoResponse(CImPdu* pPdu);
    void _HandleSetDeviceTokenResponse(CImPdu* pPdu);
    void _HandleGetDeviceTokenResponse(CImPdu* pPdu);
    void _HandleDepartmentResponse(CImPdu* pPdu);
    void _HandleUpdateUserInfoResponse(CImPdu *pPdu);
    
    void _HandlePushShieldResponse(CImPdu* pPdu);
    void _HandleQueryPushShieldResponse(CImPdu* pPdu);

    void _HandleSearchUserResponse(CImPdu *pPdu);
    void _HandleAddFriendResponse(CImPdu *pPdu);
    void _HandleDelFriendResponse(CImPdu *pPdu);
    void _HandleAgreeAddFriendResponse(CImPdu *pPdu);
    void _HandleMsgBlogAck(CImPdu *pPdu);
    void _HandleFollowUserResponse(CImPdu *pPdu);
    void _HandleDelFollowUserResponse(CImPdu *pPdu);
    void _HandleGetBlogListResponse(CImPdu *pPdu);
    void _HandleAddBlogCommentResponse(CImPdu *pPdu);
    void _HandleGetBlogCommentResponse(CImPdu *pPdu);

    void _HandleAddFriendUnreadCntResponse(CImPdu *pPdu);
    void _HandleGetAddFriendDataResponse(CImPdu *pPdu);
private:
	bool 		m_bOpen;
	uint32_t	m_serv_idx;
};

void init_db_serv_conn(serv_info_t* server_list, uint32_t server_count, uint32_t concur_conn_cnt);
CDBServConn* get_db_serv_conn_for_login();
CDBServConn* get_db_serv_conn();

#endif /* DBSERVCONN_H_ */
