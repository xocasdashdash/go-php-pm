package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func reader(c net.Conn, w http.ResponseWriter) {
	buf := make([]byte, 1024)
	n, err := c.Read(buf[:])
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Error reading data from socket"))
		return
	}
	println("Client got:", string(buf[0:n]))
	io.WriteString(w, "Read: "+string(buf[0:n]))
	return
}

//Command  we're sending to the socket
type Command struct {
	CMD string `json:"cmd"`
}

//Index route
func Index(w http.ResponseWriter, r *http.Request) {
	command := Command{CMD: "status"}
	b, err := json.Marshal(command)
	if err != nil {
		panic(err)
	}
	c, err := net.Dial("unix", os.Getenv("HOME")+"/projects/pixels-server-app/.ppm/run/controller.sock")
	if err != nil {
		panic(err)
	}
	_, errW := c.Write([]byte(fmt.Sprintf("%s\n", b)))
	if errW != nil {
		log.Fatal("write error:", errW)
		w.WriteHeader(http.StatusInternalServerError)
		io.WriteString(w, "Error reading from socket")
	}
	reader(c, w)
}
func main() {
	router := mux.NewRouter()
	router.HandleFunc("/", Index)
	log.Fatal(http.ListenAndServe(":8080", router))
}
