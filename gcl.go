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

type mpath string
type vdir string

var mpathre = regexp.MustCompile(`^\.(.*)$`)
var vdirre = regexp.MustCompile(`^[a-f0-9]{64}$`)

func newmpath(mp string) mpath {
	res := mpathre.FindAllStringSubmatch(mp, -1)
	mres := mpath("")
	if res != nil && len(res) == 1 && len(res[0]) == 2 {
		mres = mpath(res[0][1])
	}
	return mres
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
	path mpath
	dir  vdir
}

var markers = []*marker{}

type volume struct {
	dir  vdir
	mark *marker
}

var volumes = []*volume{}

func (v *volume) String() string {
	return "vol '" + string(v.dir) + "'"
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
			if mp == "" {
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
							markers = append(markers, &marker{mp, vd})
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
				volumes = append(volumes, &volume{vd, nil})
			}
		} else {
			fdir := fmt.Sprintf("/mnt/sda1/var/lib/docker/vfs/dir/%s", dir)
			fmt.Printf("Invalid file detected: '%s'\n", dir)
			mustcmd("sudo rm " + fdir)
		}
	}
	fmt.Printf("volumes: %v\nmarkers: %v\n", volumes, markers)
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
				vfs := elts[1]
				if strings.Contains(vfs, "/var/lib/docker/vfs/dir/") {
					vd := newvdir(filepath.Base(vfs))
					if vd == "" {
						fmt.Printf("Invalid volume folder detected: '%s'\n", vfs)
						break
					}
					cont.volumes = append(cont.volumes, &volume{dir: vd})
				}
			}
		}
		containers = append(containers, cont)
	}
	fmt.Printf("containers: %v\n", containers)
}

// docker run --rm -i -t -v `pwd`:`pwd` -w `pwd` --entrypoint="/bin/bash" go -c 'go build gcl.go'
func main() {
	readVolumes()
	readContainer()
	os.Exit(0)
	out := mustcmd("docker ps -qa --no-trunc")
	containers := strings.Split(out, "\n")
	containers = containers[:len(containers)-1]
	for _, id := range containers {
		fmt.Printf("container id: %s\n", id)
		out = mustcmd(fmt.Sprintf("docker inspect -f '{{ .Name }}' %s", id))
		name := strings.TrimSpace(out)[1:]
		fmt.Printf("  name: '%s'\n", name)
		out = mustcmd(fmt.Sprintf("docker inspect -f '{{ range $key, $value := .Volumes }}{{ $key }},{{ $value }}##~#{{ end }}' %s", name))
		volumes := strings.Split(out, "##~#")
		volumes = volumes[:len(volumes)-1]
		fmt.Printf("    volumes: '%v': %d\n", volumes, len(volumes))
		for i, volume := range volumes {
			vols := strings.Split(volume, ",")
			path := vols[0]
			vfs := vols[1]
			fmt.Printf("      volume %d: '%v'=>'%v'\n", i, path, vfs)
			if strings.Contains(vfs, "/var/lib/docker/vfs/dir/") {
				vfs2, _ := cmd(fmt.Sprintf("sudo readlink %s 2> /dev/null", vfs))
				vfs2 = strings.TrimSpace(vfs2)
				fmt.Printf("      vfs2 '%s' from sudo readlink %s\n", vfs2, vfs)
				link := "." + name + "###" + strings.Replace(path, "/", ",#,", -1)
				fmt.Printf("      link '%s'\n", link)
				ls, _ := cmd(fmt.Sprintf("sudo readlink /var/lib/docker/vfs/dir/%s 2> /dev/null", link))
				ls = strings.TrimSpace(ls)
				fmt.Printf("      ls link '%s'\n", ls)
				dir := filepath.Base(vfs)
				if vfs2 != "" {
					dir = filepath.Base(vfs2)
				}
				if ls == "" {
					fmt.Printf("      ln '%s' to '%s'\n", link, dir)
					mustcmd(fmt.Sprintf("sudo ln -s %s /var/lib/docker/vfs/dir/%s", dir, link))
				}
				if ls != dir && ls != "" {
					apathdir := fmt.Sprintf("/var/lib/docker/vfs/dir/%s", dir)
					mustcmd(fmt.Sprintf("sudo rm -Rf %s", apathdir))
					acmd := fmt.Sprintf("sudo ln -s %s %s", ls, apathdir)
					fmt.Printf("      must redirect '%s' to '%s'\n%s\n", dir, ls, acmd)
					mustcmd(acmd)
				}
			}
		}
	}
}
