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
		res := ""
		for _, _ = range currenttest.cs {
			res = res + "x\n"
		}
		return res, nil
	case strings.HasPrefix(cmd, "docker inspect -f '{{ .Name }},{{ range $key, $value := .Volumes }}{{ $key }},{{ $value }}##~#{{ end }}' "):
		return currenttest.inspectVolumes(), nil
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
	ci    int
}

func newTest(title string) *Test {
	return &Test{title: title, res: []int{0, 0, 0, 0, 0}}
}
func (t *Test) setContainersPs(cs contspecs) *Test {
	t.cs = cs
	return t
}
func (t *Test) setVolumesLs(vs volspecs) *Test {
	t.vs = vs
	return t
}

type setterRes interface {
	setResAt(index int) *Test
}

type result struct {
	res int
	t   *Test
}

type resultOne struct {
	t *Test
}

func (t *Test) expects(number int) *result {
	return &result{t: t, res: number}
}

func (t *Test) expectOne() *resultOne {
	return &resultOne{t: t}
}

func (r *result) setResAt(index int) *Test {
	r.t.res[index] = r.res
	return r.t
}
func (r *resultOne) setResAt(index int) *Test {
	r.t.res[index] = 1
	return r.t
}

func (r *result) containers() *Test {
	return r.setResAt(0)
}
func (ro resultOne) container() *Test {
	return ro.setResAt(0)
}

func (r *result) volumes() *Test {
	return r.setResAt(2)
}
func (r *result) orphanedVolumes() *Test {
	return r.setResAt(3)
}

func (r *result) markers() *Test {
	return r.setResAt(4)
}

func (t *Test) mustProduce(strs []string) *Test {
	t.strs = strs
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

func (t *Test) inspectVolumes() string {
	if len(t.cs) == 0 {
		return ""
	}
	res := t.cs[t.ci]
	t.ci = t.ci + 1
	return res
}

var deletions = []string{}
var tests = []*Test{
	newTest("empty vfs"),
	newTest("2 valid containers without any volume").
		setContainersPs([]string{"/contA,", "/contB,"}).
		expects(2).containers().
		mustProduce([]string{"cnt 'contA' (x)[false] - 0 vol", "cnt 'contB' (x)[false] - 0 vol"}),
	newTest("2 valid volumes").
		setVolumesLs([]string{"fa/", "fb/"}).
		expects(2).volumes().
		expects(2).orphanedVolumes().
		mustProduce([]string{"vol 'fa00000'<<nil>>", "vol 'fb11111'<<nil>>"}),
	newTest("Invalid (ill-formed) markers must be deleted").
		setVolumesLs([]string{"cainv/path/a@"}).
		expects(-1).markers(),
	newTest("Invalid (no readlink) markers must be deleted").
		setVolumesLs([]string{"ca;/path/nonexistenta@", "cb;/path/nonexistentb@"}).
		expects(-2).markers(),
	newTest("Invalid (no ls) markers must be deleted").
		setVolumesLs([]string{"ca;/path/nolsa@", "cb;/path/nolsb@"}).
		expects(-2).markers(),
	newTest("Invalid (no vdir) markers must be deleted").
		setVolumesLs([]string{"ca$novdira;/path/nolsa@", "cb$novdirb;/path/nolsb@"}).
		expects(-2).markers(),
	newTest("two valid markers").
		setVolumesLs([]string{"ca$fa;/path/vola@", "cb$fb;/path/volb@"}).
		expects(2).markers().
		mustProduce([]string{"marker 'fa11111'<ca$fa->/path/vola>", "marker 'fb11111'<cb$fb->/path/volb>"}),
	newTest("Invalid (bad name) volume").
		setVolumesLs([]string{"inva/"}).
		expects(-1).volumes(),
	newTest("Invalid file in volume vfs dir").
		setVolumesLs([]string{"invf"}).
		expects(-1).volumes(),
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

		for _, c := range tc {
			cs := c.String()
			check(cs, "container", test, t, i)
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
		t.Errorf("Test %d: '%s' expected %s >%s<, not found", i+1, test.title, tmsg, s)
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
