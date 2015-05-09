package main

import (
	"errors"
	"fmt"
	"strings"
	"testing"
)

func testcmd(cmd string) (string, error) {
	switch {
	case cmd == "sudo ls -a1F /mnt/sda1/var/lib/docker/vfs/dir":
		return "", nil
	case cmd == "docker ps -aq --no-trunc":
		return "", nil
	case strings.HasPrefix(cmd, "docker inspect -f '{{ .Name }},{{ range $key, $value := .Volumes }}{{ $key }},{{ $value }}##~#{{ end }}' "):
		return "", nil
	default:
		return fmt.Sprintf("test '%s'", cmd), errors.New("unknown command")
	}
}

type volspecs []string
type Test struct {
	title string
	vs    volspecs
	res   []int
}

var tests = []Test{
	Test{"empty vfs", []string{}, []int{0}},
}

// TestContainers test different vfs scenarios
func TestContainers(t *testing.T) {
	cmd = testcmd
	for i, test := range tests {
		main()
		if len(containers) != test.res[0] {
			t.Errorf("Test %d: '%s' expected '%d' containers, got '%d'", i, test.title, test.res[0], len(containers))
		}
	}
}
