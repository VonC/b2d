package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

type mpath struct {
	name string
	path string
}

type vdir string

func (vd vdir) trunc() string {
	s := string(vd)
	if len(s) > 0 {
		return s[:7]
	}
	return ""
}

var mpathre = regexp.MustCompile(`^\.(.*)###(.*)$`)
var vdirre = regexp.MustCompile(`^[a-f0-9]{64}$`)

func newmpath(mp string) *mpath {
	res := mpathre.FindAllStringSubmatch(mp, -1)
	var mres *mpath
	if res != nil && len(res) == 1 && len(res[0]) == 3 {
		name := res[0][1]
		path := res[0][2]
		path = strings.Replace(path, ",#,", "/", -1)
		mres = &mpath{name, path}
	}
	return mres
}

func (mp *mpath) String() string {
	return "." + mp.name + "###" + strings.Replace(mp.path, "/", ",#,", -1)
}

func newvdir(vd string) vdir {
	res := vdirre.FindString(vd)
	vres := vdir("")
	if res != "" && res == vd {
		vres = vdir(vd)
	}
	return vres
}

type marker struct {
	mp  *mpath
	dir vdir
}

func (mk *marker) String() string {
	return fmt.Sprintf("marker '%s'<%s->%s>", mk.dir.trunc(), mk.mp.name, mk.mp.path)
}

type markers []*marker

var allmarkers = markers{}

func (marks markers) getMarker(name string, path string, dir vdir) *marker {
	var mark *marker
	for _, marker := range marks {
		if marker.mp.name == name {
			if marker.mp.path == path {
				mark = marker
				break
			} else {
				fmt.Printf("Invalid marker path detected: '%s' (vs. container volume path '%s')\n", marker.mp.path, path)
				return nil
			}
		}
	}
	if mark == nil {
		mark = &marker{mp: &mpath{name: name, path: path}, dir: dir}
	}
	if mark.dir != dir {
		// TODO: move dir and ln -s mark.dir dir
		fmt.Printf("Mark container named '%s' for path '%s' as link to '%s' (from '%s')\n", name, path, mark.dir, dir)
	}
	// TODO: check that link exists
	return mark
}

type volume struct {
	dir  vdir
	mark *marker
}

type volumes []*volume

var allvolumes = volumes{}

func (v *volume) String() string {
	return fmt.Sprintf("vol '%s'<%v>", v.dir.trunc(), v.mark)
}

func (vols volumes) getVolume(vd vdir, path string, name string) *volume {
	var vol *volume
	for _, volume := range vols {
		if string(volume.dir) == string(vd) {
			vol = volume
			if vol.mark == nil {
				vol.mark = allmarkers.getMarker(name, path, vol.dir)
			}
			if vol.mark == nil {
				return nil
			}
			break
		}
	}
	if vol == nil {
		vol = &volume{dir: vd}
		vol.mark = allmarkers.getMarker(name, path, vol.dir)
		if vol.mark == nil {
			return nil
		}
	}
	return vol
}

type container struct {
	name    string
	id      string
	stopped bool
	volumes []*volume
}

func (c *container) trunc() string {
	if len(c.id) > 0 {
		return c.id[:7]
	}
	return ""
}

func (c *container) String() string {
	return "cnt '" + c.name + "' (" + c.trunc() + ")" + fmt.Sprintf("[%v] - %d vol", c.stopped, len(c.volumes))
}

var containers = []*container{}

func mustcmd(acmd string) string {
	out, err := cmd(acmd)
	if err != nil {
		log.Fatal(fmt.Sprintf("out='%s', err='%s'", out, err))
	}
	return string(out)
}

func cmd(cmd string) (string, error) {
	fmt.Println(cmd)
	out, err := exec.Command("sh", "-c", cmd).Output()
	return strings.TrimSpace(string(out)), err
}

func readVolumes() {
	out := mustcmd("sudo ls -a1F /mnt/sda1/var/lib/docker/vfs/dir")
	vollines := strings.Split(out, "\n")
	// fmt.Println(vollines)
	for _, volline := range vollines {
		dir := volline
		if dir == "./" || dir == "../" {
			continue
		}
		if strings.HasSuffix(dir, "@") {
			dir = dir[:len(dir)-1]
			fdir := fmt.Sprintf("/mnt/sda1/var/lib/docker/vfs/dir/%s", dir)
			mp := newmpath(dir)
			if mp == nil {
				fmt.Printf("Invalid marker detected: '%s'\n", dir)
				mustcmd("sudo rm " + fdir)
			} else {
				dirlink, err := cmd("sudo readlink " + fdir)
				fmt.Printf("---\ndir: '%s'\ndlk: '%s'\nerr='%v'\n", dir, dirlink, err)
				if err != nil {
					fmt.Printf("Invalid marker (no readlink) detected: '%s'\n", dir)
					mustcmd("sudo rm " + fdir)
				} else {
					_, err := cmd("sudo ls /mnt/sda1/var/lib/docker/vfs/dir/" + dirlink)
					if err != nil {
						fmt.Printf("Invalid marker (readlink no ls) detected: '%s'\n", dir)
						mustcmd("sudo rm " + fdir)
					} else {
						vd := newvdir(dirlink)
						if vd == "" {
							fmt.Printf("Invalid marker (readlink no vdir) detected: '%s'\n", dir)
							mustcmd("sudo rm " + fdir)
						} else {
							allmarkers = append(allmarkers, &marker{mp, vd})
						}
					}
				}
			}
		} else if strings.HasSuffix(dir, "/") {

			dir = dir[:len(dir)-1]
			fdir := fmt.Sprintf("/mnt/sda1/var/lib/docker/vfs/dir/%s", dir)
			vd := newvdir(dir)
			if vd == "" {
				fmt.Printf("Invalid volume folder detected: '%s'\n", dir)
				mustcmd("sudo rm " + fdir)
			} else {
				allvolumes = append(allvolumes, &volume{dir: vd})
			}
		} else {
			fdir := fmt.Sprintf("/mnt/sda1/var/lib/docker/vfs/dir/%s", dir)
			fmt.Printf("Invalid file detected: '%s'\n", dir)
			mustcmd("sudo rm " + fdir)
		}
	}
	fmt.Printf("volumes: %v\nmarkers: %v\n", allvolumes, allmarkers)
}

func readContainer() {

	out := mustcmd("docker ps -aq --no-trunc")
	contlines := strings.Split(out, "\n")
	// fmt.Println(contlines)
	for _, contline := range contlines {
		id := contline
		res := mustcmd("docker inspect -f '{{ .Name }},{{ range $key, $value := .Volumes }}{{ $key }},{{ $value }}##~#{{ end }}' " + id)
		// fmt.Println("res1: '" + res + "'")
		name := res[1:strings.Index(res, ",")]
		cont := &container{name: name, id: id}
		res = res[strings.Index(res, ",")+1:]
		// fmt.Println("res2: '" + res + "'")
		vols := strings.Split(res, "##~#")
		// fmt.Println(vols)
		for _, vol := range vols {
			elts := strings.Split(vol, ",")
			if len(elts) == 2 {
				// fmt.Printf("elts: '%v'\n", elts)
				path := elts[0]
				vfs := elts[1]
				if strings.Contains(vfs, "/var/lib/docker/vfs/dir/") {
					vd := newvdir(filepath.Base(vfs))
					if vd == "" {
						fmt.Printf("Invalid volume folder detected: '%s'\n", vfs)
						break
					}
					newvol := allvolumes.getVolume(vd, path, name)
					cont.volumes = append(cont.volumes, newvol)
				}
			}
		}
		containers = append(containers, cont)
	}
	fmt.Printf("containers: %v\n", containers)
}

func (c *container) accept(v *volume) bool {
	for _, vol := range c.volumes {
		if vol == v {
			return true
		}
	}
	return false
}

func checkVolumes() {
	for _, volume := range allvolumes {
		orphan := true
		for _, container := range containers {
			if container.accept(volume) {
				orphan = false
				break
			}
		}
		if orphan {
			fmt.Printf("Orphan detected, volume '%v'\n", volume)
			// TODO rm if necessary or at least mv _xxx
		}
	}
}

// docker run --rm -i -t -v `pwd`:`pwd` -w `pwd` --entrypoint="/bin/bash" go -c 'go build gcl.go'
func main() {
	fmt.Println("### 1/3 readVolumes     ###")
	readVolumes()
	fmt.Println("### 2/3 readContainer   ###")
	readContainer()
	fmt.Println("### 3/3 checkVolumes    ###")
	checkVolumes()
	fmt.Println("---      All done       ---")
	os.Exit(0)
}
