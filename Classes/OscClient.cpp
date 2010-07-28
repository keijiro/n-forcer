#include "OscClient.h"
#include "osc/OscOutboundPacketStream.h"
#include "ip/UdpSocket.h"
#include <cstdio>
#include <string>

namespace {
  std::string s_basePath;
  char s_streamBuffer[1024];
  UdpTransmitSocket* s_pTransmitSocket;
  osc::OutboundPacketStream* s_pStream;
}

void OscClient::SetBasePath(const char* pPath) {
  s_basePath = pPath ? pPath : "";
}

void OscClient::Open(const char* pAddress, int port) {
  if (s_pStream) return;
  s_pTransmitSocket = new UdpTransmitSocket(IpEndpointName(pAddress, port));
  s_pStream = new osc::OutboundPacketStream(s_streamBuffer, sizeof s_streamBuffer);
}

void OscClient::Close() {
  if (!s_pStream) return;
  delete s_pStream;
  delete s_pTransmitSocket;
  s_pStream = NULL;
  s_pTransmitSocket = NULL;
}

void OscClient::SendFingerMessage(int slot, float level) {
  if (!s_pStream) return;
  // スロットに対応するパスの生成
  std::string path;
  {
    char temp[64];
    std::snprintf(temp, sizeof temp, "%s/finger/%d/", s_basePath.c_str(), slot);
    path = temp;
  }
  // ここからバンドル
  *s_pStream << osc::BeginBundleImmediate;
  // level (0.0 - 1.0) メッセージ
  if (level > 0.0f) {
    *s_pStream << osc::BeginMessage((path + "level").c_str());
    *s_pStream << level << osc::EndMessage;
  }
  // touch (0.0 / 1.0) メッセージ
  *s_pStream << osc::BeginMessage((path + "touch").c_str());
  *s_pStream << (level > 0.0f ? 1.0f : 0.0f) << osc::EndMessage;
  // ここまでバンドル
  *s_pStream << osc::EndBundle;
  // 送信とバッファのクリア
  s_pTransmitSocket->Send(s_pStream->Data(), s_pStream->Size());
  s_pStream->Clear();
}

void OscClient::SendWristMessage(float pitch, float roll, float pull) {
  if (!s_pStream) return;
  // ここからバンドル
  *s_pStream << osc::BeginBundleImmediate;
  // pitch (0.0 - 1.0) メッセージ
  *s_pStream << osc::BeginMessage((s_basePath + "/wrist/pitch").c_str());
  *s_pStream << pitch << osc::EndMessage;
  // roll (0.0 - 1.0) メッセージ
  *s_pStream << osc::BeginMessage((s_basePath + "/wrist/roll").c_str());
  *s_pStream << roll << osc::EndMessage;
  // pull (0.0 - 1.0) メッセージ
  *s_pStream << osc::BeginMessage((s_basePath + "/wrist/pull").c_str());
  *s_pStream << pull << osc::EndMessage;
  // ここまでバンドル
  *s_pStream << osc::EndBundle;
  // 送信とバッファのクリア
  s_pTransmitSocket->Send(s_pStream->Data(), s_pStream->Size());
  s_pStream->Clear();
}

void OscClient::SendSpecialMessage(bool flag) {
  if (!s_pStream) return;
  // special (0.0 / 1.0) メッセージ
  *s_pStream << osc::BeginMessage((s_basePath + "/special").c_str());
  *s_pStream << (flag ? 1.0f : 0.0f) << osc::EndMessage;
  // 送信とバッファのクリア
  s_pTransmitSocket->Send(s_pStream->Data(), s_pStream->Size());
  s_pStream->Clear();
}
