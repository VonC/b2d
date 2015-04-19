#!/bin/sh

for i in $(docker ps -qa --no-trunc --filter "status=exited"); do
  nbvol=$(docker inspect -f '{{ .Volumes | len }}' $i)
  if [[ $nbvol == 0 ]]; then
    echo "rm $i (no volume)"
    res=$(docker rm $i)
  fi
  if [[ $nbvol -gt 0 ]]; then
    if [[ "$1" != "-v" ]]; then
      if [[ "$(docker inspect -f '{{ .Config.Image }}' $i)" == "docker-compose" ]]; then
        echo "remove $i with $nbvol volumes (docker-compose)"
        res=$(docker rm -v $i)
      else
        echo "preserve $i ($nbvol volumes)"
        # docker inspect -f '{{ range $key, $value := .Volumes }}{{ $key }}{{ $value }}{{ end }}' $i
      fi
    fi
    if [[ "$1" == "-v" ]]; then
      echo "rm -v $i ($nbvol volumes cleaned)"
      res=$(docker rm -v $i)
    fi
  fi
done

for i in $(docker images --filter "dangling=true" -q --no-trunc); do
  docker rmi $i
done
