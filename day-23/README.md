This time I use docker.


Run as:
```
docker run --rm -w /prg -v `readlink -f .`:/prg -it swift swift prg.swift input
```
