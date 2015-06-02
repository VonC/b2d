package main

import (
	"errors"
	"fmt"
	"regexp"
	"strings"
	"testing"
)

func testcmd(cmd string) (string, error) {
	fmt.Println("(T) " + cmd)
	switch {
	case cmd == "sudo ls -a1F /mnt/sda1/var/lib/docker/vfs/dir":
		return currenttest.vs.ls(), nil
	case cmd == "docker ps -aq --no-trunc":
		return currenttest.cs.ps(), nil
	case strings.HasPrefix(cmd, "docker inspect -f '{{ .Name }},{{ range $key, $value := .Volumes }}{{ $key }},{{ $value }}##~#{{ end }}' "):
		return "", nil
	case strings.HasPrefix(cmd, "sudo rm /mnt/sda1/var/lib/docker/vfs/dir/"):
		deleted := cmd[len("sudo rm /mnt/sda1/var/lib/docker/vfs/dir/"):]
		deletions = append(deletions, deleted)
		return "", nil
	case strings.HasPrefix(cmd, "sudo readlink /mnt/sda1/var/lib/docker/vfs/dir/"):
		if strings.Contains(cmd, ",nonexistent") {
			return "", errors.New("non-existent linked folder")
		}
		r := regexp.MustCompile(`.*\$([^#]+)###.*`)
		ss := r.FindStringSubmatch(cmd)
		if len(ss) == 2 {
			folder := ss[1]
			folder = folder + strings.Repeat("1", 64-len(folder))
			return folder, nil
		}
		return "", nil
	case strings.HasPrefix(cmd, "sudo ls /mnt/sda1/var/lib/docker/vfs/dir/"):
		if cmd == "sudo ls /mnt/sda1/var/lib/docker/vfs/dir/" {
			return "", errors.New("non-ls linked folder")
		}
		return "", nil
	default:
		currentT.Fatalf("test '%s': unknown command!\n", cmd)
		return fmt.Sprintf("test '%s'", cmd), errors.New("unknown command")
	}
}

type volspecs []string
type contspecs []string
type Test struct {
	title string
	vs    volspecs
	cs    contspecs
	res   []int
	strs  []string
}

func newTest(title string) *Test {
	return &Test{title: title, res: []int{0, 0, 0, 0, 0}}
}
func (t *Test) setContainersPs(cs contspecs) *Test {
	t.cs = cs
	return t
}

func (vs volspecs) ls() string {
	if len(vs) == 0 {
		return ""
	}
	res := ""
	for i, spec := range vs {
		switch {
		case strings.HasSuffix(spec, "/"):
			spec = spec[:len(spec)-1]
			res = res + spec + strings.Repeat(fmt.Sprintf("%d", i), 64-len(spec)) + "/\n"
		case strings.HasSuffix(spec, "@"):
			mp := "." + strings.Replace(spec, ";", "###", -1)
			mp = strings.Replace(mp, "/", ",#,", -1)
			res = res + mp + "\n"

		default:
			res = res + spec + "\n"
		}
	}
	return res
}

func (cs contspecs) ps() string {
	if len(cs) == 0 {
		return ""
	}
	res := ""
	for _, spec := range cs {
		switch {
		default:
			res = res + spec + "\n"
		}
	}
	return res
}

var deletions = []string{}
var tests = []*Test{
	newTest("empty vfs"),
	newTest("2 valid containers").
		setContainersPs([]string{"contA", "contB"}),
	/*
		Test{"empty vfs", []string{}, []int{0, 0, 0, 0, 0}, []string{}},
		Test{"two volumes", []string{"fa/", "fb/"}, []int{0, 0, 2, 2, 0}, []string{"vol 'fa00000'<<nil>>", "vol 'fb11111'<<nil>>"}},
		Test{"Invalid (ill-formed) markers must be deleted", []string{"cainv/path/a@"}, []int{0, 0, 0, 0, -1}, []string{}},
		Test{"Invalid (no readlink) markers must be deleted", []string{"ca;/path/nonexistenta@", "cb;/path/nonexistentb@"}, []int{0, 0, 0, 0, -2}, []string{}},
		Test{"Invalid (no ls) markers must be deleted", []string{"ca;/path/nolsa@", "cb;/path/nolsb@"}, []int{0, 0, 0, 0, -2}, []string{}},
		Test{"Invalid (no vdir) markers must be deleted", []string{"ca$novdira;/path/nolsa@", "cb$novdirb;/path/nolsb@"}, []int{0, 0, 0, 0, -2}, []string{}},
		Test{"two valid markers", []string{"ca$fa;/path/vola@", "cb$fb;/path/volb@"}, []int{0, 0, 0, 0, 2}, []string{"marker 'fa11111'<ca$fa->/path/vola>", "marker 'fb11111'<cb$fb->/path/volb>"}},
		Test{"Invalid (bad name) volume", []string{"inva/"}, []int{0, 0, -1, 0, 0}, []string{}},
		Test{"Invalid file in volume vfs dir", []string{"invf"}, []int{0, 0, -1, 0, 0}, []string{}},
	*/
}
var currenttest *Test
var currentT *testing.T

// TestContainers test different vfs scenarios
func TestContainers(t *testing.T) {
	cmd = testcmd
	currentT = t
	for i, test := range tests {
		currenttest = test
		deletions = []string{}
		fmt.Println("------ vvv " + test.title + " vvv ------")
		main()
		tc := Containers()
		toc := OrphanedContainers()
		tv := Volumes()
		tov := OrphanedVolumes()
		tm := Markers()
		if len(tc) != test.res[0] {
			t.Errorf("Test %d: '%s' expected '%d' containers, got '%d'", i+1, test.title, test.res[0], len(tc))
		}
		if len(toc) != test.res[1] {
			t.Errorf("Test %d: '%s' expected '%d' orphaned containers, got '%d'", i+1, test.title, test.res[1], len(toc))
		}
		if nbvolumes(tv) != test.res[2] {
			t.Errorf("Test %d: '%s' expected '%d' volumes, got '%d'", i+1, test.title, test.res[2], nbvolumes(tv))
		}
		if len(tov) != test.res[3] {
			t.Errorf("Test %d: '%s' expected '%d' orphaned volumes, got '%d'", i+1, test.title, test.res[3], len(tov))
		}
		if nbmarkers(tm) != test.res[4] {
			t.Errorf("Test %d: '%s' expected '%d' markers, got '%d'", i+1, test.title, test.res[4], nbmarkers(tm))
		}

		for _, v := range tv {
			vs := v.String()
			check(vs, "volume", test, t, i)
		}
		for _, m := range tm {
			ms := m.String()
			check(ms, "marker", test, t, i)
		}
		fmt.Println("------ ^^^ " + test.title + " ^^^ ------")
		fmt.Println("----------")
	}
}

func check(s string, tmsg string, test *Test, t *testing.T, i int) {
	found := false
	for _, tms := range test.strs {
		if s == tms {
			found = true
			break
		}
	}
	if !found {
		t.Errorf("Test %d: '%s' expected %s '%s', not found", i+1, test.title, tmsg, s)
	}

}

func nbmarkers(tm markers) int {
	res := len(tm)
	for _, d := range deletions {
		if strings.HasPrefix(d, ".") {
			res = res - 1
		}
	}
	return res
}

func nbvolumes(vm volumes) int {
	res := len(vm)
	for _, d := range deletions {
		if !strings.HasPrefix(d, ".") {
			res = res - 1
		}
	}
	return res
}
