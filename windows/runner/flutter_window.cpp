#define _CRT_SECURE_NO_DEPRECATE
#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <memory>
#include <optional>
#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}
static long get_file_size(FILE* file) {
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);

    return size;
}

static std::vector<uint8_t> get_jar_contents(const char* jar_file_path) {
    size_t result;
    FILE* jar_file = fopen(jar_file_path, "rb");
    if (jar_file == nullptr) {
        return std::vector<uint8_t>();
    }

    long buffer_size = get_file_size(jar_file);

    std::vector<uint8_t> buffer(buffer_size);
    result = fread(buffer.data(), 1, buffer_size, jar_file);

    if (result != buffer_size) {
        std::cout << "Failed to load " << jar_file_path << std::endl;
    }

    fclose(jar_file);

    return buffer;
}

static bool is_whitespace_character(char b) {
    return b == 9 || b == 10 || b == 13 || b == 32;
}

static uint32_t compute_normalized_length(std::vector<uint8_t>& buffer) {
    uint32_t num1 = 0;
    const uint32_t length = static_cast<int>(buffer.size());

    for (uint32_t index = 0; index < length; ++index) {
        if (!is_whitespace_character(buffer[index])) {
            ++num1;
        }
    }

    return num1;
}



uint32_t compute_hash(std::vector<uint8_t>& buffer) {
    const uint32_t multiplex = 1540483477;
    const uint32_t length = static_cast<int>(buffer.size());
    uint32_t num1 = static_cast<int>(length);

    num1 = compute_normalized_length(buffer);

    uint32_t num2 = (uint32_t)1 ^ num1;
    uint32_t num3 = 0;
    uint32_t num4 = 0;

    for (uint32_t index = 0; index < length; ++index) {

        unsigned char b = buffer[index];

        if (!is_whitespace_character(b)) {
            num3 |= (uint32_t)b << num4;
            num4 += 8;
            if (num4 == 32) {
                uint32_t num6 = num3 * multiplex;

                uint32_t num7 = (num6 ^ num6 >> 24) * multiplex;

                num2 = num2 * multiplex ^ num7;
                num3 = 0;
                num4 = 0;
            }
        }
    }

    if (num4 > 0) {
        num2 = (num2 ^ num3) * multiplex;
    }

    uint32_t num6 = (num2 ^ num2 >> 13) * multiplex;

    return num6 ^ num6 >> 15;
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "mc-pixie.com/murmurhash",
      &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
          std::unique_ptr<flutter::MethodResult<>> result) {
              if (call.method_name() == "get_jar_contents") {


                  const flutter::EncodableMap* argsList = std::get_if<flutter::EncodableMap>(call.arguments());
                  auto path_it = (argsList->find(flutter::EncodableValue("path")))->second;
                  std::string path = static_cast<std::string>(std::get<std::string>((path_it)));

                  std::vector<uint8_t> returns = get_jar_contents(path.c_str());
                  result->Success(flutter::EncodableValue(returns));
              }
              else if (call.method_name() == "compute_hash") {
                  const flutter::EncodableMap* argsList = std::get_if<flutter::EncodableMap>(call.arguments());
                  auto buffer_it = (argsList->find(flutter::EncodableValue("buffer")))->second;
                  std::vector<uint8_t> buffer = static_cast<std::vector<uint8_t>>(std::get<std::vector<uint8_t>>((buffer_it)));

                  uint32_t resultint = compute_hash(buffer);

                  result->Success(flutter::EncodableValue(resultint));

              }
              else {
                  result->NotImplemented();
              }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
   // this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
