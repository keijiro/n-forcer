#ifndef INCLUDE_OSCCLIENT_H
#define INCLUDE_OSCCLIENT_H

class OscClient {
public:
  static void SetBasePath(const char* pPath);
  static void Open(const char* pAddress, int port);
  static void Close();
  static void SendFingerMessage(int slot, float level);
  static void SendWristMessage(float pitch, float roll);
};

#endif
