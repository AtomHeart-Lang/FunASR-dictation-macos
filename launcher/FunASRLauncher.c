#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char *kLauncherMarker = "runtime_path_v2";

static void trim_trailing_newlines(char *value) {
    size_t len = strlen(value);
    while (len > 0 && (value[len - 1] == '\n' || value[len - 1] == '\r')) {
        value[len - 1] = '\0';
        len--;
    }
}

static int load_runtime_dir(char *buffer, size_t size) {
    const char *home = getenv("HOME");
    if (home == NULL || home[0] == '\0') {
        return -1;
    }

    char config_path[PATH_MAX];
    int written = snprintf(
        config_path,
        sizeof(config_path),
        "%s/Library/Application Support/SenseVoiceDictation/runtime_app_dir.txt",
        home
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
        return 2;
    }
    if (chdir(runtime_dir) != 0) {
        return 3;
    }

    execl("/bin/bash", "/bin/bash", "./launch_from_desktop.sh", (char *)NULL);
    return 4;
}
