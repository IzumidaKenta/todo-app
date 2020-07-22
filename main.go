package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "strconv"

    "github.com/gorilla/mux"
    "github.com/jinzhu/gorm"
    _ "github.com/jinzhu/gorm/dialects/mysql"
)

// Item representation
type Todo struct {
    Title   string `json:"title"`
    Checked bool `json:"checked"`
}

// Controller for the / route (home)
func homePage(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "This is the home page. Welcome!")
}

// Controller for the /items route
func returnAllTodos(w http.ResponseWriter, r *http.Request) {
    // Code for returning all items here

    // DB接続する(user、passwordは適宜修正)
    db, _ := gorm.Open("mysql", "root:Cbeg1nner@/todos?charset=utf8&parseTime=True&loc=Local")
    defer db.Close()
    // ロガーを有効にすると、詳細なログを表示します
    db.LogMode(true)

    // 空のスライス
    var todoList []Todo
    // SELECT文が発行されて結果がtodoListに入る
    db.Find(&todoList)

    respondWithJson(w, http.StatusOK, todoList)
}

// Controller for the /items/{id} route
func returnSingleTodo(w http.ResponseWriter, r *http.Request) {
    // Code for returning a single item here
    // Get query parameters using Mux
    vars := mux.Vars(r)

    // Convert {todoid} parameter from string to int
    key, err := strconv.Atoi(vars["id"])

    // If {todoid} parameter is not valid int
    if err != nil {
        respondWithError(w, http.StatusBadRequest, "Invalid request payload")
        return
    }

    // DB接続
    db, _ := gorm.Open("mysql", "root:Cbeg1nner@/todos?charset=utf8&parseTime=True&loc=Local")
    defer db.Close()
    db.LogMode(true)

    var todo Todo
    // IDで検索しに行く
    db.Where("id = ?", key).Find(&todo)

    respondWithJson(w, http.StatusOK, todo)
}
func handleRequests() {
    myRouter := mux.NewRouter().StrictSlash(true)
    myRouter.HandleFunc("/", homePage)
    myRouter.HandleFunc("/api/v1/todos", returnAllTodos)
    myRouter.HandleFunc("/api/v1/todos/{id}", returnSingleTodo)
    log.Fatal(http.ListenAndServe(":8000", myRouter))
}

func main() {
    handleRequests()
}

func respondWithError(w http.ResponseWriter, code int, msg string) {
    respondWithJson(w, code, map[string]string{"error": msg})
}

func respondWithJson(w http.ResponseWriter, code int, payload interface{}) {
    response, _ := json.Marshal(payload)
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(code)
    w.Write(response)
}
