package main

import "fmt"
import "os"
import "log"
import "os/exec"
import "strings"

func cmd(cmd string) string {
	out, err := exec.Command("sh", "-c", cmd).Output()
	if err != nil {
		log.Fatal(fmt.Sprintf("out='%s', err='%s'", out, err))
	}
	return string(out)
}

// docker run --rm -i -t -v `pwd`:`pwd` -w `pwd` --entrypoint="/bin/bash" go -c 'go build gcl.go'
func main() {
	args := os.Args
	id := args[1]
	fmt.Printf("container id: %s\n", id)
	out := cmd(fmt.Sprintf("docker inspect -f '{{ .Name }}' %s", id))
	name := strings.TrimSpace(out)[1:]
	fmt.Printf("  name: '%s'\n", name)
	out = cmd(fmt.Sprintf("docker inspect -f '{{ range $key, $value := .Volumes }}{{ $key }},{{ $value }}##~#{{ end }}' %s", name))
	volumes := strings.Split(out, "##~#")
	volumes = volumes[:len(volumes)-1]
	fmt.Printf("    volumes: '%v': %d\n", volumes, len(volumes))
	for i, volume := range volumes {
		vols := strings.Split(volume, ",")
		path := vols[0]
		vfs := vols[1]
		fmt.Printf("      volume %d: '%v'=>'%v'\n", i, path, vfs)
		if strings.Contains(vfs, "/var/lib/docker/vfs/dir/") {
			link := name + "###" + strings.Replace(path, "/", ",#,", -1)
			fmt.Printf("      link '%s'\n", link)
		}
	}
}
