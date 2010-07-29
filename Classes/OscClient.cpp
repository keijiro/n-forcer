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
  // アドレス
  char path[64];
  std::snprintf(path, sizeof path, "%s/finger/%d", s_basePath.c_str(), slot);
  *s_pStream << osc::BeginMessage(path);
  // f(-1.0 / 0.0 - 1.0)
  *s_pStream << level << osc::EndMessage;
  // 送信とバッファのクリア
  s_pTransmitSocket->Send(s_pStream->Data(), s_pStream->Size());
  s_pStream->Clear();
}

void OscClient::SendWristMessage(float pitch, float roll, float pull) {
  if (!s_pStream) return;
  // アドレス
  *s_pStream << osc::BeginMessage((s_basePath + "/wrist").c_str());
  // f(0.0 - 1.0), f(0.0 - 1.0), f(0.0 - 1.0)
  *s_pStream << pitch << roll << pull << osc::EndMessage;
  // 送信とバッファのクリア
  s_pTransmitSocket->Send(s_pStream->Data(), s_pStream->Size());
  s_pStream->Clear();
}
