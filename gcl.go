package main

import "fmt"

import "path/filepath"
import "log"

import "os/exec"
import "strings"

func mustcmd(acmd string) string {
	fmt.Println(acmd)
	out, err := cmd(acmd)
	if err != nil {
		log.Fatal(fmt.Sprintf("out='%s', err='%s'", out, err))
	}
	return string(out)
}

func cmd(cmd string) (string, error) {
	out, err := exec.Command("sh", "-c", cmd).Output()
	return string(out), err
}

// docker run --rm -i -t -v `pwd`:`pwd` -w `pwd` --entrypoint="/bin/bash" go -c 'go build gcl.go'
func main() {
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
				link := "." + name + "###" + strings.Replace(path, "/", ",#,", -1)
				fmt.Printf("      link '%s'\n", link)
				ls, _ := cmd(fmt.Sprintf("sudo ls /var/lib/docker/vfs/dir/%s 2> /dev/null", link))
				ls = strings.TrimSpace(ls)
				fmt.Printf("      ls link '%s'\n", ls)
				dir := filepath.Base(vfs)
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
