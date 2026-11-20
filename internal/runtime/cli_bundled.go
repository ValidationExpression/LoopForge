package runtime

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// CursorBundledInstallRoot is where the published platform image installs
// cursor-agent so EnsureToolchainCLI can copy it into sandbox toolchains.
const CursorBundledInstallRoot = "/opt/loopforge/cursor-cli"

// CursorBundledInstallScript is the official installer the Dockerfile runs
// with HOME=CursorBundledInstallRoot.
const CursorBundledInstallScript = "curl -fsSL --proto '=https' --tlsv1.2 https://cursor.com/install | bash"

func cursorBundledRootPath() string {
	if override := strings.TrimSpace(os.Getenv("AGENTFLOW_CURSOR_BUNDLED_ROOT")); override != "" {
		return override
	}
	return CursorBundledInstallRoot
}

func bundledCLIInstallRoot(binary string) string {
	switch binary {
	case "cursor-agent":
		root := cursorBundledRootPath()
		if info, err := os.Stat(root); err == nil && info.IsDir() {
			return root
		}
	}
	return ""
}

// bundledCLIExecutable locates a CLI the platform image ships globally without
// going through the on-demand npm staging directory.
func bundledCLIExecutable(binary string) string {
	if path, err := exec.LookPath(binary); err == nil && fileIsExecutable(path) {
		return path
	}
	candidates := []string{
		filepath.Join(toolchainNodePrefix, "bin", binary),
	}
	switch binary {
	case "cursor-agent":
		candidates = append(candidates,
			filepath.Join(cursorBundledRootPath(), ".local", "bin", binary),
		)
	}
	for _, path := range candidates {
		if fileIsExecutable(path) {
			return path
		}
	}
	return ""
}