package main

import (
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"

    "./utils"

    "github.com/gorilla/mux"
    _ "github.com/jinzhu/gorm/dialects/mysql"
)

// Todo representation
type Todo struct {
    ID      int   `json:"id"`
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

    // DB接続する
    db := utils.GetConnection()
    defer db.Close()

    // 空のスライス
    var todoList []Todo
    // SELECT文が発行されて結果がtodoListに入る
    db.Find(&todoList)

    utils.RespondWithJSON(w, http.StatusOK, todoList)
}

// Controller for the /items/{id} route
func returnSingleTodo(w http.ResponseWriter, r *http.Request) {
    key, err := utils.GetID(r)
    // If {todoid} parameter is not valid int
    if err != nil {
        utils.RespondWithError(w, http.StatusBadRequest, "Invalid request payload")
        return
    }

    // DB接続
    db := utils.GetConnection()
    defer db.Close()


    var todo Todo
    // IDで検索しに行く
    db.Where("id = ?", key).Find(&todo)

    utils.RespondWithJSON(w, http.StatusOK, todo)
}

func createTodo(w http.ResponseWriter, r *http.Request) {
    //リクエストボディ取得
    body, err := ioutil.ReadAll(r.Body)
    defer r.Body.Close()
    if err != nil {
      utils.RespondWithError(w, http.StatusBadRequest, "Invalid request")
      return
    }

    var todo Todo
    //読み込んだJSONを構造体に変換
    if err := json.Unmarshal(body, &todo); err != nil {
      utils.RespondWithError(w, http.StatusBadRequest, "JSON Unmarshaling failed .")
      return
    }

    //DB接続
    db := utils.GetConnection()
    defer db.Close()

    //DBにINSERTする
    db.Create(&todo)

    utils.RespondWithJSON(w, http.StatusOK, todo)
}

func updateTodo(w http.ResponseWriter, r *http.Request) {
    key, err := utils.GetID(r)
    // If {todoid} parameter is not valid int
    if err != nil {
        utils.RespondWithError(w, http.StatusBadRequest, "Invalid request payload")
        return
    }

    var todo Todo

    // DB接続
    db := utils.GetConnection()
    defer db.Close()

    // IDで検索しに行く
    db.Where("id = ?", key).Find(&todo)
    // Update実行
    db.Model(&todo).Update("checked", !todo.Checked)

    utils.RespondWithJSON(w, http.StatusOK, todo)
}

func deleteTodo(w http.ResponseWriter, r *http.Request) {
  key, err := utils.GetID(r)
  // If {todoid} parameter is not valid int
  if err != nil {
      utils.RespondWithError(w, http.StatusBadRequest, "Invalid request payload")
      return
  }

  // DB接続
  db := utils.GetConnection()
  defer db.Close()


  var todo Todo
  // IDで検索しに行く
  db.Where("id = ?", key).Find(&todo)
  // Delete実行
  db.Delete(&todo)

  // レコード数が0の場合オートインクリメントを初期化 ALTER TABLE テーブル名 AUTO_INCREMENT = 1;
  var count int
  //db.Raw("SELECT case when count(*) = 0 then '0' else '1' end count FROM 'todos'").Scan(&isEnpty)

  db.Table("todos").Count(&count)
  utils.RespondWithJSON(w, http.StatusOK, todo)
}

func handleRequests() {
    myRouter := mux.NewRouter().StrictSlash(true)
    myRouter.HandleFunc("/", homePage)
    myRouter.HandleFunc("/api/v1/todos", returnAllTodos).Methods("GET")
    myRouter.HandleFunc("/api/v1/todos/{id}", returnSingleTodo).Methods("GET")
    myRouter.HandleFunc("/api/v1/todos", createTodo).Methods("POST")
    myRouter.HandleFunc("/api/v1/todos/{id}", updateTodo).Methods("PUT")
    myRouter.HandleFunc("/api/v1/todos/{id}", deleteTodo).Methods("DELETE")
    log.Fatal(http.ListenAndServe(":8080", myRouter))
}

func main() {
    handleRequests()
}
