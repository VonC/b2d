package main

import "fmt"
import "os"
import "log"
import "os/exec"
import "strings"

// docker run --rm -i -t -v `pwd`:`pwd` -w `pwd` --entrypoint="/bin/bash" go -c 'go build gcl.go'
func main() {
	args := os.Args
	id := args[1]
	fmt.Printf("container id: %s\n", id)
	out, err := exec.Command("sh", "-c", fmt.Sprintf("docker inspect -f '{{ .Name }}' %s", id)).Output()
	if err != nil {
		log.Fatal(fmt.Sprintf("out='%s', err='%s'", out, err))
	}
	name := strings.TrimSpace(string(out))[1:]
	fmt.Printf("  name: '%s'\n", name)
	out, err = exec.Command("sh", "-c", fmt.Sprintf("docker inspect -f '{{ range $key, $value := .Volumes }}{{ $key }},{{ $value }}##~#{{ end }}' %s", name)).Output()
	if err != nil {
		log.Fatal(fmt.Sprintf("out='%s', err='%s'", out, err))
	}
	volumes := strings.Split(string(out), "##~#")
	volumes = volumes[:len(volumes)-1]
	fmt.Printf("    volumes: '%v': %d\n", volumes, len(volumes))
	for i, volume := range volumes {
		vols := strings.Split(volume, ",")
		fmt.Printf("      volume %d: '%v'=>'%v'\n", i, vols[0], vols[1])
	}
}
