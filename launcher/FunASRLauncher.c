#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

static const char *kLauncherMarker = "runtime_path_v2";
static const char *kRuntimePathRel = "Library/Application Support/FunASRDictation/runtime_app_dir.txt";
static const char *kLegacyRuntimePathRel = "Library/Application Support/SenseVoiceDictation/runtime_app_dir.txt";

static void trim_trailing_newlines(char *value) {
    size_t len = strlen(value);
    while (len > 0 && (value[len - 1] == '\n' || value[len - 1] == '\r')) {
        value[len - 1] = '\0';
        len--;
    }
}

static int load_runtime_dir_from(const char *home, const char *relative_path, char *buffer, size_t size) {
    char config_path[PATH_MAX];
    int written = snprintf(
        config_path,
        sizeof(config_path),
        "%s/%s",
        home,
        relative_path
    );
    if (written <= 0 || (size_t)written >= sizeof(config_path)) {
        return -1;
    }

    FILE *fp = fopen(config_path, "r");
    if (fp == NULL) {
        return -1;
    }

    if (fgets(buffer, (int)size, fp) == NULL) {
        fclose(fp);
        return -1;
    }
    fclose(fp);

    trim_trailing_newlines(buffer);
    return buffer[0] == '\0' ? -1 : 0;
}

static int load_runtime_dir(char *buffer, size_t size) {
    const char *home = getenv("HOME");
    if (home == NULL || home[0] == '\0') {
        return -1;
    }
    if (load_runtime_dir_from(home, kRuntimePathRel, buffer, size) == 0) {
        return 0;
    }
    return load_runtime_dir_from(home, kLegacyRuntimePathRel, buffer, size);
}

static int is_chinese_locale(void) {
    CFLocaleRef locale = CFLocaleCopyCurrent();
    if (locale == NULL) {
        return 0;
    }
    CFStringRef ident = CFLocaleGetIdentifier(locale);
    int is_zh = 0;
    if (ident != NULL) {
        char buf[64];
        if (CFStringGetCString(ident, buf, sizeof(buf), kCFStringEncodingUTF8)) {
            is_zh = (strncmp(buf, "zh", 2) == 0);
        }
    }
    CFRelease(locale);
    return is_zh;
}

static void show_alert(const char *title_zh, const char *title_en, const char *msg_zh, const char *msg_en) {
    int is_zh = is_chinese_locale();
    CFStringRef title = CFStringCreateWithCString(NULL, is_zh ? title_zh : title_en, kCFStringEncodingUTF8);
    CFStringRef message = CFStringCreateWithCString(NULL, is_zh ? msg_zh : msg_en, kCFStringEncodingUTF8);
    CFStringRef button = CFSTR("OK");
    if (title != NULL && message != NULL) {
        CFUserNotificationDisplayAlert(
            0,
            kCFUserNotificationStopAlertLevel,
            NULL,
            NULL,
            NULL,
            title,
            message,
            button,
            NULL,
            NULL,
            NULL
        );
    }
    if (title != NULL) {
        CFRelease(title);
    }
    if (message != NULL) {
        CFRelease(message);
    }
}

static void request_tcc_permissions(void) {
    if (!CGPreflightListenEventAccess()) {
        CGRequestListenEventAccess();
    }

    if (!AXIsProcessTrusted()) {
        const void *keys[] = { kAXTrustedCheckOptionPrompt };
        const void *vals[] = { kCFBooleanTrue };
        CFDictionaryRef options = CFDictionaryCreate(
            kCFAllocatorDefault,
            keys,
            vals,
            1,
            &kCFCopyStringDictionaryKeyCallBacks,
            &kCFTypeDictionaryValueCallBacks
        );
        if (options != NULL) {
            AXIsProcessTrustedWithOptions(options);
            CFRelease(options);
        }
    }
}

int main(void) {
    (void)kLauncherMarker;
    request_tcc_permissions();

    char runtime_dir[PATH_MAX];
    if (load_runtime_dir(runtime_dir, sizeof(runtime_dir)) != 0) {
        show_alert(
            "FunASR Dictation 无法启动",
            "FunASR Dictation Can't Open",
            "找不到运行时配置。请重新安装，或重新运行安装器后再试。",
            "Runtime configuration was not found. Please reinstall or run the installer again."
        );
        return 2;
    }
    if (chdir(runtime_dir) != 0) {
        show_alert(
            "FunASR Dictation 无法启动",
            "FunASR Dictation Can't Open",
            "运行目录不存在或无法访问。请重新安装后再试。",
            "The runtime directory is missing or unavailable. Please reinstall and try again."
        );
        return 3;
    }

    pid_t child = fork();
    if (child < 0) {
        return 4;
    }
    if (child == 0) {
        execl("/bin/bash", "/bin/bash", "./launch_from_desktop.sh", (char *)NULL);
        _exit(5);
    }

    int status = 0;
    while (waitpid(child, &status, 0) < 0) {
        if (errno == EINTR) {
            continue;
        }
        return 6;
    }

    if (WIFEXITED(status)) {
        return WEXITSTATUS(status);
    }
    return 7;
}
