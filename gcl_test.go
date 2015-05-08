package main

import (
	"testing"
)

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
	for i, test := range tests {
		main()
		if len(containers) != test.res[0] {
			t.Errorf("Test %d: '%s' expected '%d' containers, got '%d'", i, test.title, test.res[0], len(containers))
		}
	}
}
